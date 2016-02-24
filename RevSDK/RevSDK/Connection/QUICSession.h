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

#pragma once

#include "NativeUDPSocketCPPDelegate.h"
#include "RevProofVerifier.h"
#include "QUICSessionDelegates.h"
#include "QUICThread.h"
#include "QUICClientSession.h"

#include <unordered_map>
#include <thread>
#include <mutex>

namespace rs
{
    class UDPService;
    class QuicConnectionHelper;
    
    class QUICSession : public NativeUDPSocketCPPDelegate, public QUICDataStream::Delegate
    {
    public:
        static QUICSession* instance();
        static void reconnect();
        
        QUICSession();
        ~QUICSession();
        
        void setSessionDelegate(QUICSessionDelegate* aSessionDelegate);
        void connect(net::QuicServerId aTargetServerId);
        void disconnect();
        bool connected() const { return p_connected(); /*just accessing flag*/ };
        void sendRequest(const net::SpdyHeaderBlock &headers,
                         base::StringPiece body,
                         QUICStreamDelegate* aStreamDelegate);
        void sendRequest(const net::SpdyHeaderBlock &headers,
                         base::StringPiece body,
                         QUICStreamDelegate* aStreamDelegate,
                         int aTag,
                         std::function<void(int, QUICDataStream*)> aCallback);
        void update(size_t aNowMS);
        
        std::string host() const { return mHost; }
        int port() const { return mPort; }
        
    private:
        void p_connect(net::QuicServerId aTargetServerId);
        void p_disconnect();
        bool p_connected() const;
        QUICDataStream* p_sendRequest(const net::SpdyHeaderBlock &headers,
                                      base::StringPiece body,
                                      QUICStreamDelegate* aStreamDelegate);
        void OnClose(net::QuicSpdyStream* stream);
        
        void onQUICStreamReceivedData(QUICDataStream* aStream, const char* aData, size_t aDataLen) override;
        void onQUICStreamReceivedResponse(QUICDataStream* aStream, int aCode, const net::SpdyHeaderBlock& aHeaders) override;
        void onQUICStreamFailed(QUICDataStream* aStream, Error aError) override;
        void onQUICStreamCompleted(QUICDataStream* aStream) override;

        net::QuicConnectionId generateConnectionId();
        QuicConnectionHelper *createQuicConnectionHelper();
        net::QuicPacketWriter *createQuicPacketWriter();
        QUICDataStream *createReliableClientStream();
        net::tools::QuicClientSession *createQuicClientSession(const net::QuicConfig &config,
                                                               net::QuicConnection *connection,
                                                               const net::QuicServerId &serverId,
                                                               net::QuicCryptoClientConfig *cryptoConfig);
        bool onQUICPacket(const net::QuicEncryptedPacket &packet) override;
        void onQUICError() override;
        
    private:
        static QUICSession* mInstance;
        QUICThread mInstanceThread;
        //UDPService* mService;
        std::string mHost;
        int mPort;
        
        void executeOnSessionThread(std::function<void(void)> aFunction, bool aForceAsync = false);
        
        class ObjCImpl;
        
        QUICSessionDelegate* mSessionDelegate;
        
        base::AtExitManager mAtExitManager;
        
        // Obj-C object that manages the udp socket, needs to outlive writer.
        ObjCImpl* mObjC;
        
        // Writer used to send packets to the wire.
        // Wraps around the cocoaUDPSocketWrapper.
        scoped_ptr<net::QuicPacketWriter> mWriter;
        
        // Session which manages streams and connection.
        scoped_ptr<QUICClientSession> mSession;
        scoped_ptr<QuicConnectionHelper> mConnectionHelper;
        
        // Configuration and cached state about servers.
        net::QuicConfig mConfig;
        net::QuicCryptoClientConfig mCryptoConfig;
        
        // Peer endpoints.
        net::IPEndPoint mClientAddress;
        net::IPEndPoint mServerAddress;
        net::QuicServerId mServerId;
        
        typedef std::unordered_map<QUICDataStream*, QUICStreamDelegate*> StreamDelegateMap;
        StreamDelegateMap mStreamDelegateMap;
        
        bool mConnecting;
    };
}
