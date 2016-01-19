//
//  RSMainNC.m
//  RevEtalon
//
//  Created by Admin on 19.01.16.
//  Copyright © 2016 Tundra Mobile. All rights reserved.
//

#import "RSMainNC.h"

@implementation RSMainNC

+ (RSMainNC*)createNewWithVC:(UIViewController*)aVC
{
    if (aVC == nil)
        return nil;
    return [[RSMainNC alloc] initWithRootViewController:aVC];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        
    }
    return self;
}

- (void)dealloc
{
    
}

@end
