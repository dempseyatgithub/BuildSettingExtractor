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

// Temporary flag until the preference pane is updated
#define ENCLOSING_DESTINATION_FOLDER_ENABLED 1

@interface AppDelegate () <NSOpenSavePanelDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet DragFileView *dragFileView;
@property (weak) IBOutlet NSWindow *preferencesWindow;
@property NSWindowController *preferencesWindowController;
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
        if (ENCLOSING_DESTINATION_FOLDER_ENABLED && [[NSUserDefaults standardUserDefaults] boolForKey:TPSAutosaveInProjectFolder]) {
            NSURL *baseURL = [fileURL URLByDeletingLastPathComponent];
            NSURL *destinationURL = [self createValidatedDestinationURLForBaseURL:baseURL error:&error];
            if (!destinationURL) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:self.window completionHandler:nil];
                return;
            }
            [self performExtractionFromProject:fileURL toDestination:destinationURL];
        } else {
            [self selectDestinationURLForSourceProject:fileURL];
        }
    }
}

- (void)selectDestinationURLForSourceProject:(NSURL *)fileURL {
    
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.canCreateDirectories = YES;
    openPanel.allowsMultipleSelection = YES;
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowedFileTypes = @[(NSString *)kUTTypeFolder];
#if ENCLOSING_DESTINATION_FOLDER_ENABLED
    openPanel.message = [NSString stringWithFormat:@"Choose location to save configuration files. Configuration files for project\n‘%@’ will be saved in a folder named '%@'.", [fileURL lastPathComponent], [[NSUserDefaults standardUserDefaults] stringForKey:TPSDestinationFolderName]];
#else
    openPanel.message = [NSString stringWithFormat:@"Choose location to save configuration files for project ‘%@’.", [fileURL lastPathComponent]];
    #endif
    openPanel.prompt = @"Choose";

    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        
        if (result == NSModalResponseOK) {
#if ENCLOSING_DESTINATION_FOLDER_ENABLED
            NSError *error = nil;
            NSURL *baseURL = openPanel.URL;
            NSURL *destinationURL = [self createValidatedDestinationURLForBaseURL:baseURL error: &error];
            if (!destinationURL) {
                NSAlert *alert = [NSAlert alertWithError:error];
                [alert beginSheetModalForWindow:self.window completionHandler:nil];
                return;
            }
#else
            NSError *error = nil;
            NSURL *destinationURL = openPanel.URL;
#endif
            
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

- (nullable NSURL *)createValidatedDestinationURLForBaseURL:(NSURL *) baseURL error: (NSError **)error {
    NSString *folderName = [[NSUserDefaults standardUserDefaults] stringForKey:TPSDestinationFolderName];
    // First check if there is a folder of that name in the base url
    NSArray *fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:baseURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    NSMutableIndexSet *untakenIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(1, 9999)];
    BOOL foundNameConflict = NO;
    for (NSURL *fileURL in fileURLs) {
        NSString *filename = [fileURL lastPathComponent];
        if ([folderName isEqualToString:filename]) {
            foundNameConflict = YES;
        }
        if ([filename hasPrefix:folderName]) {
            NSArray *components = [filename componentsSeparatedByString:@"-"];
            if (components.count > 1) {
                NSUInteger value = (NSUInteger)[[components lastObject] integerValue];
                if (value != 0) {
                    [untakenIndexes removeIndex:value];
                }
            }
        }
    }
    NSString *validatedFolderName = nil;
    if (foundNameConflict) {
        validatedFolderName = [NSString stringWithFormat:@"%@-%ld", folderName, untakenIndexes.firstIndex];
    } else {
        validatedFolderName = folderName;
    }
    
    // Then create destination folder
    NSURL *validatedDestinationURL = [baseURL URLByAppendingPathComponent:validatedFolderName];
    if ([[NSFileManager defaultManager] createDirectoryAtURL:validatedDestinationURL withIntermediateDirectories:NO attributes:nil error:error]) {
        return validatedDestinationURL;
    } else {
        return nil;
    }
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
        BOOL includeInfo = [defaults boolForKey:TPSIncludeBuildSettingInfoComments];
        buildSettingExtractor.includeBuildSettingInfoComments = includeInfo;
        buildSettingExtractor.linesBetweenSettings = [defaults integerForKey:includeInfo ? TPSLinesBetweenBuildSettingsWithInfo : TPSLinesBetweenBuildSettings];
        buildSettingExtractor.targetFoldersEnabled = [defaults boolForKey:TPSTargetFoldersEnabled];
        buildSettingExtractor.projectFolderEnabled = [defaults boolForKey:TPSProjectFolderEnabled];
        buildSettingExtractor.alignBuildSettingValues = [defaults boolForKey:TPSAlignBuildSettingValues];
        
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
    if (!self.preferencesWindowController) {
        NSStoryboard *storyboard = [NSStoryboard storyboardWithName:@"Preferences" bundle:nil];
        self.preferencesWindowController = (NSWindowController *)[storyboard instantiateInitialController];
    }
    [self.preferencesWindowController showWindow:nil];
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
    [[NSUserDefaults standardUserDefaults] tps_registerApplicationDefaults];
}


@end
