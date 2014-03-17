//
//  GradeContainer.h
//  MathPad
//
//  Created by Alex Muller on 8/14/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Lesson;

@interface GradeContainer : NSManagedObject

@property (nonatomic, retain) NSData * empty;
@property (nonatomic, retain) NSSet *eighth;
@property (nonatomic, retain) NSSet *fifth;
@property (nonatomic, retain) NSSet *first;
@property (nonatomic, retain) NSSet *fourth;
@property (nonatomic, retain) NSSet *high;
@property (nonatomic, retain) NSSet *kindergarten;
@property (nonatomic, retain) NSSet *second;
@property (nonatomic, retain) NSSet *seventh;
@property (nonatomic, retain) NSSet *sixth;
@property (nonatomic, retain) NSSet *third;
@end

@interface GradeContainer (CoreDataGeneratedAccessors)

- (void)addEighthObject:(Lesson *)value;
- (void)removeEighthObject:(Lesson *)value;
- (void)addEighth:(NSSet *)values;
- (void)removeEighth:(NSSet *)values;

- (void)addFifthObject:(Lesson *)value;
- (void)removeFifthObject:(Lesson *)value;
- (void)addFifth:(NSSet *)values;
- (void)removeFifth:(NSSet *)values;

- (void)addFirstObject:(Lesson *)value;
- (void)removeFirstObject:(Lesson *)value;
- (void)addFirst:(NSSet *)values;
- (void)removeFirst:(NSSet *)values;

- (void)addFourthObject:(Lesson *)value;
- (void)removeFourthObject:(Lesson *)value;
- (void)addFourth:(NSSet *)values;
- (void)removeFourth:(NSSet *)values;

- (void)addHighObject:(Lesson *)value;
- (void)removeHighObject:(Lesson *)value;
- (void)addHigh:(NSSet *)values;
- (void)removeHigh:(NSSet *)values;

- (void)addKindergartenObject:(Lesson *)value;
- (void)removeKindergartenObject:(Lesson *)value;
- (void)addKindergarten:(NSSet *)values;
- (void)removeKindergarten:(NSSet *)values;

- (void)addSecondObject:(Lesson *)value;
- (void)removeSecondObject:(Lesson *)value;
- (void)addSecond:(NSSet *)values;
- (void)removeSecond:(NSSet *)values;

- (void)addSeventhObject:(Lesson *)value;
- (void)removeSeventhObject:(Lesson *)value;
- (void)addSeventh:(NSSet *)values;
- (void)removeSeventh:(NSSet *)values;

- (void)addSixthObject:(Lesson *)value;
- (void)removeSixthObject:(Lesson *)value;
- (void)addSixth:(NSSet *)values;
- (void)removeSixth:(NSSet *)values;

- (void)addThirdObject:(Lesson *)value;
- (void)removeThirdObject:(Lesson *)value;
- (void)addThird:(NSSet *)values;
- (void)removeThird:(NSSet *)values;

@end
