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


#import "RSDumpVC.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface RSDumpVC ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, copy) NSString* string;

@end

@implementation RSDumpVC

- (instancetype)initWithString:(NSString *)aString
{
    self = [super init];
    
    if (self)
    {
        _string = [aString copy];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem* sendItem = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(send)];

     self.navigationItem.rightBarButtonItem = sendItem;
    
    UITextView* textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.text = self.string;
    [self.view addSubview:textView];
}

- (void)send
{
    if (![MFMailComposeViewController canSendMail])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Can't send mail"
                                                        message:@"You need to enable at least one mail account on the device"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller setSubject:@"RevSDK Log"];
        [controller setMessageBody:self.string isHTML:NO];
        [self presentViewController:controller animated:YES completion:^{}];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(nullable NSError *)error
{
    NSLog(@"RESULT %ld Error %@", (long)result, error);
    
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
