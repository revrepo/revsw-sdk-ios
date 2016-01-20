//
//  IterationResult.m
//  RevTest App
//
//  Created by Vlad Joss on 06.01.16.
//
//

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



















