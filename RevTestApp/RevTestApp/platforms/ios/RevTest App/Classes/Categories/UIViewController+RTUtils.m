//
//  UIViewController+RTUtils.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "UIViewController+RTUtils.h"

@implementation UIViewController (RTUtils)

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
