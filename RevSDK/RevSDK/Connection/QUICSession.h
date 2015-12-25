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

#include <map>

namespace rs
{
    class QUICSession : public net::QuicDataStream::Visitor, public NativeUDPSocketCPPDelegate
    {
    public:
        static QUICSession* instance();
        QUICSession();
        ~QUICSession();
        
        void setSessionDelegate(QUICSessionDelegate* aSessionDelegate);
        void connect(net::QuicServerId aTargetServerId);
        void disconnect();
        bool connected() const;
        bool sendRequest(const net::SpdyHeaderBlock &headers,
                         base::StringPiece body,
                         QUICStreamDelegate* aStreamDelegate);
        
    private:
        void OnClose(net::QuicDataStream* stream);
        net::QuicConnectionId generateConnectionId();
        QuicConnectionHelper *createQuicConnectionHelper();
        net::QuicPacketWriter *createQuicPacketWriter();
        net::tools::QuicSpdyClientStream *createReliableClientStream();
        net::tools::QuicClientSession *createQuicClientSession(const net::QuicConfig &config,
                                                               net::QuicConnection *connection,
                                                               const net::QuicServerId &serverId,
                                                               net::QuicCryptoClientConfig *cryptoConfig);
        bool onQUICPacket(const net::QuicEncryptedPacket &packet);
        void onQUICError();
    private:
        static QUICSession* mInstance;
        
        class ObjCImpl;
        
        QUICSessionDelegate* mSessionDelegate;
        
        base::AtExitManager mAtExitManager;
        
        // Obj-C object that manages the udp socket, needs to outlive writer.
        ObjCImpl* mObjC;
        
        // Writer used to send packets to the wire.
        // Wraps around the cocoaUDPSocketWrapper.
        scoped_ptr<net::QuicPacketWriter> mWriter;
        
        // Session which manages streams and connection.
        scoped_ptr<net::tools::QuicClientSession> mSession;
        scoped_ptr<QuicConnectionHelper> mConnectionHelper;
        
        // Configuration and cached state about servers.
        net::QuicConfig mConfig;
        net::QuicCryptoClientConfig mCryptoConfig;
        
        // Peer endpoints.
        net::IPEndPoint mClientAddress;
        net::IPEndPoint mServerAddress;
        net::QuicServerId mServerId;
        
        typedef std::map<net::QuicDataStream*, QUICStreamDelegate*> StreamDelegateMap;
        StreamDelegateMap mStreamDelegateMap;
    };
}
