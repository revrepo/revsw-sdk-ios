//
//  RSMobileWebViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "objc/runtime.h"

#import <RevSDK/RevSDK.h>

#import "RTMobileWebViewController.h"
#import "NSURL+RTUTils.h"
#import "UIViewController+RTUtils.h"

static const NSUInteger kDefaultNumberOfTests = 5;

id setBeingRemoved(id self, SEL selector, ...)
{
    return nil;
}

@interface RTMobileWebViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>
{
    BOOL mIsPerformingTest;
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    BOOL mIsLoading;
    NSDate* mStartDate;
}

@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* sdkTestResults;

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // in order to get rid of iOS bug. unrecognized selector exception is thrown in the WebActionDisablingCALayerDelegate private Apple class otherwise
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    Class class = NSClassFromString(@"WebActionDisablingCALayerDelegate");
    class_addMethod(class, @selector(willBeRemoved), setBeingRemoved, NULL);
    class_addMethod(class, @selector(removeFromSuperview), setBeingRemoved, NULL);
#pragma clang diagnostic pop
    
    self.testResults = [NSMutableArray array];
    self.sdkTestResults = [NSMutableArray array];
    
    mIsPerformingTest       = NO;
    mTestsCounter           = 0;
    mNumberOfTestsToPerform = self.testsTextField.text.integerValue;
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource    = self;
    self.pickerView.delegate      = self;
    self.testsTextField.inputView = self.pickerView;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(done)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
    self.testsTextField.inputAccessoryView = toolBar;
    
    self.activityIndicatorView        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidden = YES;
    
    [self.view addSubview:self.activityIndicatorView];
    
    [RevSDK setWhiteListOption:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
     self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.webView.frame));
    [super viewWillAppear:animated];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent)
    {
        [RevSDK setWhiteListOption:YES];
    }
}

#pragma mark - Actions

- (IBAction)switchValueChanged:(UISwitch*)aSender
{
    [RevSDK setWhiteListOption:!aSender.on];
}

- (IBAction)start:(id)sender
{
    mTestsCounter = 0;
    
    [RevSDK setOperationMode:kRSOperationModeOff];
    
    [self.testResults removeAllObjects];
    [self.sdkTestResults removeAllObjects];
    
    [self.URLTextField resignFirstResponder];
    [self.testsTextField resignFirstResponder];
    
    [self startLoading];
}

- (void)startLoading
{
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    [[NSURLCache sharedURLCache] setDiskCapacity:0];
    [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    
    NSString* URLString = self.URLTextField.text;
    NSURL* URL          = [NSURL URLWithString:URLString];
    
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

- (void)done
{
    mNumberOfTestsToPerform = [self.pickerView selectedRowInComponent:0] + kDefaultNumberOfTests + 1;
    self.testsTextField.text = [NSString stringWithFormat:@"%ld", mNumberOfTestsToPerform];
    [self.testsTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)aTextField
{
    [aTextField resignFirstResponder];
    
    return YES;
}

#pragma mark - UIPickerViewDelegate

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    static const NSUInteger kNumberOfRows = 15;
    
    return kNumberOfRows;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", row + kDefaultNumberOfTests + 1];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (request.URL.isValid)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!mIsLoading)
    {
        ++mTestsCounter;
     
        self.startButton.enabled          = NO;
        mIsLoading                        = YES;
        mIsPerformingTest                 = YES;
        self.activityIndicatorView.hidden = NO;
        mStartDate                        = [NSDate date];
        [self.activityIndicatorView startAnimating];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        mIsPerformingTest       = NO;
        mIsLoading              = NO;
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
        mStartDate              = nil;
        NSMutableArray* array   = [RevSDK operationMode] == kRSOperationModeOff ? self.testResults : self.sdkTestResults;
        [array addObject:@(interval)];
    
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        
        if (mTestsCounter < mNumberOfTestsToPerform)
        {
            [self performSelector:@selector(startLoading)
                       withObject:nil
                       afterDelay:1.0];
        }
        else
        {
            if (self.sdkTestResults.count == 0)
            {
                [RevSDK setOperationMode:kRSOperationModeTransport];
                
                mTestsCounter = 0;
                [self performSelector:@selector(startLoading)
                           withObject:nil
                           afterDelay:1.0];
            }
            else
            {
                self.startButton.enabled = YES;
            }
        }
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)aError
{
    NSLog(@"Webview error %@", aError);
    
   /* [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    mIsPerformingTest                 = NO;
    mIsLoading                        = NO;
    self.startButton.enabled          = YES;*/
}

@end
