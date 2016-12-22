//
//  PageScrollTimerView.h
//  PageScrollViewDemo
//
//  Created by ChiJinLian on 16/12/22.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "PageScrollView.h"

typedef NS_ENUM(NSInteger, ScrollDirectionType)
{
    NextPage = 0,      //下一页
    PreviousPage,      //上一页
};

@interface PageScrollTimerView : PageScrollView

/**
 *  计时间隔
 */
@property (nonatomic, assign) NSTimeInterval timeInterval;
/**
 *  滑动方向(默认NextPage)
 */
@property (nonatomic, assign) ScrollDirectionType scrollDirection;

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
