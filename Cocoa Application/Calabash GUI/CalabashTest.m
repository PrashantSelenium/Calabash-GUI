//
//  CalabashTest.m
//  Calabash GUI
//
//  Created by James Wegner on 6/19/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import "CalabashAppDelegate.h"
#import "CalabashTest.h"

@implementation CalabashTest

- (id)init
{
    if (self = [super init]) { // self does not equal nil
        _calabashPath = @" ";
        _apkOrXcodePath = @" ";
        _screenshotPath = @"";
        _path = nil;
        _noStop = @"0";
        _finished = FALSE;
        _task = nil;
        _ios = TRUE;
        _android = FALSE;
        _overwrite = TRUE;
        _name = @"Untitled_Test";
        _tags = @" ";
        _shellPath = @" ";
    }
    return self;
}
// Creates the NSTask to be ran and calls methods to set up PATH variable and shell script file
- (void) launchTestWithProcess:(NSString *)processPath withPathVariable:(NSString *)pathVariable
{
    _finished = FALSE;
    
    _calabashPath = processPath;
    _task = [[NSTask alloc] init];
    
    //Copy over users shell environment
    NSDictionary *environmentDict = [[NSProcessInfo processInfo] environment];
    
    NSRange androidHomeRange = [pathVariable rangeOfString:@"ANDROID_HOME=/"];
    
    NSUInteger startIndex = androidHomeRange.location;
    NSUInteger endIndex = NSMaxRange(androidHomeRange);
    
    [pathVariable getLineStart:&startIndex end:&endIndex contentsEnd:NULL forRange:androidHomeRange];
    
    // We don't want to include the text "ANDROID_HOME=" in the path so we move the startIndex by 13 character, then subtract one to remove the \n characters
    NSString *androidHome = [pathVariable substringWithRange:NSMakeRange(startIndex+13, (endIndex-(startIndex+13)-1))];
    
    // Now add these paths to the environment
    [environmentDict setValue:pathVariable forKey:@"PATH"];
    [environmentDict setValue:androidHome forKey:@"ANDROID_HOME"];

    [_task setEnvironment:environmentDict];
    [_task setCurrentDirectoryPath:_calabashPath];
    [_task setLaunchPath:@"/bin/bash"];
    
    NSLog(@"Current Directory is: %@",_calabashPath);
    NSLog(@"Executing shell script at path: %@",_shellPath);

    [_task setArguments:[NSArray arrayWithObjects:[[[_shellPath stringByAppendingString:@"/"] stringByAppendingString:_name] stringByAppendingString:@".sh"], nil]];
    
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
}

// Print the output from the NSTask into the console window
-(void) notifiedForStdOutput: (NSNotification *) notification
{
    NSFileHandle *outFile = [notification object];
    [outFile waitForDataInBackgroundAndNotify];
    NSData *data = [outFile availableData];
    NSString *outString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",outString);
    
    CalabashAppDelegate *appDelegate = [[NSApplication sharedApplication]delegate];
    [appDelegate.consoleWindow setString:[appDelegate.consoleWindow.string stringByAppendingString:outString]];
    
    if(_finished)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[notification object]];
    }
}

// Sets finished flag to true and send terminate command to task
-(void) notifiedForComplete: (NSNotification *) notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];

    _finished = TRUE;
    
    CalabashAppDelegate *appDelegate = [[NSApplication sharedApplication]delegate];
    
    NSString *resultsStringPath = _calabashPath;
    resultsStringPath = [[[_calabashPath stringByAppendingString:@"/"] stringByAppendingString:_name] stringByAppendingString:@"_Report.html"];

    NSString *resultsPath = [@"file://localhost" stringByAppendingString:resultsStringPath];
    resultsPath = [resultsPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *resultsURL = [NSURL URLWithString:resultsPath];    
    NSURLRequest*request=[NSURLRequest requestWithURL:resultsURL];
    [[appDelegate.htmlResultsWindow mainFrame] loadRequest:request];
    
    //Disable progress bar and enable the start test button
    [appDelegate.progress stopAnimation:appDelegate.progress];
    [appDelegate.progress setHidden:TRUE];
    [appDelegate.startTestButton setEnabled:TRUE];
}
 
-(void) notifiedForStdError: (NSNotification *) notification
{
    NSLog(@"CALABASH TEST ERROR:");
    
    NSFileHandle *outFile = [notification object];
    NSData *data = [outFile availableData];
    NSString *outString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"%@",outString);
    
    CalabashAppDelegate *appDelegate = [[NSApplication sharedApplication]delegate];    
    [appDelegate.consoleWindow setString:[appDelegate.consoleWindow.string stringByAppendingString:outString]];
    
    if(_finished)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:[notification object]];
    }
}

// Creats shell script from user inputted variables
-(void)createShellFileAtPath:(NSString*)filePath
{
    _shellPath = filePath;
    
    NSError *error;
    
    // Use to construct are shell command
    NSString* command;
    
    command = @"SCREENSHOT_PATH=.";
    command = [command stringByAppendingString:[_screenshotPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    command = [command stringByAppendingString:@"/ "];
    
    if(_ios)
    {
        command = [command stringByAppendingString:@"cucumber PROJECT_DIR=\""];
    }
    else if (_android)
    {
        command = [command stringByAppendingString:@"calabash-android run \""];
    }
    
    command = [command stringByAppendingString:_apkOrXcodePath];
    command = [command stringByAppendingString:@"\""];
    command = [command stringByAppendingString:@" "];
    command = [command stringByAppendingString:@"NO_STOP="];
    command = [command stringByAppendingString:_noStop];
    command = [command stringByAppendingString:@" "];
    
    if([_tags length] != 0)
    {
        if(_ios)
        {
            command = [command stringByAppendingString:@"-t "];
        }
        else if(_android)
        {
            command = [command stringByAppendingString:@"--tags "];
        }
        
        _tags = [_tags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        command = [command stringByAppendingString:_tags];
    }
    
    NSString* reportName = [_name stringByAppendingString:@"_Report.html"];
    command = [[command stringByAppendingString:@" --format pretty --format html --out "] stringByAppendingString:reportName];
    
    command = [[command stringByAppendingString:@" #"] stringByAppendingString:_calabashPath];
    
    [command writeToFile:[[[filePath stringByAppendingString:@"/"] stringByAppendingString:_name] stringByAppendingString:@".sh"] atomically:YES encoding:NSUTF8StringEncoding error:&error];
}
@end