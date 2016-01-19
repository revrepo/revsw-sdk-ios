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

#import "NSURL+RTUTils.h"
#import <RevSDK/RevSDK.h>

#import "RTMobileWebViewController.h"
#import "UIViewController+RTUtils.h"
#import "RTContainerViewController.h"
#import "RTReportViewController.h"
#import "NSURLCache+ForceNoCache.h"

#import "RTHTMLGrabber.h"
#import <WebKit/WebKit.h>

static const NSUInteger kDefaultNumberOfTests = 5; 
static NSString* const kTextFieldMobileWebKey = @"tf-mw-key";
static const NSInteger kSuccessCode = 200;

@interface RTMobileWebViewController ()<UITextFieldDelegate, UIWebViewDelegate, RTHTMLGrabberDelegate /*, WKNavigationDelegate*/>

@property (nonatomic, strong) RTTestModel* testModel;
@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UITextField* fakeTextField;
@property (nonatomic, strong) RTHTMLGrabber* simpleGrabber;

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Mobile Web";
    
    self.simpleGrabber = [RTHTMLGrabber new];
    [self.simpleGrabber setDelegate:self];
    
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
        
        //[self dismissDynamicWebView];
        //[[self createDynamicWebView] loadRequest:request];
        
        [self.simpleGrabber loadRequest:request];
    }
    else
    {
        [self showErrorAlertWithMessage:@"Invalid URL"];
    }
}

- (WKWebView *)createDynamicWebView
{
    if ([self hasDynamicWebView]) {
        [self dismissDynamicWebView];
    }
    
//    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
//    WKWebView *dynamicWebView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:theConfiguration];
//    [dynamicWebView setNavigationDelegate:self];
    
    UIWebView *dynamicWebView = [[UIWebView alloc] initWithFrame:self.view.frame];
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

//#pragma mark - WKNavigationDelegate
//
//- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
//{
//    [self loadStarted];
//}
//
//- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
//{
//    if (!webView.isLoading)
//    {
//        [self didFinishLoadWithCode:kSuccessCode];
//    }
//}
//
//- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
//{
//    if (error.code == NSURLErrorCancelled) return;
//    if (!webView.isLoading)
//    {
//        NSLog(@"Webview error %@ loading %d", error, webView.isLoading);
//        [self didFinishLoadWithCode:error.code];
//    }
//}

#pragma mark - RTHTMLGrabberDelegate

- (void)grabberDidStartLoad:(RTHTMLGrabber *)grabber
{
    [self loadStarted];
}

- (void)grabberDidFinishLoad:(RTHTMLGrabber *)grabber
{
    [self didFinishLoadWithCode:kSuccessCode];
}

- (void)grabber:(RTHTMLGrabber *)grabber didFailLoadWithError:(nullable NSError *)error
{
    [self didFinishLoadWithCode:error.code];
}

@end
