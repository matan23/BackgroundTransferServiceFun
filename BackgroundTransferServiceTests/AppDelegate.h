//
//  AppDelegate.h
//  BackgroundTransferServiceTests
//
//  Created by Mathieu Tan on 11/24/15.
//  Copyright © 2015 Mathieu Tan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) void (^sessionCompletionHandler)();

@end

