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
#import "RSContainerViewController.h"
#import "RSReportViewController.h"
#import "RSTestModel.h"

static const NSUInteger kDefaultNumberOfTests = 5;

@interface RTMobileWebViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) RSTestModel* testModel;
@property (nonatomic, strong) UIPickerView* pickerView;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak RTMobileWebViewController* weakSelf = self;
    
    self.testModel = [RSTestModel new];
    self.testModel.loadStartedBlock = ^{
        weakSelf.startButton.enabled          = NO;
        weakSelf.activityIndicatorView.hidden = NO;
        [weakSelf.activityIndicatorView startAnimating];
    };
    
    self.testModel.loadFinishedBlock = ^{
        [weakSelf.activityIndicatorView stopAnimating];
         weakSelf.activityIndicatorView.hidden = YES;
    };
    
    self.testModel.restartBlock = ^{
        [weakSelf performSelector:@selector(startLoading)
                       withObject:nil
                       afterDelay:1.0];
    };
    
    self.testModel.completionBlock = ^(NSArray* aTestResults, NSArray* aSdkTestResults){
    
        weakSelf.startButton.enabled                       = YES;
        RSContainerViewController* containerViewController = [RSContainerViewController new];
        containerViewController.directResults              = aTestResults;
        containerViewController.sdkResults                 = aSdkTestResults;
        
        [weakSelf.navigationController pushViewController:containerViewController animated:YES];
    };
    
    NSUInteger numberOfTests = self.testsTextField.text.integerValue;
    [self.testModel setNumberOfTests:numberOfTests];
    
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

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent)
    {
        [self.testModel setWhiteListOption:YES];
    }
}

#pragma mark - Actions

- (IBAction)switchValueChanged:(UISwitch*)aSender
{
    [self.testModel setWhiteListOption:!aSender.on];
}

- (IBAction)start:(id)sender
{
    [self.testModel start];
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
    NSUInteger numberOfTests = [self.pickerView selectedRowInComponent:0] + kDefaultNumberOfTests + 1;
    [self.testModel setNumberOfTests:numberOfTests];
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
    return request.URL.isValid;
}

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
    [self.testModel loadStarted];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (!webView.isLoading)
    {
        NSLog(@"Finish");
        
        [self.testModel loadFinished];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)aError
{
    NSLog(@"Webview error %@", aError);
}

@end
