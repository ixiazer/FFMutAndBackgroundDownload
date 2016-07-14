//
//  AppDelegate.h
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFDownloadHandle.h"
#import "FFDownloadingViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FFDownloadHandle *downloadHandle;
@property (weak, nonatomic) FFDownloadingViewController *downloadingVC;

@property (copy) void (^backgroundURLSessionCompletionHandler)();

+ (AppDelegate *)appDelegate;

@end

