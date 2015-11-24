//
//  ViewController.m
//  BackgroundTransferServiceTests
//
//  Created by Mathieu Tan on 11/24/15.
//  Copyright © 2015 Mathieu Tan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString *downloadURLString = @"http://mirror.internode.on.net/pub/test/10meg.test";
//static NSString *downloadURLString = @"http://www.fujifilm.com/products/digital_cameras/x/fujifilm_x10/sample_images/img/index/ff_x10_022.JPG";

//@interface ViewController () <NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate>
@interface ViewController () <NSURLSessionDownloadDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSURLSessionDownloadTask *downloadTask;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
//    this should use backgroundURLSession of appDelegate
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"io.objc.backgroundTransferExample"];
    
    conf.allowsCellularAccess = YES;
    
    _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    _downloadTask = [_session downloadTaskWithRequest:request];
    
    [_downloadTask resume];
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)downloadURL {
    NSLog(@"%s:%@", __PRETTY_FUNCTION__, @"Copying image file");

    //    get documents directory
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *documentsDirectory = [URLs objectAtIndex:0];
    
//    build destination URL
    NSURL *fromURL = [[downloadTask originalRequest] URL];
    NSURL *destinationURL = [documentsDirectory URLByAppendingPathComponent:[fromURL lastPathComponent]];
    
//    remove file at the destination if it already exists
    [fileManager removeItemAtURL:destinationURL error:nil];

    NSError *error;
    BOOL success = [fileManager copyItemAtURL:downloadURL toURL:destinationURL error:&error];

    if (success) {
//        UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _imageView.image = image;
//        });
        NSLog(@"File successfully downloaded");
    } else {
        NSLog(@"File copy failed: %@", error.localizedDescription);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil) {
        NSLog(@"Task %@ completed successfully", task);
        [self presentNotificationAppWasSuspended:NO];
    }
    else {
        NSLog(@"Task %@ completed with error: %@", task,
              [error localizedDescription]);
    }
    _downloadTask = nil;
}
//called after application: handleEventsForBackgroundURLSession:
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    //    should verify identifier to call the matching completion handler see https://www.objc.io/issues/5-ios7/multitasking/#nsurlsessiondownloadtask
    if (appDelegate.sessionCompletionHandler) {
        [self presentNotificationAppWasSuspended:NO];
        appDelegate.sessionCompletionHandler();
    }
    NSLog(@"Task complete");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"bytes written to file %lld/%lld", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"bytes transferred: %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
    
//    static int i;
//    
//    if (i++ == 0) {
//        [NSThread sleepForTimeInterval:3];
//    }
}

-(void)presentNotificationAppWasSuspended:(BOOL)wasSuspended {
    dispatch_async(dispatch_get_main_queue(), ^{
        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
        
        if (!wasSuspended) {
            localNotification.alertBody = @"Download Complete!";
            localNotification.alertAction = @"Background Transfer Download!";
        } else {
            localNotification.alertBody = @"Completed while the app was suspended!";
            localNotification.alertAction = @"Background Transfer Download while the app was suspended!";
        }
        
        //On sound
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        
        //increase the badge number of application plus 1
        localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
        
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    });
    
}
@end
