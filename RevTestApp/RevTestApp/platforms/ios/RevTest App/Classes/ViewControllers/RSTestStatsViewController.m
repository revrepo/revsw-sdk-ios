//
//  RSReport2ViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RSTestStatsViewController.h"
#import "RSReportCell.h"
#import "NSArray+Stats.h"

@interface RSTestStatsViewController ()<UITableViewDataSource, UITableViewDataSource>

@property (nonatomic, strong) NSArray* cellProcessBlocks;

@end

@implementation RSTestStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.cellProcessBlocks = @[
                               ^(RSReportCell* cell){
                                   
                                   [cell setNumberText:@""
                                            directText:@"Direct"
                                               sdkText:@"SDK"];
                               },
                                ^(RSReportCell* cell){
                                   
                                    NSNumber* directMin = [self.directResults valueForKeyPath:@"@min.doubleValue"];
                                    NSNumber* sdkMin    = [self.sdkResults valueForKeyPath:@"@min.doubleValue"];
                                    
                                    [cell setNumberText:@"Min:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMin.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMin.doubleValue]];

                                },
                                ^(RSReportCell* cell){
                                    
                                    NSNumber* directMax = [self.directResults valueForKeyPath:@"@max.doubleValue"];
                                    NSNumber* sdkMax    = [self.sdkResults valueForKeyPath:@"@max.doubleValue"];
                                    
                                    [cell setNumberText:@"Max:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMax.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMax.doubleValue]];

                                },
                                ^(RSReportCell* cell){
                                    
                                    NSNumber* directAvg = [self.directResults valueForKeyPath:@"@avg.doubleValue"];
                                    NSNumber* sdkAvg    = [self.sdkResults valueForKeyPath:@"@avg.doubleValue"];
                            
                                    [cell setNumberText:@"Average:"
                                             directText:[NSString stringWithFormat:@"%.3f", directAvg.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkAvg.doubleValue]];
                                    
                                },
                                ^(RSReportCell* cell){
                                    
                                    NSNumber* directMedian = [self.directResults median];
                                    NSNumber* sdkMedian    = [self.sdkResults median];
                                    
                                    [cell setNumberText:@"Median:"
                                             directText:[NSString stringWithFormat:@"%.3f", directMedian.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkMedian.doubleValue]];
                                },
                                ^(RSReportCell* cell){
                                    
                                    NSNumber* directDeviation = [self.directResults standardDeviation];
                                    NSNumber* sdkDeviation    = [self.sdkResults standardDeviation];
                                    
                                    [cell setNumberText:@"Stand. deviation:"
                                             directText:[NSString stringWithFormat:@"%.3f", directDeviation.doubleValue]
                                                sdkText:[NSString stringWithFormat:@"%.3f", sdkDeviation.doubleValue]];
                                },
                                ^(RSReportCell* cell){
                                    
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
    
    RSReportCell* cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [RSReportCell cell];
    }
    
    void (^block)(RSReportCell *) = self.cellProcessBlocks[indexPath.row];
    block(cell);
    
    return cell;
}

@end
