//
//  PageScrollTimerView.m
//  PageScrollViewDemo
//
//  Created by ChiJinLian on 16/12/22.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "PageScrollTimerView.h"

@interface CJProxy : NSProxy
@property (nonatomic, weak, readonly) id target;
+ (CJProxy *)proxyWithTarget:(id)target;
@end
@interface CJProxy ()
@property (nonatomic, weak) id target;
@end
@implementation CJProxy
+ (CJProxy *)proxyWithTarget:(id)target {
    CJProxy *proxy = [CJProxy alloc];
    proxy.target = target;
    return proxy;
}
// 方案一：直接指定转发对象为target
- (id)forwardingTargetForSelector:(SEL)aSelector {
    return self.target;
}
//// 方案二：使用self.target转发消息
//- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
//    return [self.target methodSignatureForSelector:sel];
//}
//- (void)forwardInvocation:(NSInvocation *)invocation {
//    if ([self.target respondsToSelector:invocation.selector]) {
//        [self.target invokeWithTarget:self.target];
//    }
//}

@end

@interface PageScrollTimerView()
@property (nonatomic, strong) NSTimer *pageTimer;
@property (nonatomic, assign) BOOL isTiming;
@end

@implementation PageScrollTimerView

- (void)dealloc {
    [self cancelTimer];
}

- (void)scrollToNextWithAnimationWithTimer {
    self.isTiming = YES;
    if (self.scrolling) {
        return;
    }
    if (self.scrollDirection == NextPage) {
        [self scrollToNextWithAnimation:YES];
    }else{
        [self scrollToPreviousWithAnimation:YES];
    }
}

- (void)startTimer {
    if ([self.dataSource numberOfPages] <= 0) {
        return;
    }
    [self cancelTimer];
    self.isTiming = YES;
    self.pageTimer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(scrollToNextWithAnimationWithTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.pageTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTimer {
    [self.pageTimer invalidate];
    self.pageTimer = nil;
    self.isTiming = NO;
}

- (void)pauseTimer {
    [self.pageTimer setFireDate:[NSDate distantFuture]];
    self.isTiming = NO;
}

- (void)resumeTimer {
    [self.pageTimer setFireDate:[NSDate distantPast]];
    self.isTiming = YES;
}

@end
