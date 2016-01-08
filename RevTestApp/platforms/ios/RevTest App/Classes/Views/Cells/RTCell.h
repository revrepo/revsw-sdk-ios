//
//  RTCell.h
//  RevTest App
//
//  Created by Andrey Chernukha on 1/6/16.
//
//

#import <UIKit/UIKit.h>

@class RTIterationResult;

@interface RTCell : UITableViewCell

@property (nonatomic, strong) RTIterationResult* iterationResult;
@property (nonatomic, assign, getter=isShowingReport) BOOL showingReport;

- (void)setTexts:(NSArray<NSString *>*)aTexts startText:(NSString *)aStartText;

@end
