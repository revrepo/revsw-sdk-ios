//
//  NSURL+RevSDK.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL(NSURL_RevSDK)

- (NSURL*)revURLByReplacingHostWithHost:(NSString*)aNewHost;

@end
