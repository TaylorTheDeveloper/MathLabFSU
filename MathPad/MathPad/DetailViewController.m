//
//  DetailViewController.m
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "DetailViewController.h"
#import "BButton.h"
#import "LoginViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CSVKit.h"
#import "LessonCreation.h"
#import "MessageBox.h"

#define kDefaultRowHeight 44

@interface DetailViewController () {
    NSArray *CCS;
    NSString *comment;
    BOOL revision;
    NSString *date;
    NSArray *FSU;
    NSMutableArray *FSUTopics;
    int rating;
    int IDnumber;
    
    NSString *filePath;
    
    LessonCreation *oldLesson;
    
    IBOutlet UILabel *dateLabel;
    IBOutlet UITableView *CCStableview;
    IBOutlet UITableView *FSUtableview;
    IBOutlet UITextView *commentText;
    IBOutlet UIView *container;
    IBOutlet BButton *saveButton;
    
    AMRatingControl *starRating;
    
    DBRestClient *restClient;
}

- (void)configureView;
- (IBAction)save:(id)sender;
@end

@implementation DetailViewController

@synthesize filePath = _filePath;
@synthesize detailUser;
@synthesize masterViewController;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        starRating.rating = 0;
        CCS = [[NSArray alloc] init];
        FSU = [[NSArray alloc] init];
        FSUTopics = [[NSMutableArray alloc] init];
        CCS = [[_detailItem valueForKey:@"CCS"] componentsSeparatedByString:@","];
        FSU = [[_detailItem valueForKey:@"FSU"] componentsSeparatedByString:@","];
        date = [_detailItem valueForKey:@"Date"];
        rating = [[_detailItem valueForKey:@"Rating"] intValue];
        comment = [_detailItem valueForKey:@"Comments"];
        revision = [[_detailItem valueForKey:@"Revision"] boolValue];
        IDnumber = [[_detailItem valueForKey:@"ID"] intValue];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *standardPath = [documentsDirectory stringByAppendingPathComponent:@".FSUStandards"];
        CSVObjectParser *parser = [[CSVObjectParser alloc] initWithDialect:&CSVExcelDialect objectClass:nil propertyNames:nil];
//        Go through the FSU Standards file, and find matching IDs, and pull the topic to display
        [parser parseObjectsFromData:[NSData dataWithContentsOfFile:standardPath] block:^(id object, BOOL *stop) {
            [FSU enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([[object valueForKey:@"ID"] isEqualToString:obj]) {
                    [FSUTopics addObject:[object valueForKey:@"Topic"]];
                }
            }];
        }];

        // Update the view.
        [self configureView];
    }      
}

- (void)configureView
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{[UIColor blackColor] : UITextAttributeTextColor}];
    starRating = [[AMRatingControl alloc] initWithLocation:CGPointMake(88, 654) andMaxRating:5];
    starRating.rating = rating;
    [container addSubview:starRating];
//    NSLog(@"%@", [_detailItem description]);
    // Update the user interface for the detail item.
//    saveButton.color = [UIColor colorWithRed:(84/225) green:(1/225) blue:(21/225) alpha:1.0];
    container.backgroundColor = [UIColor garnetColor];
    saveButton.color = [UIColor blackColor];
    saveButton.titleLabel.textColor = [UIColor goldColor];
    saveButton.titleLabel.highlightedTextColor = [UIColor goldColor];
    [commentText.layer setBorderColor:[[[UIColor blackColor] colorWithAlphaComponent:0.5] CGColor]];
    [commentText.layer setBorderWidth:2.0];
    commentText.layer.cornerRadius = 5;
    commentText.clipsToBounds = YES;
    commentText.text = comment;
    dateLabel.text = [NSString stringWithFormat:@"Lesson On: %@", date];
    dateLabel.textColor = [UIColor goldColor];
    
//    Use this if you need access to the file
//    NSString *filePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"grade%@", [CCS[0] componentsSeparatedByString:@"."][1]] ofType:nil];
//    NSLog(@"%@", filePath);
}

- (void)showContainer {
    container.hidden = NO;
    [CCStableview reloadData];
    [FSUtableview reloadData];
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
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", detailUser]];
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *fileArray = [[NSMutableArray alloc] initWithArray:[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    CSVObjectParser *parser = [[CSVObjectParser alloc] initWithDialect:&CSVExcelDialect objectClass:nil propertyNames:nil];
    __block int index = 0;
    [parser parseObjectsFromData:[NSData dataWithContentsOfFile:filePath] block:^(id object, BOOL *stop) {
        if ([[object valueForKey:@"ID"] intValue] == IDnumber) {
            NSLog(@"same at index %i ", index);
            *stop = YES;
        }
        ++index;
    }];
    LessonCreation *lessonObj = [[LessonCreation alloc] init];
    [lessonObj setDateFromString:date];
    [CCS enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [lessonObj addCCS:obj];
    }];
    [FSU enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [lessonObj addFSU:obj];
    }];
    [lessonObj setRating:starRating.rating];
    [lessonObj setRevision:revision];
    [lessonObj setComment:commentText.text];
    [lessonObj setID:IDnumber];
    fileArray[index] = [lessonObj completedStringWithNoNewLine];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx == [fileArray count] - 1) {
            [fileHandler writeData:[[NSString stringWithFormat:@"%@", obj] dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            [fileHandler writeData:[[NSString stringWithFormat:@"%@\n", obj] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        [fileHandler seekToEndOfFile];
    }];
    [commentText resignFirstResponder];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadMetadata:[NSString stringWithFormat:@"/%@/%@.csv", detailUser, detailUser]];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if ([metadata.filename isEqualToString:[NSString stringWithFormat:@"%@.csv", detailUser]]) {
        [[self restClient] uploadFile:[NSString stringWithFormat:@"%@.csv", detailUser] toPath:[NSString stringWithFormat:@"/%@", detailUser] withParentRev:metadata.rev fromPath:filePath];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath {
    container.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    [masterViewController.tableView deselectRowAtIndexPath:[masterViewController.tableView indexPathForSelectedRow] animated:YES];
    [masterViewController reloadTables];
    [MessageBox displayUpdateMessageInView:self.splitViewController.view];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y - 352, container.frame.size.width, container.frame.size.height);
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    container.frame = CGRectMake(container.frame.origin.x, container.frame.origin.y + 352, container.frame.size.width, container.frame.size.height);
    return YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    container.hidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    [self configureView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == CCStableview) {
        return [CCS count];
    } else {
        return [FSUTopics count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int size = kDefaultRowHeight;
    if (tableView == FSUtableview) {
        size = [FSUTopics[indexPath.row] length]/30;
        if (size == 0) {
            return kDefaultRowHeight;
        } else {
            // To allow for rows' height to be dynamically changed if there are more than 90 characters if the descript
            return kDefaultRowHeight + (size * 20);
        }
    }
    return size;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.highlightedTextColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor goldColor];
        cell.backgroundColor = [UIColor blackColor];
    }
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (tableView == CCStableview) {
        cell.textLabel.text = CCS[indexPath.row];
    } else {
        cell.textLabel.text = FSUTopics[indexPath.row];
    }
//    if (_lessonType.selectedSegmentIndex == 0) {
//        cell.textLabel.text = [grades objectAtIndex:indexPath.row];
//    } else {
//        cell.textLabel.text = [NSString stringWithFormat:@"Test %i", indexPath.row+1];
//    }
    
    return cell;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
//    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
}

- (IBAction)logout:(id)sender {
    container.hidden = YES;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    for (NSString *path in directoryContents) {
        [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:path] error:nil];
    }
    LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [self.splitViewController presentModalViewController:lvc animated:YES];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
