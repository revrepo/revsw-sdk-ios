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
//QUICThread QUICSession::mInstanceThread;
//std::mutex QUICSession::mInstanceLock;

void QUICSession::executeOnSessionThread(std::function<void(void)> aFunction)
{
    mInstanceThread.perform(aFunction);
}

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
    std::function<void(size_t)> updFunc = std::bind(&QUICSession::update, this, std::placeholders::_1);
    mInstanceThread.setUpdateCallback(updFunc);
}

QUICSession::~QUICSession()
{
    
}

void QUICSession::setSessionDelegate(QUICSessionDelegate* aSessionDelegate)
{
    mSessionDelegate = aSessionDelegate;
}

void QUICSession::connect(net::QuicServerId aTargetServerId)
{
    executeOnSessionThread([this, aTargetServerId]()
    {
        p_connect(aTargetServerId);
    });
}

void QUICSession::disconnect()
{
    executeOnSessionThread([this]()
    {
        p_disconnect();
    });
}

void QUICSession::sendRequest(const net::SpdyHeaderBlock &headers,
                 base::StringPiece body,
                 QUICStreamDelegate* aStreamDelegate)
{
    executeOnSessionThread([this, headers, body, aStreamDelegate]()
    {
        p_sendRequest(headers, body, aStreamDelegate);
    });
}

void QUICSession::p_connect(QuicServerId aTargetServerId)
{
    if (mSession.get())
        p_disconnect();
    
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
        
        mSession.reset(new QUICClientSession(mConfig,
                                             connection,
                                             mServerId,
                                             &mCryptoConfig));
    }
    
    mSession->Initialize();
    mSession->CryptoConnect();
}

void QUICSession::p_disconnect()
{
    if (p_connected())
    {
        mSession->connection()->SendConnectionClose(QUIC_PEER_GOING_AWAY);
    }
    
    mWriter.reset();
    mSession.reset();
}

bool QUICSession::p_connected() const
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

bool QUICSession::p_sendRequest(const net::SpdyHeaderBlock &headers,
                              base::StringPiece body,
                              QUICStreamDelegate* aStreamDelegate)
{
    if (!p_connected())
    {
        return false;
    }
    
    QUICDataStream* stream = createReliableClientStream();
    
    if (stream == nullptr)
    {
        std::cout << "Stream creation failed!" << std::endl;
        return false;
    }
    
    stream->setDelegate(this);
    mStreamDelegateMap[stream] = aStreamDelegate;
    /*const size_t numBytesWritten = */stream->SendRequest(headers, body, true);
    //std::cout << "Written: " << numBytesWritten << std::endl;
    return true;
}

void QUICSession::OnClose(QuicDataStream* aStream)
{
    assert(false);
}

void QUICSession::onQUICStreamReceivedData(QUICDataStream* aStream, const char* aData, size_t aDataLen)
{
    StreamDelegateMap::iterator w = mStreamDelegateMap.find(aStream);
    if (w == mStreamDelegateMap.end())
        return;
    
    QUICStreamDelegate* sd = w->second;
    if (sd != nullptr)
    {
        sd->quicSessionDidReceiveData(this, aStream, aData, aDataLen);
    }
}

void QUICSession::onQUICStreamReceivedResponse(QUICDataStream* aStream, int aCode, const net::SpdyHeaderBlock& aHeaders)
{
    StreamDelegateMap::iterator w = mStreamDelegateMap.find(aStream);
    if (w == mStreamDelegateMap.end())
        return;
    
    QUICStreamDelegate* sd = w->second;
    if (sd != nullptr)
    {
        sd->quicSessionDidReceiveResponse(this, aStream, aHeaders, aCode);
    }
}

void QUICSession::onQUICStreamFailed(QUICDataStream* aStream)
{
    StreamDelegateMap::iterator w = mStreamDelegateMap.find(aStream);
    if (w == mStreamDelegateMap.end())
        return;
    
    QUICStreamDelegate* sd = w->second;
    if (sd != nullptr)
    {
        sd->quicSessionDidFail(this, aStream);
    }
    mStreamDelegateMap.erase(w);
}

void QUICSession::onQUICStreamCompleted(QUICDataStream* aStream)
{
    StreamDelegateMap::iterator w = mStreamDelegateMap.find(aStream);
    if (w == mStreamDelegateMap.end())
        return;
    
    QUICStreamDelegate* sd = w->second;
    if (sd != nullptr)
    {
        sd->quicSessionDidFinish(this, aStream);
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

QUICDataStream *QUICSession::createReliableClientStream()
{
    if (!p_connected())
        return nullptr;
    
    return mSession->rsCreateOutgoingDynamicStream();
}

bool QUICSession::onQUICPacket(const net::QuicEncryptedPacket& aPacket)
{
    if (!mSession.get())
    {
        return false;
    }
    
    //NSLog(@"<< incoming %zu", aPacket.length());
    mSession->connection()->ProcessUdpPacket(mClientAddress, mServerAddress, aPacket);
    
    if (!mSession->connection()->connected())
    {
        return false;
    }
    
    return true;
}

void QUICSession::onQUICError()
{
    p_disconnect();
    std::vector<QUICDataStream*> streams;
    for (auto& i : mStreamDelegateMap)
        streams.push_back(i.first);
    
    for (auto& s : streams)
        s->onSocketError();
}

void QUICSession::update(size_t aNowMS)
{
    std::vector<QUICDataStream*> streams;
    for (auto& i : mStreamDelegateMap)
        streams.push_back(i.first);
    
    for (auto& s : streams)
        s->update(aNowMS);
}
