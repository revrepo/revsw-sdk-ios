//
//  RSReport2ViewController.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <UIKit/UIKit.h>

@interface RTTestStatsViewController : UIViewController

@property (nonatomic, strong) NSArray* testResults;

- (void)prepare;

@end
