//
//  LessonCreation.h
//  MathPad
//
//  Created by Alex Muller on 10/16/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LessonCreation : NSObject

- (void)addCCS:(NSString *)CCS;
- (void)addFSU:(NSString *)FSU;
- (NSString *)getCCS;
- (NSString *)getFSU;
- (NSString *)completedString;
- (NSString *)completedStringWithNoNewLine;
- (id)init;
- (void)setID:(int)i;
- (void)setDate:(NSDate *)date;
- (void)setDateFromString:(NSString *)dateString;
- (void)setRating:(int)rate;
- (void)setRevision:(BOOL)rev;
- (void)setComment:(NSString *)newComments;

@end
