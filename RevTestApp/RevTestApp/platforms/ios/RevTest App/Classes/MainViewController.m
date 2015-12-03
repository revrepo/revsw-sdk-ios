/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  MainViewController.h
//  RevTest App
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import <RevsdK/RevSDk.h>

#import "MainViewController.h"
#import "RSContainerViewController.h"

@interface MainViewController ()
{
    BOOL mIsLoading;
    BOOL mIndexFileLoaded;
    NSUInteger mTestsCounter;
    NSUInteger mNumberOfTestsToPerform;
    NSDate* mStartDate;
}

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) NSMutableArray* testResults;
@property (nonatomic, strong) NSMutableArray* sdkTestResults;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    self.activityIndicatorView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.webView.frame));
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [RevSDK setOperationMode:kRSOperationModeOff];
    
    mStartDate       = nil;
    mIsLoading       = NO;
    mIndexFileLoaded = NO;
    mTestsCounter    = 0;
    
    self.testResults    = [NSMutableArray array];
    self.sdkTestResults = [NSMutableArray array];
    
    self.activityIndicatorView        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidden = YES;
    
    [self.view addSubview:self.activityIndicatorView];
    [RevSDK setWhiteListOption:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

#pragma mark UIWebDelegate implementation

static int start_counter;
static int finish_counter;

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    if (mIndexFileLoaded)
    {
        if (!mIsLoading)
        {
            NSLog(@"START %d", ++start_counter);
            
            if (mTestsCounter == 0 && self.testResults.count == 0)
            {
                NSString* testCount     = [self.webView stringByEvaluatingJavaScriptFromString:@"getTestsCount()"];
                mNumberOfTestsToPerform = testCount.integerValue;
                
                NSString* redirect              = [self.webView stringByEvaluatingJavaScriptFromString:@"getCheckboxValue()"];
                BOOL shouldRedirect3dPartyLinks = redirect.boolValue;
                [RevSDK setWhiteListOption:!shouldRedirect3dPartyLinks];
            }
            
            ++mTestsCounter;
            mStartDate = [NSDate date];
            mIsLoading = YES;
            
            self.activityIndicatorView.hidden = NO;
            [self.activityIndicatorView startAnimating];
        }
    }
    
    [super webViewDidStartLoad:theWebView];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];
    [super webViewDidFinishLoad:theWebView];
    
    if (mIndexFileLoaded)
    {
        if (!theWebView.isLoading)
        {
            NSLog(@"FINISH %d MODE %d", ++finish_counter, [RevSDK operationMode]);
            
            mIsLoading = NO;
            
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
            
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:mStartDate];
            NSMutableArray* array   = [RevSDK operationMode] == kRSOperationModeOff ? self.testResults : self.sdkTestResults;
            [array addObject:@(interval)];
            
            [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
            [[NSURLCache sharedURLCache] removeAllCachedResponses];
            [[NSURLCache sharedURLCache] setDiskCapacity:0];
            [[NSURLCache sharedURLCache] setMemoryCapacity:0];
            
            if (mTestsCounter < mNumberOfTestsToPerform)
            {
                [self.webView performSelector:@selector(loadRequest:)
                                   withObject:self.webView.request
                                   afterDelay:1.0];
            }
            else
            {
                if (self.sdkTestResults.count == 0)
                {
                    [RevSDK setOperationMode:kRSOperationModeTransport];
                    
                    mTestsCounter = 0;
                    [[NSURLCache sharedURLCache] removeAllCachedResponses];
                    [self.webView performSelector:@selector(loadRequest:)
                                       withObject:self.webView.request
                                       afterDelay:1.0];
                }
                else
                {
                    RSContainerViewController* containerViewController = [RSContainerViewController new];
                    containerViewController.directResults = self.testResults;
                    containerViewController.sdkResults = self.sdkTestResults;
                    
                    [self.navigationController pushViewController:containerViewController animated:YES];
                    
                }
            }
        }
    }
    
   // NSLog(@"Results %@ sdk Results %@", self.testResults, self.sdkTestResults);
    
    if (!mIndexFileLoaded)
    {
        mIndexFileLoaded = YES;
    }
}

/* Comment out the block below to over-ride */

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    NSLog(@"WEB VIEW ERROR %@ loading %d", error, theWebView.isLoading);
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
  //  [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    
    return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}

@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
