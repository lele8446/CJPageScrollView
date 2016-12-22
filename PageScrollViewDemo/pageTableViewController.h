//
//  pageTableViewController.h
//  pageScrollView
//
//  Created by C.K.Lian on 16/4/11.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface pageTableViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@end
