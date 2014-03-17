//
//  CreateDetailViewController.h
//  MathPad
//
//  Created by Alex Muller on 9/19/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "CKCalendarView.h"
#import "DetailViewController.h"
//#import "CreateMasterViewController.h"

//@protocol CreateDetailViewControllerDelegate
//- (void)saveSelectionOfCCS:(NSArray *)CCS andFSU:(NSArray *)FSU;
//@end

@class CreateMasterViewController;

@interface CreateDetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DBRestClientDelegate, CKCalendarDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) NSArray *CCSArray;
@property (nonatomic, strong) NSMutableArray *CCSSelected;
@property (nonatomic, strong) NSArray *FSUArray;
@property (nonatomic, strong) NSMutableArray *FSUSelected;
@property (nonatomic, strong) NSMutableArray *FSUSelectedIndexes;
@property (nonatomic, strong) NSMutableArray *CCSSelectedIndexes;
@property (nonatomic, strong) CreateMasterViewController *masterViewController;
@property (nonatomic, strong) DetailViewController *oldDetailViewController;

- (void)reloadView;

@end
