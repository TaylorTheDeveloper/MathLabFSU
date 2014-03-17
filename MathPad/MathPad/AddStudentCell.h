//
//  AddStudentCell.h
//  MathPad
//
//  Created by Alex Muller on 10/23/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@protocol AddStudentCellDelegate
- (void)refreshTable;
@end

@interface AddStudentCell : UITableViewCell <DBRestClientDelegate>

@property (nonatomic, strong) id<AddStudentCellDelegate> delegate;

- (void)clearFields;

@end
