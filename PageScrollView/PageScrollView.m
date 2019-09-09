//
//  PageScrollView.m
//
//
//  Created by C.K.Lian on 16/3/29.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "PageScrollView.h"

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

#define CJScrollViewAutoresizingFlexibleAll UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin

/**
 * ScrollView类型
 */
typedef NS_ENUM(NSInteger, ScrollViewType)
{
    WithOutHeadView = 0,  //无上一页
    WithOutTailView,      //无下一页
    IntactView,           //存在上下页面
    WithOutHeadTailView   //只有一页
};

@interface PageScrollView()<UIGestureRecognizerDelegate,YCScrollviewDelegate>
{
    NSInteger _totalPages;
    NSInteger _curPage;
}
@property (nonatomic, strong) YCScrollview *scrollView;
@property (nonatomic, strong) NSMutableArray *scrollViewArray;//记录scrollView上的view的array
/**
 *  是否滑动中
 */
@property (nonatomic, assign) BOOL scrolling;
@end

@implementation PageScrollView

#pragma mark - Public Methods
- (void)reloadData {
    _totalPages = [_dataSource numberOfPages];
    if (_totalPages <= 0) {
        if (self.scrollViewArray.count > 0) {
            [self.scrollViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                if ([obj[@"view"] respondsToSelector:@selector(removeFromSuperview)]) {
                    [obj[@"view"] removeFromSuperview];
                }
            }];
            [self.scrollViewArray removeAllObjects];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,0);
        return;
    }
    if (0 > _curPage || _curPage >= _totalPages) {
        _curPage = 0;
    }
    [self loadData];
    self.scrolling = NO;
}

- (void)reloadDataWithStartIndex:(NSInteger)index {
    _totalPages = [_dataSource numberOfPages];
    
    _curPage = index;
    if (index<0) {
        _curPage = 0;
    }
    if (index>=_totalPages) {
        _curPage = _totalPages-1;
    }
    
    if (_totalPages <= 0) {
        if (self.scrollViewArray.count > 0) {
            [self.scrollViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
                if ([obj[@"view"] respondsToSelector:@selector(removeFromSuperview)]) {
                    [obj[@"view"] removeFromSuperview];
                }
            }];
            [self.scrollViewArray removeAllObjects];
        }
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,0);
        return;
    }
    [self loadData];
    self.scrolling = NO;
}

- (void)scrollToNextWithAnimation:(BOOL)animation {
    if (!self.cycleEnable && _curPage >= _totalPages-1) {
        return;
    }
    
    if (self.scrolling) {
        return;
    }

    CGFloat viewPage = self.scrollView.contentSize.width/self.scrollView.bounds.size.width;
    [self.scrollView setContentOffset:CGPointMake((viewPage-1) * self.scrollView.bounds.size.width, 0) animated:animation];
    
    //没有动画，那么直接更新数据；有动画的话会在滑动动画完成后，在scrollViewDidEndScrollingAnimation: 方法中执行更新
    if (!animation) {
        [self updatePageAfterScrollViewDidEndScrollingAnimation];
    }
}

- (void)scrollToPreviousWithAnimation:(BOOL)animation {
    if (!self.cycleEnable && _curPage <= 0) {
        return;
    }
    
    if (self.scrolling) {
        return;
    }
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animation];
    
    //没有动画，那么直接更新数据；有动画的话会在滑动动画完成后，在scrollViewDidEndScrollingAnimation: 方法中执行更新
    if (!animation) {
        [self updatePageAfterScrollViewDidEndScrollingAnimation];
    }
}

- (void)scrollToIndexView:(NSInteger)index animation:(BOOL)animation {
    if (index != _curPage && (index <= _totalPages-1 && index >= 0)) {
        if (animation) {
            self.scrolling = YES;
            //滑动至指定页面动画
            CGFloat viewSize = self.scrollView.contentSize.width/self.scrollView.bounds.size.width;
            if (index < _curPage) {//往前滑
                [self.scrollView setContentOffset:CGPointMake(0, 0) animated:animation];
            }else if (index > _curPage){//往后滑
                [self.scrollView setContentOffset:CGPointMake((viewSize-1) * self.scrollView.bounds.size.width, 0) animated:animation];
            }
        }
        //动画完成，刷新数据
        double delayInSeconds = animation?0.15:0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _curPage = index;
            [self loadData];
            self.scrolling = NO;
        });
    }
}

#pragma mark - life cycle
- (void)dealloc {
    self.scrollView.delegate = nil;
    self.scrollView.scrollviewDelegate = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setInitialValue];
        [self addSubview:self.scrollView];
        [self bringSubviewToFront:self.scrollView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setInitialValue];
    [self addSubview:self.scrollView];
    [self bringSubviewToFront:self.scrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (self.scrollViewArray.count > 0) {
        for (NSDictionary *dic in self.scrollViewArray) {
            if (dic[@"view"] && ![dic[@"view"] isKindOfClass:[NSNull class]]) {
                UIView *view = dic[@"view"];
                CGRect viewFrame = view.frame;
                viewFrame.size.width = self.scrollView.bounds.size.width;
                viewFrame.size.height = self.scrollView.bounds.size.height;
                view.frame = viewFrame;
            }
        }
    }
}

- (YCScrollview *)scrollView {
    if (!_scrollView) {
        _scrollView = [[YCScrollview alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollviewDelegate = self;
//        _scrollView.autoresizingMask = CJScrollViewAutoresizingFlexibleAll;
        _scrollView.autoresizingMask = UIViewAutoresizingNone;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.scrollsToTop = NO;
        //给控件添加单击事件
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        singleTap.delegate = (id <UIGestureRecognizerDelegate>)self;
        [_scrollView addGestureRecognizer:singleTap];
    }
    return _scrollView;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:didClickPageAtIndex:)]) {
        [self.delegate pageScrollView:self didClickPageAtIndex:_curPage];
    }
}

- (void)setDataSource:(id<PageScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
}

- (void)setBounces:(BOOL)bounces {
    _bounces = bounces;
    self.scrollView.bounces = _bounces;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    _scrollEnabled = scrollEnabled;
    self.scrollView.scrollEnabled = _scrollEnabled;
}
//设置初始值
- (void)setInitialValue {
    _curPage = 0;
    self.cycleEnable = NO;
    self.bounces = NO;
    self.scrollEnabled = YES;
    self.scrollViewArray = [[NSMutableArray alloc]initWithCapacity:3];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![self.delegate respondsToSelector:@selector(pageScrollView:didClickPageAtIndex:)]) {
        return NO;
    }
    return YES;
}

- (void)loadData {
    [self updateScrollViewFrameWithCurrentViewType:[self getScrollViewType]];
}

- (void)updateCurPageIndexToNextPage:(BOOL)next {
    if (next) {
        _curPage = [self validPageValue:_curPage + 1];
    }else{
        _curPage = [self validPageValue:_curPage - 1];
    }
}

- (void)updateScrollViewFrameWithCurrentViewType:(ScrollViewType)type {
    if (self.scrollViewArray.count > 0) {
        [self.scrollViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if ([obj[@"view"] respondsToSelector:@selector(removeFromSuperview)]) {
                [obj[@"view"] removeFromSuperview];
            }
        }];
        [self.scrollViewArray removeAllObjects];
    }
    
    if (type == WithOutHeadView) {
        NSInteger curIndex = [self validPageValue:_curPage];
        UIView *curView = [_dataSource pageScrollView:self viewForIndex:curIndex];
        [self addIntentViewToScrollview:curView pageNum:0 viewIndex:curIndex];
        
        NSInteger nextIndex = [self validPageValue:_curPage+1];
        UIView *nextView = [_dataSource pageScrollView:self viewForIndex:nextIndex];
        [self addIntentViewToScrollview:nextView pageNum:1 viewIndex:nextIndex];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 2,0);
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self hasScrollToCurrentView:curView];
    }
    else if (type == IntactView) {
        NSInteger preIndex = [self validPageValue:_curPage-1];
        UIView *preView = [_dataSource pageScrollView:self viewForIndex:preIndex];
        [self addIntentViewToScrollview:preView pageNum:0 viewIndex:preIndex];
        
        NSInteger curIndex = [self validPageValue:_curPage];
        UIView *curView = [_dataSource pageScrollView:self viewForIndex:curIndex];
        [self addIntentViewToScrollview:curView pageNum:1 viewIndex:curIndex];
        
        NSInteger nextIndex = [self validPageValue:_curPage+1];
        UIView *nextView = [_dataSource pageScrollView:self viewForIndex:nextIndex];
        [self addIntentViewToScrollview:nextView pageNum:2 viewIndex:nextIndex];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 3,0);
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0) animated:NO];
        [self hasScrollToCurrentView:curView];
    }
    else if (type == WithOutTailView) {
        NSInteger preIndex = [self validPageValue:_curPage-1];
        UIView *preView = [_dataSource pageScrollView:self viewForIndex:preIndex];
        [self addIntentViewToScrollview:preView pageNum:0 viewIndex:preIndex];
        
        NSInteger curIndex = [self validPageValue:_curPage];
        UIView *curView = [_dataSource pageScrollView:self viewForIndex:curIndex];
        [self addIntentViewToScrollview:curView pageNum:1 viewIndex:curIndex];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width * 2,0);
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.bounds.size.width, 0) animated:NO];
        [self hasScrollToCurrentView:curView];
    }
    else if (type == WithOutHeadTailView) {
        NSInteger curIndex = [self validPageValue:_curPage];
        UIView *curView = [_dataSource pageScrollView:self viewForIndex:curIndex];
        [self addIntentViewToScrollview:curView pageNum:0 viewIndex:curIndex];
        
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width,0);
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
        [self hasScrollToCurrentView:curView];
    }
}

- (void)hasScrollToCurrentView:(UIView *)currentView {
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageScrollView:didLoadItemAtIndex:)]) {
        [self.dataSource pageScrollView:self didLoadItemAtIndex:_curPage];
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageScrollView:didScrollToIndex:currentView:)]) {
        [self.dataSource pageScrollView:self didScrollToIndex:_curPage currentView:currentView];
    }
    [self setViewScrollsToTop];
}

- (void)setViewScrollsToTop {
    [self setScrollviewToTopUnable:self];
    UIView *obj = nil;
    for (NSDictionary *dic in self.scrollViewArray) {
        if ([dic[@"index"] integerValue]==_curPage) obj = dic[@"view"];
    }
    
    if (![obj isKindOfClass:[NSNull class]] && [obj isKindOfClass:[UIScrollView class]]) {
        UIScrollView *scrollView = (UIScrollView *)obj;
        scrollView.scrollsToTop = YES;
    }else if (![obj isKindOfClass:[NSNull class]]) {
        for (UIView *view in obj.subviews) {
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.scrollsToTop = YES;
                return;
            }
        }
    }
}

- (void)setScrollviewToTopUnable:(UIView *)subView {
    if (subView.subviews.count > 0) {
        for (UIView *view in subView.subviews) {
            [self setScrollviewToTopUnable:view];
            if ([view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)view;
                scrollView.scrollsToTop = NO;
            }
        }
    }else{
        return;
    }
}

/**
 *  添加view到scrollView
 *
 *  @param view view
 *  @param num 该view在scrollView位置（0、1、2）
 *  @param index 该view在所有页面中的index值
 */
- (void)addIntentViewToScrollview:(UIView *)view pageNum:(NSInteger)num viewIndex:(NSInteger)index{
    CGRect viewFrame = CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    viewFrame.origin.x = num * self.scrollView.bounds.size.width;
    view.frame = viewFrame;
    [self layoutIfNeeded];
    [self.scrollView addSubview:view];
    [self.scrollViewArray addObject:@{@"index":[NSNumber numberWithInteger:index],@"view":view?view:[NSNull null]}];
}

//计算inedx值
- (NSInteger)validPageValue:(NSInteger)value {
    if (self.cycleEnable) {
        if(value == -1) value = _totalPages-1;
        if(value == _totalPages) value = 0;
    }else{
        if(value == -1) value = 0;
        if(value == _totalPages) value = _totalPages-1;
    }
    return value;
}

- (ScrollViewType)getScrollViewType {
    if (self.cycleEnable) {
        return IntactView;
    }else{
        if (_curPage == 0) {
            if (_totalPages == 1) {
                return WithOutHeadTailView;
            }else{
                return WithOutHeadView;
            }
        }else if (_curPage == (_totalPages-1)) {
            if (_totalPages == 1) {
                return WithOutHeadTailView;
            }else{
                return WithOutTailView;
            }
        }else{
            return IntactView;
        }
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.scrolling = YES;
}

static CGFloat _startContentOffsetX;
static CGFloat _willEndContentOffsetX;
static CGFloat _endContentOffsetX;
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        _startContentOffsetX = scrollView.contentOffset.x;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageScrollViewWillBeginDragging:)]) {
        [self.dataSource pageScrollViewWillBeginDragging:self];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (scrollView == self.scrollView) {
        _willEndContentOffsetX = scrollView.contentOffset.x;
    }
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(pageScrollViewWillEndDragging:)]) {
        [self.dataSource pageScrollViewWillEndDragging:self];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView == self.scrollView && !decelerate){//不减速
        self.scrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        _endContentOffsetX = scrollView.contentOffset.x;
        
        if (self.scrollView.bounces) {
            if( _endContentOffsetX >= (scrollView.contentSize.width-scrollView.bounds.size.width) && _willEndContentOffsetX >= (scrollView.contentSize.width-scrollView.bounds.size.width) && _startContentOffsetX >= (scrollView.contentSize.width-scrollView.bounds.size.width)){
                //                CRMLog(@"下一页边界处");
                [self scrollToNext:YES];
            }
            else if( _endContentOffsetX <= 0 && _willEndContentOffsetX <= 0 && _startContentOffsetX <= 0){
                //                CRMLog(@"上一页边界处");
                [self scrollToNext:NO];
            }
            else if (_endContentOffsetX > _willEndContentOffsetX && _willEndContentOffsetX > _startContentOffsetX){
                //                CRMLog(@"下一页");
                [self scrollToNext:YES];
            }
            else if (_endContentOffsetX < _willEndContentOffsetX && _willEndContentOffsetX < _startContentOffsetX)
            {
                //                CRMLog(@"上一页");
                [self scrollToNext:NO];
            }
            else{
                //                CRMLog(@"未知状态");
            }
        }else{
            if( (_endContentOffsetX == _willEndContentOffsetX) && _endContentOffsetX == 0 ){
                //                CRMLog(@"上一页边界处");
                [self scrollToNext:NO];
            }
            else if( _endContentOffsetX == _willEndContentOffsetX && _endContentOffsetX == (scrollView.contentSize.width-scrollView.bounds.size.width)){
                //                CRMLog(@"下一页边界处");
                [self scrollToNext:YES];
            }
            else if (_endContentOffsetX > _willEndContentOffsetX && _willEndContentOffsetX > _startContentOffsetX){
                //                CRMLog(@"下一页");
                [self scrollToNext:YES];
            }
            else if (_endContentOffsetX < _willEndContentOffsetX && _willEndContentOffsetX < _startContentOffsetX)
            {
                //                CRMLog(@"上一页");
                [self scrollToNext:NO];
            }
            else{
                //                CRMLog(@"未知状态");
            }
        }
        
        if ([[self.delegate class] isSubclassOfClass:[UIViewController class]]) {
            UIViewController *controller = (UIViewController *)self.delegate;
            if (controller.navigationController && ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
                controller.navigationController.interactivePopGestureRecognizer.enabled = YES;
            }
        }
        self.scrolling = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self updatePageAfterScrollViewDidEndScrollingAnimation];
}

- (void)updatePageAfterScrollViewDidEndScrollingAnimation {
    if (self.scrollDirection == NextPage) {
        [self scrollToNext:YES];
    }else{
        [self scrollToNext:NO];
    }
    self.scrolling = NO;
}

- (void)scrollToNext:(BOOL)next {
    if (next) {
        NSInteger pageIndex = _curPage;
        if (pageIndex == [self validPageValue:pageIndex + 1]) {
            //            CRMLog(@"在第一页边界");
            return;
        }
        [self updateCurPageIndexToNextPage:YES];
        [self loadData];
    }else{
        NSInteger pageIndex = _curPage;
        if (pageIndex == [self validPageValue:pageIndex - 1]) {
            //            CRMLog(@"在最后一页边界");
            return;
        }
        [self updateCurPageIndexToNextPage:NO];
        [self loadData];
    }
}

#pragma mark - YCScrollviewDelegate
- (BOOL)popGestureEnable {
    if (!self.cycleEnable && _curPage == 0) {
        return YES;
    }
    else{
        return NO;
    }
}

- (BOOL)scrollUnableWithView:(UIView *)view point:(CGPoint)point {
    BOOL scrollEnable = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(pageScrollView:scrollUnableWithView:point:)]) {
        scrollEnable = [self.delegate pageScrollView:self scrollUnableWithView:view point:point];
    }
    return scrollEnable;
}
@end


@implementation YCScrollview
//UIScrollView与右滑退出判断
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    PageScrollView *pgScrollView = (PageScrollView *)self.scrollviewDelegate;
    if ([[pgScrollView.delegate class] isSubclassOfClass:[UIViewController class]]) {
        UIViewController *controller = (UIViewController *)pgScrollView.delegate;
        if (controller.navigationController && ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)) {
            if (self.scrollviewDelegate && [self.scrollviewDelegate respondsToSelector:@selector(popGestureEnable)]) {
                controller.navigationController.interactivePopGestureRecognizer.enabled = [self.scrollviewDelegate popGestureEnable];
            }
        }
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return YES;
    }else {
        return NO;
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    if (self.scrollviewDelegate && [self.scrollviewDelegate respondsToSelector:@selector(scrollUnableWithView:point:)]) {
        BOOL canScroll = [self.scrollviewDelegate scrollUnableWithView:hitView point:point];
        self.scrollEnabled = canScroll;
    }else{
        self.scrollEnabled = YES;
    }
    return hitView;
}

@end
