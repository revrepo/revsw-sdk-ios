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

#import "RSStandardSession.h"
#import "RSURLRequestProcessor.h"
#import "RSUtils.h"
#include "Model.hpp"
#include <unordered_map>

namespace rs
{
    class ConnectionMap
    {
    public:
        typedef std::unordered_map<int, std::weak_ptr<rs::Connection>> Map;
    public:
        ConnectionMap() {}
        ~ConnectionMap() {}
        
        void add(std::shared_ptr<rs::Connection> aConnection)
        {
            if (aConnection.get() == nullptr)
                return;
            
            mLock.lock();
            mMap[aConnection->getID()] = aConnection;
            mLock.unlock();
        }
        void remove(rs::Connection* aConnection)
        {
            if (aConnection == nullptr)
                return;
            mLock.lock();
            Map::iterator w = mMap.find(aConnection->getID());
            if (w != mMap.end())
                mMap.erase(w);
            mLock.unlock();
        }
        std::shared_ptr<rs::Connection> getById(int aConnectionId)
        {
            std::shared_ptr<rs::Connection> res;
            mLock.lock();
            Map::iterator w = mMap.find(aConnectionId);
            if (w != mMap.end())
                res = w->second.lock();
            mLock.unlock();
            return res;
        }
        bool validById(int aConnectionId) const
        {
            bool ok = false;
            mLock.lock();
            Map::const_iterator w = mMap.find(aConnectionId);
            if (w != mMap.end())
                ok = !w->second.expired();
            mLock.unlock();
            return ok;
        }
        void removeById(int aConnectionId)
        {
            mLock.lock();
            Map::const_iterator w = mMap.find(aConnectionId);
            if (w != mMap.end())
                mMap.erase(w);
            mLock.unlock();
        }
    private:
        Map mMap;
        mutable std::mutex mLock;
    };
}

@interface RSStandardSession()<NSURLSessionDataDelegate>
{
    rs::ConnectionMap mConnections;
    NSLock* mLock;
    NSMutableDictionary* mHistory;
    BOOL mInitialized;
}

@property (nonatomic, readwrite, strong) NSURLSessionConfiguration* configuration;
@property (nonatomic, readwrite, strong) NSThread* thread;
@property (nonatomic, readwrite, strong) NSTimer* timer;
@property (nonatomic, readwrite, strong) NSURLSession* session;

- (void)p_createTaskWithParams:(NSDictionary*)aParams;

@end

@implementation RSStandardSession

+ (RSStandardSession*)instance
{
    static dispatch_once_t pred = 0;
    __strong static RSStandardSession* mInstance = nil;
    
    dispatch_once(&pred, ^
    {
        if ([[NSThread currentThread] isMainThread])
        {
            mInstance = [[self alloc] init];
        }
        else
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                mInstance = [[self alloc] init];
            });
        }
    });
    
    return mInstance;
}

- (id)init
{
    if (self = [super init])
    {
        mInitialized = NO;
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadRun:) object:nil];
        [self.thread start];
        
        
        mLock = [[NSLock alloc] init];
        mHistory = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)writeHistoryEntry:(NSString*)aEntry forTaskId:(NSString*)aTaskId
{
#if RS_LOG_STANDARD_CONNECTIONS_GISTORY
    if (aTaskId == nil || aEntry == nil)
        return;
    
    [mLock lock];
    NSMutableArray* entries = [mHistory objectForKey:aTaskId];
    if (entries == nil)
    {
        entries = [[NSMutableArray alloc] init];
        [mHistory setObject:entries forKey:aTaskId];
    }
    [entries addObject:aEntry];
    [mLock unlock];
#endif
}

- (void)onTimerFired:(NSTimer*)aTimer {}

- (void)threadRun:(id)ctx
{
    @autoreleasepool {
        self.configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        self.session = [NSURLSession sessionWithConfiguration:self.configuration
                                                     delegate:self
                                                delegateQueue:nil];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                    target:self
                                                    selector:@selector(onTimerFired:)
                                                    userInfo:nil
                                                     repeats:YES];
        mInitialized = YES;
        [[NSRunLoop currentRunLoop] run];
    }
}

- (void)createTaskWithRequest:(NSURLRequest*)aRequest
                   connection:(std::shared_ptr<rs::Connection>)aConnection
{
    if (aRequest == nil || aConnection.get() == nullptr)
        return;
    
    mConnections.add(aConnection);
    NSString* connectionIdStr = [NSString stringWithFormat:@"%d", aConnection->getID()];
    NSDictionary* params = @{@"r":aRequest, @"id":connectionIdStr};
    
    if ([NSThread currentThread] == self.thread)
    {
        [self p_createTaskWithParams:params];
    }
    else
    {
        [self performSelector:@selector(p_createTaskWithParams:)
                     onThread:self.thread
                   withObject:params
                waitUntilDone:NO];
    }
}

- (void)p_createTaskWithParams:(NSDictionary *)aParams
{
    NSAssert([NSThread currentThread] == self.thread, @"Wrong thread!");
    NSURLRequest* request = aParams[@"r"];
    NSString* connectionId = aParams[@"id"];
    NSAssert(request != nil && connectionId != nil, @"Bad parameters!");
    
    NSURLSessionTask* task = [self.session dataTaskWithRequest:request];
    task.taskDescription = connectionId;
    [task resume];
    [self writeHistoryEntry:@"Started" forTaskId:task.taskDescription];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task willPerformHTTPRedirection:(NSHTTPURLResponse *)response newRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    [self writeHistoryEntry:@"Redirected" forTaskId:task.taskDescription];

    if (!request)
    {
        completionHandler(nil);
    }
    else if (rs::Model::instance()->currentOperationMode() == rs::kRSOperationModeInnerOff)
    {
        completionHandler(request);
    }
    else
    {
        int connectionId = [task.taskDescription intValue];
        std::shared_ptr<rs::Connection> connection = mConnections.getById(connectionId);
        
        std::string edgeHost   = connection->edgeHost();
        NSString* nsEdgeHost   = rs::NSStringFromStdString(edgeHost);
        BOOL shouldModify      = ![request.URL.host isEqualToString:nsEdgeHost];
        NSMutableURLRequest* r = shouldModify ? [RSURLRequestProcessor proccessRequest:request isEdge:YES baseURL:task.originalRequest.URL] : [request mutableCopy];
        
        if (r != nil)
            [NSURLProtocol setProperty:@YES forKey:rs::kRSURLProtocolHandledKey inRequest:r];
        else
        {
            NSString* dump = [NSString stringWithFormat:@"%@\n%@", response.URL, response.allHeaderFields];
            std::string cDump = rs::stdStringFromNSString(dump);
            rs::Log::warning(rs::kLogTagSTDRequest, "Failed to process redirect. Resonse dump: %s", cDump.c_str());
        }
        completionHandler(r);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self writeHistoryEntry:@"Recv data" forTaskId:dataTask.taskDescription];

    int connectionId = [dataTask.taskDescription intValue];
    std::shared_ptr<rs::Connection> connection = mConnections.getById(connectionId);
    if (connection.get() != nullptr)
        connection->didReceiveData((__bridge void *)data);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    [self writeHistoryEntry:@"Recv responce" forTaskId:dataTask.taskDescription];

    int connectionId = [dataTask.taskDescription intValue];
    std::shared_ptr<rs::Connection> connection = mConnections.getById(connectionId);
    
    if (connection.get() == nullptr)
    {
        if (completionHandler)
            completionHandler(NSURLSessionResponseCancel);
    }
    else
    {
        connection->didReceiveResponse((__bridge void*)response);
        if (completionHandler)
            completionHandler(NSURLSessionResponseAllow);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSString* entry = [NSString stringWithFormat:@"Complete with error %@", error];
    [self writeHistoryEntry:entry forTaskId:task.taskDescription];

    int connectionId = [task.taskDescription intValue];
    std::shared_ptr<rs::Connection> connection = mConnections.getById(connectionId);
    
    if (connection.get() != nullptr)
        connection->didCompleteWithError((__bridge void*)error);
    
    mConnections.removeById(connectionId);
}

@end
