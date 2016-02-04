//
//  RTRequestTestLoop.m
//  RevTest App
//
//  Created by Andrey Chernukha on 2/3/16.
//
//

#import <RevSDK/RevSDK.h>

#import "RTRequestTestLoop.h"
#import "RTHTMLGrabber.h"
#import "RTTestModel.h"

@interface NSString (URLString)

- (instancetype)stringByAddingScheme;

@end

@implementation NSString (URLString)

- (instancetype)stringByAddingScheme
{
    if (![self hasPrefix:@"http://"] && ! [self hasPrefix:@"https://"])
    {
        return [@"http://" stringByAppendingString:self];
    }
    
    return self;
}

@end

typedef enum
{
    kRSOperationModeOff = 0,
    kRSOperationModeTransport = 1,
    kRSOperationModeReport = 2,
    kRSOperationModeTransportAndReport = 3
}RSOperationMode;

@interface RTRequestTestLoop ()<RTHTMLGrabberDelegate>

@property (nonatomic, strong) RTHTMLGrabber* htmlGrabber;
@property (nonatomic, strong) NSArray* domains;
@property (nonatomic, strong) NSMutableArray* testCases;
@property (nonatomic, assign) NSUInteger currentDomainIndex;
@property (nonatomic, assign) NSUInteger iterationIndex;
@property (nonatomic, assign) NSUInteger numberOfTests;
@property (nonatomic, assign) NSUInteger numberOfFullPasses;
@property (nonatomic, assign) NSUInteger currentPass;
@property (nonatomic, assign) BOOL isIterating;

@end

@implementation RTRequestTestLoop

+ (instancetype)defaultTestLoop
{
    NSArray* domains = @[@"mgemi.com",
                         @"httpbin.org",
                         @"google.com",
                         @"mbeans.com",
                         @"cnn.com",
                         @"stackoverflow.com",
                         @"bmwusa.com",
                         @"ebay.com",
                         @"m.vk.com",
                         @"yandex.ru",
                         @"amazon.com",
                         @"youtube.com",
                         @"linkedin.com",
                         @"echo.msk.ru",
                         @"ibm.com",
                         @"revapm.net",
                         @"bing.com",
                         @"akamai.com",
                         @"skrill.com",
                         @"raywenderlich.com",
                         @"facebook.com",
                         @"twitter.com"];
    
    RTRequestTestLoop* testLoop = [[RTRequestTestLoop alloc] initWithDomains:domains
                                                               numberOfTests:20
                                                          numberOfFullPasses:10];

    
    return testLoop;
}

- (instancetype)initWithDomains:(NSArray *)aDomains numberOfTests:(NSUInteger)aNumberOfTests numberOfFullPasses:(NSUInteger)aNumberOfFullPasses
{
    self = [super init];
    
    if (self)
    {
        _numberOfTests        = aNumberOfTests;
        _domains              = [aDomains copy];
        _htmlGrabber          = [RTHTMLGrabber new];
        _htmlGrabber.delegate = self;
        _numberOfFullPasses   = aNumberOfFullPasses;
        _testCases            = [NSMutableArray array];
        
        RTTestCase* tcase = [[RTTestCase alloc] init];
        // 1st case
        tcase.testName = @"Current";
        tcase.protocolID = @"none";
        tcase.operationMode = kRSOperationModeReport;
        
        [_testCases addObject:tcase];
        ////////////////////////////////
        
        tcase = [[RTTestCase alloc] init];
        tcase.testName = @"RevAPM";
        tcase.protocolID = @"standard";
        tcase.operationMode = kRSOperationModeTransportAndReport;
        
        [_testCases addObject:tcase];
        ////////////////////////////////
        
        tcase = [[RTTestCase alloc] init];
        tcase.testName = @"RevSDK";
        tcase.protocolID = @"quic";
        tcase.operationMode = kRSOperationModeTransportAndReport;
        
        [_testCases addObject:tcase];
    }
    
    return self;
}

- (void)pushTestConfiguration:(NSString *)aProtocolId mode:(RSOperationMode)mode
{
    SEL selector = @selector(debug_pushTestConifguration: mode:);
    
    if ([RevSDK respondsToSelector:selector])
    {
        NSMethodSignature* methodSignature = [RevSDK methodSignatureForSelector:selector];
        NSInvocation* invocation           = [NSInvocation invocationWithMethodSignature:methodSignature];
        
        [invocation setSelector:selector];
        [invocation setTarget:[RevSDK class]];
        
        [invocation setArgument:&(aProtocolId) atIndex:2];
        [invocation setArgument:&mode atIndex:3];
        
        [invocation invoke];
    }
}

- (void)start
{
    if (!self.isIterating)
    {
        self.isIterating = YES;
       [self startIterating];
    }
}

- (void)startIterating
{
    SEL selector = @selector(debug_enableTestMode);
    [RevSDK performSelector:selector];
    
    RTTestCase* tcase    = [self.testCases objectAtIndex:_iterationIndex];
    RSOperationMode mode = (RSOperationMode) tcase.operationMode;
    [self pushTestConfiguration:tcase.protocolID mode:mode];
    
    self.iterationIndex     = 0;
    self.currentDomainIndex = 0;
    
    [self next];
}

- (void)restart
{
    self.iterationIndex++;
    
    if (self.iterationIndex == self.numberOfTests * self.testCases.count)
    {
        self.currentDomainIndex++;
        self.iterationIndex = 0;
    }
    
    if (self.currentDomainIndex < self.domains.count && self.iterationIndex < self.numberOfTests * self.testCases.count)
    {
        RTTestCase* tcase    = [self.testCases objectAtIndex:self.iterationIndex % self.testCases.count];
        RSOperationMode mode = (RSOperationMode) tcase.operationMode;
        [self pushTestConfiguration:tcase.protocolID mode:mode];
        
        [self next];
    }
    else
    if (self.currentDomainIndex == self.domains.count && self.currentPass < self.numberOfFullPasses - 1)
    {
        self.currentPass++;
        [self startIterating];
    }
    else
    {
        self.isIterating = NO;
        
        SEL selector = @selector(debug_disableTestMode);
        [RevSDK performSelector:selector];
    }
}

- (void)next
{
    NSString* URLString   = [self.domains[self.currentDomainIndex] stringByAddingScheme];
    NSURL* URL            = [NSURL URLWithString:URLString];
    NSURLRequest* request = [NSURLRequest requestWithURL:URL];
    [self.htmlGrabber loadRequest:request];
}

#pragma mark - RTHTMLGrabberDelegate

- (void)grabberDidStartLoad:(RTHTMLGrabber *)grabber
{
   
}

- (void)grabberDidFinishLoad:(RTHTMLGrabber *)grabber withStatusCode:(NSInteger)statusCode dataSize:(NSUInteger)aDataSize
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restart];
    });
}

- (void)grabber:(RTHTMLGrabber *)grabber didFailLoadWithError:(nullable NSError *)error
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self restart];
    });
}


@end
