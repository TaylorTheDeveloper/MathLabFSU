//
//  FSUStandardContainer.m
//  ParserTestCases
//
//  Created by Alex Muller on 11/5/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "FSUStandardContainer.h"

#define kDoesntExist -1

@interface FSUStandardContainer () {
    
}

- (NSString *)bigIdeaAtIndex:(NSInteger)bigIdeaIndex inSubjectIndex:(NSInteger)subjectIndex;
- (NSString *)subjectAtIndex:(NSInteger)subjectIndex;

@end

@implementation FSUStandardContainer

@synthesize container;

- (id)initContainer {
    if (self = [self init]) {
        container = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addStandard:(FSUStandard *)standard {
    int subjectIndex, bigIdeaIndex;
    // Check to see if standard's subject exists or not, if not, create a new array and place this one in there
    // if it does, check to see if the Big Idea exists
    if ((subjectIndex = [self indexOfSubjectInContainer:standard]) == kDoesntExist) {
        NSMutableArray *topics = [[NSMutableArray alloc] init];
        NSMutableArray *bigIdeas = [[NSMutableArray alloc] init];
        [topics addObject:standard];
        [bigIdeas addObject:topics];
        [container addObject:bigIdeas];
    } else {
        // Check to see if big idea exists, if not, add a new array
       if ((bigIdeaIndex = [self indexOfBigIdeaInContainer:standard]) == kDoesntExist) {
//           Need to create new Big Idea index, so create topics array and add standard, and then add to new big Idea index, and reassign into container
           NSMutableArray *bigIdeas = container[subjectIndex];
           NSMutableArray *topics = [[NSMutableArray alloc] init];
           [topics addObject:standard];
           [bigIdeas addObject:topics];
           container[subjectIndex] = bigIdeas;
        } else {
//           Need to add to existing topics within an existing Big Idea, pull out topics array and reassign
            NSArray *bigIdeas = container[subjectIndex];
            NSMutableArray *topics = bigIdeas[bigIdeaIndex];
            [topics addObject:standard];
            container[subjectIndex][bigIdeaIndex] = topics;

        }
    }
}

- (int)indexOfSubjectInContainer:(FSUStandard *)standard {
    __block int index = kDoesntExist;
    [container enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *bigIdeas = obj;
        NSArray *topics = bigIdeas[0];
        FSUStandard *temp = topics[0];
        if ([[temp subject] isEqualToString:[standard subject]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

- (int)indexOfBigIdeaInContainer:(FSUStandard *)standard {
    __block int index = kDoesntExist;
    [container enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *bigIdeas = obj;
        [bigIdeas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSArray *topics = obj;
            FSUStandard *temp = topics[0];
            if ([[temp bigIdea] isEqualToString:[standard bigIdea]]) {
                index = idx;
                *stop = YES;
            }
        }];
        if (index != kDoesntExist) {
            *stop = YES;
        }
    }];
    return index;
}

- (NSString *)description {
    return [container description];
}

- (NSString *)bigIdeaAtIndex:(NSInteger)bigIdeaIndex inSubjectIndex:(NSInteger)subjectIndex {
    return [container[subjectIndex][bigIdeaIndex][0] bigIdea];
}

- (NSString *)subjectAtIndex:(NSInteger)subjectIndex {
    return [container[subjectIndex][0][0] subject];
}

- (NSInteger) count {
    return [container count];
}

@end
