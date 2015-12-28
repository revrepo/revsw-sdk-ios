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

#include "RevQuicClient.h"
#include "net/quic/crypto/quic_random.h"

@implementation CocoaUDPSocketWrapper

- (instancetype)initWithHost:(NSString *)host
                      onPort:(UInt16)port
                   forClient:(RevQuicClient *)client
{
    self = [super init];
    
    if (! self)
    {
        return nil;
    }
    
    self->blocked = false;
    self->targetClient = client;
    self->udpSocket = [[RevAsyncUdpSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    
    if (! [self->udpSocket connectToHost:host onPort:port error:&error])
    {
        NSLog(@"Error connectToHost: %@", error);
        return nil;
    }
    
    [self->udpSocket receiveWithTimeout:-1 tag:0];
    
    NSLog(@"Ready");
    return self;
}

#pragma mark - AsyncUdpSocketDelegate

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
 didSendDataWithTag:(long)tag
{
    self->blocked = false;
    NSLog(@">>> outgoing ok");
}

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
didNotSendDataWithTag:(long)tag
         dueToError:(NSError *)error
{
    self->blocked = false;
    NSLog(@"!! outgoing error %@", error);
}

- (BOOL)onUdpSocket:(RevAsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port
{
    if (! self->targetClient)
    {
        return NO;
    }
    
    QuicEncryptedPacket packet((const char *)data.bytes, data.length);
    if (! self->targetClient->onPacket(packet))
    {
        return NO;
    }
    
    [udpSocket receiveWithTimeout:-1 tag:0];
    return YES;
}

- (void)onUdpSocket:(RevAsyncUdpSocket *)sock
didNotReceiveDataWithTag:(long)tag
         dueToError:(NSError *)error
{
    NSLog(@"didNotReceiveDataWithTag dueToError %@", error);
}

- (void)onUdpSocketDidClose:(RevAsyncUdpSocket *)sock
{
    self->blocked = false;
    
    if (self->targetClient)
    {
        self->targetClient->onReadError();
    }
}

@end

#pragma mark - CocoaQuicPacketWriter

class CocoaQuicPacketWriter : public QuicPacketWriter
{
public:
    
    explicit CocoaQuicPacketWriter(CocoaUDPSocketWrapper *cocoaUDPSocketDelegate);
    
    virtual WriteResult WritePacket(const char *buffer, size_t buf_len,
                                    const IPAddressNumber& self_address,
                                    const IPEndPoint &peer_address) override;
    virtual bool IsWriteBlockedDataBuffered() const override;
    virtual bool IsWriteBlocked() const override;
    virtual void SetWritable() override;
    
public:
    
    CocoaUDPSocketWrapper *socketOwner;
};

CocoaQuicPacketWriter::CocoaQuicPacketWriter(CocoaUDPSocketWrapper *cocoaUDPSocketDelegate) :
socketOwner(cocoaUDPSocketDelegate)
{
    
}

WriteResult
CocoaQuicPacketWriter::WritePacket(const char* buffer, size_t buf_len,
                                   const IPAddressNumber &self_address,
                                   const IPEndPoint &peer_address)
{
    if (this->socketOwner->blocked)
    {
        return WriteResult(WRITE_STATUS_BLOCKED, 0);
    }
    
    BOOL sendResult =
    [this->socketOwner->udpSocket sendData:[NSData dataWithBytes:buffer length:buf_len]
                               withTimeout:0
                                       tag:0];
    
    if (sendResult)
    {
        NSLog(@">> outgoing %zu", buf_len);
    }
    else
    {
        NSLog(@"! WritePacket error! ");
    }
    
    this->socketOwner->blocked = sendResult;
    return WriteResult(sendResult ? WRITE_STATUS_OK : WRITE_STATUS_ERROR, buf_len);
}

bool CocoaQuicPacketWriter::IsWriteBlockedDataBuffered() const
{
    return false;
}

bool CocoaQuicPacketWriter::IsWriteBlocked() const
{
    return this->socketOwner->blocked;
}

void CocoaQuicPacketWriter::SetWritable()
{
    this->socketOwner->blocked = true;
}

#pragma mark - QuicConnectionHelper

class QuicConnectionHelper : public QuicConnectionHelperInterface
{
public:
    class DummyAlarm : public QuicAlarm
    {
    public:
        DummyAlarm(QuicAlarm::Delegate *delegate) : QuicAlarm(delegate) {}
    protected:
        virtual void SetImpl() override {}
        virtual void CancelImpl() override {}
    };
    
    QuicConnectionHelper() {}
    
    virtual const QuicClock *GetClock() const override
    { return &this->clock; }
    
    virtual QuicRandom *GetRandomGenerator() override
    { return QuicRandom::GetInstance(); }
    
    virtual QuicAlarm *CreateAlarm(QuicAlarm::Delegate *delegate) override
    { return new DummyAlarm(delegate); /* deleted by the caller */ }
    
    QuicClock clock;
};

#pragma mark - CocoaWriterFactory

class CocoaWriterFactory : public QuicConnection::PacketWriterFactory
{
public:
    
    CocoaWriterFactory(QuicPacketWriter *targetWriter) :
    writer(targetWriter) {}
    
    ~CocoaWriterFactory() override {}
    
    QuicPacketWriter *Create(QuicConnection *connection) const override
    { return this->writer; }
    
private:
    
    QuicPacketWriter *writer;
};

#pragma mark - RevQuicClient implementation

RevQuicClient::RevQuicClient() :
clientAddress({0, 0, 0, 0}, 443),
lastResponseCode(0)
{
}

RevQuicClient::~RevQuicClient()
{
    this->disconnect();
}

void RevQuicClient::connect(QuicServerId targetServerId)
{
    if (this->session.get())
    {
        this->disconnect();
    }
    
    this->serverAddress = IPEndPoint({0, 0, 0, 0}, targetServerId.port());
    this->serverId = targetServerId;
    
    const UInt16 port = serverId.host_port_pair().port();
    NSString *address = [NSString stringWithCString:serverId.host_port_pair().host().c_str()
                                           encoding:[NSString defaultCStringEncoding]];
    
    this->cocoaUDPSocketWrapper = [[CocoaUDPSocketWrapper alloc] initWithHost:address
                                                                       onPort:port
                                                                    forClient:this];
    
    if (this->cocoaUDPSocketWrapper == nil)
    {
        return;
    }
    
    this->connectionHelper.reset(new QuicConnectionHelper());
    this->cryptoConfig.SetProofVerifier(new RevProofVerifier());
    
    this->writer.reset(this->createQuicPacketWriter());
    
    if (! this->session)
    {
        // Will be owned by the session.
        QuicConnection *connection =
        new QuicConnection(this->generateConnectionId(),
                           this->serverAddress,
                           this->connectionHelper.get(),
                           CocoaWriterFactory(this->writer.get()),
                           /* owns_writer= */ false,
                           Perspective::IS_CLIENT,
                           this->serverId.is_https(),
                           QuicSupportedVersions());
        
        this->session.reset(this->createQuicClientSession(this->config,
                                                          connection,
                                                          this->serverId,
                                                          &this->cryptoConfig));
    }
    
    this->session->Initialize();
    this->session->CryptoConnect();
}

bool RevQuicClient::isConnected()
{
    if (this->session.get())
    {
        if (this->session->connection())
        {
            return
            this->session->connection()->connected() &&
            this->session->EncryptionEstablished();
        }
    }
    
    return false;
}

void RevQuicClient::disconnect()
{
    if (this->isConnected())
    {
        this->session->connection()->SendConnectionClose(QUIC_PEER_GOING_AWAY);
    }
    
    this->writer.reset();
    this->session.reset();
    
    this->lastHeaders.clear();
    this->lastBody.clear();
}

bool RevQuicClient::sendRequest(const SpdyHeaderBlock &headers,
                                base::StringPiece body)
{
    if (! this->isConnected())
    {
        return false;
    }
    
    QuicSpdyClientStream *stream = this->createReliableClientStream();
    
    if (stream == nullptr)
    {
        NSLog(@"Stream creation failed!");
        return false;
    }
    
    stream->set_visitor(this);
    
    const size_t numBytesWritten = stream->SendRequest(headers, body, true);
    NSLog(@"Written %zu bytes", numBytesWritten);
    return true;
}

void RevQuicClient::OnClose(QuicDataStream *stream)
{
    QuicSpdyClientStream *clientStream = static_cast<QuicSpdyClientStream*>(stream);
    
    this->lastHeaders = clientStream->headers();
    this->lastBody = clientStream->data();
    this->lastResponseCode = clientStream->response_code();
    
    // Debug:
    //for (const auto &header : clientStream->headers())
    //{
    //    NSString *key = [NSString stringWithUTF8String:header.first.c_str()];
    //    NSString *value = [NSString stringWithUTF8String:header.second.c_str()];
    //    NSLog(@"%@ : %@", key, value);
    //}
    
    //NSString *data = [NSString stringWithUTF8String:clientStream->data().c_str()];
    //NSLog(@"Body:\n %@", data);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RevResponseReceivedNotification object:nil];
}

void RevQuicClient::onReadError()
{
    this->disconnect();
}

bool RevQuicClient::onPacket(const QuicEncryptedPacket &packet)
{
    if (! this->session.get())
    {
        return false;
    }
    
    NSLog(@"<< incoming %zu", packet.length());
    this->session->connection()->ProcessUdpPacket(this->clientAddress, this->serverAddress, packet);
    
    if (! this->session->connection()->connected())
    {
        return false;
    }
    
    return true;
}

QuicConnectionId RevQuicClient::generateConnectionId()
{
    return this->connectionHelper->GetRandomGenerator()->RandUint64();
}

QuicConnectionHelper *RevQuicClient::createQuicConnectionHelper()
{
    return new QuicConnectionHelper();
}

QuicPacketWriter *RevQuicClient::createQuicPacketWriter()
{
    return new CocoaQuicPacketWriter(this->cocoaUDPSocketWrapper);
}

QuicClientSession *RevQuicClient::createQuicClientSession(const QuicConfig &config,
                                                          QuicConnection *connection,
                                                          const QuicServerId &serverId,
                                                          QuicCryptoClientConfig *cryptoConfig)
{
    return new QuicClientSession(config, connection, serverId, cryptoConfig);
}

QuicSpdyClientStream *RevQuicClient::createReliableClientStream()
{
    if (! this->isConnected())
    {
        return nullptr;
    }
    
    return this->session->CreateOutgoingDynamicStream();
}

const SpdyHeaderBlock &RevQuicClient::getLastHeaders() const noexcept
{
    return this->lastHeaders;
}

const std::string &RevQuicClient::getLastBody() const noexcept
{
    return this->lastBody;
}

const int RevQuicClient::getLastResponseCode() const noexcept
{
    return this->lastResponseCode;
}
