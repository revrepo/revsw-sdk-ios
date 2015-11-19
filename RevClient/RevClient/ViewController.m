//
//  ViewController.m
//  RevClient
//
//  Created by Andrey Chernukha on 11/16/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIWebViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, copy) NSString* currentURLString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.currentURLString = @"https://apple.com";
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
    [self.view addSubview:self.activityIndicatorView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.textField.text = self.currentURLString;
    
    [self startLoading];
}

- (IBAction)start
{
    [self.textField resignFirstResponder];
    self.currentURLString = self.textField.text;
    [self startLoading];
}

- (void)startLoading
{
    [self.webView stopLoading];
    
    self.currentURLString = [self.currentURLString lowercaseString];
    self.currentURLString = [self.currentURLString stringByReplacingOccurrencesOfString:@"http://" withString:@"https://"];
    self.textField.text = self.currentURLString;
    
    NSURL* URL = [NSURL URLWithString:self.currentURLString];
    
    if ([self isURLValid:URL])
    {
        NSURLRequest* request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    else
    {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                 message:@"URL not valid"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* action = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction* action){}];
        [alertController addAction:action];
        
        [self presentViewController:alertController
                           animated:YES
                         completion:nil];
    }
}

- (BOOL)isURLValid:(NSURL*)aURL
{
    return aURL && aURL.scheme && aURL.host;
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.activityIndicatorView.hidden = NO;
    [self.activityIndicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"ERROR %@", error);
    
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

@end
