//
//  PickerView.m
//  RevTest App
//
//  Created by Stanislav Bessonov on 1/25/16.
//
//

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
