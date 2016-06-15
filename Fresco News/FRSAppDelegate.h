//
//  FRSAppDelegate.h
//  Fresco
//
//  Created by Daniel Sun on 12/18/15.
//  Copyright © 2015 Fresco. All rights reserved.
//

//_          _           _           _             _             _
///\ \       /\ \        /\ \        / /\         /\ \           /\ \
///  \ \     /  \ \      /  \ \      / /  \       /  \ \         /  \ \
/// /\ \ \   / /\ \ \    / /\ \ \    / / /\ \__   / /\ \ \       / /\ \ \
/// / /\ \_\ / / /\ \_\  / / /\ \_\  / / /\ \___\ / / /\ \ \     / / /\ \ \
/// /_/_ \/_// / /_/ / / / /_/_ \/_/  \ \ \ \/___// / /  \ \_\   / / /  \ \_\
/// /____/\  / / /__\/ / / /____/\      \ \ \     / / /    \/_/  / / /   / / /
/// /\____\/ / / /_____/ / /\____\/  _    \ \ \   / / /          / / /   / / /
/// / /      / / /\ \ \  / / /______ /_/\__/ / /  / / /________  / / /___/ / /
/// / /      / / /  \ \ \/ / /_______\\ \/___/ /  / / /_________\/ / /____\/ /
//\/_/       \/_/    \_\/\/__________/ \_____\/   \/____________/\/_________/
//

#import <UIKit/UIKit.h>
#import <Fabric/Fabric.h>
#import <TwitterKit/TwitterKit.h>
#import <Crashlytics/Crashlytics.h>

@interface FRSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) id tabBarController;
-(void)reloadUser;
- (void)saveContext;
@end
