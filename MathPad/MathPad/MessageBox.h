//
//  MessageBox.h
//  MathPad
//
//  Created by Alex Muller on 9/27/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageBox : UIView

- (id)initWithMessage:(NSString *)messageString;
+ (void)displayConfirmationMessageInView:(UIView *)superView;
+ (void)displayUpdateMessageInView:(UIView *)superView;
+ (void)displayErrorMessageInView:(UIView *)superView;
+ (void)displayAddedStudentInView:(UIView *)superView;
+ (void)displayRemovedStudentInView:(UIView *)superView;

@end
