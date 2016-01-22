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

#include "StandardConnection.hpp"
#include "RSUtils.h"
#include "RSURLProtocol.h"
#include "Data.hpp"
#include "Response.hpp"
#include "Request.hpp"
#include "Error.hpp"
#include "Utils.hpp"
#include "Model.hpp"
#include <mutex>
#include "DebugUsageTracker.hpp"
#import "RSStandardSession.h"

@interface Holder : NSObject
{
    @public
    std::shared_ptr<rs::Connection> mConnection;
}

@end

@implementation Holder

- (void)dealloc
{
    
}

@end

using namespace rs;

StandardConnection::StandardConnection()
{
    mEdgeHost = Model::instance()->edgeHost();
    mConnectionDelegate = nullptr;
} 

StandardConnection::~StandardConnection()
{
    
}

void StandardConnection::startWithRequest(std::shared_ptr<Request> aRequest, ConnectionDelegate* aDelegate)
{
    mCurrentRequest                     = aRequest;
    mConnectionDelegate                 = aDelegate;
    std::shared_ptr<Connection> oAnchor = mWeakThis.lock();
    NSMutableURLRequest* request               = URLRequestFromRequest(aRequest);
//    NSMutableURLRequest* mutableRequest = request.mutableCopy;
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSString* targetHost                = request.URL.host;
    
    if (!targetHost)
    {
        Error error;
        error.code     = 404;
        error.domain   = "com.revsdk";
        error.userInfo = std::map <std::string, std::string>();
        error.userInfo[errorDescriptionKey()] = "URL not supported";
        
        Log::warning(kLogTagSTDRequest, "StandardConnection:: URL is not supported, return");
        
        aDelegate->connectionDidFailWithError(oAnchor, error);
        return;
    }
    
    oAnchor->addSentBytesCount(request.HTTPBody.length);
    [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:request];
    
    NSDictionary* headers = request.allHTTPHeaderFields;
    NSString* XRevHostHeader = headers[kRSRevHostHeader];
    
    NSString* edgeHostString = NSStringFromStdString(mEdgeHost);
    
    if ([XRevHostHeader isEqualToString:edgeHostString])
    {
        Log::error(kLogTagSTDRequest,  "Request host set to %s", [edgeHostString UTF8String]);
    }

    [[RSStandardSession instance] createTaskWithRequest:request connection:oAnchor];
    
    oAnchor->onStart();
    
    Holder* holder = [Holder new];
    holder->mConnection = oAnchor;
    mHolder = ( void *)CFBridgingRetain(holder);
}

std::string StandardConnection::edgeTransport()const
{
    return kStandardProtocolName;
}

void StandardConnection::didReceiveData(void* aData)
{
    NSData* data = (__bridge NSData*)aData;
    addReceivedBytesCount([data length]);
    Data rsData = rs::dataFromNSData(data);
    
    Log::info(kLogTagSTDStandardConnection,  "Connection recieved data, length = %d", rsData.length());
    
    mConnectionDelegate->connectionDidReceiveData(mWeakThis.lock(), rsData);
}

void StandardConnection::didReceiveResponse(void* aResponse)
{
    onResponseReceived();
    
    NSHTTPURLResponse* response = (__bridge NSHTTPURLResponse *)aResponse;
    NSString* originalURL = NSStringFromStdString(mCurrentRequest->originalURL());
    NSHTTPURLResponse* processedResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:originalURL]
                                                                       statusCode:response.statusCode
                                                                      HTTPVersion:@"1.1"
                                                                     headerFields:response.allHeaderFields];
    mResponse                   = responseFromHTTPURLResponse(processedResponse);
    
    Log::info(kLogTagSTDStandardConnection,  "Connection recieved response, code = %d",[processedResponse statusCode]);
    
//    mResponse->URL() == ""
    mConnectionDelegate->connectionDidReceiveResponse(mWeakThis.lock(), mResponse);
}

void StandardConnection::didCompleteWithError(void* aError)
{
    onEnd();
    
    NSURLRequest* request    = URLRequestFromRequest(mCurrentRequest);
    NSString* edgeHostString = NSStringFromStdString(mEdgeHost);
    const BOOL usingRevHost  = [request.URL.host isEqualToString:edgeHostString];
    
    if (!aError)
    {
        mConnectionDelegate->connectionDidFinish(mWeakThis.lock());
        Model::instance()->debug_usageTracker()->trackRequestFinished(usingRevHost, mBytesReceived, *mResponse.get());
    }
    else
    {
        NSError* error = (__bridge NSError*)aError;
        
        Error rsError = errorFromNSError(error);
        
        Log::warning(kLogTagSTDStandardConnection,  "Connection failed with an error, code = %d",rsError.code);
        
        mConnectionDelegate->connectionDidFailWithError(mWeakThis.lock(), rsError);
        Model::instance()->debug_usageTracker()->
        trackRequestFailed(usingRevHost, mBytesReceived, rsError);
    }
    
    if (Model::instance()->shouldCollectRequestsData())
    {
        NSURLRequest* request       = URLRequestFromRequest(mCurrentRequest);
        NSHTTPURLResponse* response = NSHTTPURLResponseFromResponse(mResponse);
        NSString* originalScheme    = NSStringFromStdString(mCurrentRequest->originalScheme());
        Data requestData            = dataFromRequestAndResponse(request, response, mWeakThis.lock().get(), originalScheme, YES);
        Model::instance()->addRequestData(requestData);
    }
    
    CFRelease(mHolder);
}
