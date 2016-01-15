//
//  RTStartViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "UIViewController+RTUtils.h"
#import "RTStartViewController.h"
#import "RTMobileWebViewController.h"
#import "RTNativeMobileViewController.h"
#import <RevSDK/RevSDK.h>

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
    UIViewController* startViewController = [RTMobileWebViewController viewControllerFromXib];
    [self.navigationController pushViewController:startViewController animated:YES];
}

- (void)onLogPressed:(id)sender
{
   // [RevSDK debug_showLogInViewController:self];
    
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
