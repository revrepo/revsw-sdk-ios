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
#include "RSUDPService.h"
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

void QUICSession::executeOnSessionThread(std::function<void(void)> aFunction, bool aForceAsync)
{
    //mInstanceThread.perform(aFunction);
    if (mService == nullptr)
        return;
    
    mService->perform(aFunction, aForceAsync);
}

QUICSession* QUICSession::instance()
{
    if (mInstance == nullptr)
    {
        mInstance = new QUICSession();
        
        std::string address("www.revapm.com");
        int port = 443;
        mInstance->mConnecting = true;
        UDPService::dispatch(address, port, [address, port](UDPService* s)
        {
            mInstance->mService = s;
            QuicServerId serverId(address, port, true, PRIVACY_MODE_DISABLED);
            
            s->setOnRecv([](UDPService* serv, const void* d, size_t l)
            {
                net::QuicEncryptedPacket packet((const char*)d, l);
                mInstance->onQUICPacket(packet);
            });
            
            s->setOnError([](UDPService* serv, int c, std::string d)
            {
                Error error;
                error.code = c;
                error.domain = "revsdk.quic";
                error.setDescription(d);
                mInstance->onQUICError(error);
            });
            
            std::function<void(size_t)> updFunc = std::bind(&QUICSession::update, mInstance, std::placeholders::_1);
            s->setOnIdle(updFunc);

            mInstance->connect(serverId);
            mInstance->mConnecting = false;
        });

//        UDPSocket* s = new UDPSocket("www.revapm.com", 443);
//        s->connect();
//        char sd[] = "Hello world!";
//        s->send((const void*)sd, ::strlen(sd));
//        char rd[16];
//        s->recv((void*)rd, 16, 1000);
//        s->recv((void*)rd, 16, 1000);
//        s->recv((void*)rd, 16, 1000);
//        s->recv((void*)rd, 16, 1000);
    }
    return mInstance;
}

void QUICSession::reconnect()
{
    if (mInstance->mConnecting)
        return;
    
    mInstance->mConnecting = true;

    mInstance->mService->setOnRecv(nullptr);
    mInstance->mService->setOnError(nullptr);
    mInstance->mService->setOnIdle(nullptr);
    mInstance->mService->shutdown();
    mInstance->mService = nullptr;
    mInstance->mSession = nullptr; // LEAK!
    
    std::string address("www.revapm.com");
    int port = 443;
    UDPService::dispatch(address, port, [address, port](UDPService* s)
    {
        mInstance->mService = s;
        QuicServerId serverId(address, port, true, PRIVACY_MODE_DISABLED);
        
        s->setOnRecv([](UDPService* serv, const void* d, size_t l)
                     {
                         net::QuicEncryptedPacket packet((const char*)d, l);
                         mInstance->onQUICPacket(packet);
                     });
        
        s->setOnError([](UDPService* serv, int c, std::string d)
                      {
                          Error error;
                          error.code = c;
                          error.domain = "revsdk.quic";
                          error.setDescription(d);
                          mInstance->onQUICError(error);
                      });
        
        std::function<void(size_t)> updFunc = std::bind(&QUICSession::update, mInstance, std::placeholders::_1);
        s->setOnIdle(updFunc);
        
        mInstance->connect(serverId);
        mInstance->mConnecting = false;
    });
}

QUICSession::QUICSession():
    mSessionDelegate (nullptr),
    //mObjC(new ObjCImpl()),
    mClientAddress({0, 0, 0, 0}, 443),
    mConnecting (false)
{
    //mInstanceThread.setUpdateCallback(updFunc);
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
    }, true);
}

void QUICSession::sendRequest(const net::SpdyHeaderBlock &headers,
                 base::StringPiece body,
                 QUICStreamDelegate* aStreamDelegate,
                 int aTag,
                 std::function<void(int, QUICDataStream*)> aCallback)
{
    executeOnSessionThread([this, headers, body, aStreamDelegate, aTag, aCallback]()
    {
        QUICDataStream* stream = p_sendRequest(headers, body, aStreamDelegate);
        if (aCallback)
            aCallback(aTag, stream);
    }, true);
}

void QUICSession::p_connect(QuicServerId aTargetServerId)
{
    if (mSession.get())
        p_disconnect();
    
    mServerAddress = IPEndPoint({0, 0, 0, 0}, aTargetServerId.port());
    mServerId = aTargetServerId;
    
//    const UInt16 port = mServerId.host_port_pair().port();
//    NSString *address = [NSString stringWithCString:mServerId.host_port_pair().host().c_str()
//                                           encoding:[NSString defaultCStringEncoding]];
    
//    mObjC->mNativeUDPSocket = [[NativeUDPSocketWrapper alloc] initWithHost:address
//                                                                       onPort:port
//                                                                    delegate:this];
//    
//    if (mObjC->mNativeUDPSocket == nil)
//    {
//        return;
//    }
    
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
    if (!mSession.get())
        return false;
    
    if (!mSession->connection())
        return false;
    
    if (!mSession->connection()->connected() || !mSession->EncryptionEstablished())
        return false;
    
    if (!mService)
        return false;
    
    if (!mService->connected())
        return false;
    
    return true;
}

QUICDataStream* QUICSession::p_sendRequest(const net::SpdyHeaderBlock &headers,
                              base::StringPiece body,
                              QUICStreamDelegate* aStreamDelegate)
{
    if (!p_connected())
    {
        return nullptr;
    }
    
    QUICDataStream* stream = createReliableClientStream();
    
    if (stream == nullptr)
    {
        std::cout << "Stream creation failed!" << std::endl;
        reconnect();
        return nullptr;
    }
    
    stream->setDelegate(this);
    mStreamDelegateMap[stream] = aStreamDelegate;
    /*const size_t numBytesWritten = */stream->SendRequest(headers, body, true);
    //std::cout << "Written: " << numBytesWritten << std::endl;
    return stream;
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

void QUICSession::onQUICStreamFailed(QUICDataStream* aStream, Error aError)
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
    return new CocoaQuicPacketWriter(mService);
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

void QUICSession::onQUICError(Error aError)
{
    p_disconnect();
    std::vector<QUICDataStream*> streams;
    for (auto& i : mStreamDelegateMap)
        streams.push_back(i.first);
    
    for (auto& s : streams)
        s->onSocketError(aError);
}

void QUICSession::update(size_t aNowMS)
{
    std::vector<QUICDataStream*> streams;
    for (auto& i : mStreamDelegateMap)
        streams.push_back(i.first);
    
    for (auto& s : streams)
        s->update(aNowMS);
}
