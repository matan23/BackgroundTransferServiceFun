//
//  AppDelegate.m
//  BackgroundTransferServiceTests
//
//  Created by Mathieu Tan on 11/24/15.
//  Copyright © 2015 Mathieu Tan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // if the app is not running at all when the background transfer finishes, iOS will launch it into the background, and the preceding application and session delegate methods are called after application:didFinishLaunchingWithOptions:.
    
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

- (NSURLSession *)backgroundURLSession
{
//    delegate method in appDelegate..?
//    mainQueue or backgroundQueue?
    
//    static NSURLSession *session = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        NSString *identifier = @"io.objc.backgroundTransferExample";
//        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:identifier];
//        session = [NSURLSession sessionWithConfiguration:sessionConfig
//                                                delegate:self
//                                           delegateQueue:[NSOperationQueue mainQueue]];
//    });
//    
//    return session;
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    //    should verify identifier to call the matching completion handler see https://www.objc.io/issues/5-ios7/multitasking/#nsurlsessiondownloadtask

//    from objc.io
    // You must re-establish a reference to the background session,
    // or NSURLSessionDownloadDelegate and NSURLSessionDelegate methods will not be called
    // as no delegate is attached to the session.
//    NSURLSessionConfiguration *config = [self backgroundURLSession];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
//    
////    from realm.io talk
//    [session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
////        
//    }];
//    
    
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.sessionCompletionHandler = completionHandler;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // if the app is not running at all when the background transfer finishes, iOS will launch it into the background, and the preceding application and session delegate methods are called after application:didFinishLaunchingWithOptions:.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
