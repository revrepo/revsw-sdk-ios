//
//  RSReportViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RTReportViewController.h"
#import "RTCell.h"
#import "RTUtils.h"
#import "RTIterationResult.h"

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
    }
    
    NSInteger row = indexPath.row == 0 ? indexPath.row : indexPath.row - 1;
    
    RTIterationResult* iterationResult = self.testResults[row];
    
    if (indexPath.row == 0)
    {
       NSArray* texts = [iterationResult.testResults valueForKeyPath:@"@unionOfObjects.nameString"];
       [cell setTexts:texts];
    }
    else
    {
        NSArray* durations = [iterationResult.testResults valueForKeyPath:@"@unionOfObjects.wholeString"];
        [cell setTexts:durations];
    }
    
    [cell setNumber:indexPath.row];
//    
//    if (indexPath.row == 0)
//    {
//       // NSString* sdkLabelText = self.userInfo[kRTSDKLabelTextKey];
//        
//        cell.directLabel.text = @"Current(KB)";
//        cell.sdkLabel.text    = [NSString stringWithFormat:@"%@(KB)", @"Rev"];
//    }
//    else
//    {
//       /* cell.numberLabel.text = [NSString stringWithFormat:@"%ld.", (long)indexPath.row];
//        cell.directLabel.text = [NSString stringWithFormat:@"%.3f (%.1f)", directResult.doubleValue, dataLength.floatValue];
//        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f (%.1f)", sdkResults.doubleValue, sdkDataLength.floatValue];*/
//    }
    
    /*if ([self.resultSuccessFlags count] > indexPath.row - 1)
    {
        NSNumber* numb = (NSNumber*)self.resultSuccessFlags[indexPath.row - 1];
        bool flag = ![numb boolValue];
        cell.contentView.backgroundColor = flag ? ([UIColor redColor]) : ([UIColor whiteColor]);
    }*/
    
    return cell;
}

@end
