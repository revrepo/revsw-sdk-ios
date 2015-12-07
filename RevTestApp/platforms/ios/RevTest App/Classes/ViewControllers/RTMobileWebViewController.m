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
@property (nonatomic, strong) UITextField* fakeTextField;
@property (nonatomic, strong) NSURLComponents* URLComponents;
@property (nonatomic, strong) NSArray* URLSchemes;

@end

@implementation RTMobileWebViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Mobile Web";
    
    self.URLComponents        = [NSURLComponents new];
    self.URLSchemes           = @[@"http", @"https"];
    self.URLComponents.scheme = self.URLSchemes[0];
    
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
    self.pickerView.showsSelectionIndicator = YES;
    
    UIToolbar *toolBar= [[UIToolbar alloc] initWithFrame:CGRectMake(0,0,320,44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(done)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    
    self.fakeTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:self.fakeTextField];
    
    self.fakeTextField.inputView = self.pickerView;
    self.fakeTextField.inputAccessoryView = toolBar;

    [[UIPickerView appearance] setBackgroundColor:[UIColor grayColor]];
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

- (IBAction)schemeButtonPressed
{
    [self.fakeTextField becomeFirstResponder];
    [[self.pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[self.pickerView.subviews objectAtIndex:2] setHidden:TRUE];
}

- (IBAction)sliderValueChanged:(UISlider *)aSender
{
    NSUInteger numberOfTests = aSender.value;
    
    [self.testModel setNumberOfTests:numberOfTests];
    self.testsNumberLabel.text = [NSString stringWithFormat:@"%ld", numberOfTests];
}

- (IBAction)start:(id)sender
{
    self.URLComponents.host = self.URLTextField.text;
    
    [self.testModel start];
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
    
    NSURL* URL = [self.URLComponents URL];
    
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
    NSString* scheme = self.URLSchemes[[self.pickerView selectedRowInComponent:0]];
    self.URLComponents.scheme = scheme;
    [self.schemeButton setTitle:scheme forState:UIControlStateNormal];
    [self.fakeTextField resignFirstResponder];
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
    return 2;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.URLSchemes[row];
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
