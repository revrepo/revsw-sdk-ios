//
//  RSLogVC.m
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/8/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "RSLogVC.h"
#import <MessageUI/MFMailComposeViewController.h>
#include "Model.hpp"
#import "RSEntryVC.h"

@interface RSLogEntry : NSObject

@property (nonatomic, readwrite, assign) rs::Log::Level level;
@property (nonatomic, readwrite, assign) int tag;
@property (nonatomic, readwrite, strong) NSString* message;

@end

@implementation RSLogEntry

@end

@interface RSLogVC()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate>

@property (nonatomic, readwrite, weak) UITableView* table;
@property (nonatomic, readwrite, strong) NSArray* content;

@end

@implementation RSLogVC

+ (NSString*)levelToString:(rs::Log::Level)aLevel
{
    switch (aLevel)
    {
        case rs::Log::Level::Error:     return @"E";
        case rs::Log::Level::Warning:   return @"W";
        case rs::Log::Level::Info:      return @"I";
    }
    return nil;
}

+ (NSString*)levelToStringFull:(rs::Log::Level)aLevel
{
    switch (aLevel)
    {
        case rs::Log::Level::Error:     return @"Error";
        case rs::Log::Level::Warning:   return @"Warning";
        case rs::Log::Level::Info:      return @"Info";
    }
    return nil;
}

+ (RSLogVC*)createNew
{
    return [[RSLogVC alloc] init];
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
    self.navigationItem.title = @"LOG";
    UIBarButtonItem* bbi = nil;
    bbi = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(onBackPressed:)];
    self.navigationItem.leftBarButtonItem = bbi;
    bbi = [[UIBarButtonItem alloc] initWithTitle:@"Send"
                                           style:UIBarButtonItemStylePlain
                                          target:self
                                          action:@selector(onFilterPressed:)];
    self.navigationItem.rightBarButtonItem = bbi;
    
    NSMutableArray* c = [NSMutableArray array];
    rs::LogTarget* lt = rs::Model::instance()->log();
    rs::LogTarget::Entry::List entries;
    rs::LogTarget::SimpleFilter filter;
    // play with filter here
    
    lt->filter(entries, &filter);
    for (const rs::LogTarget::Entry& e : entries)
    {
        RSLogEntry* entry = [[RSLogEntry alloc] init];
        entry.level = e.level();
        entry.tag = e.tag();
        entry.message = [NSString stringWithUTF8String:e.message().c_str()];
        [c addObject:entry];
    }
    
    UITableView* tv = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.table = tv;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.table];

    self.content = c;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table reloadData];
}

- (void)onFilterPressed:(id)sender
{
    if (![MFMailComposeViewController canSendMail])
    {
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSMutableArray* fileContent = [[NSMutableArray alloc] init];
        for (RSLogEntry* entry in weakSelf.content)
        {
            NSMutableString* line = [[NSMutableString alloc] initWithString:@">>> "];
            [line appendString:[RSLogVC levelToString:entry.level]];
            [line appendFormat:@"(%d)\n", entry.tag];
            [line appendString:entry.message];
            [line appendString:@"\n"];
            [fileContent addObject:line];
        }
        
        NSString* content = [fileContent componentsJoinedByString:@"\n"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
            controller.mailComposeDelegate = weakSelf;
            [controller setSubject:@"RevSDK Log"];
            [controller setMessageBody:content isHTML:NO];
            [controller setToRecipients:@[@"alex@tundramobile.com"]];
            [weakSelf presentViewController:controller animated:YES completion:^{}];
        });
    });
}

- (void)onBackPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.content.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kCellID = @"cell-id";
    
    RSLogEntry* entry = self.content[indexPath.row];
    NSString* title = [NSString stringWithFormat:@"%@|%3d\n%@",
                       [RSLogVC levelToString:entry.level],
                       entry.tag, entry.message];
    
    if (title.length > 50)
        title = [title substringToIndex:50];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellID];
    
    cell.textLabel.text = title;
    cell.textLabel.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:14.0f];
    cell.textLabel.numberOfLines = 2;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(nullable NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSEntryVC* evc = [RSEntryVC createNew];
    
    RSLogEntry* entry = self.content[indexPath.row];
    
    NSMutableString* line = [[NSMutableString alloc] init];
    [line appendString:[RSLogVC levelToStringFull:entry.level]];
    [line appendFormat:@"(%d)\n=====\n", entry.tag];
    [line appendString:entry.message];
    [line appendString:@"\n"];
    
    evc.message = line;
    [self.navigationController pushViewController:evc animated:YES];
}

@end