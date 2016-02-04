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
#import "RTStartViewController.h"
#import "RTMobileWebViewController.h"
#import "RTNativeMobileViewController.h"
#import <RevSDK/RevSDK.h>
#import "RTRequestTestLoop.h"

@interface RTStartViewController ()

@property (nonatomic, strong) RTRequestTestLoop* testLoop;

@end

@implementation RTStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([RevSDK respondsToSelector:@selector(debug_turnOnDebugBanners)])
    {
        [[RevSDK class] performSelector:@selector(debug_turnOnDebugBanners)];
    }
    
    self.navigationItem.title = @"Select";
    
    UIBarButtonItem* rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                                                          target:self
                                                                          action:@selector(onLogPressed:)];
    self.navigationItem.rightBarButtonItem = rbbi;
}

- (IBAction)nativeMobile:(id)sender
{
    UIViewController* startViewController = [RTNativeMobileViewController viewControllerFromXib];
    [self.navigationController pushViewController:startViewController animated:YES];

}

- (IBAction)hybridMobile:(id)sender
{
    //[self.navigationController pushViewController:[RTPhoneGapViewController new] animated:YES];
}

- (IBAction)mobileWeb:(id)sender
{
    self.testLoop = [RTRequestTestLoop defaultTestLoop];
    [self.testLoop start];
    
    //UIViewController* startViewController = [RTMobileWebViewController viewControllerFromXib];
    //[self.navigationController pushViewController:startViewController animated:YES];
}

- (void)onLogPressed:(id)sender
{
    if ([RevSDK respondsToSelector:@selector(debug_showLogInViewController:)])
    {
        [[RevSDK class] performSelector:@selector(debug_showLogInViewController:) withObject:self];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
