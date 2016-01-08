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
    
    NSInteger row                      = indexPath.row == 0 ? indexPath.row : indexPath.row - 1;
    RTIterationResult* iterationResult = self.testResults[row];
    NSString* propertyString           = indexPath.row == 0 ? @"nameString" : @"wholeString";
    NSString* keyPath                  = [NSString stringWithFormat:@"@unionOfObjects.%@", propertyString];
    NSArray* texts                     = [iterationResult.testResults valueForKeyPath:keyPath];
    [cell setTexts:texts number:indexPath.row];
    
    return cell;
}

@end
