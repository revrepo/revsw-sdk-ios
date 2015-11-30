//
//  RSReportViewController.m
//  RevTest App
//
//  Created by Andrey Chernukha on 11/30/15.
//
//

#import "RSReportViewController.h"

@interface RSReportViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation RSReportViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.results[0] count];
}

@end
