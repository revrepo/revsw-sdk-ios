//
//  RTStartViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "UIViewController+RTUtils.h"
#import "MainViewController.h"
#import "RTStartViewController.h"
#import "RTMobileWebViewController.h"

@implementation RTStartViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select";
}

- (IBAction)nativeMobile:(id)sender
{
    
}

- (IBAction)hybridMobile:(id)sender
{
    [self pushViewController:[MainViewController new]];
}

- (IBAction)mobileWeb:(id)sender
{
    UIViewController* startViewController = [RTMobileWebViewController viewControllerFromXib];
    [self pushViewController:startViewController];
}

- (void)pushViewController:(UIViewController *)aViewController
{
    [self.navigationController pushViewController:aViewController animated:YES];
}

@end
