//
//  AppDelegate.h
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, DBRestClientDelegate> {
    DBRestClient *restClient;
}

@property (strong, nonatomic) UIWindow *window;

//@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) UISplitViewController *splitViewController;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;

@end
