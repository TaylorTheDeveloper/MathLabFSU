//
//  Lesson.m
//  MathPad
//
//  Created by Alex Muller on 9/21/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "Lesson.h"

@implementation Lesson

@synthesize category = _category;
@synthesize chapter = _chapter;
@synthesize complexity = _complexity;
@synthesize descript = _descript;
@synthesize grade = _grade;
@synthesize section = _section;
@synthesize subject = _subject;

- (id)initWithLesson:(id)lesson {
    self = [super init];
    if(self) {
        _category = [lesson valueForKey:@"category"];
        _chapter = [lesson valueForKey:@"chapter"];
        _complexity = [lesson valueForKey:@"complexity"];
        _descript = [lesson valueForKey:@"descript"];
        _grade = [lesson valueForKey:@"grade"];
        _section = [lesson valueForKey:@"section"];
        _subject = [lesson valueForKey:@"subject"];
    }
    return self;
}

+ (id)createLessonFromObject:(id)lesson {
    Lesson *temp = [[Lesson alloc] initWithLesson:lesson];
    return temp;
}

@end
