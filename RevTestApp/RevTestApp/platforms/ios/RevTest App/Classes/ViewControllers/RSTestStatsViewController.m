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

@end

@implementation RSTestStatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    
    if (indexPath.row == 0)
    {
        cell.directLabel.text = @"Direct";
        cell.sdkLabel.text    = @"SDK";
    }
    else
        if (indexPath.row == 1)
        {
            NSNumber* directMin = [self.directResults valueForKeyPath:@"@min.doubleValue"];
            NSNumber* sdkMin    = [self.sdkResults valueForKeyPath:@"@min.doubleValue"];
            
            cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directMin.doubleValue];
            cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkMin.doubleValue];
            cell.numberLabel.text = @"Min:";
        }
    else
    if (indexPath.row == 2)
    {
        NSNumber* directMax = [self.directResults valueForKeyPath:@"@max.doubleValue"];
        NSNumber* sdkMax    = [self.sdkResults valueForKeyPath:@"@max.doubleValue"];
        
        cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directMax.doubleValue];
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkMax.doubleValue];
        cell.numberLabel.text = @"Max:";
    }
    else
        if (indexPath.row == 3)
        {
            NSNumber* directAvg = [self.directResults valueForKeyPath:@"@avg.doubleValue"];
            NSNumber* sdkAvg    = [self.sdkResults valueForKeyPath:@"@avg.doubleValue"];
            
            cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directAvg.doubleValue];
            cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkAvg.doubleValue];
            cell.numberLabel.text = @"Average:";
        }
        else
            if (indexPath.row == 4)
            {
                NSNumber* directMedian = [self.directResults median];
                NSNumber* sdkMedian    = [self.sdkResults median];
                
                cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directMedian.doubleValue];
                cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkMedian.doubleValue];
                cell.numberLabel.text = @"Median:";
            }
    else
    if (indexPath.row == 5)
    {
        NSNumber* directDeviation = [self.directResults standardDeviation];
        NSNumber* sdkDeviation    = [self.sdkResults standardDeviation];
        
        cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directDeviation.doubleValue];
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkDeviation.doubleValue];
        cell.numberLabel.text = @"Stand. deviation:";
    }
    else
    if (indexPath.row == 6)
    {
        NSNumber* directExpectedValue = [self.directResults expectedValue];
        NSNumber* sdkExpectedValue    = [self.sdkResults expectedValue];
        
        cell.directLabel.text = [NSString stringWithFormat:@"%.3f", directExpectedValue.doubleValue];
        cell.sdkLabel.text    = [NSString stringWithFormat:@"%.3f", sdkExpectedValue.doubleValue];
        cell.numberLabel.text = @"Expected value:";
    }
    
    return cell;
}

@end
