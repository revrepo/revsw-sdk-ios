//
//  RSDumpVC.m
//  RevSDK
//
//  Created by Andrey Chernukha on 2/4/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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
    NSLog(@"RESULT %d Error %@", result, error);
    
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
