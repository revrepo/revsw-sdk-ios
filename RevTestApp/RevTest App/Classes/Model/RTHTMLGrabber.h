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

#import <Foundation/Foundation.h>

@protocol RTHTMLGrabberDelegate;

@interface RTHTMLGrabber : NSObject

- (void)loadRequest:(NSURLRequest *)request;
@property (nullable, nonatomic, assign) id <RTHTMLGrabberDelegate> delegate;

@end

@protocol RTHTMLGrabberDelegate <NSObject>

@optional
- (void)grabberDidStartLoad:(RTHTMLGrabber *)grabber;
- (void)grabberDidFinishLoad:(RTHTMLGrabber *)grabber withStatusCode:(NSInteger)statusCode dataSize:(NSUInteger)aDataSize;
- (void)grabber:(RTHTMLGrabber *)grabber didFailLoadWithError:(nullable NSError *)error;

@end
