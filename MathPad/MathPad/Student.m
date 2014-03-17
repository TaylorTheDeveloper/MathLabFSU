//
//  Student.m
//  MathPad
//
//  Created by Alex Muller on 10/22/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "Student.h"

@implementation Student {
    DBRestClient *restClient;
}

@synthesize user = _user;
@synthesize pass = _pass;
@synthesize lessons = _lessons;
@synthesize filePath = _filePath;

- (id)initWithUsername:(NSString *)user {
    if (self = [self init]) {
        _user = user;
        _lessons = [[NSMutableArray alloc] init];
        [self loadFile];
    }
    return self;
}

+ (id)studentWithUsername:(NSString *)user andPassword:(NSString *)pass {
    Student *temp = [[Student alloc] init];
    temp.user = user;
    temp.pass = pass;
    return temp;
}

- (void)loadFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    _filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", self.user]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadFile:[NSString stringWithFormat:@"/%@/%@.csv", self.user, self.user] intoPath:self.filePath];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
    [self readFile];
}

- (void)readFile {
    CSVObjectParser *parser = [[CSVObjectParser alloc] initWithDialect:&CSVExcelDialect objectClass:nil propertyNames:nil];
    [parser parseObjectsFromData:[NSData dataWithContentsOfFile:self.filePath] block:^(id object, BOOL *stop) {
        [self.lessons addObject:object];
    }];
    [self.lessons sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterLongStyle];
        NSDate *date1 = [formatter dateFromString:[[obj1 valueForKey:@"Date"] description]];
        NSDate *date2 = [formatter dateFromString:[[obj2 valueForKey:@"Date"] description]];
        return [date1 compare:date2];
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"edu.fsu.mobile.studentUpdate" object:self];
}

+ (id)studentObjectWithUsername:(NSString *)user {
    Student *temp = [[Student alloc] initWithUsername:user];
    return temp;
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

@end
