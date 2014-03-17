//
//  Lesson.h
//  MathPad
//
//  Created by Alex Muller on 9/21/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Lesson : NSObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSNumber * chapter;
@property (nonatomic, retain) NSString * complexity;
@property (nonatomic, retain) NSString * descript;
@property (nonatomic, retain) NSString * grade;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSString * subject;

- (id)initWithLesson:(id)lesson;
+ (id)createLessonFromObject:(id)lesson;

@end
