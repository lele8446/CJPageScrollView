//
//  ViewController.m
//  pageScrollView
//
//  Created by C.K.Lian on 16/4/10.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "ViewController.h"
#import "PageScrollTimerView.h"
#import "pageTableViewController.h"

@interface ViewController ()<PageScrollViewDelegate,PageScrollViewDataSource>
@property (nonatomic, strong)IBOutlet PageScrollTimerView *pgScrollView;
@property (nonatomic, strong)NSMutableArray *ctrArray;
@property (nonatomic, assign)NSUInteger num;
@end

@implementation ViewController

- (IBAction)click:(id)sender {
    [self.pgScrollView scrollToNextWithAnimation:YES];
}

- (IBAction)clickLast:(id)sender {
    [self.pgScrollView scrollToPreviousWithAnimation:YES];
}

- (IBAction)clickTo:(UIButton *)sender {
    [self.pgScrollView scrollToIndexView:sender.tag animation:YES];
}

- (IBAction)clickToLast:(id)sender {
    [self.pgScrollView scrollToIndexView:self.num-1 animation:YES];
}

- (IBAction)refreshAdd:(UIButton *)sender {
    self.num += sender.tag;
    self.num = self.num<=0?0:self.num;
    [self.pgScrollView reloadData];
}

- (IBAction)refresh:(UIButton *)sender {
    self.num -= sender.tag;
    self.num = self.num<=0?0:self.num;
    [self.pgScrollView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.num = 500;
    self.ctrArray = [[NSMutableArray alloc]initWithCapacity:4];
    
    self.pgScrollView = [[PageScrollTimerView alloc]initWithFrame:CGRectMake(0, 20, 300, 400)];
    self.pgScrollView.dataSource = self;
    self.pgScrollView.delegate = self;
    [self.view addSubview:self.pgScrollView];
    
    self.pgScrollView.timeInterval = 3;
    self.pgScrollView.scrollDirection = PreviousPage;
    self.pgScrollView.cycleEnable = YES;
    [self.pgScrollView startTimer];
    
    [self.pgScrollView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)getViewCtrWithIndex:(NSUInteger)index {
    UIViewController *ctr = nil;
    for (NSDictionary *dic in _ctrArray) {
        if ([dic[@"index"] unsignedIntegerValue] == index) {
            ctr = dic[@"ctr"];
        }
    }
    
    if (ctr) {
        return ctr;
    }else{
        if (self.ctrArray.count > 4) {
            NSMutableArray *newAvailableCtrAry = [[NSMutableArray alloc]initWithCapacity:4];
            [self.ctrArray enumerateObjectsUsingBlock:^(id num, NSUInteger idx, BOOL *stop){
                NSDictionary *dic = (NSDictionary *)num;
                if (([dic[@"index"] unsignedIntegerValue] == index-1) || ([dic[@"index"] unsignedIntegerValue] == index+1) || ([dic[@"index"] unsignedIntegerValue] == index)) {
                    
                    [newAvailableCtrAry addObject:dic];
                }else{
                    UIViewController *ctr = dic[@"ctr"];
                    [ctr removeFromParentViewController];
                    ctr = nil;
                }
            }];
            [self.ctrArray removeAllObjects];
            [self.ctrArray addObjectsFromArray:newAvailableCtrAry];
        }
        ctr = [[pageTableViewController alloc]init];
        [self.ctrArray addObject:@{@"ctr":ctr,@"index":[NSNumber numberWithUnsignedInteger:index]}];
        [self addChildViewController:ctr];
        return ctr;
    }
}

- (NSInteger)numberOfPages {
    return self.num;
}

- (UIView *)pageScrollView:(PageScrollView *)pageView viewForIndex:(NSInteger)index {
    UIView *view = nil;
    pageTableViewController *page = (pageTableViewController *)[self getViewCtrWithIndex:index];
    page.tableView.frame = CGRectMake(0, 0, pageView.bounds.size.width, pageView.bounds.size.height);
    page.tableView.backgroundColor = [UIColor colorWithRed:1.0 green:0.6743 blue:0.144 alpha:1.0];
    view = page.tableView;
    return view;
}

- (void)pageScrollView:(PageScrollView *)pageView didLoadItemAtIndex:(NSInteger)index {
    NSLog(@"滑动到第 %@ 页",@(index+1));
    [[self getViewCtrWithIndex:index] didMoveToParentViewController:self];
}

- (void)didClickPage:(PageScrollView *)pageView atIndex:(NSInteger)index {
//    NSLog(@"点击了第 %@ 页",@(index+1));
}

- (void)pageScrollViewWillBeginDragging:(PageScrollView *)pageView {
    [self.pgScrollView cancelTimer];
}
- (void)pageScrollViewWillEndDragging:(PageScrollView *)pageView {
    [self.pgScrollView startTimer];
}
@end
