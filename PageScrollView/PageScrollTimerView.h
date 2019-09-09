//
//  PageScrollTimerView.h
//  PageScrollViewDemo
//
//  Created by ChiJinLian on 16/12/22.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "PageScrollView.h"



@interface PageScrollTimerView : PageScrollView

/**
 *  是否计时中
 */
@property (nonatomic, assign, readonly) BOOL isTiming;
/**
 *  计时间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;

/**
 *  开启计时
 */
- (void)startTimer;
/**
 *  取消计时
 */
- (void)cancelTimer;
/**
 *  暂停计时
 */
- (void)pauseTimer;
/**
 *  恢复计时
 */
- (void)resumeTimer;
@end
