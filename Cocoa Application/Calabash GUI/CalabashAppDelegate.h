//
//  CalabashAppDelegate.h
//  Calabash GUI
//
//  Created by James Wegner on 6/6/13.
//  Copyright (c) 2013 James Wegner. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CalabashTest.h"
#import "UserEnvironment.h"
#import "UserEnvironment.h"
#import "ConsoleOutputTextView.h"
#import <WebKit/WebKit.h>

@interface CalabashAppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTabView *tabView; 
@property (unsafe_unretained) IBOutlet NSTextView *consoleWindow;
@property (weak) IBOutlet WebView *htmlResultsWindow;

@property (strong,nonatomic) CalabashTest *calabashTest;
//@property (strong, nonatomic) CalabashTestManager *calabashTestManager;
@property (strong, nonatomic) UserEnvironment *userEnvironment;

-(CalabashTest*)getCalabashTestAtPath:(NSString*)path;

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *tags;
@property (weak) IBOutlet NSMatrix *osRadio;
@property (weak) IBOutlet NSTextField *xcodeOrApkPathLabel;
@property (weak) IBOutlet NSTextField *calabashPathLabel;
@property (weak) IBOutlet NSTextField *xcodePathLabel;
@property (weak) IBOutlet NSMatrix *restartRadio;
@property (weak) IBOutlet NSTextField *xCodeProjectLabel;
@property (weak) IBOutlet NSButton *xcodeProjectBrowseButton;
@property (weak) IBOutlet NSButton *apkFileBrowseButton;
@property (weak) IBOutlet NSTextField *apkFileLabel;
@property (weak) IBOutlet NSTextField *screenshotPathLabel;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSButton *stopTestButton;
@property (weak) IBOutlet NSButton *startTestButton;
@property (weak) IBOutlet NSTextField *testNameLabel;

@property(strong, nonatomic) NSString* fileName;
@property(strong) NSMutableArray *windowArray;
@property (weak) IBOutlet NSButton *saveTestButton;
@property Boolean canRun;
@property Boolean testSaved;

@property (weak) IBOutlet NSTextField *calabashFeatureFolderText;
@property (weak) IBOutlet NSTextField *apkFileText;
@property (weak) IBOutlet NSTextField *xcodeProjectFolderText;

- (IBAction)onRestartChange:(id)sender;
- (IBAction)browseScreenshotFolder:(id)sender;
- (IBAction)onOSChange:(id)sender;
- (IBAction)runTest:(id)sender;
- (IBAction)browseAPK:(id)sender;
- (IBAction)browseXcodeProject:(id)sender;
- (IBAction)browseCalabashFeature:(id)sender;
- (IBAction)saveTestAction:(id)sender;
- (IBAction)loadTest:(id)sender;
- (IBAction)stopTest:(id)sender;

-(NSString*)getTags;

@end