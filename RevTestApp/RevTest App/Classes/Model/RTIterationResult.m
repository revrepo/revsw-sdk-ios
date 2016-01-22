/*************************************************************************
 *
 * REV SOFTWARE CONFIDENTIAL
 *
 * [2013] - [2015] Rev Software, Inc.
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


#import <Foundation/Foundation.h>
#import "RTIterationResult.h"

@implementation RTIterationResult

- (id)init
{
    self = [super init];
    if (self)
    {
        self.testResults = [[NSMutableArray alloc] init];
    } 
    
    return self;
}

-(void)pushResult:(RTTestResult*)aResult
{
    [self.testResults addObject:aResult];
}

- (BOOL)valid
{
    long currentCode = 0;
    
    for (id it in self.testResults)
    {
        RTTestResult* tst = it;
        
        if (0 == currentCode)
        {
            currentCode = tst.errorCode;
        }
        else if (currentCode != tst.errorCode)
        {
            return false;
        }
    }
    
    return true;

}

- (NSString *)description
{
    return self.testResults.description;
}

@end



















