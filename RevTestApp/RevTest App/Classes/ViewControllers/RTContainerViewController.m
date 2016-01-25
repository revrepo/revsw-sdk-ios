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
#import "RTIterationResult.h"
#import "NSArray+Stats.h"

@interface RTContainerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) RTReportViewController* reportViewController;
@property (nonatomic, strong) RTTestStatsViewController* testStatsViewController;
@property (nonatomic, copy) NSString* dateString;
@property (nonatomic, strong) NSArray* bigArray;
@property (nonatomic, strong) NSArray* averageSizes;

@end

@implementation RTContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout               = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"Report";
    
    NSDateFormatter* dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat       = @"MM/DD/YYYY HH:MM:SS";
    NSDate* date                   = [NSDate date];
    self.dateString                = [dateFormatter stringFromDate:date];
    
    self.reportViewController             = [RTReportViewController viewControllerFromXib];
    self.reportViewController.urlString   = self.urlString;
    self.reportViewController.testResults = self.testResults;
    
    self.testStatsViewController                   = [RTTestStatsViewController viewControllerFromXib];
    self.testStatsViewController.urlString         = self.urlString;
    self.testStatsViewController.testResults       = self.testResults;
    self.testStatsViewController.cellProcessBlocks = [self processSummary];
    
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

- (NSArray *)processSummary
{
    RTIterationResult* result = self.testResults.firstObject;
    NSUInteger count = result.testResults.count;
    NSMutableArray* bigArray = [NSMutableArray array];
    NSMutableArray* averageSizes = [NSMutableArray array];
    
    for (int i = 0; i < count; i++)
    {
        NSMutableArray* tests = [NSMutableArray array];
        
        float averageSize = 0.0f;
        int cnt = 0;
        
        for (RTIterationResult* itResult in self.testResults)
        {
            RTTestResult* tr;
            
            if (itResult.testResults.count > i)
            {
                tr = itResult.testResults[i];
            }
            else
            {
                tr = [RTTestResult new];
            }
            
            [tests addObject:@(tr.duration)];
            averageSize += tr.dataLength;
            cnt++;
        }
        
        averageSize /= cnt;
        
        [bigArray addObject:tests];
        [averageSizes addObject:@(averageSize)];
    }
    
    self.bigArray = bigArray;
    self.averageSizes = averageSizes;
    
    NSArray* cellProcessBlocks = @[
                                   
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@min.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Min:"
                                             };
                                } copy],
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@max.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Max:"
                                             };
                                } copy],
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@avg.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Average:"
                                             };
                                } copy],
                                [^NSDictionary*{
                                    
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results median];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Median:"
                                             };
                                } copy],
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results standardDeviation];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"St. deviation:"
                                             };
                                } copy],
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in self.bigArray)
                                    {
                                        NSNumber* num = [results expectedValue];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Exp. value:"
                                             };
                                    } copy],
                                [^NSDictionary*{
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSNumber* result in self.averageSizes)
                                    {
//                                        float sum = 0;
//                                        for (NSNumber* value in results)
//                                        {
//                                            sum += [value floatValue];
//                                        }
//                                        sum /= [results count];
                                        NSString* text = [NSString stringWithFormat:@"%d", (int)([result floatValue] / 1024.0f)];
                                        [texsts addObject:text];
                                    }
                                    
                                    return @{
                                             kRTTextsKey : texsts,
                                             kRTTitleKey : @"Avg. size(KB):"
                                             };
                                } copy]
                                ];

    return cellProcessBlocks;
}

- (void)showEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        NSString* title               = [NSString stringWithFormat:@"Test results for %@, %@",
                                         self.urlString, self.dateString];
        NSArray* processSummaryBlocks = [self processSummary];
        NSMutableArray* dictionaries  = [NSMutableArray array];
        
        for (NSDictionary* (^block)() in processSummaryBlocks)
        {
            NSDictionary* dictionary = block();
            [dictionaries addObject:dictionary];
        }
        
        NSString* messageBody = [RTUtils htmlStringFromTestResults:self.testResults
                                                      dictionaries:dictionaries
                                                             title:title
                                                          testType:self.testType];
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:[NSString stringWithFormat:@"Test results for %@, %@",
                          self.urlString, self.dateString]];
        [mail setToRecipients:@[@"eng@revsw.com"]];
        [mail setMessageBody:messageBody isHTML:YES];
        
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
