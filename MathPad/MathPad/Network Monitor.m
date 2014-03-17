//
//  Network Monitor.m
//  MathPad
//
//  Created by Alex Muller on 1/7/13.
//  Copyright (c) 2013 Alex Muller. All rights reserved.
//

#import "Network Monitor.h"

@implementation Network_Monitor

+ (void)checkConnection {
    if (![self hasInternet]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Internet connection is required for this application. Please enable WiFi/3G in the Settings app." delegate:self cancelButtonTitle:nil otherButtonTitles:@"Exit", nil];
        [alert show];
    }
}

// Check whether the user has internet
+ (BOOL)hasInternet {
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.google.com"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    if ([NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil]) {
        return YES;
    }
    return NO;
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        exit(0);
    }
}

@end
