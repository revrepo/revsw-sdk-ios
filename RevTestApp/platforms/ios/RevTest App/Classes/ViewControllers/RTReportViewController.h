//
//  RSReportViewController.h
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import <UIKit/UIKit.h>

@interface RTReportViewController : UIViewController

@property (nonatomic, weak) IBOutlet UITableView* tableView;
/*@property (nonatomic, strong) NSArray* directResults;
@property (nonatomic, strong) NSArray* sdkResults;
@property (nonatomic, strong) NSArray* dataLengths;
@property (nonatomic, strong) NSArray* sdkDataLengths;
@property (nonatomic, strong) NSArray* resultSuccessFlags;
@property (nonatomic, strong) NSDictionary* userInfo;*/
@property (nonatomic, strong) NSArray* testResults;

@end
