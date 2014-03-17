//
//  LoginViewController.m
//  MathPad
//
//  Created by Alex Muller on 9/4/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//
// Updates made by Taylor Brockhoeft on 3/17/14 -> Happy St. Patty's :)
//

#import "LoginViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "BButton.h"

#define ADMINUSER @"kclark"
#define ADMINPASS @"sammers2"

@interface LoginViewController () {
    IBOutlet UITextField *username;
    IBOutlet UITextField *password;
    IBOutlet UILabel *errorMessage;
    IBOutlet BButton *loginButton;
    DBRestClient *restClient;
    NSString *filePath;
    int fileIndex;
    
    IBOutlet BButton *bugButton;
}

@end

#warning modify network notification when incorrect username/password because it still displays
#warning disable ALL BUTTONS when pressed along with disallowing touches
#warning include wifi network check and push them to settings

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [Network_Monitor checkConnection];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loginButton.color = [UIColor blackColor];
    [loginButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
    bugButton.color = [UIColor blackColor];
    [bugButton setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
	// Do any additional setup after loading the view.
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == username) {
        [password becomeFirstResponder];
    } else {
        [self login:nil];
    }
    return YES;
}

- (IBAction)login:(id)sender {
    if ([username.text length] == 0 || [password.text length] == 0) {
        [self displayErrorWithMessage:@"No fields can be empty."];
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:username.text forKey:@"username"];
    [defaults synchronize];
//    if ([username.text isEqualToString:ADMINUSER]) {
//        
//    } else {
    [username resignFirstResponder];
    [password resignFirstResponder];
    loginButton.enabled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] loadMetadata:[NSString stringWithFormat:@"/%@", username.text]];
//    }
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (!metadata.isDirectory) {
        [self displayErrorWithMessage:@"This user does not exist."];
        return;
    } else {
        if (![metadata.path isEqualToDropboxPath:@"/"]) {
            [[self restClient] loadMetadata:@"/"];
            return;
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        filePath = [documentsDirectory stringByAppendingPathComponent:@".validation"];
        fileIndex = [self searchForIndex:username.text inArray:metadata.contents];
        [Network_Monitor checkConnection];
        [[self restClient] loadFile:@"/.validation" intoPath:filePath];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    loginButton.enabled = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (int)searchForIndex:(NSString *)user inArray:(NSArray *)array {
    __block int index = -1;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSLog(@"%@", [obj valueForKey:@"path"]);
        if ([[obj valueForKey:@"path"] isEqualToDropboxPath:[NSString stringWithFormat:@"/%@", user]]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index - 2;
}

- (void)loadFSUStandards {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
    NSString *standardPath = [documentsDirectory stringByAppendingPathComponent:@".FSUStandards"];
    [[self restClient] loadFile:@"/.FSUStandards" intoPath:standardPath];
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {
    if ([LoginViewController isAdmin]) {
        return;
    }
    // This should be true if coming from creation of temp for validation
    if ([localPath isEqualToString:filePath]) {
        NSString* fileContents =
        [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSArray *tempArray = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        // Check to see if SHA1 from .Validation matches SHA1 from password. If yes, proceed else display error
        if ([[tempArray objectAtIndex:fileIndex] isEqualToString:[self SHA1FromText:password.text]]) {
            NSLog(@"Passwords are verified, continue");
//            [self loadFSUStandards];
            // ALWAYS delete the temp validation file
//            NSFileManager *fileManager = [[NSFileManager alloc] init];
//            if ([fileManager removeItemAtPath:filePath error:nil]) {
            self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self dismissModalViewControllerAnimated:YES];
//            }
        } else {
            [self displayErrorWithMessage:@"Incorrect password for user."];
            loginButton.enabled = YES;
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }
    }
}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    NSLog(@"There was an error loading the file - %@", error);
    if (error.code == 503 || error.code == -1009) {
        [self displayErrorWithMessage:@"Dropbox is currently down."];
        loginButton.enabled = YES;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    if ([LoginViewController isAdmin] && [password.text isEqualToString:ADMINPASS]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        NSString *temp = [documentsDirectory stringByAppendingPathComponent:@".validation"];
        [[self restClient] loadFile:@"/.validation" intoPath:temp];
//        [self loadFSUStandards];
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self dismissModalViewControllerAnimated:YES];
    } else {
        if ([username.text isEqualToString:ADMINUSER] && ![password.text isEqualToString:ADMINPASS]) {
            [self displayErrorWithMessage:@"Incorrect password for user."];
        } else {
            [self displayErrorWithMessage:@"This user does not exist."];
        }
    }
}

- (NSString*)SHA1FromText:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (BOOL) isAdmin {
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"username"] isEqualToString:ADMINUSER]) {
        return YES;
    }
    return NO;
}

- (void)displayErrorWithMessage:(NSString *)message {
    
    errorMessage.text = message;
    
    UIColor *color = [UIColor whiteColor];
    [self->errorMessage setTextColor:color];
    
    [UIView animateWithDuration:0.5 animations:^{
        errorMessage.alpha = 1.0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionCurveLinear animations:^{
            errorMessage.alpha = 0.0;
        } completion:nil];
    }];
}

@end
