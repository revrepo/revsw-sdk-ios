//
//  RSMobileWebViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "NSURL+RTUTils.h"
#import <RevSDK/RevSDK.h>

#import "RTMobileWebViewController.h"
#import "UIViewController+RTUtils.h"
#import "RTContainerViewController.h"
#import "RTReportViewController.h"
#import "NSURLCache+ForceNoCache.h"

static const NSUInteger kDefaultNumberOfTests = 5; 
static NSString* const kTextFieldMobileWebKey = @"tf-mw-key";
static const NSInteger kSuccessCode = 200;

@interface RTMobileWebViewController ()<UITextFieldDelegate, UIWebViewDelegate>

@property (nonatomic, strong) RTTestModel* testModel;
@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UITextField* fakeTextField;

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Mobile Web";
    
    __weak RTMobileWebViewController* weakSelf = self;
    
    self.loadStartedBlock = ^{
        weakSelf.startButton.enabled = NO;
    };
    
    self.restartBlock = ^{
        
            [weakSelf performSelector:@selector(startLoading)
                       withObject:nil
                       afterDelay:1.0];
    };
    
    self.completionBlock = ^{
        weakSelf.startButton.enabled = YES;
    };
    
    self.cancelBlock = ^{
        [weakSelf dismissDynamicWebView];
    };
    
     [self initializeTestModel];
     [self setNumberOfTests:kDefaultNumberOfTests];
    
     self.startButton.layer.cornerRadius = 8.f;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString* lastSearch = [ud objectForKey:kTextFieldMobileWebKey];
    
    if (lastSearch == nil)
        lastSearch = @"http://edition.cnn.com";
    
    self.URLTextField.text = lastSearch;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString* lastSearch = self.URLTextField.text;
    
    if (lastSearch == nil)
        lastSearch = @"http://edition.cnn.com";
    
    [ud setObject:lastSearch forKey:kTextFieldMobileWebKey];
    [ud synchronize];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent)
    {
        [self dismissDynamicWebView];
        [self setWhiteListOption:YES];
    }
}

#pragma mark - Actions

- (IBAction)schemeButtonPressed
{
    [self.fakeTextField becomeFirstResponder];
    [[self.pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[self.pickerView.subviews objectAtIndex:2] setHidden:TRUE];
}

- (IBAction)sliderValueChanged:(UISlider *)aSender
{
    NSUInteger numberOfTests = aSender.value;
    
    [self setNumberOfTests:numberOfTests];
    self.testsNumberLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)numberOfTests];
}

- (IBAction)start:(id)sender
{
    [self startTesting];
    [self.fakeTextField resignFirstResponder];
    [self.URLTextField resignFirstResponder];
    [self startLoading];
}

- (void)startLoading
{
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
    
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    [[NSFileManager defaultManager]removeItemAtPath:cacheDir error:nil];
    [[NSFileManager defaultManager]createDirectoryAtPath:cacheDir withIntermediateDirectories:NO attributes:nil error:nil];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    NSString* URLString = self.URLTextField.text;
    
    if (!([URLString hasPrefix:@"http://"] || [URLString hasPrefix:@"https://"]))
    {
        URLString = [@"http://" stringByAppendingString:URLString];
    }
   
    NSURL* URL = [NSURL URLWithString:URLString];
    
    if ([URL isValid])
    {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        
//        if (0 >= self.testLeftOnThisStep)
//        {
//            [self stepStarted];
//        }
        
        [self dismissDynamicWebView];
        [[self createDynamicWebView] loadRequest:request];
    }
    else
    {
        [self showErrorAlertWithMessage:@"Invalid URL"];
    }
}

- (UIWebView *)createDynamicWebView
{
    if ([self hasDynamicWebView]) {
        [self dismissDynamicWebView];
    }
    
    UIWebView *dynamicWebView  = [[UIWebView alloc] init];
    [dynamicWebView setDelegate:self];
    [dynamicWebView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.webViewContainer addSubview:dynamicWebView];
    [self.webViewContainer bringSubviewToFront:dynamicWebView];
    
    NSDictionary *metrics = @{@"lowPriority":@(UILayoutPriorityDefaultLow)};
    [self.webViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[webView]-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:@{@"webView" : dynamicWebView}]];
    
    [self.webViewContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[webView]-|"
                                                                                  options:0
                                                                                  metrics:metrics
                                                                                    views:@{@"webView" : dynamicWebView}]];
    
    [self.webViewContainer updateConstraints];
    return dynamicWebView;
}

- (void)dismissDynamicWebView
{
    while ([self hasDynamicWebView]) {
        [self.webViewContainer.subviews.firstObject removeFromSuperview];
    }
}

- (BOOL)hasDynamicWebView
{
    return ([self.webViewContainer.subviews count] > 0);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    return [self shouldStartLoadingRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [self loadStarted];
}

- (void)didFinishLoadWithCode:(NSInteger)aCode
{
    RSOperationMode mode = [RevSDK operationMode];
    
    [self loadFinished:aCode];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
    if (!aWebView.isLoading)
    {
        [self didFinishLoadWithCode:kSuccessCode];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)aError
{
    if (aError.code == NSURLErrorCancelled) return;
    if (!aWebView.isLoading)
    {
        NSLog(@"Webview error %@ loading %d", aError, aWebView.isLoading);
        [self didFinishLoadWithCode:aError.code];
    }
}

@end
