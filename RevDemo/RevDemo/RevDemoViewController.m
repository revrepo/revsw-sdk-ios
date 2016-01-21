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

#import "RevDemoViewController.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <RevSDK/RevSDK.h>
#import <RevSDK/RevSDKPrivate.h>

#import "MBProgressHUD.h"

@interface RevDemoViewController () <UITextFieldDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (nonatomic, strong) MBProgressHUD* hud;

@end

@implementation RevDemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [RevSDK debug_turnOnDebugBanners];
    [self reloadPage];
}

- (void)reloadPage
{
    if ([self.urlTextField.text rangeOfString:@"://"].location == NSNotFound) {
        self.urlTextField.text = [NSString stringWithFormat:@"http://%@", self.urlTextField.text];
    }
    
    NSURL *url = [NSURL URLWithString:self.urlTextField.text];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - Actions

- (IBAction)onBackButtonPressed:(id)sender
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
} // return NO to disallow editing.

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
} // became first responder

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
} // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self reloadPage];
} // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
} // return NO to not change text

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self reloadPage];
    return NO;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeReload)
    {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (!self.hud)
    {
       self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
       self.hud.labelText = @"Loading...";
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.backButton setEnabled:[webView canGoBack]];
    self.urlTextField.text = webView.request.URL.absoluteString;
    
    [self performSelector:@selector(hideHUD)
               withObject:nil
               afterDelay:2.0];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    [self performSelector:@selector(hideHUD)
               withObject:nil
               afterDelay:2.0];
}

- (void)hideHUD
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    self.hud = nil;
}

@end
