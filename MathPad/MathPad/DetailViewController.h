//
//  DetailViewController.h
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "MasterViewController.h"
#import "AMRatingControl.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, DBRestClientDelegate>

@property (strong, nonatomic) id detailItem;
@property (strong, nonatomic) NSString *filePath;

@property (weak, nonatomic) NSString *detailUser;
@property (strong, nonatomic) MasterViewController *masterViewController;

- (void)showContainer;

@end
