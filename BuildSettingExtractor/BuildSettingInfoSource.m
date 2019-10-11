//
//  BuildSettingInfoSource.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 10/9/19.
//  Copyright © 2019 Tapas Software. All rights reserved.
//

#import "BuildSettingInfoSource.h"

@interface BuildSettingInfoSource ()
@property BuildSettingInfoSourceStyle style;
@property (nullable) NSURL *customURL;
@end

@implementation BuildSettingInfoSource

+ (BuildSettingInfoSource *)resolvedBuildSettingInfoSourceWithStyle:(BuildSettingInfoSourceStyle)style customURL:(NSURL *)customURL error:(NSError **)error {
    
    BuildSettingInfoSource *infoSource = [[BuildSettingInfoSource alloc] initWithStyle:style customURL:customURL];
    BOOL success = [infoSource resolveBuildSettingInfoSourceWithError:error];
    
    if (success) {
        return infoSource;
    } else {
        return nil;
    }
}

- (instancetype)init {
    return [self initWithStyle:BuildSettingInfoSourceStyleStandard customURL:nil];
}

- (instancetype)initWithStyle:(BuildSettingInfoSourceStyle)style customURL:(nullable NSURL *)customURL {
    self = [super init];
    if (self) {
        self.style = style;
        self.customURL = customURL;
        self.resolvedURL = nil;
        self.resolvedVersion = -1;
    }
    return self;
}

- (BOOL)resolveBuildSettingInfoSourceWithError: (NSError **)error {
    BOOL successfullyResolved = NO;
    
    NSString *standardAppPath = @"/Applications/Xcode.app";
    BOOL standardAppExists = [[NSFileManager defaultManager] fileExistsAtPath:standardAppPath];
    NSInteger standardAppVersion = -1;
    NSURL *standardAppURL = nil;
    
    NSString *standardBetaPath = @"/Applications/Xcode-beta.app";
    BOOL standardBetaExists = [[NSFileManager defaultManager] fileExistsAtPath:standardBetaPath];
    NSInteger standardBetaVersion = -1;
    NSURL *standardBetaURL = nil;
    
    if (standardAppExists) {
        standardAppURL = [NSURL fileURLWithPath:standardAppPath];
        standardAppVersion = [self versionForXcodeAtURL:standardAppURL];
    }
    
    if (standardBetaExists) {
        standardBetaURL = [NSURL fileURLWithPath:standardBetaPath];
        standardBetaVersion = [self versionForXcodeAtURL:standardBetaURL];
    }
    
    // If both are found use the beta if it is a later version
    if (standardAppExists && standardBetaExists) {
        if (standardBetaVersion > standardAppVersion) {
            self.resolvedURL = standardBetaURL;
            self.resolvedVersion = standardBetaVersion;
        } else {
            self.resolvedURL = standardAppURL;
            self.resolvedVersion = standardAppVersion;
        }
    }

    else if (standardAppExists) {
        self.resolvedURL = standardAppURL;
        self.resolvedVersion = standardAppVersion;
    }
    
    else if (standardBetaExists) {
        self.resolvedURL = standardBetaURL;
        self.resolvedVersion = standardBetaVersion;
    }
    
    if (self.resolvedURL != nil && self.resolvedVersion != -1) {
        successfullyResolved = YES;
    }
    
    return successfullyResolved;
}

- (NSInteger)versionForXcodeAtURL:(NSURL *)url {
    NSString *pathToXcodeInfoPlist = [[url path] stringByAppendingPathComponent:@"Contents/Info.plist"];
    NSDictionary *xcodeInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:pathToXcodeInfoPlist];
    NSString *versionString = xcodeInfoDictionary[@"DTXcode"];
    NSInteger xcodeVersion = [versionString integerValue];
    if (!versionString || xcodeVersion == 0) {
        NSLog(@"Could not read Xcode version. Version string: %@, Version Number: %ld", versionString, (long)xcodeVersion);
    }
    return xcodeVersion;
}

@end
