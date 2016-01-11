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
    const NSInteger kFontSize = 15;
    self.fontSize             = kFontSize + ((kFontSize / 6) * (2 - count));
   
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    UILabel* label = [self.contentView viewWithTag:kStartLabelTag];
    
    if (!label)
    {
        label = [self addLabelWithOffsetConstant:kNumberLabelOffset
                                             tag:kStartLabelTag
                                 offsetAttribute:NSLayoutAttributeLeading];
    }
    
    label.text = aStartText;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    CGFloat addition = self.isShowingReport ? 0.f : 60.f;
    CGFloat offsetValue = self.isShowingReport ? screenWidth / 3.9f : 70.f;
    __block CGFloat constant = -offsetValue;
    
    [aTexts enumerateObjectsUsingBlock:^(NSString* text, NSUInteger index, BOOL* stop){
    
        UILabel* label = [self.contentView viewWithTag:index + 50];
        
        if (!label)
        {
            label = [self addLabelWithOffsetConstant:constant + screenWidth  * 0.5f + addition
                                                 tag:index + 50
                                     offsetAttribute:NSLayoutAttributeCenterX];
        }
        
        label.text = text;
        
        constant += offsetValue;
    }];
}

- (UILabel *)addLabelWithOffsetConstant:(CGFloat)aOffsetConstant tag:(NSInteger)aTag offsetAttribute:(NSLayoutAttribute)aAttribute
{
    UILabel* label                                  = [UILabel new];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.tag                                       = aTag;
    label.font                                      = [UIFont fontWithName:label.font.fontName size:self.fontSize];
    
    NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                         attribute:aAttribute
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.contentView
                                                                         attribute:aAttribute
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
