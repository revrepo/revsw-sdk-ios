//
//  RSReportViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RTReportViewController.h"
#import "RTReportCell.h"
#import "RTUtils.h"

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
    return [self.directResults count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kIdentifier = @"kIdentifier";
    
    RTReportCell* cell = (RTReportCell *)[tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [RTReportCell cellWithCenterOffset:-70.f];
    }
    
    if (indexPath.row == 0)
    {
        NSString* sdkLabelText = self.userInfo[kRTSDKLabelTextKey];
        
        cell.directLabel.text = @"Current(KB)";
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%@(KB)", sdkLabelText];
    }
    else
    {
        NSNumber* directResult  = self.directResults[indexPath.row - 1];
        NSNumber* sdkResults    = self.sdkResults[indexPath.row - 1];
        NSNumber* dataLength    = self.dataLengths[indexPath.row - 1];
        NSNumber* sdkDataLength = self.sdkDataLengths[indexPath.row - 1];
        
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld.", (long)indexPath.row];
        cell.directLabel.text = [NSString stringWithFormat:@"%.3f (%.2f)", directResult.doubleValue, dataLength.floatValue];
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f (%.2f)", sdkResults.doubleValue, sdkDataLength.floatValue];
    }
    
    return cell;
}

@end
