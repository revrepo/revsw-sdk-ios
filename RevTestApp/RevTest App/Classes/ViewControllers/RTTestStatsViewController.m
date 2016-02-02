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

#import "RTTestStatsViewController.h"
#import "RTCell.h"
#import "NSArray+Stats.h"
#import "RTUtils.h"
#import "RTIterationResult.h"
#import "RTTestResult.h"

@interface RTTestStatsViewController ()<UITableViewDataSource, UITableViewDataSource>

@end

@implementation RTTestStatsViewController

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.urlString;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    static const NSInteger kNumberOfRows = 8;
    
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kIdentifier = @"kIdentifier";
    
    RTCell* cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [[RTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
        cell.showingReport = NO;
    }
    
    if (indexPath.row == 0)
    {
        NSArray* names = [[self.testResults.firstObject testResults] valueForKeyPath:@"@unionOfObjects.testName"];
        [cell setTexts:names startText:@""];
    }
    else
    {
        NSDictionary* (^block)() =  self.cellProcessBlocks[indexPath.row - 1];
        
        if (block)
        {
            NSDictionary* cellInfo = block();
            NSArray* texts         = cellInfo[kRTTextsKey];
            NSString* startText    = cellInfo[kRTTitleKey];
            
            [cell setTexts:texts
                 startText:startText];
        }
    }
    
    return cell;
}

@end
