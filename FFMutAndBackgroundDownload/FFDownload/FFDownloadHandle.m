//
//  FFDownloadHandle.m
//  FFMutAndBackgroundDownload
//
//  Created by ixiazer on 16/7/13.
//  Copyright © 2016年 FF. All rights reserved.
//

#import "FFDownloadHandle.h"
#import "FFDownloadResponse.h"
#import "AppDelegate.h"
#import "FFDownloadItem.h"
#import "FFFileManager.h"

@interface FFDownloadHandle () <NSURLSessionDownloadDelegate, NSURLSessionDataDelegate, NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *backgroundSession;
@property (nonatomic, copy) void(^downloadResultBlock)(FFDownloadResponse *response);
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

- (void)configDownloadResultBlock:(void(^)(FFDownloadResponse *response))downloadResultBlock {
    self.downloadResultBlock = downloadResultBlock;
}

#pragma mark -- method,下载任务相关
- (void)startDownload:(NSString *)identify downloadUrl:(NSString *)downloadUrl {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identify];
    if (task) {
        NSLog(@"此下载任务已经存在");
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
    NSURLSessionDownloadTask *backgroundSessionTask = [self.backgroundSession downloadTaskWithRequest:request];
    backgroundSessionTask.taskDescription = identify;
    [backgroundSessionTask resume];
    
    if (self.downloadResultBlock) {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadStart identity:identify hasDownloadLength:0 totalLength:0]);
    }
}

- (void)pauseDownload:(NSString *)identify {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identify];
    if (task && task.state == NSURLSessionTaskStateRunning) {
        [task suspend];
    }
    
    if (self.downloadResultBlock) {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadPause identity:identify hasDownloadLength:0 totalLength:0]);
    }
}

- (void)resumeDownload:(NSString *)identify {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identify];
    if (task && task.state == NSURLSessionTaskStateSuspended) {
        [task resume];
    }
    
    if (self.downloadResultBlock) {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadResume identity:identify hasDownloadLength:0 totalLength:0]);
    }
}

- (void)cancleDownload:(NSString *)identify {
    NSURLSessionDownloadTask *task = [self getDownloadtask:identify];
    if (task && (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended)) {
        [task cancel];
        task = nil;
        
        [self removeDownloadTask:identify];
    }
    
    if (self.downloadResultBlock) {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadCancle identity:identify hasDownloadLength:0 totalLength:0]);
    }
}

#pragma mark -- method
- (void)recoverDownloadItems:(NSArray *)tasks {
    self.downloadItems = [NSMutableArray new];
    for (NSURLSessionDownloadTask *task in tasks) {
        FFDownloadItem *item = [[FFDownloadItem alloc] init];
        item.identifier = task.taskDescription;
        item.downloadUrl = [task.currentRequest.URL absoluteString];
        item.downloadTask = task;
        
        [self.downloadItems addObject:item];
    }
}

- (NSURLSessionDownloadTask *)getDownloadtask:(NSString *)identify {
    [self.lock lock];
    if (self.downloadItems.count > 0) {
        for (FFDownloadItem *item in self.downloadItems) {
            if ([item.identifier isEqualToString:identify]) {
                [self.lock unlock];
                return item.downloadTask;
            }
        }
    }
    [self.lock unlock];
    return nil;
}

- (BOOL)removeDownloadTask:(NSString *)identify {
    if (self.downloadItems.count > 0) {
        for (FFDownloadItem *item in self.downloadItems) {
            if ([item.identifier isEqualToString:identify]) {
                [self.downloadItems removeObject:item];
                
                break;
            }
        }
    }
    return YES;
}

- (BOOL)saveDownloadFile:(NSString *)identify location:(NSURL *)location {
    // 移除下载任务
    NSURLSessionDownloadTask *task = [self getDownloadtask:identify];
    if (task && (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended)) {
        [task cancel];
        task = nil;
        
        [self removeDownloadTask:identify];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSURL *targetFile = [NSURL URLWithString:[FFFileManager getFullFile:identify]];
    [fileManager removeItemAtURL:targetFile error:NULL];
    NSError *error;
    BOOL success = [fileManager copyItemAtURL:location toURL:targetFile error:&error];
    if (success) {
        if (self.downloadResultBlock) {
            self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadBackgroudSuccuss identity:identify hasDownloadLength:0 totalLength:0]);
        }
    }

    return YES;
}

#pragma mark - NSURLSessionDownloadDelegate methods
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"下载字节==>>%f/%f",(double)totalBytesWritten,(double)totalBytesExpectedToWrite);
    if (self.downloadResultBlock) {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadIng identity:downloadTask.taskDescription hasDownloadLength:totalBytesWritten totalLength:totalBytesExpectedToWrite]);
    }
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
    NSLog(@"任务已完成!");
}

#pragma mark -- NSURLSessionDataDelegate
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
    } else {
        self.downloadResultBlock([FFDownloadResponse getDownloadRespose:FFDownloadFail identity:task.taskDescription hasDownloadLength:0 totalLength:0]);
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
