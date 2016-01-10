//
//  StandardConnection.cpp
//  RevSDK
//
//  Created by Andrey Chernukha on 11/17/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

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
#import "RSURLSessionDelegate.h"
#import "RSStandardSession.h"

@interface RSURLSessionDataDelegate : NSObject<NSURLSessionDataDelegate>

@end

@implementation RSURLSessionDataDelegate

@end

using namespace rs;

StandardConnection::StandardConnection()
{
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
    NSURLRequest* request               = URLRequestFromRequest(aRequest);
    NSMutableURLRequest* mutableRequest = request.mutableCopy;
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
    [NSURLProtocol setProperty:@YES forKey:kRSURLProtocolHandledKey inRequest:mutableRequest];

    RSURLSessionDelegate* customDelegate = [[RSURLSessionDelegate alloc] init];
    [customDelegate setConnection:oAnchor];
    
    NSDictionary* headers = mutableRequest.allHTTPHeaderFields;
    NSString* XRevHostHeader = headers[kRSRevHostHeader];
    
    if ([XRevHostHeader isEqualToString:kRSRevRedirectHost])
    {
        Log::error(kLogTagSTDRequest,  "Request host set to %s", [kRSRevRedirectHost UTF8String]);
    }

//    [[RSStandardSession instance] createTaskWithRequest:mutableRequest connection:oAnchor];
    NSURLSessionConfiguration* sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session                           = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                                                    delegate:customDelegate
                                                                               delegateQueue:nil];
    
    NSURLSessionTask* task = [session dataTaskWithRequest:mutableRequest];
    [task resume];
    
    oAnchor->onStart();
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
    
    Log::info(kLogTagStandardConnection,  "Connection recieved data, length = %d", rsData.length());
    
    mConnectionDelegate->connectionDidReceiveData(mWeakThis.lock(), rsData);
}

void StandardConnection::didReceiveResponse(void* aResponse)
{
    NSHTTPURLResponse* response = (__bridge NSHTTPURLResponse *)aResponse;
    mResponse                   = responseFromHTTPURLResponse(response);
    
    Log::info(kLogTagStandardConnection,  "Connection recieved response, code = %d",[response statusCode]);
    
    mConnectionDelegate->connectionDidReceiveResponse(mWeakThis.lock(), mResponse);
}

void StandardConnection::didCompleteWithError(void* aError)
{
    onEnd();
    
    NSURLRequest* request   = URLRequestFromRequest(mCurrentRequest);
    const BOOL usingRevHost = [request.URL.host isEqualToString:kRSRevRedirectHost];
    
    if (!aError)
    {
        mConnectionDelegate->connectionDidFinish(mWeakThis.lock());
        Model::instance()->debug_usageTracker()->trackRequestFinished(usingRevHost, mBytesReceived, *mResponse.get());
    }
    else
    {
        NSError* error = (__bridge NSError*)aError;
        
        Error rsError = errorFromNSError(error);
        
        Log::warning(kLogTagStandardConnection,  "Connection failed with an error, code = %d",rsError.code);
        
        mConnectionDelegate->connectionDidFailWithError(mWeakThis.lock(), rsError);
        Model::instance()->debug_usageTracker()->
        trackRequestFailed(usingRevHost, mBytesReceived, rsError);
    }
    
    if (Model::instance()->shouldCollectRequestsData())
    {
        NSURLRequest* request       = URLRequestFromRequest(mCurrentRequest);
        NSHTTPURLResponse* response = NSHTTPURLResponseFromResponse(mResponse);
        NSString* originalScheme    = NSStringFromStdString(mCurrentRequest->originalScheme());
        Data requestData            = dataFromRequestAndResponse(request, response, mWeakThis.lock().get(), originalScheme);
        Model::instance()->addRequestData(requestData);
    }
}
