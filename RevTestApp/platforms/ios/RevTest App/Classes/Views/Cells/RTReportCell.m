//
//  RSReportCell.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

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

- (void)setNumberText:(NSString *)aNumberText directText:(NSString *)aDirectText sdkText:(NSString *)aSdkText
{
    self.numberLabel.text = aNumberText;
    self.directLabel.text = aDirectText;
    self.sdkLabel.text    = aSdkText;
}

@end
