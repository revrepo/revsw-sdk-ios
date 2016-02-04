//
//  RSDumpVC.m
//  RevSDK
//
//  Created by Andrey Chernukha on 2/4/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import "RSDumpListVC.h"
#import "LogStorage.h"
#import "RSDumpVC.h"

@interface RSDumpListVC ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray* content;

@end

@implementation RSDumpListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Dumps";
    
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(back)];
    
    
    self.navigationItem.leftBarButtonItem  = backItem;
    
    self.content = [LogStorage allDumps];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds
                                                  style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate   = self;
    [self.view addSubview:self.tableView];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.content.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kIdentifier = @"kIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kIdentifier];
    }
    
    NSDictionary* dict = self.content[indexPath.row];
    cell.textLabel.text = dict.allKeys.firstObject;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dict = self.content[indexPath.row];
    NSString* str      = dict.allValues.firstObject;
    
    RSDumpVC* dumpVC = [[RSDumpVC alloc] initWithString:str];
    
    [self.navigationController pushViewController:dumpVC
                                         animated:YES];
}

@end
