//
//  RSNativeMobileViewController.h
//  RevTest App
//
//  Created by Andrey Chernukha on 12/7/15.
//
//

#import <UIKit/UIKit.h>

@interface RTNativeMobileViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField* URLTextField;
@property (nonatomic, weak) IBOutlet UILabel* testsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel* payloadSizeLabel;
@property (nonatomic, weak) IBOutlet UISlider* testsCountSlider;
@property (nonatomic, weak) IBOutlet UISlider* payloadSizeSlider;
@property (nonatomic, weak) IBOutlet UIButton* schemeButton;
@property (nonatomic, weak) IBOutlet UIButton* methodButton;
@property (nonatomic, weak) IBOutlet UIButton* formatButton;
@property (nonatomic, weak) IBOutlet UIButton* startButton;

@end
