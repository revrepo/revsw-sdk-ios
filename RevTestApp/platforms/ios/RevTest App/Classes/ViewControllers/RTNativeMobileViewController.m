//
//  RSNativeMobileViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 12/7/15.
//
//

#import "UIViewController+RTUtils.h"

#import "RTNativeMobileViewController.h"
#import "RTUtils.h"
#import "RTTestModel.h"
#import "RTContainerViewController.h"

static const NSUInteger kDefaultNumberOfTests = 5;
static const NSInteger kSchemePickerTag = 1;
static const NSInteger kMethodPickerTag = 2;
static const NSInteger kFormatPickerTag = 3;

@interface RTNativeMobileViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) UITextField* fakeTextField;
@property (nonatomic, strong) NSArray* schemes;
@property (nonatomic, strong) NSArray* methods;
@property (nonatomic, strong) NSArray* formats;
@property (nonatomic, copy) NSString* scheme;
@property (nonatomic, copy) NSString* method;
@property (nonatomic, copy) NSString* format;
@property (nonatomic, strong) RTTestModel* testModel;

@end

@implementation RTNativeMobileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.testModel = [RTTestModel new];
    
    [self.testModel setWhiteListOption:NO];
    
    self.schemes = @[@"http", @"https"];
    self.methods = @[@"GET", @"POST", @"PUT"];
    self.formats = @[@"JSON", @"XML"];
    self.scheme  = self.schemes.firstObject;
    self.method  = self.methods.firstObject;
    self.format  = self.formats.firstObject;
    
    self.navigationItem.title = @"Native Mobile";
    self.fakeTextField        = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    [self.view addSubview:self.fakeTextField];
    
    [self.testModel setNumberOfTests:kDefaultNumberOfTests];
     [[UIPickerView appearance] setBackgroundColor:[UIColor grayColor]];
    
    __weak RTNativeMobileViewController* weakSelf = self;
    
    self.testModel.loadStartedBlock = ^(NSString *aText){
        weakSelf.startButton.enabled = NO;
        [self showHudWithText:aText];
    };
    
    self.testModel.loadFinishedBlock = ^{
        
        [self hideHud];
    };
    
    self.testModel.completionBlock = ^(NSArray* aTestResults, NSArray* aSdkTestResults){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            weakSelf.startButton.enabled                       = YES;
            RTContainerViewController* containerViewController = [RTContainerViewController new];
            containerViewController.directResults              = aTestResults;
            containerViewController.sdkResults                 = aSdkTestResults;
            
            [weakSelf.navigationController pushViewController:containerViewController animated:YES];
        });
    };
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
    NSUInteger value  = (NSUInteger)aSender.value;
    BOOL isTestsCount = aSender == self.testsCountSlider;
    NSString* text    = [NSString stringWithFormat:isTestsCount ? @"%ld" : @"%ld KB", value];
    UILabel* label    = isTestsCount ? self.testsCountLabel : self.payloadSizeLabel;
    label.text        = text;
    
    if (isTestsCount)
    {
        [self.testModel setNumberOfTests:value];
    }
}

- (IBAction)start
{
    const NSUInteger kBytesInKB = 1024;
    NSString* URLString         = [NSString stringWithFormat:@"%@://%@", self.scheme, self.URLTextField.text];
    NSURL* URL                  = [NSURL URLWithString:URLString];
    NSUInteger payloadSize      = self.payloadSizeSlider.value * kBytesInKB;
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod           = self.method;
    
    if (![request.HTTPMethod isEqualToString:@"GET"])
    {
       request.HTTPBody = [RTUtils xmlDataOfSize:payloadSize];
    }
    
    __weak id weakSelf = self;
    
    self.testModel.restartBlock = ^{
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           
            [weakSelf loadRequest:request];
        });
    };
    
    [self.testModel start];
    [self loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)aRequest
{
    NSURLSession* session = [NSURLSession sharedSession];
    
    [self.testModel loadStarted];
    
    NSURLSessionTask* task = [session dataTaskWithRequest:aRequest
                                        completionHandler:^(NSData* aData, NSURLResponse* aResponse, NSError* aError){
                                            
                                            [self.testModel loadFinished];
                                        }];
    [task resume];
}

- (IBAction)schemeButtonPressed
{
    [self showPickerViewWithTag:kSchemePickerTag];
}

- (IBAction)methodButtonPressed
{
    [self showPickerViewWithTag:kMethodPickerTag];
}

- (IBAction)formatButtonPressed
{
    [self showPickerViewWithTag:kFormatPickerTag];
}

- (void)pickerDone
{
    NSArray* strings         = @[@"setScheme:", @"setMethod:", @"setFormat:"];
    NSArray* arrays          = @[self.schemes, self.methods, self.formats];
    NSArray* buttons         = @[self.schemeButton, self.methodButton, self.formatButton];
    UIPickerView* pickerView = (UIPickerView *)self.fakeTextField.inputView;
    NSArray* array           = arrays[pickerView.tag - 1];
    UIButton* button         = buttons[pickerView.tag - 1];
    NSUInteger selectedRow   = [pickerView selectedRowInComponent:0];
    NSString* text           = array[selectedRow];
    [button setTitle:text forState:UIControlStateNormal];
    
    SEL selector = NSSelectorFromString(strings[pickerView.tag - 1]);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector withObject:text];
#pragma clang diagnostic pop
    [self.fakeTextField resignFirstResponder];
}

- (void)showPickerViewWithTag:(NSInteger)aTag
{
    UIPickerView* pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource    = self;
    pickerView.delegate      = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.tag           = aTag;
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, [UIScreen mainScreen].bounds.size.width, 44)];
    [toolBar setBarStyle:UIBarStyleBlackOpaque];
    UIBarButtonItem *barButtonDone = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(pickerDone)];
    toolBar.items = @[barButtonDone];
    barButtonDone.tintColor = [UIColor blackColor];
    
    self.fakeTextField.inputView = pickerView;
    self.fakeTextField.inputAccessoryView = toolBar;
    
    [self.fakeTextField becomeFirstResponder];
    
    [[pickerView.subviews objectAtIndex:1] setHidden:TRUE];
    [[pickerView.subviews objectAtIndex:2] setHidden:TRUE];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return NO;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == kSchemePickerTag)
    {
        return self.schemes.count;
    }
    else
    if (pickerView.tag == kMethodPickerTag)
    {
        return self.methods.count;
    }
    else
    {
        return self.formats.count;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == kSchemePickerTag)
    {
        return self.schemes[row];
    }
    else
    if (pickerView.tag == kMethodPickerTag)
    {
        return self.methods[row];
    }
    else
    {
        return self.formats[row];
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
}

@end
