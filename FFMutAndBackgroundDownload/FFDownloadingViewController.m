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
#import "FFFileManager.h"

#define FFShowAlertView(_message_)  UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:_message_ delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];\
[alertView show];


@interface FFDownloadingViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSArray *willDownloadSource;
@property (nonatomic, strong) UITableView *tableList;
@property (nonatomic, strong) NSMutableArray *downloadTasks;
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
    
    self.downloadTasks = [NSMutableArray arrayWithArray:[FFFileManager getPlistModelData]];
    [self.tableList reloadData];
}

- (void)initData {
    self.willDownloadSource = @[@{@"name":@"QQmusic",@"url":@"http://soft.duote.com.cn/qqmusic2015_12.68.3461.0620.zip"},
  @{@"name":@"酷狗",@"url":@"http://soft.duote.com.cn/kugou_8.0.71.exe"},
  @{@"name":@"点歌系统",@"url":@"http://soft.duote.com.cn/xzcvbjew_5.2.0.3_10.exe"},@{@"name":@"UC Web",@"url":@"http://soft.duote.com.cn/ucweb_5.6.14087.7.exe"},
                                @{@"name":@"IE浏览器",@"url":@"http://soft.duote.com.cn/ie6setup.zip"}];

    
}

#pragma mark -- method
- (void)addNewDownTask:(id)sender {
    if (self.downloadTasks.count >= self.willDownloadSource.count) {
        return;
    }
    NSDictionary *willAddTask = self.willDownloadSource[self.downloadTasks.count];
    
    FFDownloadItem *downloadItem = [[FFDownloadItem alloc] init];
    downloadItem.downloadTaskName = willAddTask[@"name"];
    downloadItem.identifier = [[NSProcessInfo processInfo] globallyUniqueString];
    downloadItem.downloadUrl = willAddTask[@"url"];

    [self.downloadTasks addObject:downloadItem];
    
    [FFFileManager saveModelDataToPlist:self.downloadTasks];
    
    [self.tableList reloadData];
    
    FFDownloadHandle *downloadHandle = [AppDelegate appDelegate].downloadHandle;
    [downloadHandle startDownload:downloadItem.identifier downloadUrl:downloadItem.downloadUrl];
}

- (void)handleDownload:(FFDownloadItem *)item {
    NSInteger index = [self getTaskIndex:item];

    [self updateCell:index];
}

- (NSInteger)getTaskIndex:(FFDownloadItem *)item {
    NSInteger index = 0;
    [self.lock lock];
    for (FFDownloadItem *eachItem in self.downloadTasks) {
        if ([item.identifier isEqualToString:eachItem.identifier]) {
            index = [self.downloadTasks indexOfObject:eachItem];
            item.downloadTaskName = eachItem.downloadTaskName;

            if (item.downloadStatus == FFDownloadBackgroudSuccuss || item.downloadStatus == FFDownloadPause || item.downloadStatus == FFDownloadCancle || item.downloadStatus == FFDownloadFail) {
                item.hasDownloadLength = eachItem.hasDownloadLength;
                item.totalLength = eachItem.totalLength;
            }
            [self.downloadTasks replaceObjectAtIndex:index withObject:item];

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
    
    [cell configData:self.downloadTasks[indexPath.row]];
    [self.lock unlock];
}

#pragma mark -- UITableviewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.downloadTasks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [FFBaseTableViewCell getHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FFBaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[FFBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    [cell configData:self.downloadTasks[indexPath.row]];
    
    return cell;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"开启下载",@"暂停下载",@"重新下载",@"取消下载", nil];
    sheet.tag = 100+indexPath.row;
    [sheet showInView:self.view];
}

#pragma mark -- UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    FFDownloadItem *item = self.downloadTasks[actionSheet.tag-100];
    if (item) {
        if (item.downloadStatus == FFDownloadIng) {
            if (buttonIndex == 0) {
                FFShowAlertView(@"此任务正在进行");
            } else if (buttonIndex == 1) {
                [[AppDelegate appDelegate].downloadHandle pauseDownload:item.identifier];
            } else if (buttonIndex == 2) {
                FFShowAlertView(@"此任务正在进行");
            } else if (buttonIndex == 3) {
                [[AppDelegate appDelegate].downloadHandle cancleDownload:item.identifier];
            }
        } else if (item.downloadStatus == FFDownloadPause) {
            if (buttonIndex == 0) {
                FFShowAlertView(@"此任务暂停中");
            } else if (buttonIndex == 1) {
                FFShowAlertView(@"此任务暂停中");
            } else if (buttonIndex == 2) {
                [[AppDelegate appDelegate].downloadHandle resumeDownload:item.identifier];
            } else if (buttonIndex == 3) {
                [[AppDelegate appDelegate].downloadHandle cancleDownload:item.identifier];
            }
        } else if (item.downloadStatus == FFDownloadCancle) {
            if (buttonIndex == 0) {
                [[AppDelegate appDelegate].downloadHandle startDownload:item.identifier downloadUrl:item.downloadUrl];
            } else if (buttonIndex == 1) {
                FFShowAlertView(@"此任务已经取消");
            } else if (buttonIndex == 2) {
                FFShowAlertView(@"此任务已经取消");
            } else if (buttonIndex == 3) {
                FFShowAlertView(@"此任务已经取消");
            }
        } else if (item.downloadStatus == FFDownloadBackgroudSuccuss) {
            FFShowAlertView(@"此任务已经完成");
        }
    }
}

#pragma mark -- get method
- (NSMutableArray *)downloadTasks {
    if (!_downloadTasks) {
        _downloadTasks = [NSMutableArray new];
    }
    return _downloadTasks;
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
