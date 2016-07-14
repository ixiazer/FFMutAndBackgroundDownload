//
//  FFBaseTableViewCell.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/14.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FFBaseTableViewCell : UITableViewCell

- (BOOL)configData:(id)data;

+ (CGFloat)getHeight;

@end
