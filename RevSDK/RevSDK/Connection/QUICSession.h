//
//  QUICSession.hpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/25/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#pragma once

#include "QUICHelpers.h"
#include "NativeUDPSocketCPPDelegate.h"
#include "RevProofVerifier.h"
#include "QUICSessionDelegates.h"
#include "QUICThread.h"
#include "QUICClientSession.h"

#include <map>
#include <thread>
#include <mutex>

namespace rs
{
    class UDPService;
    class QUICSession : public NativeUDPSocketCPPDelegate, public QUICDataStream::Delegate
    {
    public:
        static QUICSession* instance();
        QUICSession();
        ~QUICSession();
        
        void setSessionDelegate(QUICSessionDelegate* aSessionDelegate);
        void connect(net::QuicServerId aTargetServerId);
        void disconnect();
        bool connected() const { return p_connected(); /*just accessing flag*/ };
        void sendRequest(const net::SpdyHeaderBlock &headers,
                         base::StringPiece body,
                         QUICStreamDelegate* aStreamDelegate);
        void update(size_t aNowMS);
        
        
    private:
        void p_connect(net::QuicServerId aTargetServerId);
        void p_disconnect();
        bool p_connected() const;
        bool p_sendRequest(const net::SpdyHeaderBlock &headers,
                           base::StringPiece body,
                           QUICStreamDelegate* aStreamDelegate);
        void OnClose(net::QuicDataStream* stream);
        
        void onQUICStreamReceivedData(QUICDataStream* aStream, const char* aData, size_t aDataLen) override;
        void onQUICStreamReceivedResponse(QUICDataStream* aStream, int aCode, const net::SpdyHeaderBlock& aHeaders) override;
        void onQUICStreamFailed(QUICDataStream* aStream) override;
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
        //QUICThread mInstanceThread;
        UDPService* mService;
        
        void executeOnSessionThread(std::function<void(void)> aFunction);
        
        class ObjCImpl;
        
        QUICSessionDelegate* mSessionDelegate;
        
        base::AtExitManager mAtExitManager;
        
        // Obj-C object that manages the udp socket, needs to outlive writer.
        //ObjCImpl* mObjC;
        
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
        
        typedef std::map<QUICDataStream*, QUICStreamDelegate*> StreamDelegateMap;
        StreamDelegateMap mStreamDelegateMap;
    };
}
