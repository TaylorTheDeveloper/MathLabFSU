//
//  CreateMasterViewController.h
//  MathPad
//
//  Created by Alex Muller on 9/19/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateDetailViewController.h"

@interface CreateMasterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UISegmentedControl *lessonType;
@property (nonatomic, strong) NSIndexPath *FSUIndex, *CCSIndex;

@end
