/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2016] Rev Software, Inc.
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

#import <UIKit/UIKit.h> 

@interface RTNativeMobileViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField* URLTextField;
@property (nonatomic, weak) IBOutlet UILabel* testsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel* payloadSizeLabel;
@property (nonatomic, weak) IBOutlet UISlider* testsCountSlider;
@property (nonatomic, weak) IBOutlet UISlider* payloadSizeSlider;
@property (nonatomic, weak) IBOutlet UIButton* methodButton;
@property (nonatomic, weak) IBOutlet UIButton* formatButton;
@property (nonatomic, weak) IBOutlet UIButton* startButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

@end
