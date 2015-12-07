//
//  RSReport2ViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RTTestStatsViewController.h"
#import "RTReportCell.h"
#import "NSArray+Stats.h"

@interface RTTestStatsViewController ()<UITableViewDataSource, UITableViewDataSource>

@property (nonatomic, strong) NSArray* cellProcessBlocks;

@end

@implementation RTTestStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cellProcessBlocks = @[
                               ^(RTReportCell* cell){
                                   
                                   [cell setNumberText:@""
                                            directText:@"Direct"
                                               sdkText:@"SDK"];
                               },
                                ^(RTReportCell* cell){
                                   
                                    NSNumber* directMin = [self.directResults valueForKeyPath:@"@min.doubleValue"];
                                    NSNumber* sdkMin    = [self.sdkResults valueForKeyPath:@"@min.doubleValue"];
                                    
                                    [cell setNumberText:@"Min:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMin.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMin.doubleValue]];

                                },
                                ^(RTReportCell* cell){
                                    
                                    NSNumber* directMax = [self.directResults valueForKeyPath:@"@max.doubleValue"];
                                    NSNumber* sdkMax    = [self.sdkResults valueForKeyPath:@"@max.doubleValue"];
                                    
                                    [cell setNumberText:@"Max:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMax.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMax.doubleValue]];

                                },
                                ^(RTReportCell* cell){
                                    
                                    NSNumber* directAvg = [self.directResults valueForKeyPath:@"@avg.doubleValue"];
                                    NSNumber* sdkAvg    = [self.sdkResults valueForKeyPath:@"@avg.doubleValue"];
                            
                                    [cell setNumberText:@"Average:"
                                             directText:[NSString stringWithFormat:@"%.3f", directAvg.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkAvg.doubleValue]];
                                    
                                },
                                ^(RTReportCell* cell){
                                    
                                    NSNumber* directMedian = [self.directResults median];
                                    NSNumber* sdkMedian    = [self.sdkResults median];
                                    
                                    [cell setNumberText:@"Median:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMedian.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMedian.doubleValue]];
                                },
                                ^(RTReportCell* cell){
                                    
                                    NSNumber* directDeviation = [self.directResults standardDeviation];
                                    NSNumber* sdkDeviation    = [self.sdkResults standardDeviation];
                                    
                                    [cell setNumberText:@"Stand. deviation:"
                                             directText:[NSString stringWithFormat:@"%.3f", directDeviation.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkDeviation.doubleValue]];
                                },
                                ^(RTReportCell* cell){
                                    
                                    NSNumber* directExpectedValue = [self.directResults expectedValue];
                                    NSNumber* sdkExpectedValue    = [self.sdkResults expectedValue];
                                    
                                    [cell setNumberText:@"Expected value:"
                                             directText:[NSString stringWithFormat:@"%.3f", directExpectedValue.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkExpectedValue.doubleValue]];
                                }
                               
                               ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    static const NSInteger kNumberOfRows = 7;
    
    return kNumberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* const kIdentifier = @"kIdentifier";
    
    RTReportCell* cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [RTReportCell cell];
    }
    
    void (^block)(RTReportCell *) = self.cellProcessBlocks[indexPath.row];
    block(cell);
    
    return cell;
}

@end
