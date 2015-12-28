/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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

#ifndef QuicClient_hpp
#define QuicClient_hpp

#include <string>

#include "base/at_exit.h"
#include "quic_client_session.h"
#include "quic_spdy_client_stream.h"

#include "RevProofVerifier.h"
#include "RevAsyncUdpSocket.h"

using namespace net;
using namespace net::tools;

class RevQuicClient;
class CocoaQuicPacketWriter;
class QuicConnectionHelper;

/**
 *  Simple RevAsyncUdpSocket owner and delegate.
 *  Acts as a glue between RevAsyncUdpSocket and RevQuicClient.
 */
@interface CocoaUDPSocketWrapper : NSObject <RevAsyncUdpSocketDelegate>
{
@public
    
    bool blocked;
    
    // Socket itself, owned by the wrapper.
    RevAsyncUdpSocket *udpSocket;
    
    // Client reference, a C++ object, not managed by ARC and acting as a weakref.
    RevQuicClient *targetClient;
}

- (instancetype) __unavailable init;
- (instancetype)initWithHost:(NSString *)host
                      onPort:(UInt16)port
                   forClient:(RevQuicClient *)client;

@end

/**
 *  The QUIC client for encrypted connections, made as simple as possible.
 *  Demonstrates how to create and manage libQUIC session and streams.
 *  Feel free to modify and reuse.
 */
class RevQuicClient : public QuicDataStream::Visitor
{
public:
    
    RevQuicClient();
    ~RevQuicClient();
    
    /**
     *  Checks if client has an encrypted connection to any server.
     *
     *  @return true, if has session with encryption estabilished.
     */
    bool isConnected();
    
    /**
     *  Sends "peer is going away" message and closes the session.
     */
    void disconnect();
    
    /**
     *  Creates a udp socket that is connected to the target server,
     *  then creates and initializes a client session
     *  and performs crypto handshake flow.
     *
     *  @param targetServerId Server's address and port.
     */
    void connect(QuicServerId targetServerId);
    
    /**
     *  Sends a request once have successfully connected.
     *
     *  @param headers A simple key-value headers map.
     *  @param body    Request body string.
     *
     *  @return true if request was sent.
     */
    bool sendRequest(const SpdyHeaderBlock &headers, base::StringPiece body);
    
    /**
     *  QuicDataStream::Visitor implementation, called when the request stream is done.
     *  Currently fires a NSNotification called RevResponseReceivedNotification.
     *
     *  You'll probably want to reimplement your way of processing the response
     *  for your particular purposes, e.g. register a delegate or a callback block.
     *
     *  @param stream SPDY stream that was earlier created in sendRequest.
     */
    void OnClose(QuicDataStream *stream) override;
    
    /**
     *  Called by CocoaUDPSocketWrapper on any socket read error.
     */
    void onReadError();
    
    /**
     *  Called by CocoaUDPSocketWrapper on any incoming packet.
     *  Simply feeds the incoming data into libQUIC frame processor,
     *  if has any session available.
     *
     *  @param packet raw packet data.
     *
     *  @return true if the packet was processed normally.
     */
    bool onPacket(const QuicEncryptedPacket &packet);
    
    /**
     *  Last received response details.
     *
     *  @return headers, body or response code
     */
    const SpdyHeaderBlock &getLastHeaders() const noexcept;
    const std::string &getLastBody() const noexcept;
    const int getLastResponseCode() const noexcept;
    
private:
    
    /**
     *  Some shorthands.
     */
    
    QuicConnectionId generateConnectionId();
    QuicConnectionHelper *createQuicConnectionHelper();
    QuicPacketWriter *createQuicPacketWriter();
    QuicSpdyClientStream *createReliableClientStream();
    QuicClientSession *createQuicClientSession(const QuicConfig &config,
                                               QuicConnection *connection,
                                               const QuicServerId &serverId,
                                               QuicCryptoClientConfig *cryptoConfig);
    
private:
    
    // This is a hacky way that Chromium developers make you control the scope
    // of all the singletones' instances created during the lifetime of our class.
    // Without having this declared, the libQUIC will just crash.
    // Obviously, this one needs to outlive any other object in here.
    base::AtExitManager atExitManager;
    
    // Obj-C object that manages the udp socket, needs to outlive writer.
    CocoaUDPSocketWrapper *cocoaUDPSocketWrapper;
    
    // Writer used to send packets to the wire.
    // Wraps around the cocoaUDPSocketWrapper.
    scoped_ptr<QuicPacketWriter> writer;
    
    // Session which manages streams and connection.
    scoped_ptr<QuicClientSession> session;
    scoped_ptr<QuicConnectionHelper> connectionHelper;
    
    // Configuration and cached state about servers.
    QuicConfig config;
    QuicCryptoClientConfig cryptoConfig;
    
    // Peer endpoints.
    IPEndPoint clientAddress;
    IPEndPoint serverAddress;
    QuicServerId serverId;
    
    // The most recent response.
    SpdyHeaderBlock lastHeaders;
    std::string lastBody;
    int lastResponseCode;
};

NSString *const RevResponseReceivedNotification = @"RevResponseReceivedNotification";

#endif /* QuicClient_hpp */
