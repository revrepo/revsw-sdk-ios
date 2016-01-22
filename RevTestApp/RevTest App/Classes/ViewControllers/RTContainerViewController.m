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

#import <MessageUI/MessageUI.h>

#import "UIViewController+RTUtils.h"

#import "RTContainerViewController.h"
#import "RTReportViewController.h"
#import "RTTestStatsViewController.h"
#import "RTUtils.h"

@interface RTContainerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) RTReportViewController* reportViewController;
@property (nonatomic, strong) RTTestStatsViewController* testStatsViewController;

@end

@implementation RTContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout               = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"Report";
    
    self.reportViewController             = [RTReportViewController viewControllerFromXib];
    self.reportViewController.urlString   = self.urlString;
    self.reportViewController.testResults = self.testResults;
    
    self.testStatsViewController             = [RTTestStatsViewController viewControllerFromXib];
    self.testStatsViewController.urlString   = self.urlString;
    self.testStatsViewController.testResults = self.testResults;
    [self.testStatsViewController prepare];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    
    [self.pageViewController setViewControllers:@[self.reportViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    
    UIBarButtonItem* emailItem = [[UIBarButtonItem alloc] initWithTitle:@"Email"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(showEmail)];
    self.navigationItem.rightBarButtonItem = emailItem;
}

- (void)processSummary
{
    
}

- (void)showEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString* formattedString = [RTUtils formattedStringFromTestResults:self.testResults];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Tests Report"];
        [mail setMessageBody:formattedString isHTML:NO];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        [self showErrorAlertWithMessage:@"Unable to send mail. Enable at least one mail account on the device"];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            [self showErrorAlertWithMessage:@"Failed to send email"];
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (viewController == self.reportViewController)
    {
        return self.testStatsViewController;
    }
    
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (viewController == self.testStatsViewController)
    {
        return self.reportViewController;
    }
    
    return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
