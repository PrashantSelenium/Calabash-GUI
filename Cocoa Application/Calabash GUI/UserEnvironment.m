//
//  UserEnvironment.m
//  Calabash GUI
//
//  Created by James Wegner on 7/23/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import "UserEnvironment.h"

@implementation UserEnvironment
- (id)init
{
    if (self = [super init]) { // self does not equal nil
        _pathVariable = @" ";
    }
    return self;
}

// Execute task to get the users environment settings
-(NSString *) getUserEnvironment
{
    _task = [[NSTask alloc] init];

    [_task setLaunchPath:@"/bin/bash"];

    // This will give us the environment variables as output
    [_task setArguments: [NSArray arrayWithObjects:@"-l", @"-c", @"env", nil]];

    //Create pipes for output
    NSPipe *outPipe = [NSPipe pipe];
    NSPipe *errorPipe = [NSPipe pipe];
    
    //Set input, output, and error
    [_task setStandardInput:[NSPipe pipe]];
    [_task setStandardOutput:outPipe];
    [_task setStandardError:errorPipe];
    
    //Create the filehandles to be used for notifications
    NSFileHandle *outFile = [outPipe fileHandleForReading];
    NSFileHandle *errFile = [errorPipe fileHandleForReading];
    [outFile waitForDataInBackgroundAndNotify];
    [errFile waitForDataInBackgroundAndNotify];

    // Setup the notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self selector:@selector(notifiedForStdOutput:) name:NSFileHandleDataAvailableNotification object:outFile];
    [nc addObserver:self selector:@selector(notifiedForStdError:)  name:NSFileHandleDataAvailableNotification object:errFile];
    [nc addObserver:self selector:@selector(notifiedForComplete:)  name:NSTaskDidTerminateNotification object:_task];
    
    [_task launch];
    [_task waitUntilExit];
    // _pathVariable should be set in output notification
    return _pathVariable;
}

// Get the outputted string that contains the path variable and assign it to _pathVariable, then remove the observer
-(void) notifiedForStdOutput:(NSNotification *)notification
{
    NSFileHandle *outFile = [notification object];
    NSData *data = [outFile availableData];
    NSString *outString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    
    _pathVariable = outString;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[notification object]];
    
    // We have what we want so terminate the task
    [_task terminate];
}

-(void) notifiedForComplete:(NSNotification *)notification
{
    NSLog(@"User environment task complete");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:[notification object]];
}

// Print the error and remove observer
-(void) notifiedForStdError:(NSNotification *)notification
{
    NSLog(@"USER ENVIRONMENT ERROR:");
    
    NSFileHandle *outFile = [notification object];
    NSData *data = [outFile availableData];
    NSString *outString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",outString);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[notification object]];    
}
@end