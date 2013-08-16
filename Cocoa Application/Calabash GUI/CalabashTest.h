//
//  CalabashTest.h
//  Calabash GUI
//
//  Created by James Wegner on 6/19/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import "CalabashAppDelegate.h"
#import <Foundation/Foundation.h>

@interface CalabashTest : NSObject
@property (strong,nonatomic) NSString* tags;
@property (strong,nonatomic) NSString* calabashPath;
@property (strong,nonatomic) NSString* apkOrXcodePath;
@property (strong,nonatomic) NSString* screenshotPath;
@property (strong,nonatomic) NSString* path;
@property (strong,nonatomic) NSString* noStop;
@property (strong,nonatomic) NSTask* task;
@property (strong,nonatomic) NSString* name;
@property (strong,nonatomic) NSString* shellPath;

@property BOOL finished;
@property BOOL android;
@property BOOL ios;
@property BOOL overwrite;

-(void)launchTestWithProcess:(NSString*)processPath withPathVariable:(NSString *)pathVariable;
-(void)createShellFileAtPath:(NSString*)filePath;

-(void)notifiedForStdOutput:(NSNotification*)notification;
-(void)notifiedForStdError:(NSNotification*)notification;
-(void)notifiedForComplete:(NSNotification*)notification;

@end
