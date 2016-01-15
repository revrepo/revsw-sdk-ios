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

#import "NSURL+RevSDK.h"

@implementation NSURL(NSURL_RevSDK)

- (NSURL*)revURLByReplacingHostWithHost:(NSString*)aNewHost
{
    if (aNewHost.length == 0)
        return self;
    
    if (self.host == nil)
        return self;
    
    NSString* as = self.absoluteString;
    NSRange r = [as rangeOfString:self.host];
    if (r.location == NSNotFound)
        return self;
    
    as = [as stringByReplacingCharactersInRange:r withString:aNewHost];
    
    NSURL* newURL = [NSURL URLWithString:as];
    
    return (newURL != nil) ? (newURL) : (self);
}

@end
