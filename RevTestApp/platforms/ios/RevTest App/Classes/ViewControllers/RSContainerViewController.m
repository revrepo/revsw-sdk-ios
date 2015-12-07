//
//  RSContainerViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "UIViewController+RTUtils.h"

#import "RSContainerViewController.h"
#import "RSReportViewController.h"
#import "RSTestStatsViewController.h"

@interface RSContainerViewController ()<UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController* pageViewController;
@property (nonatomic, strong) RSReportViewController* reportViewController;
@property (nonatomic, strong) RSTestStatsViewController* testStatsViewController;

@end

@implementation RSContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout               = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.navigationItem.title = @"Report";
    
    self.reportViewController  = [RSReportViewController viewControllerFromXib];
    self.reportViewController.directResults = self.directResults;
    self.reportViewController.sdkResults = self.sdkResults;
    
    self.testStatsViewController = [RSTestStatsViewController viewControllerFromXib];
    
    self.testStatsViewController.directResults = self.directResults;
    self.testStatsViewController.sdkResults = self.sdkResults;
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                            options:nil];
    
    self.pageViewController.dataSource = self;
    
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

@end
