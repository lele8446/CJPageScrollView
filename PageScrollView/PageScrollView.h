//
//  PageScrollView.h
//
//
//  Created by C.K.Lian on 16/3/29.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PageScrollViewDelegate;
@protocol PageScrollViewDataSource;

@interface PageScrollView : UIView<UIScrollViewDelegate>
{
    NSInteger _totalPages;
    NSInteger _curPage;
}
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
@property (nonatomic,assign) BOOL scrolling;

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


/*******************************************
 *  PageScrollViewDelegate
 *******************************************/
@protocol PageScrollViewDelegate <NSObject>
@optional
/**
 *  点击页面
 *
 *  @param pageView
 *  @param index    点击了第index的页面
 */
- (void)pageScrollView:(PageScrollView *)pageView didClickPageAtIndex:(NSInteger)index;

/**
 *  声明在pageView上的指定view，滑动无效（用来处理scrollView的手势冲突）
 *
 *  @param pageView
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
 *  @return
 */
- (NSInteger)numberOfPages;

/**
 *  生成index对应的view
 *
 *  @param pageView
 *  @param index
 *
 *  @return 目标view
 */
- (UIView *)pageScrollView:(PageScrollView *)pageView viewForIndex:(NSInteger)index;

@optional
/**
 *  已滑动至第index页
 *
 *  @param pageView
 *  @param index
 */
- (void)pageScrollView:(PageScrollView *)pageView didLoadItemAtIndex:(NSInteger)index;
@end

/*******************************************
 *  YCScrollview
 *******************************************/
@protocol YCScrollviewDelegate <NSObject>
- (BOOL)popGestureEnable;
@optional
- (BOOL)scrollUnableWithView:(UIView *)view point:(CGPoint)point;
@end
@interface YCScrollview :UIScrollView
@property(nonatomic, assign)id<YCScrollviewDelegate> scrollviewDelegate;
@end
