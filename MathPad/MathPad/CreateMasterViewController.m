//
//  CreateMasterViewController.m
//  MathPad
//
//  Created by Alex Muller on 9/19/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "CreateMasterViewController.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
#import "Lesson.h"
#import "CreateDetailViewController.h"
#import "FSUStandardContainer.h"
#import "FSUStandard.h"
#import "CSVKit.h"

#define kNothingSelected [NSIndexPath indexPathForRow:-1 inSection:-1]


@interface CreateMasterViewController () {
    NSArray *grades;
    FSUStandardContainer *fsuCourses;
    IBOutlet UITableView *tableview;
    NSMutableArray *lessons;
    CreateDetailViewController *cdvc;
}

@end

@implementation CreateMasterViewController

@synthesize lessonType = _lessonType;
@synthesize FSUIndex, CCSIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    lessons = [[NSMutableArray alloc] init];
    FSUIndex = CCSIndex = kNothingSelected;
    [super viewDidLoad];
    [self segmentChanged];
    grades = @[ @"6th", @"7th", @"8th", @"9-12th" ];
    [self readCourses];
    [_lessonType addTarget:self action:@selector(segmentChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)readCourses {
    fsuCourses = [[FSUStandardContainer alloc] initContainer];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@".FSUStandards"];
    CSVObjectParser *parser = [[CSVObjectParser alloc] initWithDialect:&CSVExcelDialect objectClass:nil propertyNames:nil];
    [parser parseObjectsFromData:[NSData dataWithContentsOfFile:filePath] block:^(id object, BOOL *stop) {
        NSLog(@"%@", [object description]);
        if (![[object valueForKey:@"Big Idea"] isEqualToString:@""]) {
            [fsuCourses addStandard:[FSUStandard FSUStandardFromObject:object]];
        }
    }];
}

- (void)segmentChanged {
    [tableview reloadData];
    if (_lessonType.selectedSegmentIndex == 0) {
        tableview.scrollEnabled = NO;
        if (![CCSIndex isEqual:kNothingSelected]) {
            [tableview selectRowAtIndexPath:CCSIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
            cdvc.CCSArray = lessons;
            cdvc.FSUArray = nil;
            [cdvc reloadView];
        }
    } else {
        tableview.scrollEnabled = YES;
        if (![FSUIndex isEqual:kNothingSelected]) {
            [tableview selectRowAtIndexPath:FSUIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
            cdvc.CCSArray = nil;
            cdvc.FSUArray = fsuCourses.container[FSUIndex.row];
            [cdvc reloadView];
        }

    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillDisappear:(BOOL)animated {
    DetailViewController *dvc = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:appDelegate.splitViewController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers addObject:dvc];
    appDelegate.splitViewController.viewControllers = viewControllers;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_lessonType.selectedSegmentIndex == 0) {
        return [grades count];
    } else {
        return [fsuCourses count];
//        return [fsuCourses count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor goldColor];
    cell.backgroundColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (_lessonType.selectedSegmentIndex == 0) {
        cell.textLabel.text = [grades objectAtIndex:indexPath.row];
    } else {
        cell.textLabel.text = [fsuCourses.container[indexPath.row][0][0] subject];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *filePath;
    NSError *error;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    cdvc = [appDelegate.splitViewController.viewControllers lastObject];
    if (_lessonType.selectedSegmentIndex == 0) {
        [lessons removeAllObjects];
        if (CCSIndex != kNothingSelected) {
            [cdvc.CCSSelectedIndexes removeAllObjects];
        }
        switch (indexPath.row) {
            case 0:
//                filePath = [[NSBundle mainBundle] pathForResource:@"grade6" ofType:nil];
                filePath = [[NSBundle mainBundle] pathForResource:@"grade6new" ofType:nil];
                break;
            case 1:
                filePath = [[NSBundle mainBundle] pathForResource:@"grade7new" ofType:nil];
                break;
            case 2:
                filePath = [[NSBundle mainBundle] pathForResource:@"grade8new" ofType:nil];
                break;
            case 3:
                filePath = [[NSBundle mainBundle] pathForResource:@"grade912new" ofType:nil];
                break;
        }
        CCSIndex = indexPath;
        NSArray *jsonObject = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
        [jsonObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [lessons addObject:[Lesson createLessonFromObject:obj]];
        }];
        cdvc.CCSArray = lessons;
        cdvc.FSUArray = nil;
    } else {
        if (FSUIndex != kNothingSelected) {
            [cdvc.FSUSelectedIndexes removeAllObjects];
        }
        FSUIndex = indexPath;
        cdvc.FSUArray = fsuCourses.container[indexPath.row];
        cdvc.CCSArray = nil;
    }
    cdvc.masterViewController = self;
    [cdvc reloadView];
}

@end
