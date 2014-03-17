//
//  MessageBox.m
//  MathPad
//
//  Created by Alex Muller on 9/27/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "MessageBox.h"
#import <QuartzCore/QuartzCore.h>

#define kWindowHeight 768
#define kWindowWidth 1024

@implementation MessageBox

- (id)initWithMessage:(NSString *)messageString
{
    self = [super initWithFrame:CGRectMake(kWindowWidth/2 - 100, kWindowHeight/2 - 75, 200, 150)];
    if (self) {
        self.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(25, 90, 150, 50)];
        message.backgroundColor = [UIColor clearColor];
        message.textColor = [UIColor colorWithWhite:1.0 alpha:6.0];
        message.textAlignment = NSTextAlignmentCenter;
        message.font = [UIFont systemFontOfSize:22];
        message.numberOfLines = 0;
        message.text = messageString;
        [self addSubview:message];
        self.alpha = 0;
    }
    return self;
}

+ (void)displayConfirmationMessageInView:(UIView *)superView {
    MessageBox *temp = [[MessageBox alloc] initWithMessage:@"Lesson has been added!"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 10, 74, 74)];
    imageView.image = [UIImage imageNamed:@"37x-Checkmark"];
    [temp addSubview:imageView];
    [superView addSubview:temp];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 1.0;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(remove:) userInfo:@{@"box" : temp} repeats:NO];
    }];
}

+ (void)displayAddedStudentInView:(UIView *)superView {
    MessageBox *temp = [[MessageBox alloc] initWithMessage:@"Student has been added!"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 10, 74, 74)];
    imageView.image = [UIImage imageNamed:@"37x-Checkmark"];
    [temp addSubview:imageView];
    [superView addSubview:temp];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 1.0;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(remove:) userInfo:@{@"box" : temp} repeats:NO];
    }];
}

+ (void)displayRemovedStudentInView:(UIView *)superView {
    MessageBox *temp = [[MessageBox alloc] initWithMessage:@"Lesson has been removed!"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 10, 74, 74)];
    imageView.image = [UIImage imageNamed:@"37x-Checkmark"];
    [temp addSubview:imageView];
    [superView addSubview:temp];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 1.0;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(remove:) userInfo:@{@"box" : temp} repeats:NO];
    }];
}

+ (void)displayUpdateMessageInView:(UIView *)superView {
    MessageBox *temp = [[MessageBox alloc] initWithMessage:@"Lesson has been updated!"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 10, 74, 74)];
    imageView.image = [UIImage imageNamed:@"37x-Checkmark"];
    [temp addSubview:imageView];
    [superView addSubview:temp];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 1.0;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(remove:) userInfo:@{@"box" : temp} repeats:NO];
    }];
}

+ (void)displayErrorMessageInView:(UIView *)superView {
    MessageBox *temp = [[MessageBox alloc] initWithMessage:@"MathPad has an error!"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(63, 10, 74, 74)];
    imageView.image = [UIImage imageNamed:@"Error@2x.png"];
    [temp addSubview:imageView];
    [superView addSubview:temp];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 1.0;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(remove:) userInfo:@{@"box" : temp} repeats:NO];
    }];
}

+ (void)remove:(NSTimer *)timer {
    MessageBox *temp = [[timer userInfo] objectForKey:@"box"];
    [UIView animateWithDuration:.3 animations:^{
        temp.alpha = 0.0;
    } completion:^(BOOL finished) {
        [temp removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
