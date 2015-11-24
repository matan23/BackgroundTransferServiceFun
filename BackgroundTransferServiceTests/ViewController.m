//
//  ViewController.m
//  BackgroundTransferServiceTests
//
//  Created by Mathieu Tan on 11/24/15.
//  Copyright © 2015 Mathieu Tan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

static NSString *downloadURLString = @"http://www.fujifilm.com/products/digital_cameras/x/fujifilm_x10/sample_images/img/index/ff_x10_022.JPG";

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
    
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.ebookfrenzy.transfer"];
    conf.allowsCellularAccess = YES;
    
    _session = [NSURLSession sessionWithConfiguration:conf delegate:self delegateQueue:nil];
    
    NSURL *downloadURL = [NSURL URLWithString:downloadURLString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    _downloadTask = [_session downloadTaskWithRequest:request];
    
    
    [NSThread sleepForTimeInterval:3];
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
        UIImage *image = [UIImage imageWithContentsOfFile:[destinationURL path]];
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = image;
        });
    } else {
        NSLog(@"File copy failed: %@", error.localizedDescription);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error == nil)
    {
        NSLog(@"Task %@ completed successfully", task);
    }
    else
    {
        NSLog(@"Task %@ completed with error: %@", task,
              [error localizedDescription]);
    }
    _downloadTask = nil;
}

- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.sessionCompletionHandler) {
        appDelegate.sessionCompletionHandler();
    }
    NSLog(@"Task complete");
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"bytes written to file %lld/%lld", fileOffset, expectedTotalBytes);
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"bytes transferred: %lld/%lld", totalBytesWritten, totalBytesExpectedToWrite);
}

@end
