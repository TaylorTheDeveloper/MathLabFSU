//
//  AppDelegate.m
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MasterViewController.h"

// Change these for FSU Math's Dropbox account. Using beta.testers.iphone@gmail.com account

//#define kAccessToken @"fvhj0j4m21hqu2g"
//#define kTokenSecret @"14rzja9lp2l09nt"
//#define kUserId @"108907597"

//kclark@fsu.edu
#define kAccessToken @"dyfk5nrso9ny802"
#define kTokenSecret @"ginl94u7jcauaff"
#define kUserId @"115659561"

@implementation AppDelegate

//@synthesize managedObjectContext = _managedObjectContext;
//@synthesize managedObjectModel = _managedObjectModel;
//@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize splitViewController = _splitViewController;
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    UINavigationController *navigationController = [_splitViewController.viewControllers lastObject];
    _splitViewController = (UISplitViewController *)self.window.rootViewController;
    _splitViewController.delegate = (id)navigationController.topViewController;
    UINavigationController *masterNavigationController = [_splitViewController.viewControllers objectAtIndex:0];
    MasterViewController *controller = (MasterViewController *)masterNavigationController.topViewController;
    [self.window makeKeyAndVisible];
    LoginViewController *login = [_splitViewController.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [_splitViewController presentModalViewController:login animated:NO];
    controller.loginViewController = login;
    DBSession* dbSession =
    [[DBSession alloc]
     initWithAppKey:@"d6phjzq6awf4uhj"
     appSecret:@"6iivuc1epb0swip"
     root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
    [dbSession updateAccessToken:kAccessToken accessTokenSecret:kTokenSecret forUserId:kUserId];
    [DBSession setSharedSession:dbSession];
//    [[self restClient] loadMetadata:@"/.validation"];
    /*if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:login];
    }*/
    return YES;
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@".validation"]];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    [[self restClient] uploadFile:@".validation" toPath:@"/" withParentRev:nil fromPath:filePath];
}


- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

/*- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url  {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        NSLog(@"%@", [url description]);
    }
}*/

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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *path in directoryContents) {
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:nil];
    }
    
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

//- (void)saveContext
//{
//    NSError *error = nil;
//    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
//    if (managedObjectContext != nil) {
//        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
//             // Replace this implementation with code to handle the error appropriately.
//             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        } 
//    }
//}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
//- (NSManagedObjectContext *)managedObjectContext
//{
//    if (_managedObjectContext != nil) {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return _managedObjectContext;
//}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (_managedObjectModel != nil) {
//        return _managedObjectModel;
//    }
//    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MathPad" withExtension:@"momd"];
//    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    return _managedObjectModel;
//}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil) {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MathPad.sqlite"];
//    
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
//    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//         
//         Typical reasons for an error here include:
//         * The persistent store is not accessible;
//         * The schema for the persistent store is incompatible with current managed object model.
//         Check the error message to determine what the actual problem was.
//         
//         
//         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
//         
//         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
//         * Simply deleting the existing store:
//         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
//         
//         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
//         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
//         
//         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
//         
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }    
//    
//    return _persistentStoreCoordinator;
//}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
