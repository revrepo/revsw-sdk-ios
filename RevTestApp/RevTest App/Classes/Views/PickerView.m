/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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


#import "PickerView.h"

@interface PickerView() <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@end

@implementation PickerView

+ (instancetype)view
{
    return [[NSBundle.mainBundle loadNibNamed:NSStringFromClass(self.class) owner:nil options:nil] firstObject];
}

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor grayColor];
    self.pickerView.backgroundColor = [UIColor grayColor];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
}

- (void)layoutSubviews
{

}

- (NSInteger)numberOfComponentsInPickerView: (UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.pickerData count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.pickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.urlString = [self.pickerData objectAtIndex:[self.pickerView selectedRowInComponent:0]];
}

- (IBAction)onOkPressed:(id)sender
{
    [self.delegate pickerViewDidPressOK:self.urlString];
}

@end
