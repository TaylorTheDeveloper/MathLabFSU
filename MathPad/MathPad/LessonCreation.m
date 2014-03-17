//
//  LessonCreation.m
//  MathPad
//
//  Created by Alex Muller on 10/16/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "LessonCreation.h"

@implementation LessonCreation {
    NSMutableArray *CCSArray;
    NSMutableArray *FSUArray;
    NSString *date;
    NSString *comments;
    BOOL revision;
    int rating;
    int ID;
}

- (id)init {
    if (self = [super init]) {
        CCSArray = [[NSMutableArray alloc] init];
        FSUArray = [[NSMutableArray alloc] init];
        revision = NO;
    }
    return self;
}

- (void)addCCS:(NSString *)CCS {
    if (!CCSArray) {
        CCSArray = [[NSMutableArray alloc] init];
    }
    [CCSArray addObject:CCS];
}

- (void)addFSU:(NSString *)FSU {
    if (!FSUArray) {
        FSUArray = [[NSMutableArray alloc] init];
    }
    [FSUArray addObject:FSU];
}

- (NSString *)getCCS {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"\""];
    [CCSArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [string appendString:obj];
        if (idx != [CCSArray count] - 1) {
            [string appendString:@","];
        }
    }];
    [string appendString:@"\""];
    return string;
}

- (NSString *)getFSU {
    NSMutableString *string = [[NSMutableString alloc] initWithString:@"\""];
    [FSUArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [string appendString:obj];
        if (idx != [FSUArray count] - 1) {
            [string appendString:@","];
        }
    }];
    [string appendString:@"\""];
    return string;
}

- (NSString *)completedString {
    if (!date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
    }
    return [NSString stringWithFormat:@"\n%i,\"%@\",%@,%@,%@,\"\",%i", ID, date, revision?@"YES":@"NO", [self getCCS], [self getFSU], rating];
}

- (NSString *)completedStringWithNoNewLine {
    if (!date) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
    }
    return [NSString stringWithFormat:@"%i,\"%@\",%@,%@,%@,\"%@\",%i", ID, date, revision?@"YES":@"NO", [self getCCS], [self getFSU], comments, rating];
}

- (void)setDate:(NSDate *)dateObj {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    date = [formatter stringFromDate:dateObj];
}

- (void)setDateFromString:(NSString *)dateString {
    date = dateString;
}

- (NSString *)getDate {
    return date;
}

- (void)setRating:(int)rate {
    rating = rate;
}

- (void)setRevision:(BOOL)rev {
    revision = rev;
}

- (void)setID:(int)i {
    ID = i;
}

// Add if time allotted
- (void)addComment:(NSString *)newComment FromUser:(NSString *)user toPreviousComments:(NSString *)pastComments {
    NSMutableString *temp = [[NSMutableString alloc] initWithString:pastComments];
    [temp appendFormat:@"\n%@: %@\n", user, newComment];
    comments = temp;
}

- (void)setComment:(NSString *)newComments {
    comments = [[newComments componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];;
}

@end
