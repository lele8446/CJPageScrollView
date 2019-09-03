//
//  PageScrollTimerView.m
//  PageScrollViewDemo
//
//  Created by ChiJinLian on 16/12/22.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "PageScrollTimerView.h"

@interface PageScrollTimerView()
@property (nonatomic, strong) NSTimer *pageTimer;
@end

@implementation PageScrollTimerView

- (void)dealloc {
    [self cancelTimer];
}

- (void)scrollToNextWithAnimationWithTimer {
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
    self.pageTimer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(scrollToNextWithAnimationWithTimer) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.pageTimer forMode:NSRunLoopCommonModes];
}

- (void)cancelTimer
{
    [self.pageTimer invalidate];
    self.pageTimer = nil;
}

- (void)pauseTimer {
    [self.pageTimer setFireDate:[NSDate distantFuture]];
}

- (void)resumeTimer {
    [self.pageTimer setFireDate:[NSDate distantPast]];
}

@end
