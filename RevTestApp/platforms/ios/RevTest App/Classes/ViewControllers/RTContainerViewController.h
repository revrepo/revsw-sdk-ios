//
//  RSContainerViewController.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <UIKit/UIKit.h>

@interface RTContainerViewController : UIViewController

@property (nonatomic, strong) NSArray* directResults;
@property (nonatomic, strong) NSArray* sdkResults;
@property (nonatomic, strong) NSArray* dataLengths;
@property (nonatomic, strong) NSArray* sdkDataLengths;

@end
