//
//  LoginViewController.h
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>

@interface LoginViewController : UIViewController <DBRestClientDelegate, UITextFieldDelegate>

+ (BOOL)isAdmin;

@end
