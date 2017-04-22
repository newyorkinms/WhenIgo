//
//  AppDelegate.m
//  BZTimeCheck
//
//  Created by 강문성 on 2017. 4. 8..
//  Copyright © 2017년 강문성. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!error) {
                                  //NSLog(@"request succeeded!");
                                  //[self testAlrt];
                              }
                          }];
    
    /**
     카테고리 등록
     */
    UNNotificationCategory* generalCategory = [UNNotificationCategory
                                               categoryWithIdentifier:@"GENERAL"
                                               actions:@[]
                                               intentIdentifiers:@[]
                                               options:UNNotificationCategoryOptionCustomDismissAction];
    
    // Register the notification categories.
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    
    UIApplicationShortcutItem *shortcutItem = launchOptions[UIApplicationLaunchOptionsShortcutItemKey];
    if( shortcutItem != nil ){
        
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if(application.applicationState == UIApplicationStateActive){
        
        // Foreground에서 알림 수신
    }
    
    if(application.applicationState == UIApplicationStateInactive){
        
        // Background에서 알림 액션에 의한 수신
        // notification.userInfo 이용하여 처리
    }
}
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL succeeded))completionHandler{
    if( [[shortcutItem type] isEqualToString:@"Start"] ){
        NSLog(@"####");
        NSDate *startDate = [NSDate date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd    HH:mm:ss"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        NSString *str = [dateFormatter stringFromDate:[NSDate date]];

        [[NSUserDefaults standardUserDefaults] setObject:startDate forKey:@"TEMP_START_TIME"];
    } else if( [[shortcutItem type] isEqualToString:@"End"] ){
        NSLog(@"####");
        NSDate *endDate = [NSDate date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd    HH:mm:ss"];
        // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
        NSString *str = [dateFormatter stringFromDate:[NSDate date]];
        
        [[NSUserDefaults standardUserDefaults] setObject:endDate forKey:@"END_TIME"];
    }
    [[NSUserDefaults standardUserDefaults]synchronize];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"####  didReceiveNotificationResponse");
    if ([response.notification.request.content.categoryIdentifier isEqualToString:@"TIMER_EXPIRED"]) {
        // Handle the actions for the expired timer.
        if ([response.actionIdentifier isEqualToString:@"SNOOZE_ACTION"])
        {
            // Invalidate the old timer and create a new one. . .
        }
        else if ([response.actionIdentifier isEqualToString:@"STOP_ACTION"])
        {
            // Invalidate the timer. . .
        }
        
    }
    
    // Else handle actions for other notification types. . .
}
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    // Update the app interface directly.
    
    // Play a sound.
    completionHandler(UNNotificationPresentationOptionSound);
}
@end
