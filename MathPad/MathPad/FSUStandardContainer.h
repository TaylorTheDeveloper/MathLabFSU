//
//  FSUStandardContainer.h
//  ParserTestCases
//
//  Created by Alex Muller on 11/5/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FSUStandard.h"

@interface FSUStandardContainer : NSObject

@property (nonatomic, strong) NSMutableArray *container;

- (id)initContainer;
- (void)addStandard:(FSUStandard *)standard;

- (NSInteger) count;
- (NSString *)description;

@end
