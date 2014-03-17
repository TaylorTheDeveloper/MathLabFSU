//
//  Student.h
//  MathPad
//
//  Created by Alex Muller on 10/22/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>
#import "CSVKit.h"

@interface Student : NSObject <DBRestClientDelegate>

@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *pass;
@property (nonatomic, strong) NSMutableArray *lessons;
@property (nonatomic, strong) NSString *filePath;


- (id)initWithUsername:(NSString *)user;
+ (id)studentObjectWithUsername:(NSString *)user;
+ (id)studentWithUsername:(NSString *)user andPassword:(NSString *)pass;

@end
