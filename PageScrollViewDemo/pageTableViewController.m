//
//  pageTableViewController.m
//  pageScrollView
//
//  Created by C.K.Lian on 16/4/11.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "pageTableViewController.h"

@implementation pageTableViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.view addSubview:self.tableView];
        [self.tableView reloadData];
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *TableSampleIdentifier = @"TableSampleIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableSampleIdentifier];
    UILabel *label = nil;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableSampleIdentifier];
        label = [[UILabel alloc]initWithFrame:cell.bounds];
        label.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:label];
    }
    label.text = @"";
    label.text = [NSString stringWithFormat:@"%@",@(indexPath.row +1)];
    return cell;
}
@end
