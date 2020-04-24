//
//  PageScrollView.h
//
//
//  Created by C.K.Lian on 16/3/29.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, ScrollDirectionType)
{
    NextPage = 0,      ///< 下一页
    PreviousPage,      ///< 上一页
};

@class PageScrollView;

/*******************************************
 *  PageScrollViewDelegate
 *******************************************/
@protocol PageScrollViewDelegate <NSObject>
@optional
/**
 *  点击页面
 *
 *  @param pageView PageScrollView
 *  @param index    点击了第index的页面
 */
- (void)pageScrollView:(PageScrollView *)pageView didClickPageAtIndex:(NSInteger)index;

/**
 *  声明在pageView上的指定view，滑动无效（用来处理scrollView的手势冲突）
 *
 *  @param pageView    PageScrollView
 *  @param view        需要处理手势冲突的view
 *  @param point       触摸点
 *
 *  @return 是否可滑动
 */
- (BOOL)pageScrollView:(PageScrollView *)pageView scrollUnableWithView:(UIView *)view point:(CGPoint)point;
@end

/*******************************************
 *  PageScrollViewDataSource
 *******************************************/
@protocol PageScrollViewDataSource <NSObject>
@required
/**
 *  可滑动页面个数
 *
 *  @return  NSInteger
 */
- (NSInteger)numberOfPages;

/**
 *  生成指定index对应的view
 *
 *  @param pageView  PageScrollView
 *  @param index     指定页面的index
 *
 *  @return 目标view
 */
- (UIView *)pageScrollView:(PageScrollView *)pageView viewForIndex:(NSInteger)index;

@optional
/**
 *  已滑动至第index页
 *
 *  @param pageView  PageScrollView
 *  @param index     指定页面的index
 */
- (void)pageScrollView:(PageScrollView *)pageView didLoadItemAtIndex:(NSInteger)index;

/**
 *  已滑动至第index页
 *
 *  @param pageView  PageScrollView
 *  @param index     指定页面的index
 *  @param currentView     当前所在view
 */
- (void)pageScrollView:(PageScrollView *)pageView didScrollToIndex:(NSInteger)index currentView:(UIView *)currentView;

/**
 *  将要开始滑动（手动滑动时触发，PageScrollTimerView定时器自动滚动时不触发）
 *
 *  @param pageView  PageScrollView
 */
- (void)pageScrollViewWillBeginDragging:(PageScrollView *)pageView;
/**
 *  将要停止滑动（手动滑动时触发，PageScrollTimerView定时器自动滚动时不触发）
 *
 *  @param pageView  PageScrollView
 */
- (void)pageScrollViewWillEndDragging:(PageScrollView *)pageView;
@end


@interface PageScrollView : UIView<UIScrollViewDelegate>

/**
 *  是否可滑动（默认YES）
 */
@property (nonatomic,assign,setter = setScrollEnabled:) BOOL scrollEnabled;
/**
 *  是否循环滚动(默认NO)
 */
@property (nonatomic,assign) BOOL cycleEnable;
/**
 *  PageScrollView的bounces属性，默认NO
 */
@property (nonatomic,assign,setter = setBounces:) BOOL bounces;
/**
 *  数据源
 */
@property (nonatomic,weak,setter = setDataSource:) id<PageScrollViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic,weak,setter = setDelegate:) id<PageScrollViewDelegate> delegate;
/**
 *  是否滑动中
 */
@property (nonatomic, assign,readonly) BOOL scrolling;
/**
 *  滑动方向(默认NextPage)
 */
@property (nonatomic, assign) ScrollDirectionType scrollDirection;
/**
 * 所在VC是否禁用右滑返回，默认NO
 */
@property(nonatomic, assign) BOOL disablePopGesture;

/**
 *  刷新数据
 */
- (void)reloadData;

/**
 *  从指定位置开始刷新数据
 *
 *  @param index 初始位置
 */
- (void)reloadDataWithStartIndex:(NSInteger)index;

/**
 *  滑动到下一页
 *
 *  @param animation 是否有动画
 */
- (void)scrollToNextWithAnimation:(BOOL)animation;

/**
 *  滑动到上一页
 *
 *  @param animation 是否有动画
 */
- (void)scrollToPreviousWithAnimation:(BOOL)animation;

/**
 *  滑动到指定页面
 *
 *  @param index     第index页
 *  @param animation 是否有动画
 */
- (void)scrollToIndexView:(NSInteger)index animation:(BOOL)animation;
@end


