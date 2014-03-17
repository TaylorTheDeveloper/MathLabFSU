//
//  FSUStandard.h
//  ParserTestCases
//
//  Created by Alex Muller on 11/3/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSUStandard : NSObject

- (id)initWithID:(int)i andSubject:(NSString *)sub andBigIdea:(NSString *)big andTopic:(NSString *)top;
+ (id)FSUStandardFromObject:(id)object;
@property (nonatomic, strong) NSString *subject;
@property (nonatomic, strong) NSString *bigIdea;
@property (nonatomic, strong) NSString *topic;
@property (nonatomic) int ID;

@end
