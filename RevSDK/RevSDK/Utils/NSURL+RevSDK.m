//
//  NSURL+RevSDK.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "NSURL+RevSDK.h"

@implementation NSURL(NSURL_RevSDK)

- (NSURL*)revURLByReplacingHostWithHost:(NSString*)aNewHost
{
    if (aNewHost.length == 0)
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
