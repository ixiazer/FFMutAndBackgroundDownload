//
//  AppDelegate.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "AppDelegate.h"
#import "FFDownloadingViewController.h"
#import "FFDownloadSucViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    FFDownloadingViewController *downloadingVC = [[FFDownloadingViewController alloc] init];

    UINavigationController *downloadingNav = [[UINavigationController alloc] initWithRootViewController:downloadingVC];
    downloadingNav.tabBarItem.title = @"下载";
    downloadingNav.tabBarItem.image = [UIImage imageNamed:@""];
    
    FFDownloadSucViewController *downloadSucVC = [[FFDownloadSucViewController alloc] init];

    UINavigationController *downloadSucNav = [[UINavigationController alloc] initWithRootViewController:downloadSucVC];
    downloadSucNav.tabBarItem.title = @"成功";
    downloadSucNav.tabBarItem.image = [UIImage imageNamed:@""];
    
    UITabBarController *tabbarController = [[UITabBarController alloc] init];
    tabbarController.viewControllers = @[downloadingNav,downloadSucNav];

    self.window.rootViewController = tabbarController;

    __weak typeof(self) this = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [this configDownloadtask];
    });
    
    return YES;
}

- (void)configDownloadtask {
    __weak typeof(self) this = self;
    [self.downloadHandle configDownloadResultBlock:^(FFDownloadItem *response) {
        if (this.downloadingVC) {
            [this.downloadingVC handleDownload:response];
        }
    }];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.backgroundURLSessionCompletionHandler = completionHandler;
}

+ (AppDelegate *)appDelegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark -- get method
- (FFDownloadHandle *)downloadHandle {
    if (!_downloadHandle) {
        _downloadHandle = [[FFDownloadHandle alloc] init];
    }
    return _downloadHandle;
}

@end
