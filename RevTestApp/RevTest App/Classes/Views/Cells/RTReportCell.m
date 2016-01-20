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

#import "RTReportCell.h"

@implementation RTReportCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.directLabel.text = @"";
    self.sdkLabel.text    = @"";
    self.numberLabel.text = @"";
}

+ (instancetype)cell
{
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                         owner:self
                                       options:nil][0];
}

+ (instancetype)cellWithCenterOffset:(CGFloat)aOffset
{
    RTReportCell* cell = [self cell];
    cell.centerConstraint.constant += aOffset;
    return cell;
}

- (void)setNumberText:(NSString *)aNumberText directText:(NSString *)aDirectText sdkText:(NSString *)aSdkText
{
    self.numberLabel.text = aNumberText;
    self.directLabel.text = aDirectText;
    self.sdkLabel.text    = aSdkText;
}

@end
