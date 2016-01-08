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

#define kStartLabelTag 100
#define kNumberLabelOffset 16.f

@interface RTCell ()

@property (nonatomic, assign) NSInteger fontSize;

@end

@implementation RTCell

- (void)setTexts:(NSArray<NSString *> *)aTexts startText:(NSString *)aStartText
{
    NSUInteger    count       = aTexts.count;
    const NSInteger kFontSize = 16;
    self.fontSize             = kFontSize + ((kFontSize / 6) * (2 - count));
   
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel* label = [self.contentView viewWithTag:kStartLabelTag];
    
    if (!label)
    {
        label = [self addLabelWithOffsetConstant:kNumberLabelOffset tag:kStartLabelTag];
    }
    
    label.text = aStartText;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    const NSInteger kDefaultDivider = 6;
    NSInteger divider = kDefaultDivider - ((kDefaultDivider / 3) * (2 - count));
    
    __block CGFloat constant = screenWidth / (self.isShowingReport ? divider : 2);
    
    divider /= (self.isShowingReport ? 2 : 1);
    
    [aTexts enumerateObjectsUsingBlock:^(NSString* text, NSUInteger index, BOOL* stop){
    
        UILabel* label = [self.contentView viewWithTag:index + 50];
        
        if (!label)
        {
            label = [self addLabelWithOffsetConstant:constant tag:index + 50];
        }
        
        label.text = text;
        
        CGFloat correctedDivider = divider;
        correctedDivider *= 0.9;
        constant += screenWidth / correctedDivider;
    }];
}

- (UILabel *)addLabelWithOffsetConstant:(CGFloat)aOffsetConstant tag:(NSInteger)aTag
{
    UILabel* label                                  = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.tag                                       = aTag;
    label.font                                      = [UIFont fontWithName:label.font.fontName size:self.fontSize];
    
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
