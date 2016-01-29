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

#import "RTHTMLGrabber.h"
#import "HTMLParser.h"
#import "NSURL+RTUTils.h"

@interface RTHTMLGrabber ()

@property (atomic, strong) NSMutableDictionary *activeTasks;
@property (nonatomic, strong) NSMutableSet* set;
@property (nonatomic, copy) NSString* requestAbsoluteURL;
@property (nonatomic) NSInteger statusCode;
@end

@implementation RTHTMLGrabber

- (NSMutableSet *)set
{
    if (!_set)
    {
        _set = [NSMutableSet set];
    }
    
    return _set;
}

- (void)loadRequest:(NSURLRequest *)request
{
    NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.protocolClasses            = @[NSClassFromString(@"RSURLProtocol")];
    NSURLSession* session                    = [NSURLSession sessionWithConfiguration:configuration];
    
    self.requestAbsoluteURL = request.URL.absoluteString;
    self.statusCode = -1;
    
    for (NSURLSessionTask *task in [self.activeTasks allValues]) {
        [task cancel];
    }
    
    self.activeTasks = [NSMutableDictionary new];
    
    if (self.delegate)
    {
        [self.delegate grabberDidStartLoad:self];
    }
    
    NSURLSessionTask *task = [self recursiveTaskForRequest:request withinSession:session];
    
    if (task != nil)
    {
        [self.activeTasks setObject:task forKey:request];
        [task resume];
    }
}

- (NSURLSessionTask *)recursiveTaskForRequest:(NSURLRequest *)request
                                withinSession:(NSURLSession *)session
{
    NSString* urlStr = request.URL.absoluteString;
//    if ([urlStr isEqualToString:@"https://:0"])
//        return nil;
    NSLog(@"RTHTMLGrabber loading URL: %@", urlStr);
   // NSLog(@"Request started %@", request.URL);
    
    return
    [session dataTaskWithRequest:request
               completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError) {
                   
                    if ([self.requestAbsoluteURL isEqualToString:request.URL.absoluteString])
                    {
                        self.statusCode = [(NSHTTPURLResponse *)aResponse statusCode];
                    }
                   
                   if (aError != nil)
                   {
                       [self.activeTasks removeObjectForKey:request];
                       return;
                   }
                   
                   if (self.activeTasks.count == 0)
                   {
                       return;
                   }
                   
                   NSLog(@"RTHTMLGrabber done URL: %@", request.URL.absoluteString);
                   //NSLog(@"Request done %@", aResponse);
                   NSString *rcvdData = [[NSString alloc] initWithData:aData encoding:NSUTF8StringEncoding];
                   
                   NSMutableArray *newTasks = [NSMutableArray new];
                   NSError *error = nil;
                   HTMLParser *parser = [[HTMLParser alloc] initWithString:rcvdData error:&error];
                  // NSLog(@"rcvdData %@", rcvdData);
                   BOOL contains = [self.set containsObject:rcvdData];
                   //NSLog(@"CONTAINS %d", contains);
                   if (!contains && !error)
                   {
                       if (rcvdData)
                       {
                           [self.set addObject:rcvdData];
                       }
                       
                       HTMLNode *bodyNode = [parser body];
                       
                       NSArray *links = [bodyNode findChildTags:@"link"];
                       
                       for (HTMLNode *linkNode in links)
                       {
                           NSString *linkString = [linkNode getAttributeNamed:@"href"];
                           NSURLRequest *subRequest = [self subRequestFrom:request withRelativePath:linkString];
                           
                           if (subRequest != nil)
                           {
                               NSURLSessionTask *subTask = [self recursiveTaskForRequest:subRequest withinSession:session];
                               if (subTask != nil)
                               {
                                   [self.activeTasks setObject:subTask forKey:subRequest];
                                   [newTasks addObject:subTask];
                               }
                           }
                       }
                       
                       NSMutableArray *resources = [NSMutableArray new];
                       [resources addObjectsFromArray:[bodyNode findChildTags:@"script"]];
                       [resources addObjectsFromArray:[bodyNode findChildTags:@"img"]];
                       [resources addObjectsFromArray:[bodyNode findChildTags:@"iframe"]];
                       
                       for (HTMLNode *resourceNode in resources)
                       {
                           NSString *resourceString = [resourceNode getAttributeNamed:@"src"];
                           NSURLRequest *subRequest = [self subRequestFrom:request withRelativePath:resourceString];
                           
                           if (subRequest != nil)
                           {
                               NSURLSessionTask *subTask = [self recursiveTaskForRequest:subRequest withinSession:session];
                               if (subTask != nil)
                               {
                                   [self.activeTasks setObject:subTask forKey:subRequest];
                                   [newTasks addObject:subTask];
                               }
                           }
                       }
                   }
                   
                   [self.activeTasks removeObjectForKey:request];
                   
                   for (NSURLSessionTask *task in newTasks)
                   {
                       [task resume];
                   }
                   
                   if (self.activeTasks.count == 0)
                   {
                       if (self.delegate)
                       {
                           [self.set removeAllObjects];
                           [self.delegate grabberDidFinishLoad:self withStatusCode:self.statusCode];
                       }
                   }
               }];
}

- (NSURLRequest *)subRequestFrom:(NSURLRequest *)baseRequest
                withRelativePath:(NSString *)relativePath
{
    NSURL *baseURL = [baseRequest URL];
    
    NSURL *newURL = [NSURL URLWithString:relativePath relativeToURL:baseURL];
    
    if (! newURL.isValid)
    {
        return nil;
    }
    
    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:newURL];
    [newRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [newRequest setValue:@"Mozilla/5.0 (iPhone; CPU iPhone OS 9_2 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13C75"
      forHTTPHeaderField:@"User-Agent"];
    return newRequest;
}

@end
