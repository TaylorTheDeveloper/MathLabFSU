//
//  FSUStandard.m
//  ParserTestCases
//
//  Created by Alex Muller on 11/3/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "FSUStandard.h"

@interface FSUStandard ()

@end

@implementation FSUStandard

@synthesize ID, subject, bigIdea, topic;

- (id)initWithID:(int)i andSubject:(NSString *)sub andBigIdea:(NSString *)big andTopic:(NSString *)top {
    if (self = [self init]) {
        ID = i;
        subject = sub;
        bigIdea = big;
        topic = top;
    }
    return self;
}

+ (id)FSUStandardFromObject:(id)object {
    FSUStandard *temp = [[FSUStandard alloc] initWithID:[[object valueForKey:@"ID"] intValue] andSubject:[object valueForKey:@"Subject"] andBigIdea:[object valueForKey:@"Big Idea"] andTopic:[object valueForKey:@"Topic"]];
    return temp;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"\nID: %i\nSubject: %@\nBig Idea: %@\nTopic: %@\n", ID, subject, bigIdea, topic];
}

@end
