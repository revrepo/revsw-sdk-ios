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

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak RTMobileWebViewController* weakSelf = self;
    
    self.testModel = [RSTestModel new];
    self.testModel.loadStartedBlock = ^{
        weakSelf.startButton.enabled = NO;
    };
    
    self.testModel.loadFinishedBlock = ^{
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
    
    [self.testModel setNumberOfTests:kDefaultNumberOfTests];
    
    self.pickerView = [[UIPickerView alloc] init];
    self.pickerView.dataSource    = self;
    self.pickerView.delegate      = self;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(done)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor=[UIColor blackColor];
}

- (void)viewWillAppear:(BOOL)animated
{
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

- (IBAction)sliderValueChanged:(UISlider *)aSender
{
    NSUInteger numberOfTests = aSender.value;
    
    [self.testModel setNumberOfTests:numberOfTests];
    self.testsNumberLabel.text = [NSString stringWithFormat:@"%ld", numberOfTests];
}

- (IBAction)start:(id)sender
{
    [self.testModel start];
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
        [self.testModel loadFinished];
    }
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)aError
{
    NSLog(@"Webview error %@", aError);
}

@end
