//
//  RSReportViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RSReportViewController.h"

#import "RSReportCell.h"

@interface RSReportViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation RSReportViewController

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
    
    RSReportCell* cell = (RSReportCell *)[tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [RSReportCell cell];
    }
    
    if (indexPath.row == 0)
    {
        cell.directLabel.text = @"Direct";
        cell.sdkLabel.text    = @"SDK";
    }
    else
    {
        NSNumber* directResult = self.directResults[indexPath.row - 1];
        NSNumber* sdkResults   = self.sdkResults[indexPath.row - 1];
        
        cell.numberLabel.text = [NSString stringWithFormat:@"%ld.", indexPath.row];
        cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directResult.doubleValue];
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkResults.doubleValue];
    }
    
    return cell;
}

@end
