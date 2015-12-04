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

#import "RSPhoneGapViewController.h"
#import "RSContainerViewController.h"
#import "RSTestModel.h"

@interface RSPhoneGapViewController ()
{
    BOOL mIndexFileLoaded;
    BOOL mIsFirstTest;
}

@property (nonatomic, strong) RSTestModel* testModel;
@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;

@end

@implementation RSPhoneGapViewController

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
    
    mIndexFileLoaded = NO;
    mIsFirstTest     = YES;
    
    __weak RSPhoneGapViewController* weakSelf = self;
    self.testModel = [RSTestModel new];
    
    self.testModel.loadStartedBlock = ^{
        weakSelf.activityIndicatorView.hidden = NO;
        [weakSelf.activityIndicatorView startAnimating];
    };
    
    self.testModel.loadFinishedBlock = ^{
    
        [weakSelf.activityIndicatorView stopAnimating];
        weakSelf.activityIndicatorView.hidden = YES;
        
        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
    };
    
    self.testModel.restartBlock = ^{
        
        [weakSelf.webView performSelector:@selector(loadRequest:)
                           withObject:weakSelf.webView.request
                           afterDelay:1.0];
    };
    
    self.testModel.completionBlock = ^(NSArray* aTestResults, NSArray* aSdkResults){

        RSContainerViewController* containerViewController = [RSContainerViewController new];
        containerViewController.directResults              = aTestResults;
        containerViewController.sdkResults                 = aSdkResults;
        [weakSelf.navigationController pushViewController:containerViewController animated:YES];
        
        [weakSelf.activityIndicatorView stopAnimating];
        weakSelf.activityIndicatorView.hidden = YES;
    };
    
    self.activityIndicatorView        = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.hidden = YES;
    
    [self.view addSubview:self.activityIndicatorView];
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

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    
    if (!parent)
    {
        [self.testModel setWhiteListOption:YES];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    mIsFirstTest     = YES;
    
    NSURL* URL = [self performSelector:NSSelectorFromString(@"appUrl")];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
    
    [self.webView loadRequest:request];
    
    [super viewDidDisappear:animated];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

- (BOOL)isVisible
{
    return self.navigationController.viewControllers.lastObject == self;
}

#pragma mark UIWebDelegate implementation

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    if (![self isVisible])
    {
        return;
    }
    
    if (mIndexFileLoaded)
    {
        if (mIsFirstTest)
        {
            mIsFirstTest = NO;
            
            NSString* testCount = [self.webView stringByEvaluatingJavaScriptFromString:@"getTestsCount()"];
            [self.testModel setNumberOfTests:testCount.integerValue];
            
            NSString* redirect              = [self.webView stringByEvaluatingJavaScriptFromString:@"getCheckboxValue()"];
            BOOL shouldRedirect3dPartyLinks = redirect.boolValue;
            [self.testModel setWhiteListOption:!shouldRedirect3dPartyLinks];
            
            [self.testModel start];
        }
        
        [self.testModel loadStarted];
    }
    
    [super webViewDidStartLoad:theWebView];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];
    [super webViewDidFinishLoad:theWebView];
   
    if ([self isVisible])
    {
        if (mIndexFileLoaded)
        {
            if (!theWebView.isLoading)
            {
                [self.testModel loadFinished];
            }
        }
    }
    
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
