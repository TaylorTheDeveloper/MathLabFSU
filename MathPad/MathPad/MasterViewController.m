//
//  MasterViewController.m
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "CreateMasterViewController.h"
#import "CreateDetailViewController.h"
#import "Student.h"


@interface MasterViewController () {
    DBRestClient *restClient;
    NSString *username;
    Student *student;
    BOOL isAdminAccount;
    ModifyUserViewController *muvc;
    UIPopoverController *popoverController;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureStudentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

@synthesize studentArray = _studentArray;
@synthesize comparativeObject;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(studentUpdated:) name:@"edu.fsu.mobile.studentUpdate" object:nil];
    self.studentArray = [[NSMutableArray alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"Lessons";
    isAdminAccount = [LoginViewController isAdmin];
    
    self.detailViewController = (DetailViewController *)[self.splitViewController.viewControllers lastObject];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor garnetColor];
}

- (void)studentUpdated:(NSNotification *)notif {
    [self.tableView reloadData];
}

- (void)loadFSUStandards {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *standardPath = [documentsDirectory stringByAppendingPathComponent:@".FSUStandards"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadFile:@"/.FSUStandards" intoPath:standardPath];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)reloadTables {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadMetadata:@"/"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    isAdminAccount = [LoginViewController isAdmin];
    [self loadFSUStandards];
    username = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    UIBarButtonItem *button;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    if (isAdminAccount) {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadTables)];
        refreshButton.tintColor = [UIColor garnetButtonColor];
        self.navigationItem.leftBarButtonItem = refreshButton;
        button = [[UIBarButtonItem alloc] initWithTitle:@"Modify Users" style:UIBarButtonItemStyleBordered target:self action:@selector(modifyUsers:)];
        [[self restClient] loadMetadata:@"/"];
    } else {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
        button.tintColor = [UIColor garnetButtonColor];
        self.navigationItem.leftBarButtonItem = nil;
        [[self restClient] loadMetadata:[NSString stringWithFormat:@"/%@", username]];
    }
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    button.tintColor = [UIColor garnetButtonColor];
    self.navigationItem.rightBarButtonItem = button;

}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {        
        if (isAdminAccount) {
            [_studentArray removeAllObjects];
            for (DBMetadata *file in metadata.contents) {
                if (![file.filename isEqualToString:@".validation"] && ![file.filename isEqualToString:@".FSUStandards"]) {
                    [_studentArray addObject:[Student studentObjectWithUsername:file.filename]];
                }
            }
        } else {
            student = [[Student alloc] initWithUsername:username];
            self.detailViewController.filePath = student.filePath;
        }
    }
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
 
- (void)viewDidUnload
{
    [super viewDidUnload];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"edu.fsu.mobile.studentUpdate" object:nil];
}

- (void)insertNewObject:(id)sender
{
    CreateMasterViewController *cmvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateMasterViewController"];
    [self.navigationController pushViewController:cmvc animated:YES];
    CreateDetailViewController *cdvc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateDetailViewController"];
    cdvc.masterViewController = cmvc;
    cdvc.oldDetailViewController = self.detailViewController;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:appDelegate.splitViewController.viewControllers];
    [viewControllers removeLastObject];
    [viewControllers addObject:cdvc];
    appDelegate.splitViewController.viewControllers = viewControllers;
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
//    if ([muvc.studentArray count] != [self.tableView numberOfSections]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] loadMetadata:@"/"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    }
}

- (void)modifyUsers:(id)sender {
    if (popoverController.isPopoverVisible) {
        [popoverController dismissPopoverAnimated:YES];
//        if ([muvc.studentArray count] != [self.tableView numberOfSections]) {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
            [[self restClient] loadMetadata:@"/"];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//        }
        return;
    }
    if (muvc == nil) {
        muvc = [[ModifyUserViewController alloc] initWithStyle:UITableViewStylePlain];
        popoverController = [[UIPopoverController alloc] initWithContentViewController:muvc];
        popoverController.delegate = self;
    }
    [popoverController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - Table View

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!isAdminAccount) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.tableHeaderView.frame.size.width, tableView.tableHeaderView.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *headerText = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 250, 34)];
    headerText.backgroundColor = [UIColor clearColor];
    headerText.textColor = [UIColor goldColor];
    headerText.font = [UIFont boldSystemFontOfSize:17];
    [view addSubview:headerText];
    if ([_studentArray count] > 0) {
        if ([[_studentArray[section] lessons] count] == 0) {
            headerText.text = [NSString stringWithFormat:@"%@ -- No Lessons Created", [_studentArray[section] user]];
        } else {
            headerText.text = [_studentArray[section] user];
        }
    }
    return view;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 80;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (isAdminAccount) {
        return [_studentArray count];
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isAdminAccount) {
        return [[_studentArray[section] lessons] count];
    }
    return [student.lessons count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (isAdminAccount) {
        return [_studentArray[section] user];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor goldColor];
    cell.backgroundColor = [UIColor blackColor];
    if (isAdminAccount) {
        [self configureStudentCell:cell atIndexPath:indexPath];
    } else {
        [self configureCell:cell atIndexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isAdminAccount) {
        Student *temp = _studentArray[indexPath.section];
        [self.detailViewController setDetailItem:temp.lessons[indexPath.row]];
        [self.detailViewController setDetailUser:[_studentArray[indexPath.section] user]];
        comparativeObject = temp.lessons[indexPath.row];
    } else {
        [self.detailViewController setDetailItem:student.lessons[indexPath.row]];
        [self.detailViewController setDetailUser:student.user];
        comparativeObject = student.lessons[indexPath.row];
        
    }
    [self.detailViewController setMasterViewController:self];
    [self.detailViewController showContainer];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([[student.lessons[indexPath.row] valueForKey:@"Revision"] isEqualToString:@"YES"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@   revision", [[student.lessons[indexPath.row] valueForKey:@"Date"] description]];
    } else {
        cell.textLabel.text = [[student.lessons[indexPath.row] valueForKey:@"Date"] description];
    }
}

- (void)configureStudentCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Student *object = _studentArray[indexPath.section];
    if ([[object.lessons[indexPath.row] valueForKey:@"Revision"] isEqualToString:@"YES"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@   revision", [[object.lessons[indexPath.row] valueForKey:@"Date"] description]];
    } else {
        cell.textLabel.text = [[object.lessons[indexPath.row] valueForKey:@"Date"] description];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation

{
    return (interfaceOrientation != UIInterfaceOrientationPortrait);
}

@end
