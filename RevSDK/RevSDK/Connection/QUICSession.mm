//
//  QUICSession.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RSNativeUDPSocketWrapper.h"

#include "QUICSession.h"
#include <iostream>

class rs::QUICSession::ObjCImpl
{
public:
    ObjCImpl(): mNativeUDPSocket (nil) {}
    NativeUDPSocketWrapper* mNativeUDPSocket;
};

using namespace rs;
using namespace net;
using namespace net::tools;

QUICSession* QUICSession::mInstance = nullptr;

QUICSession* QUICSession::instance()
{
    if (mInstance == nullptr)
    {
        mInstance = new QUICSession();
        int port = 443;
        std::string address("www.revapm.com");
        QuicServerId serverId(address, port, true, PRIVACY_MODE_DISABLED);
        mInstance->connect(serverId);
    }
    return mInstance;
}

QUICSession::QUICSession():
    mSessionDelegate (nullptr),
    mObjC(new ObjCImpl()),
    mClientAddress({0, 0, 0, 0}, 443)
{
    
}

QUICSession::~QUICSession()
{
    
}

void QUICSession::setSessionDelegate(QUICSessionDelegate* aSessionDelegate)
{
    mSessionDelegate = aSessionDelegate;
}

void QUICSession::connect(QuicServerId aTargetServerId)
{
    if (mSession.get())
        disconnect();
    
    mServerAddress = IPEndPoint({0, 0, 0, 0}, aTargetServerId.port());
    mServerId = aTargetServerId;
    
    const UInt16 port = mServerId.host_port_pair().port();
    NSString *address = [NSString stringWithCString:mServerId.host_port_pair().host().c_str()
                                           encoding:[NSString defaultCStringEncoding]];
    
    mObjC->mNativeUDPSocket = [[NativeUDPSocketWrapper alloc] initWithHost:address
                                                                       onPort:port
                                                                    delegate:this];
    
    if (mObjC->mNativeUDPSocket == nil)
    {
        return;
    }
    
    mConnectionHelper.reset(new QuicConnectionHelper());
    mCryptoConfig.SetProofVerifier(new RevProofVerifier());
    
    mWriter.reset(createQuicPacketWriter());
    
    if (!mSession)
    {
        // Will be owned by the session.
        QuicConnection *connection = new QuicConnection(generateConnectionId(),
                                                        mServerAddress,
                                                        mConnectionHelper.get(),
                                                        CocoaWriterFactory(mWriter.get()),
                                                        /* owns_writer= */ false,
                                                        Perspective::IS_CLIENT,
                                                        mServerId.is_https(),
                                                        QuicSupportedVersions());
        
        mSession.reset(createQuicClientSession(mConfig,
                                               connection,
                                               mServerId,
                                               &mCryptoConfig));
    }
    
    mSession->Initialize();
    mSession->CryptoConnect();
}

void QUICSession::disconnect()
{
    if (connected())
    {
        mSession->connection()->SendConnectionClose(QUIC_PEER_GOING_AWAY);
    }
    
    mWriter.reset();
    mSession.reset();
}

bool QUICSession::connected() const
{
    if (mSession.get())
    {
        if (mSession->connection())
        {
            return
            mSession->connection()->connected() &&
            mSession->EncryptionEstablished();
        }
    }
    
    return false;
}

bool QUICSession::sendRequest(const net::SpdyHeaderBlock &headers,
                              base::StringPiece body,
                              QUICStreamDelegate* aStreamDelegate)
{
    if (!connected())
    {
        return false;
    }
    
    QuicSpdyClientStream* stream = createReliableClientStream();
    
    if (stream == nullptr)
    {
        std::cout << "Stream creation failed!" << std::endl;
        return false;
    }
    
    stream->set_visitor(this);
    mStreamDelegateMap[stream] = aStreamDelegate;
    const size_t numBytesWritten = stream->SendRequest(headers, body, true);
    std::cout << "Written: " << numBytesWritten << std::endl;
    return true;
}

void QUICSession::OnClose(QuicDataStream* aStream)
{
    StreamDelegateMap::iterator w = mStreamDelegateMap.find(aStream);
    if (w == mStreamDelegateMap.end())
        return;
    
    QUICStreamDelegate* sd = w->second;
    if (sd != nullptr)
    {
        QuicSpdyClientStream* clientStream = static_cast<QuicSpdyClientStream*>(aStream);
        SpdyHeaderBlock headers = clientStream->headers();
        std::string body = clientStream->data();
        int code = clientStream->response_code();
        sd->quicSessionDidCloseStream(this, aStream, headers, body, code);
    }
    
    mStreamDelegateMap.erase(w);
}

QuicConnectionId QUICSession::generateConnectionId()
{
    return mConnectionHelper->GetRandomGenerator()->RandUint64();
}

QuicConnectionHelper *QUICSession::createQuicConnectionHelper()
{
    return new QuicConnectionHelper();
}

QuicPacketWriter *QUICSession::createQuicPacketWriter()
{
    return new CocoaQuicPacketWriter(mObjC->mNativeUDPSocket);
}

QuicClientSession *QUICSession::createQuicClientSession(const QuicConfig &config,
                                                        QuicConnection *connection,
                                                        const QuicServerId &serverId,
                                                        QuicCryptoClientConfig *cryptoConfig)
{
    return new QuicClientSession(config, connection, serverId, cryptoConfig);
}

QuicSpdyClientStream *QUICSession::createReliableClientStream()
{
    if (!connected())
        return nullptr;
    
    return mSession->CreateOutgoingDynamicStream();
}

bool QUICSession::onQUICPacket(const net::QuicEncryptedPacket& aPacket)
{
    if (!mSession.get())
    {
        return false;
    }
    
    NSLog(@"<< incoming %zu", aPacket.length());
    mSession->connection()->ProcessUdpPacket(mClientAddress, mServerAddress, aPacket);
    
    if (!mSession->connection()->connected())
    {
        return false;
    }
    
    return true;
}

void QUICSession::onQUICError()
{
    disconnect();
}
