//
//  RTSearchControlView.m
//  RevTest App
//
//  Created by Oleksander Mamchych on 12/22/15.
//
//

#import "RTSearchControlView.h"

@interface RTSearchControlView() <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readwrite, weak) IBOutlet UITextField* field;
@property (nonatomic, readwrite, weak) IBOutlet UITableView* table;
@property (nonatomic, readwrite, weak) IBOutlet NSLayoutConstraint* bottomTableConstraint;

@end

@implementation RTSearchControlView

+ (RTSearchControlView*)instance
{
    static RTSearchControlView* sInstance = nil;
    if (sInstance == nil)
    {
        NSAssert([[NSThread currentThread] isMainThread], @"Not a main thread");
        sInstance = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                   owner:nil
                                                 options:nil] lastObject];
    }
    return sInstance;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 24.0f;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)show
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
    [self.field becomeFirstResponder];
}

- (void)hide
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onKeyboardShown:(NSNotification*)n
{
}

- (void)onKeyboardHidden:(NSNotification*)n
{
}

@end
