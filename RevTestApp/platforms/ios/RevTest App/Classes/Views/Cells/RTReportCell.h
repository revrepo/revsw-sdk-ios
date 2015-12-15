//
//  RSReportCell.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <UIKit/UIKit.h>

@interface RTReportCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel* numberLabel;
@property (nonatomic, weak) IBOutlet UILabel* directLabel;
@property (nonatomic, weak) IBOutlet UILabel* sdkLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint* centerConstraint;

+ (instancetype)cell;
+ (instancetype)cellWithCenterOffset:(CGFloat)aOffset;
- (void)setNumberText:(NSString *)aNumberText directText:(NSString *)aDirectText sdkText:(NSString *)aSdkText;

@end
