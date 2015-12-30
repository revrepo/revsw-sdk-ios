//
//  QUICThread.cpp
//  RevSDK
//
//  Created by Oleksander Mamchych on 12/30/15.
//  Copyright © 2015 TundraMobile. All rights reserved.
//

#include "QUICThread.h"
#import <Foundation/Foundation.h>

@interface QUICFunc : NSObject

@property (nonatomic, readwrite, assign) std::function<void(void)> func;

@end

@implementation QUICFunc
@end

@interface QUICThreadImpl : NSObject
{
    rs::QUICThread* mOwner;
}

@property (nonatomic, readwrite, strong) NSThread* thread;
@property (nonatomic, readwrite, strong) NSTimer* timer;
@property (nonatomic, readwrite, assign) rs::QUICThread* owner;

@end


namespace rs
{
    struct QUICThread::Impl
    {
    public:
        Impl(QUICThread* aOwner): mThreadImpl (nil) {}
        QUICThreadImpl* mThreadImpl;
    };
}

@implementation QUICThreadImpl

- (id)init
{
    if (self = [super init])
    {
        self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(run:) object:nil];
        [self.thread start];
    }
    return self;
}

- (int)run:(id)ctx
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(onTimerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] run];
    return 0;
}

- (void)onTimerFired:(NSTimer*)aTimer {}

- (void)doCall:(QUICFunc*)aFunc
{
    if (aFunc == nil)
        return;
    
    if (aFunc.func == nullptr)
        return;
    
    aFunc.func();
}

@end

using namespace rs;

QUICThread::QUICThread():
    mImpl (nullptr)
{
    mImpl = new Impl(this);
    mImpl->mThreadImpl = [[QUICThreadImpl alloc] init];
    mImpl->mThreadImpl.owner = this;
}

QUICThread::~QUICThread()
{
    
}

void QUICThread::perform(std::function<void(void)> aFunc)
{
    if (aFunc == nullptr)
        return;
    
    QUICFunc* func = [[QUICFunc alloc] init];
    func.func = aFunc;
    
    [mImpl->mThreadImpl performSelector:@selector(doCall:)
                               onThread:mImpl->mThreadImpl.thread
                             withObject:func
                          waitUntilDone:NO];
}


