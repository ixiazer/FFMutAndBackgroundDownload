//
//  FFDownloadingViewController.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDownloadingViewController.h"
#import "FFBaseTableViewCell.h"
#import "FFDownloadItem.h"
#import "AppDelegate.h"

@interface FFDownloadingViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *willDownloadSource;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSMutableArray *downloadTask;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation FFDownloadingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [AppDelegate appDelegate].downloadingVC = self;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewDownTask:)];
    self.navigationItem.rightBarButtonItem = rightButton;

    [self initData];

    
    self.tableList = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableList.dataSource = self;
    self.tableList.delegate = self;
    [self.view addSubview:self.tableList];
}

- (void)initData {
//    @{@"name":@"kuaipingp2p_6.4.5_12",@"url":@"http://soft.duote.com.cn/kuaipingp2p_6.4.5_12.exe"},
    self.willDownloadSource = @[@{@"name":@"酷狗",@"url":@"http://soft.duote.com.cn/kugou_8.0.71.exe"},
                               @{@"name":@"QQmusic",@"url":@"http://soft.duote.com.cn/qqmusic2015_12.68.3461.0620.zip"},
                                @{@"name":@"点歌系统",@"url":@"http://soft.duote.com.cn/xzcvbjew_5.2.0.3_10.exe"},@{@"name":@"UC Web",@"url":@"http://soft.duote.com.cn/ucweb_5.6.14087.7.exe"},
                                @{@"name":@"IE浏览器",@"url":@"http://soft.duote.com.cn/ie6setup.zip"}];

    
}

#pragma mark -- method
- (void)addNewDownTask:(id)sender {
    if (self.downloadTask.count >= self.willDownloadSource.count) {
        return;
    }
    NSDictionary *willAddTask = self.willDownloadSource[self.downloadTask.count];
    
    FFDownloadItem *downloadItem = [[FFDownloadItem alloc] init];
    downloadItem.downloadTaskName = willAddTask[@"name"];
    downloadItem.identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    downloadItem.downloadUrl = willAddTask[@"url"];

    [self.downloadTask addObject:downloadItem];
    
    [self.tableList reloadData];
    
    FFDownloadHandle *downloadHandle = [AppDelegate appDelegate].downloadHandle;
    [downloadHandle startDownload:downloadItem.identifier downloadUrl:downloadItem.downloadUrl];
}

- (void)handleDownload:(FFDownloadItem *)item {
    NSInteger index = [self getTaskIndex:item];
    NSLog(@"item.identify===>>%ld/%@/%.0f/%.0f",(long)index,item.identifier,item.hasDownloadLength,item.totalLength);
    
    [self updateCell:index];
}

- (NSInteger)getTaskIndex:(FFDownloadItem *)item {
    NSInteger index = 0;
    [self.lock lock];
    for (FFDownloadItem *eachItem in self.downloadTask) {
        if ([item.identifier isEqualToString:eachItem.identifier]) {
            index = [self.downloadTask indexOfObject:eachItem];
            item.downloadTaskName = eachItem.downloadTaskName;
            [self.downloadTask replaceObjectAtIndex:index withObject:item];

            [self.lock unlock];
            break;
        }
    }
    
    return index;
}

- (void)updateCell:(NSInteger)index {
    [self.lock lock];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    FFBaseTableViewCell *cell = [self.tableList cellForRowAtIndexPath:indexPath];
    
    [cell configData:self.downloadTask[indexPath.row]];
    [self.lock unlock];
}

#pragma mark -- UITableviewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadTask.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FFBaseTableViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FFBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[FFBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [cell configData:self.downloadTask[indexPath.row]];
    
    return cell;
}

#pragma mark -- get method
- (NSMutableArray *)downloadTask {
    if (!_downloadTask) {
        _downloadTask = [NSMutableArray new];
    }
    return _downloadTask;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
