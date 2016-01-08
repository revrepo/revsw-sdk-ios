//
//  RSReport2ViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RTTestStatsViewController.h"
#import "RTCell.h"
#import "NSArray+Stats.h"
#import "RTUtils.h"
#import "RTIterationResult.h"
#import "RTTestResult.h"

@interface RTTestStatsViewController ()<UITableViewDataSource, UITableViewDataSource>

@property (nonatomic, strong) NSArray* cellProcessBlocks;

@end

@implementation RTTestStatsViewController

- (void)prepare
{
    __weak RTTestStatsViewController* weakSelf = self;
    
    RTIterationResult* result = weakSelf.testResults.firstObject;
    NSUInteger count = result.testResults.count;
    NSMutableArray* bigArray = [NSMutableArray array];
    
    for (int i = 0; i < count; i++)
    {
        NSMutableArray* tests = [NSMutableArray array];
        
        for (RTIterationResult* itResult in weakSelf.testResults)
        {
            RTTestResult* tr = itResult.testResults[i];
            [tests addObject:@(tr.duration)];
        }
        
        [bigArray addObject:tests];
    }
    
    self.cellProcessBlocks = @[
                               ^(RTCell* cell){
                                   
                                   NSArray* names = [result.testResults valueForKeyPath:@"@unionOfObjects.testName"];
                                   [cell setTexts:names startText:@""];
                                   
                               },
                                ^(RTCell* cell){
                                   
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@min.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Min:"];
                                },
                                ^(RTCell* cell){
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@max.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Max:"];

                                },
                                ^(RTCell* cell){
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results valueForKeyPath:@"@avg.doubleValue"];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Average:"];
                                    
                                },
                                ^(RTCell* cell){
                                    
                                  
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results median];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];
                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Median:"];
                                },
                                ^(RTCell* cell){
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results standardDeviation];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Stand. deviation:"];
                                },
                                ^(RTCell* cell){
                                    
                                    NSMutableArray* texsts = [NSMutableArray array];
                                    
                                    for (NSArray* results in bigArray)
                                    {
                                        NSNumber* num = [results expectedValue];
                                        NSString* text = [NSString stringWithFormat:@"%.3f", num.doubleValue];
                                        [texsts addObject:text];                                    }
                                    
                                    [cell setTexts:texsts
                                         startText:@"Expected value:"];
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
    
    RTCell* cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    
    if (!cell)
    {
        cell = [[RTCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kIdentifier];
        cell.showingReport = NO;
    }
    
    void (^block)(RTCell *) = self.cellProcessBlocks[indexPath.row];
    
    if (block)
    {
       block(cell);
    }
     
    return cell;
}

@end
