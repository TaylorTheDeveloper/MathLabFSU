//
//  MasterViewController.m
//  MathPad
//
//  Created by Alex Muller on 8/14/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "MasterViewController.h"
#import "LessonViewController.h"
#import "Lesson.h"
#import "GradeContainer.h"

#define kKindergarten 0
#define kFirst 1
#define kSecond 2
#define kThird 3
#define kFourth 4
#define kFifth 5
#define kSixth 6
#define kSeventh 7
#define kEighth 8
#define kHigh 9

@interface MasterViewController () {
    GradeContainer *gradeContainer;
    NSArray *menuItems;
}
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    menuItems = @[ @"Kindergarten", @"1st Grade", @"2nd Grade", @"3rd Grade", @"4th Grade", @"5th Grade", @"6th Grade", @"7th Grade", @"8th Grade", @"9-12th Grade" ];
    NSError *error = nil;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"GradeContainer"];
    NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
    gradeContainer = [result lastObject];
    if ([[[gradeContainer kindergarten] allObjects] count] == 0) {
        gradeContainer = [NSEntityDescription insertNewObjectForEntityForName:@"GradeContainer" inManagedObjectContext:self.managedObjectContext];
        NSLog(@"Fill");
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"lesson" ofType:nil];
        if (filePath) {
            NSArray *jsonObject = [[NSArray alloc] initWithArray:[NSJSONSerialization JSONObjectWithData:[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil]];
            [jsonObject enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                Lesson *lesson = [NSEntityDescription insertNewObjectForEntityForName:@"Lesson" inManagedObjectContext:self.managedObjectContext];
                [lesson setValuesForKeysWithDictionary:obj];
                if ([[lesson grade] isEqualToString:@"K"]) {
                    [gradeContainer addKindergartenObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"1"]) {
                    [gradeContainer addFirstObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"2"]) {
                    [gradeContainer addSecondObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"3"]) {
                    [gradeContainer addThirdObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"4"]) {
                    [gradeContainer addFourthObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"5"]) {
                    [gradeContainer addFifthObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"6"]) {
                    [gradeContainer addSixthObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"7"]) {
                    [gradeContainer addSeventhObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"8"]) {
                    [gradeContainer addEighthObject:lesson];
                } else if ([[lesson grade] isEqualToString:@"912"]) {
                    [gradeContainer addHighObject:lesson];
                }
//                NSLog(@"%@", [lesson grade]);
            }];
        }
        if ([self.managedObjectContext save:&error]) {
            NSLog(@"%@", [error localizedDescription]);
        }
        NSArray *result = [self.managedObjectContext executeFetchRequest:request error:&error];
        gradeContainer = [result lastObject];
    }
    
//    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
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

//- (void)insertNewObject:(id)sender
//{
//    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//    
//    // If appropriate, configure the new managed object.
//    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//    
//    // Save the context.
//    NSError *error = nil;
//    if (![context save:&error]) {
//         // Replace this implementation with code to handle the error appropriately.
//         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    return [[self.fetchedResultsController sections] count];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
//    return [sectionInfo numberOfObjects];
    return [menuItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//    self.detailViewController.detailItem = object;
//    NSLog(@"%@", [object valueForKey:@"grade"]);
    LessonViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LessonViewController"];
    switch (indexPath.row) {
        case kKindergarten:
            lvc.title = @"Kindergarten";
            lvc.lessons = [[gradeContainer kindergarten] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kFirst:
            lvc.title = @"1st Grade";
            lvc.lessons = [[gradeContainer first] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kSecond:
            lvc.title = @"2nd Grade";
            lvc.lessons = [[gradeContainer second] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kThird:
            lvc.title = @"3rd Grade";
            lvc.lessons = [[gradeContainer third] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kFourth:
            lvc.title = @"4th Grade";
            lvc.lessons = [[gradeContainer fourth] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kFifth:
            lvc.title = @"5th Grade";
            lvc.lessons = [[gradeContainer fifth] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kSixth:
            lvc.title = @"6th Grade";
            lvc.lessons = [[gradeContainer sixth] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kSeventh:
            lvc.title = @"7th Grade";
            lvc.lessons = [[gradeContainer seventh] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kEighth:
            lvc.title = @"8th Grade";
            lvc.lessons = [[gradeContainer eighth] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
        case kHigh:
            lvc.title = @"9-12th Grade";
            lvc.lessons = [[gradeContainer high] allObjects];
            [self.navigationController pushViewController:lvc animated:YES];
            break;
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"GradeContainer" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"empty" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
//    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [menuItems objectAtIndex:indexPath.row];
//    cell.textLabel.text = [[object valueForKey:@"grade"] description];
}

@end
