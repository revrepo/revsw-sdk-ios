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

#import "UIViewController+RTUtils.h"

@implementation UIViewController (RTUtils)

+ (instancetype)viewControllerFromXib
{
    NSString* className  = NSStringFromClass([self class]);
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
