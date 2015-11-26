//
//  RSMobileWebViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import "RTMobileWebViewController.h"
#import "NSURL+RTUTils.h"
#import "UIViewController+RTUtils.h"

#import "objc/runtime.h"

void setBeingRemoved(BOOL removed)
{

}

@interface RTMobileWebViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>
{
    BOOL mIsPerformingTest;
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
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
    
    Class class = NSClassFromString(@"WebActionDisablingCALayerDelegate");
    class_addMethod(class, @selector(willBeRemoved), setBeingRemoved, NULL);
    class_addMethod(class, @selector(removeFromSuperview), setBeingRemoved, NULL);
    
    self.testResults = [NSMutableArray array];
    self.sdkTestResults = [NSMutableArray array];
    
    mIsPerformingTest       = NO;
    mTestsCounter           = 0;
    mNumberOfTestsToPerform = 5;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
     self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.webView.frame));
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (IBAction)start:(id)sender
{
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
    mNumberOfTestsToPerform = [self.pickerView selectedRowInComponent:0] + 6;
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
    return 15;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%ld", row + 6];
}

#pragma mark - UIWebViewDelegate

static NSDate* startDate = nil;
static BOOL isLoading = NO;

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
    if (!isLoading)
    {
        isLoading = YES;
         mIsPerformingTest = YES;
        startDate = [NSDate date];
        NSLog(@"DID START %@ %d", webView.request.URL, webView.isLoading);
        [self.activityIndicatorView startAnimating];
        self.activityIndicatorView.hidden = NO;

    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        mIsPerformingTest = NO;
        isLoading = NO;
        
        NSLog(@"DID FINISH %@ %d", webView.request, webView.isLoading);
        
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:startDate];
        startDate = nil;
        
        [self.testResults addObject:@(interval)];
        
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        
        if (mTestsCounter < mNumberOfTestsToPerform)
        {
            mTestsCounter++;
            [self performSelector:@selector(startLoading)
                       withObject:nil
                       afterDelay:1.0];
        }
        else
        {
            if (self.sdkTestResults.count == 0)
            {
                mTestsCounter = 0;
                [self performSelector:@selector(startLoading)
                           withObject:nil
                           afterDelay:1.0];
            }
            else
            {
                 NSLog(@"Test results %@", self.testResults);
                 NSLog(@"SDK Test results %@", self.sdkTestResults);
            }
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
    mIsPerformingTest = NO;
}

@end
