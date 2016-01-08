//
//  RTCell.m
//  RevTest App
//
//  Created by Andrey Chernukha on 1/6/16.
//
//

#import "RTCell.h"
#import "RTIterationResult.h"
#import "RTUtils.h"

@implementation RTCell

- (void)setTexts:(NSArray<NSString *> *)aTexts
{
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSArray *viewsToRemove = [self.contentView subviews];
    
    for (UIView *v in viewsToRemove)
    {
        if (v.tag != 100)
        {
           [v removeFromSuperview];
        }
    }
    
    CGFloat constant = 50.f;
    
    for (NSString* text in aTexts)
    {
        UILabel* label = [self addLabelWithOffsetConstant:constant tag:0];
        label.text = text;
        constant += 70.f;
    }
}

- (void)setNumber:(NSInteger)aNumber
{
    UILabel* label = [self.contentView viewWithTag:100];
    
     if (!label)
     {
        label = [self addLabelWithOffsetConstant:12.f tag:100];
     }
    
    label.text = aNumber == 0 ? @"" : [NSString stringWithFormat:@"%ld.", aNumber];
}

- (UILabel *)addLabelWithOffsetConstant:(CGFloat)aOffsetConstant tag:(NSInteger)aTag
{
    UILabel* label                                  = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.tag                                       = aTag;
    
    NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.f
                                                                          constant:aOffsetConstant];
    
    NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.f
                                                                          constant:kRTRowHeight / 2.f];
    [self.contentView addSubview:label];
    [self.contentView addConstraints:@[leadingConstraint, centerYConstraint]];
    
    return label;
}

@end
