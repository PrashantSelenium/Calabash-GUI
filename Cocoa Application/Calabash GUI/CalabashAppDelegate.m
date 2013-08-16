//
//  CalabashAppDelegate.m
//  Calabash GUI
//
//  Created by James Wegner on 6/6/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import "CalabashAppDelegate.h"

@implementation CalabashAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _calabashTest = [[CalabashTest alloc] init];
    _userEnvironment = [[UserEnvironment alloc] init];

    //Hide Android and Enable  iOS as default
    [_apkFileBrowseButton setEnabled:FALSE];
    _calabashTest.ios = TRUE;
    
    //Hide Progress
    [_progress setHidden:TRUE];
    _windowArray = [[NSMutableArray alloc] init];
    
    //Disable run and save
    [_startTestButton setEnabled:FALSE];
    [_saveTestButton setEnabled:FALSE];
    [_stopTestButton setEnabled:FALSE];
    _canRun = FALSE;
    _testSaved = FALSE;
}

- (IBAction)runTest:(id)sender
{
    [_stopTestButton setEnabled:TRUE];
    [_tabView selectNextTabViewItem:(_tabView)];
    //Get user envrionment    
    NSString *pathVariable = [_userEnvironment getUserEnvironment];

    //Start progress
    [_progress setHidden:FALSE];
    [_progress setIndeterminate:TRUE];
    [_progress startAnimation:_progress];
    
    _calabashTest.tags = [self getTags];
    
    // Clear console
    [_consoleWindow setString:@""];
    [_consoleWindow setTextColor:[NSColor whiteColor]];

    // Start the task creation and disable start test button
    [_startTestButton setEnabled:FALSE];
    
    // Check if the user saved the test, if not use calabash path as the location
    if(!_testSaved)
    {
        [_calabashTest createShellFileAtPath:_calabashTest.calabashPath];
    }
    else
    {
        [_calabashTest createShellFileAtPath:_calabashTest.shellPath];
    }
    
    [_calabashTest launchTestWithProcess:[_calabashPathLabel stringValue] withPathVariable:pathVariable];
}

- (IBAction)onOSChange:(id)sender
{
    if ([_osRadio selectedTag] == 1)
    {
        // Enable Android
        _calabashTest.android = TRUE;
        [_apkFileLabel setEnabled:TRUE];
        [_apkFileBrowseButton setEnabled:TRUE];
        
        //Disable iOS
        _calabashTest.ios = FALSE;
        [_xcodeProjectBrowseButton setEnabled:FALSE];
        [_xcodePathLabel setEnabled:FALSE];        
    }else
    {
        // Enable iOS
        _calabashTest.ios = TRUE;
        [_xcodeProjectBrowseButton setEnabled:TRUE];
        [_xcodePathLabel setEnabled:TRUE];
        
        //Disable Android
        _calabashTest.android = FALSE;
        [_apkFileLabel setEnabled:FALSE];
        [_apkFileBrowseButton setEnabled:FALSE];
    }
}

- (IBAction)onRestartChange:(id)sender
{
    if ([_osRadio selectedTag] == 1)
    {
        _calabashTest.noStop = @"1";
    }else
    {
        _calabashTest.noStop = @"0";
    }
}

- (IBAction)browseScreenshotFolder:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton){
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            
            //Grab the file/folder path
            [_screenshotPathLabel setStringValue:[theDoc path]];
            _calabashTest.screenshotPath = [theDoc path];
        }
    }];
}

- (IBAction)browseAPK:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton){
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            
            //Grab the file/folder path
            [_xcodeOrApkPathLabel setStringValue:[theDoc path]];
            _calabashTest.apkOrXcodePath = [theDoc path];
            
            //Check if can run
            if (_calabashTest.calabashPath != nil)
            {
                _canRun = true;
                [_startTestButton setEnabled:TRUE];
            }
        }
    }];
}

- (IBAction)browseXcodeProject:(id)sender {
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton){
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            
            //Grab the file/folder path
            [_xcodeOrApkPathLabel setStringValue:[theDoc path]];
            _calabashTest.apkOrXcodePath = [theDoc path];
            
            //Check if can run
            if (_calabashTest.calabashPath != nil)
            {
                _canRun = true;
                [_startTestButton setEnabled:TRUE];
                [_saveTestButton setEnabled:TRUE];
            }
        }
    }];
}

- (IBAction)browseCalabashFeature:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton){
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            
            //Grab the file/folder path
            [_calabashPathLabel setStringValue:[theDoc path]];
            _calabashTest.calabashPath = [theDoc path];
            
            //Check if can run
            if (_calabashTest.apkOrXcodePath != nil)
            {
                _canRun = true;
                [_saveTestButton setEnabled:TRUE];
                [_startTestButton setEnabled:TRUE];
            }
        }
    }];
}

- (IBAction)stopTest:(id)sender {
    if(_canRun)
    {
        [_startTestButton setEnabled:TRUE];
    }
    [_progress setHidden:TRUE];
    
    @try
    {
        [[_calabashTest task] terminate];
    }
    @catch (NSException* e)
    {
    }
}

- (IBAction)saveTestAction:(id)sender
{
    NSSavePanel* panel = [NSSavePanel savePanel];
    [panel setCanCreateDirectories:YES];
    [panel setNameFieldStringValue:_calabashTest.name];
    
    NSArray *fileType = [NSArray arrayWithObjects:@"sh", nil];
    [panel setAllowedFileTypes:fileType];
    
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton){
            _testSaved = true;
            NSURL* theDoc = [panel directoryURL];
        
            [_testNameLabel setStringValue:[panel nameFieldStringValue]];
            _calabashTest.name = [panel.nameFieldStringValue substringWithRange: NSMakeRange(0, panel.nameFieldStringValue.length - 3)]; // Ignore .sh at end
            _calabashTest.tags = [self getTags];
            
            [_calabashTest createShellFileAtPath:theDoc.path];
        }
    }];
}

- (IBAction)loadTest:(id)sender
{
    NSOpenPanel* panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:NO];
    [panel beginWithCompletionHandler:^(NSInteger result) {
        if (result == 1)
        {
            NSURL* theDoc = [[panel URLs] objectAtIndex:0];
            _testSaved = true;
            
            _calabashTest.name = [theDoc lastPathComponent];
            
            // Set the appropriate values
            _calabashTest =  [self getCalabashTestAtPath:[theDoc path]];
            
            // Now set the screen controls appropriately
            [_testNameLabel setStringValue:_calabashTest.name];
            [_xcodeOrApkPathLabel setStringValue:_calabashTest.apkOrXcodePath];
            
            if([_calabashTest.noStop isEqualTo:@"1"])
            {
                [_restartRadio selectCellAtRow:0 column:1];
            }
            else
            {
                [_restartRadio selectCellAtRow:0 column:0];
            }
            
            if(_calabashTest.android)
            {
                [_apkFileBrowseButton setEnabled:TRUE];
                [_xcodeProjectBrowseButton setEnabled:FALSE];
                [_osRadio selectCellAtRow:0 column:1];
            }
            else
            {
                [_apkFileBrowseButton setEnabled:FALSE];
                [_xcodeProjectBrowseButton setEnabled:TRUE];
                [_osRadio selectCellAtRow:0 column:0];
            }
            
            [_calabashPathLabel setStringValue:_calabashTest.calabashPath];
            [_screenshotPathLabel setStringValue:_calabashTest.screenshotPath];
            [_tags setStringValue:_calabashTest.tags];
            
            _canRun = TRUE;
            [_startTestButton setEnabled:TRUE];
            [_saveTestButton setEnabled:TRUE];
        }
    }];
}

// Parses the shell command at the given path and gives us a calabashTest
-(CalabashTest*) getCalabashTestAtPath:(NSString*)path
{
    CalabashTest* newTest = [[CalabashTest alloc]init];
    
    // Get the contents of the shell file
    NSData* shellFileData = [[NSData alloc] initWithContentsOfFile:_calabashTest.shellPath];
    NSString* shellFileString = [[NSString alloc]initWithData:shellFileData encoding:NSUTF8StringEncoding];
    
    NSRange screenshotPathRange = [shellFileString rangeOfString:@"SCREENSHOT_PATH=/"];
    NSRange endScreenshotRange = [shellFileString rangeOfString:@"/ c"];

    // Now we need to determine if this is iOS or Android
    NSRange cucumberRange = [shellFileString rangeOfString:@"cucumber"];
    NSRange calabashAndroidRange = [shellFileString rangeOfString:@"calabash-android run"];

    if(cucumberRange.length != 0 && calabashAndroidRange.length == 0)
    {
        newTest.android = false;
        newTest.ios = true;
    }else if(cucumberRange.length == 0 && calabashAndroidRange.length != 0)
    {
        newTest.android = true;
        newTest.ios = false;
    }else
    {
        // Something went wrong
        NSLog(@"Problem Loading Test");
    }
    
    NSRange apkOrProjectRange;
    if(newTest.android)
    {
        apkOrProjectRange = [shellFileString rangeOfString:@"run \""];
    }else
    {
        apkOrProjectRange = [shellFileString rangeOfString:@"PROJECT_DIR=\""];
    }
    
    NSRange endApkOrProjectRange = [shellFileString rangeOfString:@"\" NO_STOP="];
    NSRange noStopRange = [shellFileString rangeOfString:@"NO_STOP="];
    
    NSRange tagRange;
    if(newTest.android)
    {
        tagRange = [shellFileString rangeOfString:@"--tags"];
    }else
    {
        tagRange = [shellFileString rangeOfString:@"-t"];
    }
    
    NSRange endTagRange = [shellFileString rangeOfString:@"--format"];
    
    // Get the xcode/APK file path
     newTest.apkOrXcodePath = [[shellFileString substringWithRange:NSMakeRange(NSMaxRange(apkOrProjectRange), endApkOrProjectRange.location-NSMaxRange(apkOrProjectRange))] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    // Get the noStop value
    if(tagRange.location != NSNotFound)
    {
        newTest.noStop = [[shellFileString substringWithRange:NSMakeRange(NSMaxRange(noStopRange), tagRange.location - NSMaxRange(noStopRange))] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }else
    {
       newTest.noStop = [[shellFileString substringWithRange:NSMakeRange(NSMaxRange(noStopRange), endTagRange.location - NSMaxRange(noStopRange))] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }

    // Get the screenshot path
    if(screenshotPathRange.length > endScreenshotRange.location)
    {
        newTest.screenshotPath = @"";
    }
    else
    {
        newTest.screenshotPath = [[shellFileString substringWithRange:NSMakeRange(NSMaxRange(screenshotPathRange), endScreenshotRange.location - NSMaxRange(screenshotPathRange))] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    // Get the tags
    if(tagRange.location != NSNotFound)
    {
        newTest.tags = [[shellFileString substringWithRange:NSMakeRange(NSMaxRange(tagRange),endTagRange.location - NSMaxRange(tagRange))] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
    
    // Finally get the calabash path label which is commented with a '#'
    NSRange calabashPathRange = [shellFileString rangeOfString:@"#"];
    calabashPathRange.location += 1; // So we don't get the #
    newTest.calabashPath = [shellFileString substringFromIndex:calabashPathRange.location];
    [self.calabashPathLabel setStringValue:newTest.calabashPath];
    
    return newTest;
}

// Loads the test results HTML file into the webView
-(void)showResultsAtPath:(NSString*)htmlStringPath WithURL:(NSURL*)htmlURLPath
{
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlStringPath encoding:NSUTF8StringEncoding error: nil];
    [[_htmlResultsWindow mainFrame] loadHTMLString:htmlString baseURL:htmlURLPath];
}

-(NSString*)getTags
{
    return [_tags.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
@end