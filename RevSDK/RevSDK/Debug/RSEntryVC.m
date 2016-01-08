//
//  RSEntryVC.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/8/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

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
