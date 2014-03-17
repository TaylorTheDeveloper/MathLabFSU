//
//  ModifyUserViewController.m
//  MathPad
//
//  Created by Alex Muller on 10/23/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "ModifyUserViewController.h"
#import "Student.h"
#import "MessageBox.h"

@interface ModifyUserViewController () {
    DBRestClient *restClient;
    NSIndexPath *selectedIndex;
    BOOL cellIsSelected;
    int height;
    UITextField *username;
    UITextField *password;
    BOOL isDeleting;
    NSString *userToDelete;
    NSString *filePath;
    NSIndexPath *indexPathToDelete;
    AddStudentCell *studentCell;
}

@end

@implementation ModifyUserViewController

@synthesize studentArray = _studentArray;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.editing = YES;
        _studentArray = [[NSMutableArray alloc] init];
        selectedIndex = nil;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor FSUGrayColor];
    self.tableView.separatorColor = [UIColor blackColor];
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 130.0);
    self.tableView.allowsSelectionDuringEditing = YES;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.studentArray count] == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] loadMetadata:@"/"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)refreshTable {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadMetadata:@"/"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.studentArray count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    if ([metadata.filename isEqualToString:@".validation"]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] deletePath:[NSString stringWithFormat:@"/%@", [self.studentArray[indexPathToDelete.row] user]]];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)restClient:(DBRestClient *)client deletedPath:(NSString *)path {
    [self refreshTable];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if ([metadata.filename isEqualToString:@".validation"]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] uploadFile:@".validation" toPath:@"/" withParentRev:metadata.rev fromPath:filePath];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    if (isDeleting) {
        isDeleting = NO;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@".validation"]];
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *fileArray = [[NSMutableArray alloc] initWithArray:[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        [fileArray removeObjectAtIndex:[self searchForIndex:userToDelete inArray:metadata.contents]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
        NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandler seekToEndOfFile];
        [fileArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [fileHandler writeData:[[NSString stringWithFormat:@"%@\n", obj] dataUsingEncoding:NSUTF8StringEncoding]];
            [fileHandler seekToEndOfFile];
        }];
        [fileHandler closeFile];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] loadMetadata:@"/.validation"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        return;
    }
    [self.studentArray removeAllObjects];
    if (metadata.isDirectory) {
            for (DBMetadata *file in metadata.contents) {
                if (![file.filename isEqualToString:@".validation"] && ![file.filename isEqualToString:@".FSUStandards"]) {
                    [self.studentArray addObject:[Student studentWithUsername:file.filename andPassword:nil]];
                }
            }
    }
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.studentArray count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)dismissCell {
    cellIsSelected = NO;
    NSIndexPath *temp = selectedIndex;
    selectedIndex = nil;
    [self.tableView deselectRowAtIndexPath:temp animated:YES];
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:temp atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [studentCell clearFields];
//    Make username/pass clear
}

- (int)searchForIndex:(NSString *)user inArray:(NSArray *)array {
    __block int index = -1;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj valueForKey:@"path"] isEqualToDropboxPath:[NSString stringWithFormat:@"/%@", user]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index - 2;
}

- (void)deleteUserFromValidationFile:(NSString *)user atIndexPath:(NSIndexPath *)indexPath {
    isDeleting = YES;
    indexPathToDelete = indexPath;
    userToDelete = user;
    [[self restClient] loadMetadata:@"/"];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath isEqual:[NSIndexPath indexPathForRow:[self.studentArray count] inSection:0]]) {
        return 130;
    }
    return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    height = 44 * ([self.studentArray count] + 1) + 86;
    self.tableView.scrollEnabled = NO;
    if (height >= 660) {
        self.tableView.scrollEnabled = YES;
        height = 660;
    }
    self.contentSizeForViewInPopover = CGSizeMake(300, height);
    return [self.studentArray count] + 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.studentArray count]) {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.studentArray count]) {
        return YES;
    }
    return NO;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [self.studentArray count]) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UserCell"];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = [self.studentArray[indexPath.row] user];
        cell.detailTextLabel.text = [self.studentArray[indexPath.row] pass];
        return cell;
    } else {
        studentCell = [tableView dequeueReusableCellWithIdentifier:@"AddStudentCell"];
        if (!studentCell) {
            studentCell = [[AddStudentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddStudentCell"];
            studentCell.delegate = self;
            studentCell.editing = NO;
        }
        studentCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return studentCell;
    }
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteUserFromValidationFile:[self.studentArray[indexPath.row] user] atIndexPath:indexPath];
//        [self refreshTable];
//        [studentArray removeObjectAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        [studentArray insertObject:[NSString stringWithFormat:@"Test %i", indexPath.row + 1] atIndex:indexPath.row];
//        [tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[studentArray count] inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Table view delegate

@end
