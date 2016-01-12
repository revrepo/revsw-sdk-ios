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

@interface RSLogVC()<UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
{
    NSUInteger mDomain;
    NSUInteger mLevel;
}

@property (nonatomic, readwrite, weak) UITableView* table;
@property (nonatomic, readwrite, strong) UIBarButtonItem* domainButton;
@property (nonatomic, readwrite, strong) UIBarButtonItem* levelButton;
@property (nonatomic, readwrite, strong) NSArray* content;
@property (nonatomic, readwrite, strong) NSArray* domains;
@property (nonatomic, readwrite, strong) NSArray* levels;
@property (nonatomic, readwrite, strong) UIActionSheet* domainPicker;
@property (nonatomic, readwrite, strong) UIActionSheet* levelPicker;


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

- (UIToolbar*)createToolbar
{
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.domainButton = [[UIBarButtonItem alloc] initWithTitle:@"Domain"
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(onDomainClicked:)];
    self.levelButton = [[UIBarButtonItem alloc] initWithTitle:@"Level"
                                                        style:UIBarButtonItemStylePlain
                                                       target:self
                                                       action:@selector(onLevelClicked:)];
    [toolbar setItems:@[self.domainButton, self.levelButton]];
    return toolbar;
}

- (void)applyDomainAndLevel
{
    NSMutableArray* c = [NSMutableArray array];
    rs::LogTarget* lt = rs::Model::instance()->log();
    rs::LogTarget::Entry::List entries;
    rs::LogTarget::SimpleFilter filter;
    rs::LogTarget::SimpleFilter::TagList tags;
    switch (mDomain)
    {
        case 0: // ANY
            break;
        case 1: // QUIC
            for (int i = rs::kLogTagQUICMIN; i <= rs::kLogTagQUICMAX; ++i)
                tags.insert(i);
            break;
        case 2: // STD
            for (int i = rs::kLogTagSTDMIN; i <= rs::kLogTagSTDMAX; ++i)
                tags.insert(i);
            break;
        case 3: // SDK
            for (int i = rs::kLogTagSDKMIN; i <= rs::kLogTagSDKMAX; ++i)
                tags.insert(i);
            break;
        case 4: // Performance
            for (int i = rs::kLogTagPerfMIN; i <= rs::kLogTagPerfMAX; ++i)
                tags.insert(i);
            break;
        default:
            break;
    }
    filter.setTags(tags);
    // play with filter here

    switch (mLevel)
    {
        case 0: // ALL
            filter.setLevels(true, true, true);
            break;
        case 1: // I
            filter.setLevels(false, false, true);
            break;
        case 2: // W
            filter.setLevels(false, true, false);
            break;
        case 3: // E
            filter.setLevels(true, false, false);
            break;
            
        default:
            break;
    }
    
    lt->filter(entries, &filter);
    for (const rs::LogTarget::Entry& e : entries)
    {
        RSLogEntry* entry = [[RSLogEntry alloc] init];
        entry.level = e.level();
        entry.tag = e.tag();
        entry.message = [NSString stringWithUTF8String:e.message().c_str()];
        [c addObject:entry];
    }

    self.content = c;
    [self.table reloadData];
    
    self.domainButton.title = self.domains[mDomain];
    self.levelButton.title = self.levels[mLevel];
}

- (void)onDomainClicked:(id)sender
{
    self.domainPicker = [[UIActionSheet alloc] init];
    [self.domainPicker setTitle:@"Pick domain"];
    [self.domainPicker addButtonWithTitle:@"ANY"];
    [self.domainPicker addButtonWithTitle:@"QUIC"];
    [self.domainPicker addButtonWithTitle:@"STD"];
    [self.domainPicker addButtonWithTitle:@"SDK"];
    [self.domainPicker addButtonWithTitle:@"Performance"];
    NSInteger cb = [self.domainPicker addButtonWithTitle:@"Cancel"];
    self.domainPicker.cancelButtonIndex = cb;
    self.domainPicker.delegate = self;
    [self.domainPicker showInView:self.view];
}

- (void)onLevelClicked:(id)sender
{
    self.levelPicker = [[UIActionSheet alloc] init];
    [self.levelPicker setTitle:@"Pick log level"];
    [self.levelPicker addButtonWithTitle:@"ALL"];
    [self.levelPicker addButtonWithTitle:@"Info"];
    [self.levelPicker addButtonWithTitle:@"Warning"];
    [self.levelPicker addButtonWithTitle:@"Error"];
    NSInteger cb = [self.levelPicker addButtonWithTitle:@"Cancel"];
    self.levelPicker.cancelButtonIndex = cb;
    self.levelPicker.delegate = self;
    [self.levelPicker showInView:self.view];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.levels = @[@"ALL", @"INF", @"WRN", @"ERR"];
    self.domains = @[@"ANY", @"QUIC", @"STD", @"SDK", @"Perf"];
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

    UITableView* tv = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.table = tv;
    self.table.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.table];

    self.table.delegate = self;
    self.table.dataSource = self;
    [self.table reloadData];
    [self.view addSubview:[self createToolbar]];

    [self applyDomainAndLevel];
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
    NSString* title = [NSString stringWithFormat:@"%@|%3d -> %@",
                       [RSLogVC levelToString:entry.level],
                       entry.tag, entry.message];
    
    if (title.length > 80)
        title = [title substringToIndex:80];
    
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

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
        return;
    
    if (actionSheet == self.domainPicker)
    {
        mDomain = buttonIndex;
        [self applyDomainAndLevel];
    }
    else if (actionSheet == self.levelPicker)
    {
        mLevel = buttonIndex;
        [self applyDomainAndLevel];
    }
}

@end