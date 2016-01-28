/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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


#import "RSMainVC.h"

static const NSUInteger kMaxIterations = 10;

@interface RSMainVC() <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>
{
    BOOL mEdgeEnabled;
}

@property (nonatomic, readwrite, weak) IBOutlet UIView* container;
@property (nonatomic, readwrite, weak) IBOutlet UIButton* btnMode;
@property (nonatomic, readwrite, weak) IBOutlet UIButton* btnGo;
@property (nonatomic, readwrite, weak) IBOutlet UITextField* inputURL;
@property (nonatomic, readwrite, weak) IBOutlet UITextField* inputKey;
@property (nonatomic, readwrite, weak) IBOutlet UITextField* inputHost;
@property (nonatomic, readwrite, weak) IBOutlet UITextView* output;
@property (nonatomic, readwrite, weak) IBOutlet UIView* overlay;

@property (nonatomic, readwrite, assign) BOOL edgeEnabled;
@property (nonatomic, readwrite, assign) NSInteger asModeOriginBtn;
@property (nonatomic, readwrite, assign) NSInteger asModeEdgeBtn;
@property (nonatomic, readwrite, assign) CFAbsoluteTime iterationStart;
@property (nonatomic, readwrite, assign) CFAbsoluteTime iterationEnd;
@property (nonatomic, readwrite, strong) NSURLRequest* request;

@property (nonatomic, readonly, strong) NSURLSession* session;
@property (nonatomic, readwrite, strong) NSMutableArray* results;
@property (nonatomic, readwrite, strong) NSMutableArray* log;

@end

@implementation RSMainVC

+ (RSMainVC*)createNew
{
    return [[RSMainVC alloc] initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
    {
        self.edgeEnabled = NO;
        self.results = [[NSMutableArray alloc] init];
        self.log = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    
}

- (NSURLSession*)session
{
    return [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    self.inputURL.text = [ud objectForKey:@"input-url"];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.inputURL)
    {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        NSString* text = self.inputURL.text;
        [ud setObject:text forKey:@"input-url"];
        [ud synchronize];
    }
    return YES;
}

- (IBAction)onModeClicked:(id)sender
{
    self.edgeEnabled = !self.edgeEnabled;
}

- (IBAction)onGoClicked:(id)sender
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSString* text = self.inputURL.text;
    [ud setObject:text forKey:@"input-url"];
    [ud synchronize];
    if (![self launchTest])
    {
        [[[UIAlertView alloc] initWithTitle:@"Error!"
                                    message:@"Invalid URL!"
                                   delegate:nil
                          cancelButtonTitle:@"ok"
                          otherButtonTitles:nil] show];
    }
}

- (void)setEdgeEnabled:(BOOL)aEnabled
{
    mEdgeEnabled = aEnabled;
    if (mEdgeEnabled)
    {
        [self.btnMode setTitle:@"Edge" forState:UIControlStateNormal];
    }
    else
    {
        [self.btnMode setTitle:@"Origin" forState:UIControlStateNormal];
    }
}

- (BOOL)edgeEnabled
{
    return mEdgeEnabled;
}

- (NSString*)getEdgeHost
{
    return (self.inputHost.text.length > 0) ? (self.inputHost.text) : (self.inputHost.placeholder);
}

- (NSString*)getSDKKey
{
    return (self.inputKey.text.length > 0) ? (self.inputKey.text) : (self.inputKey.placeholder);
}

- (BOOL)launchTest
{
    self.edgeEnabled = YES;
    
    NSString* urlString = self.inputURL.text;
    
    if (urlString == nil)
        return NO;

    NSURL* url = [NSURL URLWithString:urlString];
    if (url == nil)
        return NO;
    
    if (!([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]))
        return NO;
    
    if (url.host == nil)
        return NO;
    
    self.request = nil;
    if (self.edgeEnabled)
    {
        NSString* revHost = [self getEdgeHost];
        NSString* revKey = [self getSDKKey];
        
        if (revHost.length == 0 || revKey.length == 0)
            return NO;
        
        NSMutableURLRequest* req = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:20.0f];
        NSString* edgeURLStr = [url absoluteString];
        NSString* originalHost = url.host;
        NSString* originalScheme = url.scheme;
        NSString* hostKey = [NSString stringWithFormat:@"%@.revsdk.net", revKey];
        NSRange hostRange = [edgeURLStr rangeOfString:originalHost];
        if (hostRange.location == NSNotFound)
            return NO;
        
        edgeURLStr = [edgeURLStr stringByReplacingCharactersInRange:hostRange withString:revHost];
        NSURL* edgeURL = [NSURL URLWithString:edgeURLStr];
        if (edgeURL == nil)
            return NO;

        if ([edgeURLStr rangeOfString:@"https"].location != 0)
        {
            NSRange range = [edgeURLStr rangeOfString:@"http"];
            if (range.location != 0)
            {
                return NO;
            }
            edgeURLStr = [edgeURLStr stringByReplacingCharactersInRange:range withString:@"https"];
            edgeURL = [NSURL URLWithString:edgeURLStr];
        }

        [req setURL:edgeURL];
        [req setValue:originalHost forHTTPHeaderField:@"X-Rev-Host"];
        [req setValue:originalScheme forHTTPHeaderField:@"X-Rev-Proto"];
        [req setValue:hostKey forHTTPHeaderField:@"Host"];
        
        self.request = req;
    }
    else
    {
        self.request = [[NSURLRequest alloc] initWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:20.0f];
    }
    
    self.overlay.hidden = NO;

    [self launchTestWithURLRequest];

    return YES;
}

- (void)launchTestWithURLRequest
{
    if (self.request == nil)
    {
        self.overlay.hidden = YES;
        return;
    }
    
    [self.results removeAllObjects];
    [self clearLog];
    [self launchSingleIteration];
}

- (void)launchSingleIteration
{
    if (self.results.count >= kMaxIterations)
    {
        [self finishTest];
        return;
    }
    
    [self writeToLog:[NSString stringWithFormat:@"Iteration %@...", @(self.results.count)]];
    self.iterationStart = CFAbsoluteTimeGetCurrent();
    
    [[self.session dataTaskWithRequest:self.request
                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.iterationEnd = CFAbsoluteTimeGetCurrent();
                            float respTime = (float)(self.iterationEnd - self.iterationStart);
                            if (error == nil)
                            {
                                NSHTTPURLResponse* httpResp = (NSHTTPURLResponse*)response;
                                [self writeToLog:[NSString stringWithFormat:@"%d after %.3fs: %d bytes",
                                                  (int)httpResp.statusCode,
                                                  respTime,
                                                  (int)data.length]];
                            }
                            else
                            {
                                [self writeToLog:[NSString stringWithFormat:@"Error %@ after %.3fs",
                                                  error, respTime]];
                            }
                            [self.results addObject:@(respTime)];
                            [self launchSingleIteration];
                        });
                    }] resume];
}

- (void)finishTest
{
    self.overlay.hidden = YES;
    
    if (self.results.count != 0)
    {
        float avg = 0.0f;
        for (NSNumber* respTime in self.results)
        {
            avg += [respTime floatValue];
        }
        
        avg /= self.results.count;
        
        [self writeToLog:[NSString stringWithFormat:@"Average time: %.3fs", avg]];
    }
}

- (void)writeToLog:(NSString*)aString
{
    if (aString.length == 0)
        return;
    
    [self.log addObject:aString];
    self.output.text = [self.log componentsJoinedByString:@"\n"];
}

- (void)clearLog
{
    [self.log removeAllObjects];
    self.output.text = @"";
}

@end
