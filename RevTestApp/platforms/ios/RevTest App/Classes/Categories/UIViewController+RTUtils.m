//
//  UIViewController+RTUtils.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "objc/runtime.h"

#import "MBProgressHUD.h"

#import "UIViewController+RTUtils.h"

@implementation UIViewController (RTUtils)

- (void)setProgressHUD:(MBProgressHUD *)aProgressHUD
{
    objc_setAssociatedObject(self, @selector(progressHUD), aProgressHUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (MBProgressHUD *)progressHUD
{
    return objc_getAssociatedObject(self, @selector(progressHUD));
}

- (void)showHudWithText:(NSString *)aText
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        self.progressHUD.labelText = aText;
        self.progressHUD.removeFromSuperViewOnHide = YES;
    });
}

- (void)hideHud
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressHUD hide:YES];
    });
}

+ (instancetype)viewControllerFromXib
{
    NSString* className = NSStringFromClass([self class]);
    UIViewController* vc = [[[NSBundle mainBundle] loadNibNamed:className
                                                         owner:self
                                                       options:nil] lastObject];
    
    return vc;
}

- (void)showErrorAlertWithMessage:(NSString *)aMessage
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                             message:aMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [alertController addAction:action];
    
    [self presentViewController:alertController
                       animated:YES
                     completion:nil];
}

@end
