//
//  PickerView.h
//  RevTest App
//
//  Created by Stanislav Bessonov on 1/25/16.
//
//

#import <UIKit/UIKit.h>

@protocol PickerViewDelegate <NSObject>
@optional
- (void)pickerViewDidPressOK:(NSString*)urlString;
@end

@interface PickerView : UIView

+ (instancetype)view;

@property (nonatomic, strong) NSArray* pickerData;
@property (nonatomic, copy) NSString* urlString;
@property (weak, nonatomic) id <PickerViewDelegate> delegate;

@end
