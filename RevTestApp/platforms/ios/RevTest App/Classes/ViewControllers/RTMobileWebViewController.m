//
//  RSMobileWebViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "NSURL+RTUTils.h"

#import "RTMobileWebViewController.h"
#import "UIViewController+RTUtils.h"
#import "RTContainerViewController.h"
#import "RTReportViewController.h"

static const NSUInteger kDefaultNumberOfTests = 5;

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
    
     [self initializeTestModel];
     [self setNumberOfTests:kDefaultNumberOfTests];
    
     self.startButton.layer.cornerRadius = 8.f;
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent)
    {
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
    self.testsNumberLabel.text = [NSString stringWithFormat:@"%ld", numberOfTests];
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
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
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
        [self.webView loadRequest:request];
    }
    else
    {
        [self showErrorAlertWithMessage:@"Invalid URL"];
    }
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
    return [self shouldStartLoadingRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [self loadStarted];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        [self loadFinished];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)aError
{
    NSLog(@"Webview error %@ loading %d", aError, aWebView.isLoading);
}

@end