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
@property (nonatomic, copy) NSArray* directResults;
@property (nonatomic, copy) NSArray* sdkResults;

@end
