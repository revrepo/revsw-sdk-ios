//
//  RSReportCell.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RSReportCell.h"

@implementation RSReportCell

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

@end
