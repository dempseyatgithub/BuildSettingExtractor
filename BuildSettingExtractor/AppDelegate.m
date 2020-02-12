//
//  AppDelegate.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 9/9/14.
//  Copyright (c) 2014 Tapas Software. All rights reserved.
//

#import "AppDelegate.h"
#import "DragFileView.h"
#import "BuildSettingExtractor.h"
#import "AppConstants+Categories.h"
#import "Constants+Categories.h"

// During development it is useful to turn off the overwrite checking
#define OVERWRITE_CHECKING_DISABLED 0

@interface AppDelegate () <NSOpenSavePanelDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet DragFileView *dragFileView;
@property (weak) IBOutlet NSWindow *preferencesWindow;
@property (weak) IBOutlet NSTextField *dragFileLabel;

@end

@implementation AppDelegate

- (void)awakeFromNib {
    self.dragFileView.target = self;
    self.dragFileView.action = @selector(handleDroppedFile:);
    if (@available(macOS 10.13, *)) {
        self.dragFileLabel.textColor = [NSColor colorNamed:@"dragViewTextColor"];
    } else {
        self.dragFileLabel.textColor = [NSColor colorWithCalibratedRed:0.13 green:0.26 blue:0.42 alpha:1.0];
    }
}


- (IBAction)chooseXcodeProject:(id)sender {

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canCreateDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    openPanel.canChooseDirectories = NO;
    openPanel.canChooseFiles = YES;
    openPanel.allowedFileTypes = @[[NSString tps_projectBundleTypeIdentifier]];
    openPanel.message = @"Choose an Xcode project to extract its build settings.";
    openPanel.prompt = @"Choose";
    
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSModalResponseOK) {
            NSURL *projectURL = openPanel.URL;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self processXcodeProjectAtURL:projectURL];
            });
        }
    }];
}

- (IBAction)handleDroppedFile:(DragFileView *)sender {
    NSURL *fileURL = sender.fileURL;
    [self processXcodeProjectAtURL:fileURL];
}

- (void)processXcodeProjectAtURL:(NSURL *)fileURL {
    NSString *typeIdentifier = nil;
    NSError *error = nil;
    [fileURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&error];

    if (fileURL && [typeIdentifier isEqualToString:[NSString tps_projectBundleTypeIdentifier]]) {
        [self selectDestinationURLForSourceProject:fileURL];
    }
}

- (void)selectDestinationURLForSourceProject:(NSURL *)fileURL {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = YES;
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowedFileTypes = @[(NSString *)kUTTypeFolder];
    openPanel.message = [NSString stringWithFormat:@"Choose location to save configuration files for project ‘%@’.", [fileURL lastPathComponent]];
    openPanel.prompt = @"Choose";

    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
            NSURL *destinationURL = openPanel.URL;
            
            NSError *error = nil;
            BOOL validDestination = [BuildSettingExtractor validateDestinationFolder:destinationURL error:&error];
            
            if (validDestination || OVERWRITE_CHECKING_DISABLED) {
                [self performExtractionFromProject:fileURL toDestination:destinationURL];
            }
            else {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
                    if (returnCode == NSAlertSecondButtonReturn) {
                        [self performExtractionFromProject:fileURL toDestination:destinationURL];
                    }
                }];
            }
        }
    }];
}

- (void)performExtractionFromProject:(NSURL *)fileURL toDestination:(NSURL *)destinationURL {
    
    // Perform the extraction in the background.
    // Using DISPATCH_QUEUE_PRIORITY_HIGH which is available on 10.9
    // Move to QOS_CLASS_USER_INITIATED when 10.10 is the deployment target
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        BuildSettingExtractor *buildSettingExtractor = [[BuildSettingExtractor alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        buildSettingExtractor.sharedConfigName = [defaults stringForKey:TPSOutputFileNameShared];
        buildSettingExtractor.projectConfigName = [defaults stringForKey:TPSOutputFileNameProject];
        buildSettingExtractor.nameSeparator = [defaults stringForKey:TPSOutputFileNameSeparator];
        buildSettingExtractor.includeBuildSettingInfoComments = [[NSUserDefaults standardUserDefaults] boolForKey:TPSIncludeBuildSettingInfoComments];
        if (buildSettingExtractor.includeBuildSettingInfoComments) {
            buildSettingExtractor.linesBetweenSettings = [[NSUserDefaults standardUserDefaults] integerForKey:TPSLinesBetweenBuildSettingsWithInfo];
        } else {
            buildSettingExtractor.linesBetweenSettings = [[NSUserDefaults standardUserDefaults] integerForKey:TPSLinesBetweenBuildSettings];
        }
        
        NSError *fatalError = nil;
        
        // Extract the build settings
        NSArray *nonFatalErrors = [buildSettingExtractor extractBuildSettingsFromProject:fileURL error:&fatalError];
        
        // On extraction fatal error, present the error and return.
        if (!nonFatalErrors && fatalError) {
            // present error on main thread and return
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp presentError:fatalError];
            });
            return; // Can't continue, fatal error.

        }
        // Otherwise, present non-fatal errors, if present.
        else if (nonFatalErrors && nonFatalErrors.count > 0) {
            // present non-fatal errors on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                for (NSError *anError in nonFatalErrors) {
                    [NSApp presentError:anError]; // Will present one at a time.
                }
            });
        }
        
        //  Write the config files
        BOOL success = [buildSettingExtractor writeConfigFilesToDestinationFolder: destinationURL error: &fatalError];
        if (!success && fatalError) {
            // present error on main thread and return
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSApp presentError:fatalError];
            });
            return; // Can't continue, fatal error.
        }

        BOOL openInFinder = [[NSUserDefaults standardUserDefaults] boolForKey:TPSOpenDirectoryInFinder];
        if (success && openInFinder) {
            [[NSWorkspace sharedWorkspace] openURL:destinationURL];
        }
    });
}

- (IBAction)presentPreferencesWindow:(id)sender {
    [self.window beginSheet:self.preferencesWindow completionHandler:nil];
}

- (IBAction)dismissPreferencesWindow:(id)sender {
    // make sure current edit field gets bound
    [self.preferencesWindow makeFirstResponder:nil];
    
    [self.window endSheet:self.preferencesWindow];
}


#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *defaults = @{
        TPSOpenDirectoryInFinder:@(YES),
        TPSIncludeBuildSettingInfoComments:@(YES),
        TPSOutputFileNameShared:BuildSettingExtractor.defaultSharedConfigName,
        TPSOutputFileNameProject:BuildSettingExtractor.defaultProjectConfigName,
        TPSOutputFileNameSeparator:BuildSettingExtractor.defaultNameSeparator,
        TPSLinesBetweenBuildSettings:@0,
        TPSLinesBetweenBuildSettingsWithInfo:@3
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


@end
