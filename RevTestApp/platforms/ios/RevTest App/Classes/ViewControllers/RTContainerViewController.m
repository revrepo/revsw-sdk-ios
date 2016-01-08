//
//  RSContainerViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "UIViewController+RTUtils.h"

#import "RTContainerViewController.h"
#import "RTReportViewController.h"
#import "RTTestStatsViewController.h"

@interface RTContainerViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate>

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
    
    self.reportViewController                = [RTReportViewController viewControllerFromXib];
   /* self.reportViewController.directResults  = self.directResults;
    self.reportViewController.sdkResults     = self.sdkResults;
    self.reportViewController.dataLengths    = self.dataLengths;
    self.reportViewController.sdkDataLengths = self.sdkDataLengths;
    self.reportViewController.userInfo       = self.userInfo;
    self.reportViewController.resultSuccessFlags = self.resultSuccessFlags;
    */
    self.reportViewController.testResults = self.testResults;
    
    self.testStatsViewController = [RTTestStatsViewController viewControllerFromXib];
    
    /*self.testStatsViewController.directResults = self.directResults;
    self.testStatsViewController.sdkResults    = self.sdkResults;
    self.testStatsViewController.userInfo      = self.userInfo;
    self.testStatsViewController.resultSuccessFlags = self.resultSuccessFlags;
    */
    self.testStatsViewController.testResults = self.testResults;
    
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
