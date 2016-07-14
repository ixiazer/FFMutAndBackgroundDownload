//
//  FFDownloadingViewController.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFDownloadItem.h"

@interface FFDownloadingViewController : UIViewController

- (void)handleDownload:(FFDownloadItem *)item;

@end
