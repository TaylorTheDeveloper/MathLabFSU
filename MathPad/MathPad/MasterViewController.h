//
//  MasterViewController.h
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>
#import "LoginViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "ModifyUserViewController.h"

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate, DBRestClientDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;
@property (strong, nonatomic) id comparativeObject;
@property (strong, nonatomic) NSMutableArray *studentArray;

- (void)reloadTables;


@end
