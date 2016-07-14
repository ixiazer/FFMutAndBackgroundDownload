//
//  FFBaseTableViewCell.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/14.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFBaseTableViewCell.h"
#import "FFDownloadItem.h"

@interface FFBaseTableViewCell ()
@property (nonatomic, strong) UILabel *taskName;
@property (nonatomic, strong) UILabel *taskStatus;
@property (nonatomic, strong) UILabel *taskProgress;
@end

@implementation FFBaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self.contentView addSubview:self.taskName];
    [self.contentView addSubview:self.taskStatus];
    [self.contentView addSubview:self.taskProgress];
}

- (BOOL)configData:(id)data {
    if ([data isKindOfClass:[FFDownloadItem class]]) {
        FFDownloadItem *item = (FFDownloadItem *)data;
        
        self.taskName.text = [NSString stringWithFormat:@"下载任务:%@",item.downloadTaskName];
        NSString *status;
        if (item.downloadStatus == FFDownloadBackgroudSuccuss) {
            status = @"下载成功";
        } else if (item.downloadStatus == FFDownloadFail) {
            status = @"下载失败";
        } else if (item.downloadStatus == FFDownloadStart) {
            status = @"开始下载";
        } else if (item.downloadStatus == FFDownloadIng) {
            status = @"下载中...";
        } else if (item.downloadStatus == FFDownloadPause) {
            status = @"下载暂停";
        } else if (item.downloadStatus == FFDownloadResume) {
            status = @"下载重启";
        } else if (item.downloadStatus == FFDownloadCancle) {
            status = @"下载取消";
        }
        
        self.taskStatus.text = [NSString stringWithFormat:@"下载任务:%@",status];
        self.taskProgress.text = [NSString stringWithFormat:@"下载进度:%.2f/%.2f",item.hasDownloadLength,item.totalLength];
    }
    
    return YES;
}

+ (CGFloat)getHeight {
    return 70;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- get method
- (UILabel *)taskName {
    if (!_taskName) {
        _taskName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 15)];
        _taskName.text = @"下载任务:";
    }
    
    return _taskName;
}

- (UILabel *)taskStatus {
    if (!_taskStatus) {
        _taskStatus = [[UILabel alloc] initWithFrame:CGRectMake(10, 5+20, 300, 15)];
        _taskStatus.text = @"下载状态:";
    }
    
    return _taskStatus;
}

- (UILabel *)taskProgress {
    if (!_taskProgress) {
        _taskProgress = [[UILabel alloc] initWithFrame:CGRectMake(10, 5+40, 300, 15)];
        _taskProgress.text = @"下载进度:";
    }
    
    return _taskProgress;
}

@end
