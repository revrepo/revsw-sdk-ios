//
//  RSEntryVC.h
//  RevSDK
//
//  Created by Oleksander Mamchych on 1/8/16.
//  Copyright © 2016 TundraMobile. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RSEntryVC : UIViewController

@property (nonatomic, readwrite, strong) NSString* message;
+ (RSEntryVC*)createNew;

@end
