//
//  FFDownloadHandle.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDownloadHandle.h"
#import "AppDelegate.h"
#import "FFDownloadItem.h"
#import "FFFileManager.h"

@interface FFDownloadHandle () <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionDataDelegate, NSURLSessionDelegate>
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, copy) void(^downloadResultBlock)(FFDownloadItem *response);
@property (nonatomic, strong) NSMutableArray *downloadItems;
@property (nonatomic, strong) NSLock *lock;
@end

@implementation FFDownloadHandle


- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundSession = [self getBackgroundSession];
        
        __weak typeof(self) this = self;
        [self.backgroundSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            self.downloadItems = [NSMutableArray arrayWithArray:downloadTasks];
            if (self.downloadItems.count > 0) {
                [this recoverDownloadItems:self.downloadItems];
            }
        }];
    }
    
    return self;
}

- (void)configDownloadResultBlock:(void(^)(FFDownloadItem *response))downloadResultBlock {
    self.downloadResultBlock = downloadResultBlock;
}

#pragma mark -- method,下载任务相关
- (void)startDownload:(NSString *)identifier downloadUrl:(NSString *)downloadUrl {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identifier];
    if (task) {
        NSLog(@"此下载任务已经存在");
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    NSURLSessionDownloadTask *backgroundSessionTask = [self.backgroundSession downloadTaskWithRequest:request];
    backgroundSessionTask.taskDescription = identifier;
    [backgroundSessionTask resume];
    
    FFDownloadItem *item = [[FFDownloadItem alloc] init];
    item.identifier = identifier;
    item.downloadUrl = downloadUrl;
    item.downloadTask = backgroundSessionTask;
    
    [self.downloadItems addObject:item];
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (this.downloadResultBlock) {
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadStart identity:identifier hasDownloadLength:0 totalLength:0]);
        }
    });
}

- (void)pauseDownload:(NSString *)identifier {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identifier];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        [task suspend];
    }
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (this.downloadResultBlock) {
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadPause identity:identifier hasDownloadLength:0 totalLength:0]);
        }
    });
}

- (void)resumeDownload:(NSString *)identifier {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identifier];
    if (task && task.state == NSURLSessionTaskStateSuspended) {
        [task resume];
    }
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (this.downloadResultBlock) {
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadResume identity:identifier hasDownloadLength:0 totalLength:0]);
        }
    });
}

- (void)cancleDownload:(NSString *)identifier {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identifier];
    if (task && (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended)) {
        [task cancel];
        task = nil;
        
        [self removeDownloadTask:identifier];
    }
    
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (this.downloadResultBlock) {
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadCancle identity:identifier hasDownloadLength:0 totalLength:0]);
        }
    });
}

#pragma mark -- method
- (void)recoverDownloadItems:(NSArray *)tasks {
    self.downloadItems = [NSMutableArray new];
    for (NSURLSessionDownloadTask *task in tasks) {
        FFDownloadItem *item = [[FFDownloadItem alloc] init];
        item.identifier = task.taskDescription;
        item.downloadUrl = [task.currentRequest.URL absoluteString];
        item.downloadTask = task;
        
        if (task.state == NSURLSessionTaskStateRunning) {
            item.downloadStatus = FFDownloadIng;
        } else if (task.state == NSURLSessionTaskStateSuspended) {
            item.downloadStatus = FFDownloadPause;
        } else if (task.state == NSURLSessionTaskStateCanceling) {
            item.downloadStatus = FFDownloadCancle;
        } else if (task.state == NSURLSessionTaskStateCompleted) {
            item.downloadStatus = FFDownloadBackgroudSuccuss;
        }
        
        [self.downloadItems addObject:item];
    }
}

- (NSURLSessionDownloadTask *)getDownloadtask:(NSString *)identifier {
    [self.lock lock];
    if (self.downloadItems.count > 0) {
        for (FFDownloadItem *item in self.downloadItems) {
            if ([item.identifier isEqualToString:identifier]) {
                [self.lock unlock];
                return item.downloadTask;
            }
        }
    }
    [self.lock unlock];
    return nil;
}

- (BOOL)removeDownloadTask:(NSString *)identifier {
    if (self.downloadItems.count > 0) {
        for (FFDownloadItem *item in self.downloadItems) {
            if ([item.identifier isEqualToString:identifier]) {
                [self.downloadItems removeObject:item];
                
                break;
            }
        }
    }
    return YES;
}

- (BOOL)saveDownloadFile:(NSString *)identifier location:(NSURL *)location {
    // 移除下载任务
    NSURLSessionDownloadTask *task = [self getDownloadtask:identifier];
    if (task && (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended)) {
        [task cancel];
        task = nil;
        
        [self removeDownloadTask:identifier];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *targetFile = [NSString stringWithFormat:@"file://%@",[FFFileManager getFullFile:identifier]];
    NSURL *targetFileUrl = [NSURL URLWithString:targetFile];
    NSLog(@"targetFile==>>%@",targetFileUrl.absoluteString);
//    [fileManager removeItemAtURL:targetFile error:NULL];
    NSError *error;
    BOOL success = [fileManager copyItemAtURL:location toURL:targetFileUrl error:&error];
    if (success) {
        __weak typeof(self) this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (this.downloadResultBlock) {
                this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadBackgroudSuccuss identity:identifier hasDownloadLength:0 totalLength:0]);
            }
        });
    }

    return YES;
}

#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
//    NSLog(@"下载字节==>>%f/%f",(double)totalBytesWritten,(double)totalBytesExpectedToWrite);
    __weak typeof(self) this = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (this.downloadResultBlock) {
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadIng identity:downloadTask.taskDescription hasDownloadLength:totalBytesWritten totalLength:totalBytesExpectedToWrite]);
        }
    });
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    [self saveDownloadFile:downloadTask.taskDescription location:location];
}

#pragma mark - NSURLSessionDelegate
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.backgroundURLSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundURLSessionCompletionHandler;
        appDelegate.backgroundURLSessionCompletionHandler = nil;
        completionHandler();
    }
    NSLog(@"全部任务已完成!");
}

#pragma mark -- NSURLSessionDataDelegate
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        NSLog(@"下载成功");
    } else {
        __weak typeof(self) this = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            this.downloadResultBlock([FFDownloadItem getDownloadRespose:FFDownloadFail identity:task.taskDescription hasDownloadLength:0 totalLength:0]);
        });
    }
}

#pragma mark -- get method
- (NSURLSession *)getBackgroundSession {
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.freshfresh.backgroundsession"];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    });
    return session;
}

- (NSMutableArray *)downloadItems {
    if (!_downloadItems) {
        _downloadItems = [NSMutableArray new];
    }
    
    return _downloadItems;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [[NSLock alloc] init];
    }
    return _lock;
}

@end
