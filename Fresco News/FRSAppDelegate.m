//
//  FRSAppDelegate.m
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "FRSAppDelegate.h"
#import "FRSTabBarController.h"
#import "FRSOnboardingViewController.h"
#import "FRSSettingsViewController.h"
#import "FRSNavigationController.h"
#import "FRSSignUpViewController.h"
#import "FRSSetupProfileViewController.h"
#import "FRSProfileViewController.h"
#import "FRSLocationManager.h"
#import "FRSCameraViewController.h"
#import <MagicalRecord/MagicalRecord.h>
#import <CoreLocation/CoreLocation.h>

@implementation FRSAppDelegate


#pragma mark - Startup and Application States

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    
    [self configureWindow];
    [self configureThirdPartyApplicationsWithOptions:launchOptions];
    
    [self configureCoreDataStack];
    [self createItemsWithIcons];
    
    self.window.rootViewController = [[FRSTabBarController alloc] init];
    
    if (launchOptions[UIApplicationLaunchOptionsLocationKey]) {
        [self handleLocationUpdate];
    }
    
    return YES;
}

-(void)handleLocationUpdate {
    
}

-(void)applicationDidEnterBackground:(UIApplication *)application{
    
}

-(void)applicationWillResignActive:(UIApplication *)application{
    [[FRSLocationManager sharedManager] pauseLocationMonitoring];
}

-(void)applicationDidBecomeActive:(UIApplication *)application{
    
}

-(void)applicationWillTerminate:(UIApplication *)application{
    [MagicalRecord cleanUp];
}

#pragma mark - Push Notifications

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
}

#pragma mark - App Path

-(void)determineAppPath{

    NSString *versionString = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSArray *versionComps = [versionString componentsSeparatedByString:@"."];
    NSInteger firstVersionNum = [[versionComps firstObject] integerValue];
    
    if (firstVersionNum < 3){ //This is a legacy user from prior to the redesign and persistance layer
        [self configureCoreDataStack];
        
    }
    else if (firstVersionNum == 3){ //This is the current high level version number we are working with.
        [self configureCoreDataStack];
        
    }
    else { //We will eventually need this if our high level verison numbers increment, but for now, it will never get called.
        
    }
    
    
}


#pragma mark - Config

-(void)configureWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor]; // used to be [UIColor whiteBackgroundColor];
    
    [self.window makeKeyAndVisible];
}

-(void)configureThirdPartyApplicationsWithOptions:(NSDictionary *)options{
    
}

-(void)configureCoreDataStack{
    [MagicalRecord setupAutoMigratingCoreDataStack];
    [MagicalRecord setLoggingLevel:MagicalRecordLoggingLevelVerbose];
}


#pragma mark - Quick Actions

- (void)createItemsWithIcons {
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0){
        
        UIApplicationShortcutIcon *camera = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-camera"];
        UIApplicationShortcutIcon *video = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-video"];
        UIApplicationShortcutIcon *map = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick-action-map"];
        
        // create dynamic shortcut items
        UIMutableApplicationShortcutItem *item1 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-camera" localizedTitle:@"Take photo" localizedSubtitle:@"" icon:camera userInfo:nil];
        
        UIMutableApplicationShortcutItem *item2 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-video" localizedTitle:@"Take video" localizedSubtitle:@"" icon:video userInfo:nil];
        
        UIMutableApplicationShortcutItem *item3 = [[UIMutableApplicationShortcutItem alloc]initWithType:@"quick-action-map" localizedTitle:@"Assignments" localizedSubtitle:@"" icon:map userInfo:nil];
        
        // add all items to an array
        NSArray *items = @[item1, item2, item3];
        
        // add the array to our app
        [UIApplication sharedApplication].shortcutItems = items;
    }
}

//- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler{
//    
//    //Which index of the tabbar are we trying to present?
//    // added defaults
//    NSInteger indexToPresent = 2;
//    FRSCaptureMode captureMode = FRSCaptureModePhoto;
//    
//    if ([shortcutItem.localizedTitle isEqual: @"Take photo"]) {
//        indexToPresent = 2;
//        captureMode = FRSCaptureModePhoto;
//        //        [self.frsRootViewController setRootViewControllerToCamera];
//    } else if ([shortcutItem.localizedTitle isEqual: @"Assignments"]) {
//        //        [self.frsRootViewController setRootViewControllerToAssignments];
//        indexToPresent = 3;
//    } else if ([shortcutItem.localizedTitle isEqual: @"Take video"]) {
//        captureMode = FRSCaptureModeVideo;
//        //        [self.frsRootViewController setRootViewControllerToCameraForVideo];
//        indexToPresent = 2;
//    }
//    
//    
//    UIViewController *vc = self.frsRootViewController.viewController;
//    
//    if (!vc)  return;
//    
//    else{
//        FRSTabBarController *tbvc = (FRSTabBarController *)vc;
//        
//        if (tbvc.selectedIndex == indexToPresent){ //we were already on the view controller
//            if (indexToPresent == 2 && [tbvc.presentedViewController isKindOfClass:[FRSCameraViewController class]]){
//                FRSCameraViewController *camVC = (FRSCameraViewController *)tbvc.presentedViewController;
//                
//                if (camVC.isPresented && camVC.captureMode != captureMode){ //The camera was the last visible viewcontroller and the user has not gone to assetpicker or gallerypost but the desired capture mode is different than current capture mode
//                    [camVC toggleCaptureMode];
//                }
//                else if (!camVC.isPresented){ //The tabbar did present the camera vc, but the user moved to the assetpicker or gallery post
//                    [camVC dismissAndReturnToPreviousTab];
//                    captureMode == FRSCaptureModePhoto ? [self.frsRootViewController setRootViewControllerToCamera] : [self.frsRootViewController setRootViewControllerToCameraForVideo];
//                }
//            }
//        }
//        else{ //We were NOT on the correct view controller
//            if (indexToPresent == 2){
//                [[NSUserDefaults standardUserDefaults] setInteger:tbvc.selectedIndex forKey:UD_PREVIOUSLY_SELECTED_TAB];
//                captureMode == FRSCaptureModePhoto ? [self.frsRootViewController setRootViewControllerToCamera] : [self.frsRootViewController setRootViewControllerToCameraForVideo];
//                
//            }
//            else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (tbvc.presentedViewController && [tbvc.presentedViewController isKindOfClass:[FRSCameraViewController class]]){
//                        FRSCameraViewController *camVC = (FRSCameraViewController *)tbvc.presentedViewController;
//                        [camVC dismissViewControllerAnimated:NO completion:^{
//                            [self.frsRootViewController setRootViewControllerToAssignments];
//                        }];
//                    }
//                    else {
//                        [self.frsRootViewController setRootViewControllerToAssignments];
//                    }
//                });
//                
//            }
//        }
//        return;
//    }
//}

#pragma mark - Status Bar
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)){
        [self statusBarTouchedAction];
    }
}

-(void)statusBarTouchedAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification
                                                        object:nil];
}


@end
