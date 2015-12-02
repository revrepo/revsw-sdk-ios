//
//  RSReportCell.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <UIKit/UIKit.h>

@interface RSReportCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* numberLabel;
@property (nonatomic, weak) IBOutlet UILabel* directLabel;
@property (nonatomic, weak) IBOutlet UILabel* sdkLabel;

+ (instancetype)cell;

@end
