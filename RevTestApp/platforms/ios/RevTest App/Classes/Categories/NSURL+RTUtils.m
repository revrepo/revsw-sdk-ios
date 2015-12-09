//
//  NSURL+RTUtils.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "NSURL+RTUtils.h"

@implementation NSURL (RTUtils)

- (BOOL)isValid
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlTest evaluateWithObject:self.absoluteString];
}

@end
