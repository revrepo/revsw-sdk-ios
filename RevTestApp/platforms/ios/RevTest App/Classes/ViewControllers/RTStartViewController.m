//
//  RTStartViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "UIViewController+RTUtils.h"
#import "RTPhoneGapViewController.h"
#import "RTStartViewController.h"
#import "RTMobileWebViewController.h"
#import "RTNativeMobileViewController.h"

@implementation RTStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select";
}

- (IBAction)nativeMobile:(id)sender
{
    UIViewController* startViewController = [RTMobileWebViewController viewControllerFromXib];
    [self.navigationController pushViewController:startViewController animated:YES];

}

- (IBAction)hybridMobile:(id)sender
{
    [self.navigationController pushViewController:[RTPhoneGapViewController new] animated:YES];
}

- (IBAction)mobileWeb:(id)sender
{
    UIViewController* startViewController = [RTMobileWebViewController viewControllerFromXib];
    [self.navigationController pushViewController:startViewController animated:YES];
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
