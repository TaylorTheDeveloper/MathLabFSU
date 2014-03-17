//
//  CreateDetailViewController.m
//  MathPad
//
//  Created by Alex Muller on 9/19/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "CreateDetailViewController.h"
#import "CreateMasterViewController.h"
#import "Lesson.h"
#import "MessageBox.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "LessonCreation.h"
#import "FSUStandard.h"

#define kDefaultRowHeight 44

@interface CreateDetailViewController () {
    IBOutlet UITableView *tableview;
    DBRestClient *restClient;
    NSString *filePath;
    LessonCreation *lessonObj;
    CKCalendarView *_calendar;
    IBOutlet UIButton *dateButton;
    IBOutlet UISegmentedControl *revision;
    IBOutlet UILabel *errorMessage;
    IBOutlet UIBarButtonItem *saveButton;
    UIPopoverController *popoverController;
    UIViewController *webView;
}

@end

@implementation CreateDetailViewController

@synthesize CCSArray = _CCSArray;
@synthesize FSUArray = _FSUArray;
@synthesize CCSSelected = _CCSSelected;
@synthesize FSUSelected = _FSUSelected;
@synthesize FSUSelectedIndexes, CCSSelectedIndexes;
@synthesize masterViewController = _masterViewController;
@synthesize oldDetailViewController = _oldDetailViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    _CCSArray = [[NSArray alloc] init];
    _FSUArray = [[NSArray alloc] init];
    _CCSSelected = [[NSMutableArray alloc] init];
    _FSUSelected = [[NSMutableArray alloc] init];
    FSUSelectedIndexes = [[NSMutableArray alloc] init];
    CCSSelectedIndexes = [[NSMutableArray alloc] init];
    tableview.editing = YES;
    tableview.allowsMultipleSelectionDuringEditing = YES;
    _calendar = [[CKCalendarView alloc] initWithFrame:CGRectMake((dateButton.frame.origin.x + dateButton.frame.size.width/2) - 150 , (dateButton.frame.origin.y + dateButton.frame.size.height), 300, 320)];
    _calendar.delegate = self;
    [_calendar setDateBackgroundColor:[UIColor colorWithRed:.8 green:.7 blue:.5 alpha:1.0]];
    [_calendar setSelectedDateBackgroundColor:[UIColor colorWithRed:0.373 green:0.004 blue:0.093 alpha:1.0]];
    [self.view addSubview:_calendar];
    
    _calendar.hidden = YES;
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateStyle:NSDateFormatterLongStyle];
//    dateButton.titleLabel.text = [formatter stringFromDate:[NSDate date]];
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)help:(id)sender {
    if (popoverController.isPopoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
        //        if ([muvc.studentArray count] != [self.tableView numberOfSections]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] loadMetadata:@"/"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        //        }
        return;
    }
    if (webView == nil) {
        webView = [[UIViewController alloc] init];
        webView.contentSizeForViewInPopover = CGSizeMake(500, 700);
        UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 500, 700)];
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://dl.dropbox.com/s/4q1yva7dswrld0r/MathPad%20Instructional%20Documentation.pdf?disable_range=1#zoom=100"]]];
        [webView.view addSubview:web];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:webView];
        popoverController.delegate = self;
    }
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)setDate:(id)sender {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    if (_calendar.isHidden) {
        _calendar.hidden = NO;
    } else {
        _calendar.hidden = YES;
    }
}

- (void)calendar:(CKCalendarView *)calendar didSelectDate:(NSDate *)date {
    calendar.hidden = YES;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    dateButton.titleLabel.text = [formatter stringFromDate:date];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)reloadView {
    saveButton.enabled = YES;
    [tableview reloadData];
//    Reselect UITableViewCells
    if (!_CCSArray) {
        [FSUSelectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableview selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    } else {
        [CCSSelectedIndexes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [tableview selectRowAtIndexPath:obj animated:NO scrollPosition:UITableViewScrollPositionNone];
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (_CCSArray) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 700, 20)];
    headerText.backgroundColor = [UIColor clearColor];
    headerText.textColor = [UIColor goldColor];
    headerText.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:headerText];
    headerText.text = [_FSUArray[section][0] bigIdea];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!_CCSArray) {
        return [_FSUArray count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!_CCSArray) {
        return [_FSUArray[section] count];
    } 
    return [_CCSArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int size;
    if (!_CCSArray) {
        size = [[_FSUArray[indexPath.section][indexPath.row] topic] length]/65;
    } else {
        size = [[_CCSArray[indexPath.row] descript] length]/90;
    }
    if (size == 0) {
        return kDefaultRowHeight;
    } else {
        // To allow for rows' height to be dynamically changed if there are more than 90 characters if the descript
        return kDefaultRowHeight + (size * 20);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CCSCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CCSCell"];
//        cell.textLabel.textColor = [UIColor goldColor];
        cell.backgroundColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.numberOfLines = 0;
        cell.textLabel.numberOfLines = 0;
    }
    if (!_CCSArray) {
        if ([FSUSelectedIndexes containsObject:indexPath]) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor garnetColor];
        } else {
            cell.textLabel.textColor = [UIColor goldColor];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
        cell.textLabel.text = [_FSUArray[indexPath.section][indexPath.row] topic];
        cell.detailTextLabel.text = @"";
    } else {
        if ([CCSSelectedIndexes containsObject:indexPath]) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.textColor = [UIColor garnetColor];
        } else {
            cell.textLabel.textColor = [UIColor goldColor];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
        Lesson *lesson = [_CCSArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"%@.%@.%@.%@.%@", [lesson subject], [lesson grade], [lesson category], [lesson chapter], [lesson section]];
        cell.detailTextLabel.text = [lesson descript];
    }
    return cell;
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (IBAction)save:(id)sender {
    [Network_Monitor checkConnection];
    if (![_calendar selectedDate]) {
        [self displayErrorWithMessage:@"Please select a date for the Lesson."];
        return;
    }
    if ([_CCSSelected count] == 0 || [_FSUSelected count] == 0) {
        [self displayErrorWithMessage:@"Both a CCSS and FSU Course Standard Must be Selected."];
        return;
    }
    lessonObj = [[LessonCreation alloc] init];
    [lessonObj setDate:[_calendar selectedDate]];
    for (int counter = 0; counter < [_CCSSelected count]; counter++) {
        [lessonObj addCCS:_CCSSelected[counter]];
    }
    for (int counter = 0; counter < [_FSUSelected count]; counter++) {
        [lessonObj addFSU:_FSUSelected[counter]];
    }
    [lessonObj setRevision:revision.selectedSegmentIndex?YES:NO];
    NSString *user = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", user]];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *fileArray = [[NSMutableArray alloc] initWithArray:[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    [lessonObj setID:([fileArray count] - 1)];
    saveButton.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadMetadata:[NSString stringWithFormat:@"/%@/%@.csv", user, user]];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:[[lessonObj completedString] dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
    [[self restClient] uploadFile:metadata.filename toPath:[NSString stringWithFormat:@"/%@", [[NSUserDefaults standardUserDefaults] valueForKey:@"username"]] withParentRev:metadata.rev fromPath:filePath];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_CCSArray) {
        FSUStandard *temp = _FSUArray[indexPath.section][indexPath.row];
        [_FSUSelected addObject:[NSString stringWithFormat:@"%i", [temp ID]]];
        [FSUSelectedIndexes addObject:indexPath];
        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor blackColor]];
    } else {
        [_CCSSelected addObject:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [CCSSelectedIndexes addObject:indexPath];
        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor blackColor]];
        [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] setTextColor:[UIColor garnetColor]];
        
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!_CCSArray) {
        FSUStandard *temp = _FSUArray[indexPath.section][indexPath.row];
        [_FSUSelected removeObject:[NSString stringWithFormat:@"%i", [temp ID]]];
        [FSUSelectedIndexes removeObject:indexPath];
        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor goldColor]];
    } else {
        [_CCSSelected removeObject:[[[tableView cellForRowAtIndexPath:indexPath] textLabel] text]];
        [CCSSelectedIndexes removeObject:indexPath];
        [[[tableView cellForRowAtIndexPath:indexPath] textLabel] setTextColor:[UIColor goldColor]];
        [[[tableView cellForRowAtIndexPath:indexPath] detailTextLabel] setTextColor:[UIColor grayColor]];
    }
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    [MessageBox displayConfirmationMessageInView:self.splitViewController.view];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:filePath error:nil];
    [self.masterViewController.navigationController popViewControllerAnimated:YES];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:appDelegate.splitViewController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers addObject:self.oldDetailViewController];
    appDelegate.splitViewController.viewControllers = viewControllers;
//    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    if (popoverController.contentViewController != webView) {
        [MessageBox displayErrorMessageInView:self.splitViewController.view];
    }
//    NSLog(@"File upload failed with error - %@", error);
}

- (void)displayErrorWithMessage:(NSString *)message {
    errorMessage.text = message;
    [UIView animateWithDuration:0.5 animations:^{
        errorMessage.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
            errorMessage.alpha = 0.0;
        } completion:nil];
    }];
}

@end
