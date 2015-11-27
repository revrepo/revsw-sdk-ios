//
//  RSMobileWebViewController.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/26/15.
//
//

#import <UIKit/UIKit.h>

@interface RTMobileWebViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITextField* URLTextField;
@property (nonatomic, weak) IBOutlet UITextField* testsTextField;
@property (nonatomic, weak) IBOutlet UISwitch*    redirectSwitch;
@property (nonatomic, weak) IBOutlet UIWebView*   webView;
@property (nonatomic, weak) IBOutlet UIButton*    startButton;

@end
