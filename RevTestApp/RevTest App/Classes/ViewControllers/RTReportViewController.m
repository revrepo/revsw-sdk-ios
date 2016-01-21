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

#import "RTReportViewController.h"
#import "RTCell.h"
#import "RTUtils.h"
#import "RTIterationResult.h"
#import "UIViewController+RTUtils.h"

@interface RTReportViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation RTReportViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.testResults count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRTRowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kIdentifier = @"kIdentifier";
    
    RTCell* cell = (RTCell *)[tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [[RTCell alloc] initWithStyle:UITableViewCellStyleDefault
                             reuseIdentifier:kIdentifier];
        
        cell.showingReport = YES;
    }
    
    NSInteger row                      = indexPath.row == 0 ? indexPath.row : indexPath.row - 1;
    RTIterationResult* iterationResult = self.testResults[row];
    NSString* propertyString           = indexPath.row == 0 ? @"nameString" : @"wholeString";
    NSString* keyPath                  = [NSString stringWithFormat:@"@unionOfObjects.%@", propertyString];
    NSArray* texts                     = [iterationResult.testResults valueForKeyPath:keyPath];
    NSString* startString              = indexPath.row == 0 ? @"" : [NSString stringWithFormat:@"%ld.", indexPath.row];
    [cell setTexts:texts startText:startString];
    
    
    cell.contentView.backgroundColor = iterationResult.valid || indexPath.row == 0 ? [UIColor whiteColor] : [UIColor redColor];
    
    return cell;
}

@end
