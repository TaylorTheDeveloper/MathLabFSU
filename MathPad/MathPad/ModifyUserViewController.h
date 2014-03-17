//
//  ModifyUserViewController.h
//  MathPad
//
//  Created by Alex Muller on 10/23/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "AddStudentCell.h"

@interface ModifyUserViewController : UITableViewController <DBRestClientDelegate, AddStudentCellDelegate>

@property (nonatomic, strong) NSMutableArray *studentArray;

@end
