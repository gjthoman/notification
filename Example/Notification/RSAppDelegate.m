//
//  RSAppDelegate.m
//  Notification
//
//  Created by Greg Thoman on 11/18/2015.
//  Copyright (c) 2015 Greg Thoman. All rights reserved.
//

#import "RSAppDelegate.h"
#import "RSNotifications.h"

@implementation RSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

    UIViewController *view = [[UIViewController alloc]init];
    self.window.rootViewController = view;

    [self.window makeKeyAndVisible];
    
    RSNotifications *notifications = [[RSNotifications notificationManager]init];

    notifications.vc = view;
    notifications.enabled = true;
    
    notifications.messageTitle = @"Theme Hours";
    notifications.messageBody = @"Would you like a notification when we have a special show hour?";
    notifications.messageLabelLater = @"Maybe Later";
    
    notifications.settingsAlertTitle = @"Toggle Notifications";
    notifications.logging = true;
    
    notifications.customValidation = ^BOOL{
        if ( ![[[RSNotifications notificationManager]init] isLessThanOS8] ){
            UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
            
            if (grantedSettings.types == UIUserNotificationTypeNone) {
                return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    };

    notifications.onVerificationComplete = ^{
        NSLog(@"callback override");
    };

    notifications.onYes = ^{
        NSLog(@"YES");
    };
    notifications.onLater = ^{
        NSLog(@"LATER");
    };
    notifications.onNever = ^{
        NSLog(@"NEVER");
    };
    
    [notifications run];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
