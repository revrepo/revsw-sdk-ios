//
//  RTCell.m
//  RevTest App
//
//  Created by Andrey Chernukha on 1/6/16.
//
//

#import "RTCell.h"
#import "RTIterationResult.h"

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
    
    UIView* lastView = nil;
    
    CGFloat constant = 50.f;
    
    for (NSString* text in aTexts)
    {
        UILabel* label = [UILabel new];
        label.text = text;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1.f
                                                                              constant:constant];
        
        NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                             attribute:NSLayoutAttributeCenterY
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:self.contentView
                                                                             attribute:NSLayoutAttributeCenterY
                                                                            multiplier:1.f
                                                                              constant:20.f];
        [self.contentView addSubview:label];
        [self.contentView addConstraints:@[leadingConstraint, centerYConstraint]];
        lastView = label;
        
        constant += 70.f;
    }
}

- (void)setNumber:(NSInteger)aNumber
{
    UILabel* label = [self.contentView viewWithTag:100];
    
     if (!label)
     {
         label = [UILabel new];
         label.translatesAutoresizingMaskIntoConstraints = NO;
         label.tag = 100;
         
         NSLayoutConstraint* leadingConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                              attribute:NSLayoutAttributeLeading
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentView
                                                                              attribute:NSLayoutAttributeLeading
                                                                             multiplier:1.f
                                                                               constant:12.f];
         
         NSLayoutConstraint* centerYConstraint = [NSLayoutConstraint constraintWithItem:label
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.contentView
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1.f
                                                                               constant:self.contentView.bounds.size.height / 2.f];
         [self.contentView addSubview:label];
         [self.contentView addConstraints:@[leadingConstraint, centerYConstraint]];
     }
    
    label.text = aNumber == 0 ? @"" : [NSString stringWithFormat:@"%ld.", aNumber];
}

@end
