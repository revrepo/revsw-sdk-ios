//
//  UIViewController+RTUtils.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import <UIKit/UIKit.h>

#import "UIViewController+RTTesting.h"

@interface UIViewController (RTUtils)

+ (instancetype)viewControllerFromXib;
- (void)showErrorAlertWithMessage:(NSString *)aMessage;

@end
