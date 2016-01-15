/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

#import <Foundation/Foundation.h>

#import "RSNativeUDPSocketWrapper.h"

#include "QUICHelpers.h"
#include "QUICSession.h"
#include "RSUDPService.h"
#include "Model.hpp"
#include <iostream>

// The initial receive window size for both streams and sessions.
const size_t kInitialReceiveWindowSize = 10 * 1024 * 1024;  // 10MB

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
//    dispatch_async(dispatch_get_main_queue(), ^{
//        aFunction();
//    });
    mInstanceThread.perform(aFunction);
}

QUICSession* QUICSession::instance()
{
    if (mInstance == nullptr)
    {
        mInstance = new QUICSession();
        reconnect();
    }
    return mInstance;
}

void QUICSession::reconnect()
{
    int port = 443;
    std::string address = Model::instance()->edgeHost();
    if (address.size() == 0) {
        address = "www.revapm.com";
    }
    
    QuicServerId serverId(address, port, PRIVACY_MODE_DISABLED);
    mInstance->connect(serverId);
}

QUICSession::QUICSession():
    mAtExitManager(),
    mCryptoConfig(new RevProofVerifier()),
    mConnectionHelper(new QuicConnectionHelper()),
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
    
    
    
    mWriter.reset(createQuicPacketWriter());
    
    mConfig.SetInitialSessionFlowControlWindowToSend(kInitialReceiveWindowSize);
    mConfig.SetInitialStreamFlowControlWindowToSend(kInitialReceiveWindowSize);
    mConfig.SetInitialStreamFlowControlWindowToSend(kInitialReceiveWindowSize);
    mConfig.SetSocketReceiveBufferToSend(256000);
    mConfig.SetInitialRoundTripTimeUsToSend(10 * base::Time::kMicrosecondsPerMillisecond);
    
//    static const int kDefaultTimeoutSecs = 30;
//    mConfig.SetIdleConnectionStateLifetime(QuicTime::Delta::FromSeconds(2 * kDefaultTimeoutSecs),
//                                           QuicTime::Delta::FromSeconds(kDefaultTimeoutSecs));
    
    if (!mSession)
    {
        // Will be owned by the session.
        QuicConnection *connection = new QuicConnection(generateConnectionId(),
                                                        mServerAddress,
                                                        mConnectionHelper.get(),
                                                        CocoaWriterFactory(mWriter.get()),
                                                        /* owns_writer= */ false,
                                                        Perspective::IS_CLIENT,
                                                        QuicSupportedVersions());
        connection->SetMaxPacketLength(UINT64_MAX);
        
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
    
    if (!mSession->connection()->connected())
        return false;

    if (!mSession->EncryptionEstablished())
        return false;
    
    //if (!mService)
    //    return false;
    
    //if (!mService->connected())
    //    return false;
    
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

void QUICSession::OnClose(QuicSpdyStream* aStream)
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
    
    // FIXME prioritization is critical
    const int highestPriority = 0; // 7 is the lowest
    return mSession->rsCreateOutgoingDynamicStream(highestPriority);
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
    
    Error aError; // FIXME
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
