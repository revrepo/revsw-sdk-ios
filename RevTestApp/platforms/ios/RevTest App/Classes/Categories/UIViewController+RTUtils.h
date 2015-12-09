//
//  UIViewController+RTUtils.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface UIViewController (RTUtils)

@property (nonatomic, strong) MBProgressHUD* progressHUD;

+ (instancetype)viewControllerFromXib;
- (void)showErrorAlertWithMessage:(NSString *)aMessage;

- (void)showHudWithText:(NSString *)aText;
- (void)hideHud;

@end
