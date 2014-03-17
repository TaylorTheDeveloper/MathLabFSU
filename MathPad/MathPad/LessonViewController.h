//
//  LessonViewController.h
//  MathPad
//
//  Created by Alex Muller on 8/15/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface LessonViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (nonatomic, strong) NSArray *lessons;

@end
