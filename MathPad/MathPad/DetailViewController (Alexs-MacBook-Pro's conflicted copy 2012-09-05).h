//
//  DetailViewController.h
//  MathPad
//
//  Created by Alex Muller on 8/14/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Lesson;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Lesson *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
