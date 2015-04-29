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
#import "Constants+Categories.h"

// During development it is useful to turn off the overwrite checking
#define OVERWRITE_CHECKING_DISABLED 0

@interface AppDelegate () <NSOpenSavePanelDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet DragFileView *dragFileView;
@property (weak) IBOutlet NSWindow *preferencesWindow;

@property BOOL shouldOverwriteFiles;

@end

@implementation AppDelegate

- (void)awakeFromNib {
    self.dragFileView.target = self;
    self.dragFileView.action = @selector(handleDroppedFile:);
}


- (IBAction)handleDroppedFile:(DragFileView *)sender {
    NSURL *fileURL = sender.fileURL;
    NSString *typeIdentifier = nil;
    NSString *fileName = nil;
    NSError *error = nil;
    [fileURL getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&error];
    [fileURL getResourceValue:&fileName forKey:NSURLLocalizedNameKey error:&error];


    if (fileURL && [typeIdentifier isEqualToString:[NSString tps_projectBundleTypeIdentifier]]) {
        self.shouldOverwriteFiles = OVERWRITE_CHECKING_DISABLED;
        NSOpenPanel *openPanel = [NSOpenPanel openPanel];
        openPanel.delegate = self;
        openPanel.canCreateDirectories = YES;
        openPanel.allowsMultipleSelection = YES;
        openPanel.canChooseDirectories = YES;
        openPanel.canChooseFiles = NO;
        openPanel.allowedFileTypes = @[(NSString *)kUTTypeFolder];
        openPanel.message = [NSString stringWithFormat:@"Choose location to save configuration files for project ‘%@’.", fileName];
        openPanel.prompt = @"Choose";

        [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
            if (result == NSModalResponseOK) {
                NSURL *destinationURL = openPanel.URL;

                // Perform the extraction in the background.
                dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
                    BuildSettingExtractor *buildSettingExtractor = [[BuildSettingExtractor alloc] init];
                    buildSettingExtractor.includeBuildSettingInfoComments = [[NSUserDefaults standardUserDefaults] boolForKey:TPSIncludeBuildSettingInfoComments];

                    [buildSettingExtractor extractBuildSettingsFromProject:fileURL toDestinationFolder:destinationURL];

                    BOOL openInFinder = [[NSUserDefaults standardUserDefaults] boolForKey:TPSOpenDirectoryInFinder];
                    if (openInFinder) {
                        [[NSWorkspace sharedWorkspace] openURL:destinationURL];
                    }
                });
            }
        }];
    }
}

- (IBAction)presentPreferencesWindow:(id)sender {
    [self.window beginSheet:self.preferencesWindow completionHandler:nil];
}

- (IBAction)dismissPreferencesWindow:(id)sender {
    // make sure current edit field gets bound
    [self.preferencesWindow makeFirstResponder:nil];
    
    [self.window endSheet:self.preferencesWindow];
}

#pragma mark - NSOpenSavePanelDelegate

/* We want to protect against overwriting the contents of a folder that already has xcconfig files in it.  So validate the contents of the selected folder.
 */
- (BOOL)panel:(id)panel validateURL:(NSURL *)url error:(NSError *__autoreleasing *)outError {
    NSError *error = nil;
    NSArray *filesInDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url includingPropertiesForKeys:@[NSURLTypeIdentifierKey] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles error:&error];

    __block BOOL foundBuildConfigFile = NO;

    [filesInDirectory enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *typeIdentifier = nil;
        NSError *resourceError = nil;
        [obj getResourceValue:&typeIdentifier forKey:NSURLTypeIdentifierKey error:&resourceError];
        if ([typeIdentifier isEqualToString:[NSString tps_buildConfigurationFileTypeIdentifier]]) {
            foundBuildConfigFile = YES;
            *stop = YES;
        }

    }];

    BOOL valid = (!foundBuildConfigFile || self.shouldOverwriteFiles);

    if (!valid) {
        NSDictionary *errorUserInfo = @{NSLocalizedDescriptionKey:@"Build config files already exist in this folder. Do you want to replace them?", NSLocalizedRecoveryOptionsErrorKey:@[@"Cancel", @"Replace"], NSLocalizedRecoverySuggestionErrorKey:@"Build configuration files already exist in this folder. Replacing will overwrite any files with the same file names.", NSRecoveryAttempterErrorKey: self};
        NSError *error = [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:DirectoryContainsBuildConfigFiles userInfo:errorUserInfo];
        *outError = error;
    }


    return valid;
}

#pragma mark - NSError Recovery

/* The user can choose to replace / overwrite the contents of the folder as a recovery option.  If so, the open panel goes through validation again.
 */
- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo {

    BOOL success = NO;
    NSInvocation *invoke = [NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:didRecoverSelector]];
    [invoke setSelector:didRecoverSelector];

    if (recoveryOptionIndex == 1) { // Recovery requested.
        self.shouldOverwriteFiles = YES;
        success = YES;
    }

    [invoke setArgument:(void *)&success atIndex:2];
    [invoke setArgument:(void *)&contextInfo atIndex:3];
    [invoke invokeWithTarget:delegate];
}

#pragma mark - NSApplicationDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSDictionary *defaults = @{
        TPSOpenDirectoryInFinder:@(YES),
        TPSIncludeBuildSettingInfoComments:@(YES),
        TPSOutputFileNameProject:@"Project",
        TPSOutputFileNameShared:@"Shared",
        TPSOutputFileNameSeparator:@"-",
    };
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}


@end
