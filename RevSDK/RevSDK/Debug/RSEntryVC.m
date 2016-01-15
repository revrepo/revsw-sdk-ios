/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
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

#import "RSEntryVC.h"

@interface RSEntryVC()

@property (nonatomic, readwrite, weak) UITextView* textView;

@end

@implementation RSEntryVC

+ (RSEntryVC*)createNew
{
    return [[RSEntryVC alloc] init];
}

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (void)dealloc
{
    
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"ENTRY";
    
    
    UITextView* tv = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textView = tv;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.textView];

    self.textView.text = self.message;
    self.textView.font = [UIFont fontWithName:@"Courier New" size:14.0f];
    self.textView.editable = NO;
}

@end
