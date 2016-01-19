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

#import "RevStatisticsViewController.h"
#import "RevStatisticsTableViewCell.h"
#import <RevSDK/RevSDK.h>
#import <RevSDK/RevSDKPrivate.h>

@interface RevStatisticsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *statsTableView;
@property (strong, nonatomic) NSDictionary *recentStats;

@end

@implementation RevStatisticsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.recentStats = [RevSDK debug_getUsageStatistics];
    [self.statsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recentStats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RevStatisticsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RevStatisticsTableViewCell"];
    
    if (cell == nil) {
        cell = [[RevStatisticsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RevStatisticsTableViewCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSArray *keys = [[self.recentStats allKeys] sortedArrayUsingComparator:^(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    NSString *key = [keys objectAtIndex:indexPath.row];
    NSString *value = [self.recentStats objectForKey:key];
    cell.keyLabel.text = key;
    cell.valueLabel.text = value;
    return cell;
}


#pragma mark - Actions

- (IBAction)onResetButtonTapped:(id)sender
{
    [RevSDK debug_resetUsageStatistics];
    self.recentStats = [RevSDK debug_getUsageStatistics];
    [self.statsTableView reloadData];
}

@end
