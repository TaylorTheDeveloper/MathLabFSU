//
//  AddStudentCell.m
//  MathPad
//
//  Created by Alex Muller on 10/23/12.
//  Copyright (c) 2012 Alex Muller. All rights reserved.
//

#import "AddStudentCell.h"
#import "BButton.h"
#import <CommonCrypto/CommonDigest.h>

@interface AddStudentCell () {
    UITextField *username;
    UITextField *password;
    UILabel *errorMessage;
    DBRestClient *restClient;
    BButton *add;
    
    NSString *filePath;
}
- (NSString*)SHA1FromText:(NSString*)input;

@end

@implementation AddStudentCell

@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor FSUGrayColor];
        username = [[UITextField alloc] initWithFrame:CGRectMake(20, 41, 97, 30)];
        username.borderStyle = UITextBorderStyleRoundedRect;
        username.placeholder = @"FSUID";
        username.autocapitalizationType = UITextAutocapitalizationTypeNone;
        password = [[UITextField alloc] initWithFrame:CGRectMake(20, 79, 173, 30)];
        password.borderStyle = UITextBorderStyleRoundedRect;
        password.placeholder = @"Password";
        password.autocapitalizationType = UITextAutocapitalizationTypeNone;
        errorMessage = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 260, 35)];
        errorMessage.backgroundColor = [UIColor clearColor];
        errorMessage.textColor = [UIColor garnetColor];
        errorMessage.font = [UIFont systemFontOfSize:15];
        errorMessage.textAlignment = UITextAlignmentCenter;
        errorMessage.alpha = 0.0;
        add = [[BButton alloc] initWithFrame:CGRectMake(220, 77, 72, 37)];
        add.color = [UIColor garnetColor];
        [add setTitleColor:[UIColor goldColor] forState:UIControlStateNormal];
        [add setTitle:@"Add" forState:UIControlStateNormal];
        [add addTarget:self action:@selector(saveAdd:) forControlEvents:UIControlEventTouchUpInside];
        UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(120, 41, 110, 30)];
        email.font = [UIFont boldSystemFontOfSize:17];
        email.text = @"@my.fsu.edu";
        email.backgroundColor = [UIColor clearColor];
        email.textColor = [UIColor goldColor];
        [self.contentView addSubview:username];
        [self.contentView addSubview:password];
        [self.contentView addSubview:add];
        [self.contentView addSubview:email];
        [self.contentView addSubview:errorMessage];
    }
    return self;
}

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
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

- (NSString *)SHA1FromText:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
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

- (void)clearFields {
    username.text = @"";
    password.text = @"";
}

- (void)saveAdd:(id)sender {
    username.text = [username.text lowercaseString];
    password.text = [password.text lowercaseString];
    add.enabled = NO;
    if ([username.text length] == 0 || [password.text length] == 0) {
        [self displayErrorWithMessage:@"Must contain FSUID and Password."];
        return;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.csv", username.text]];
    [[NSString stringWithFormat:@"ID,Date,Revision,CCS,FSU,Comments,Rating"] writeToFile:filePath atomically:YES encoding:NSStringEncodingConversionAllowLossy error:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [[self restClient] uploadFile:[NSString stringWithFormat:@"%@.csv", username.text] toPath:[NSString stringWithFormat:@"/%@", username.text] withParentRev:nil fromPath:filePath];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    add.enabled = YES;
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    if ([metadata.filename isEqualToString:[NSString stringWithFormat:@"%@.csv", username.text]]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] loadMetadata:@"/"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    } else if ([metadata.filename isEqualToString:@".validation"]) {
        [_delegate refreshTable];
        [self clearFields];
    }
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if ([metadata.path isEqualToDropboxPath:@"/"]) {
//        NSLog(@"Index for %@ is %i", username.text, [self searchForIndex:username.text inArray:metadata.contents]);
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents directory
        filePath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@".validation"]];
        NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *fileArray = [[NSMutableArray alloc] initWithArray:[fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
        [fileArray insertObject:[self SHA1FromText:password.text] atIndex:[self searchForIndex:username.text inArray:metadata.contents]];
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
    } else if ([metadata.filename isEqualToString:@".validation"]) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [[self restClient] uploadFile:@".validation" toPath:@"/" withParentRev:metadata.rev fromPath:filePath];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
