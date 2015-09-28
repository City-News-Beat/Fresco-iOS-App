//
//  AppDelegate+Additons.m
//  Fresco
//
//  Created by Elmir Kouliev on 9/22/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

#import "AppDelegate+Additions.h"
#import "FRSDataManager.h"
#import "HighlightsViewController.h"
#import "GalleryViewController.h"
#import "AssignmentsViewController.h"
#import "FRSRootViewController.h"
#import "StoryViewController.h"
#import "FRSStory.h"

@implementation AppDelegate (Additions)

- (void)openGalleryFromPush:(NSString *)galleryId{

    [[FRSDataManager sharedManager] getGallery:galleryId WithResponseBlock:^(id responseObject, NSError *error) {
        
        if (!error && responseObject) {
            
            //Retreieve Gallery View Controller from storyboard
            UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
            
            //Set the tab bar to the first tab
            tabBarController.selectedIndex = 0;
            
            HighlightsViewController *homeVC = (HighlightsViewController *) ([[tabBarController viewControllers][0] viewControllers][0]);
            
            //Retreieve Notifications View Controller from storyboard
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            GalleryViewController *galleryView = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];
            
            [galleryView setGallery:responseObject];
            
            [homeVC.navigationController pushViewController:galleryView animated:YES];
            
        }
    }];

}

- (void)openAssignmentFromPush:(NSString *)assignmentId withNavigation:(BOOL)navigation{

    [[FRSDataManager sharedManager] getAssignment:assignmentId withResponseBlock:^(id responseObject, NSError *error) {
        
        if (!error) {
        
            UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
            
            AssignmentsViewController *assignmentVC = (AssignmentsViewController *) ([[tabBarController viewControllers][3] viewControllers][0]);
            
            [tabBarController setSelectedIndex:3];
            
            [assignmentVC setCurrentAssignment:responseObject navigateTo:navigation present:YES withAnimation:NO];
            
        }
    
    }];

}

- (void)openStoryFromPush:(NSString *)storyId{

    

}

- (void)openGalleryListFromPush:(NSArray *)galleries withTitle:(NSString *)navTitle{

    [[FRSDataManager sharedManager] resolveGalleriesInList:galleries withResponseBlock:^(id responseObject, NSError *error) {
        
        if(responseObject != nil){
            
            //Retreieve Gallery View Controller from storyboard
            UITabBarController *tabBarController = ((UITabBarController *)((FRSRootViewController *)[UIApplication sharedApplication].keyWindow.rootViewController).viewController);
            
            //Set the tab bar to the first tab
            tabBarController.selectedIndex = 0;
            
            UIViewController *homeVC = ([[tabBarController viewControllers][0] viewControllers][0]);
            
            //Retreieve Notifications View Controller from storyboard
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
            
            StoryViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"storyViewController"];
            svc.galleries = responseObject;
            
            svc.story = [[FRSStory alloc] initWithDictionary:@{@"title" : navTitle ? navTitle : TODAY_TITLE} error:nil];
            
            [homeVC.navigationController pushViewController:svc animated:YES];
            
        }
        
    }];
}


@end
