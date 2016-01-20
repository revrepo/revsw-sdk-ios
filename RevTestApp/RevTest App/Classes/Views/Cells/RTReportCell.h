/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
 * All Rights Reserved.
 *
 * NOTICE:  All information contained herein is, and remains
 * the property of Rev Software, Inc. and its suppliers,
 * if any.  The intellectual and technical concepts contained
 * herein are proprietary to Rev Software, Inc.
 * and its suppliers and may be covered by U.S. and Foreign Patents,
 * patents in process, and are protected by trade secret or copyright law.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Rev Software, Inc.
 */

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
