//
//  BuildSettingInfoSource.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/3/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#define MAX_LINE_LENGTH 87 // For 90 columns, minus three (comment slashes and a space)

#import "BuildSettingInfoSource.h"
#import "Constants+Categories.h"

@interface BuildSettingInfoSource ()

@property (strong, nonatomic) NSDictionary *buildSettingInfoDictionary;

@end


@implementation BuildSettingInfoSource


- (NSString *)commentForBuildSettingWithName:(NSString *)buildSettingName {
    NSMutableString *comment = [[NSMutableString alloc] init];

    NSString *presentationName = [self presentationNameForKey:buildSettingName];
    NSString *settingDescription = [self descriptionForKey:buildSettingName];

    if (presentationName || settingDescription) {

        if (settingDescription) {
            settingDescription = [self processedDescriptionString:settingDescription forKey:buildSettingName];
        }

        [comment appendString:@"\n\n\n"];
        if (presentationName) {
            [comment appendFormat:@"// %@\n", presentationName];
        }
        if (settingDescription) {
            [comment appendFormat:@"// %@\n", settingDescription];
        }
        [comment appendString:@"\n"];
    } else {
        // For now, leave some space above an entry without a name or description
        [comment appendString:@"\n\n\n"];
    }

    return comment;
}

- (NSString *)presentationNameForKey:(NSString *)key {
    if (!self.buildSettingInfoDictionary) {
        [self loadBuildSettingInfo];
    }

    NSString *processedKey = [key tps_baseBuildSettingName]; // strip any conditional part of build setting

    processedKey = [NSString stringWithFormat:@"[%@]-name", processedKey];
    return self.buildSettingInfoDictionary[processedKey];
}

- (NSString *)descriptionForKey:(NSString *)key {
    if (!self.buildSettingInfoDictionary) {
        [self loadBuildSettingInfo];
    }

    NSString *processedKey = [key tps_baseBuildSettingName]; // strip any conditional part of build setting

    processedKey = [NSString stringWithFormat:@"[%@]-description", processedKey];
    return self.buildSettingInfoDictionary[processedKey];
}

- (NSString *)processedDescriptionString:(NSString *)string forKey:(NSString *)key {

    NSString *processedString = @"";

    // Take the repetition of the build setting name out of the description.
    NSString *baseBuildSettingName = [key tps_baseBuildSettingName];
    NSString *buildNameString = [NSString stringWithFormat:@"[%@]", baseBuildSettingName];
    string = [string stringByReplacingOccurrencesOfString:buildNameString withString:@""];

    buildNameString = [NSString stringWithFormat:@"[%@, ", baseBuildSettingName];
    string = [string stringByReplacingOccurrencesOfString:buildNameString withString:@"["];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    for (NSString *paragraphString in [string componentsSeparatedByString:@"\n"]) {


        // Yes, this is not using grapheme clusters and assumes one char is one character.
        // It also assumes spaces separate words, which is not true in some languages.
        NSInteger characterCount = 0;
        NSString *currentLine = @"";

        for (NSString *wordish in [paragraphString componentsSeparatedByString:@" "]) {
            characterCount += wordish.length;
            if (characterCount < MAX_LINE_LENGTH) {
                currentLine = [currentLine stringByAppendingFormat:@"%@ ", wordish];
                characterCount++; // Account for the space
            } else {
                // Trim whitespace
                currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                // Add newline and comment prefix
                currentLine = [NSString stringWithFormat:@"\n// %@", currentLine];
                // Add to processed string
                processedString = [processedString stringByAppendingString:currentLine];
                // reset line count and set current line to token that didn't fit.
                characterCount = wordish.length + 1;
                currentLine = [NSString stringWithFormat:@"%@ ", wordish];
            }


        }

        // Append the last line if there is any
        if (![currentLine isEqualToString:@""]) {
            // Trim whitespace
            currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            // Add newline and comment prefix
            currentLine = [NSString stringWithFormat:@"\n// %@", currentLine];
            // Add to processed string
            processedString = [processedString stringByAppendingString:currentLine];
        }

    }

    return processedString;
}

- (void)loadBuildSettingInfo {
    NSString *defaultXcodePath = @"/Applications/Xcode.app";
    NSURL *buildSettingInfoPlistURL = [[NSBundle mainBundle] URLForResource:@"BuildSettingInfoSubpaths" withExtension:@"plist"];
    NSDictionary *buildSettingInfoDict = [NSDictionary dictionaryWithContentsOfURL:buildSettingInfoPlistURL];
    NSArray *buildSettingInfoSubpaths = buildSettingInfoDict[@"subpaths"];

    NSMutableDictionary *infoStringFile = [NSMutableDictionary new];

    // A spot to put additional setting info. If a more official version is read in, it replaces the backstop info.
    NSDictionary *backstopSettingsInfo = buildSettingInfoDict[@"backstopSettingInfo"];
    [infoStringFile addEntriesFromDictionary:backstopSettingsInfo];

    // Rather than track exactly what Xcode versions contain which files, group versions of an expected file in an array.
    // Log if no file in the group can be read in.
    for (NSArray *buildSettingInfoSubpathList in buildSettingInfoSubpaths) {
        BOOL foundOne = NO;
        for (NSString *subpath in buildSettingInfoSubpathList) {
            NSString *fullpath = [defaultXcodePath stringByAppendingPathComponent:subpath];
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:fullpath];
            [infoStringFile addEntriesFromDictionary:dictionary];
            if (dictionary || foundOne) {
                foundOne = YES;
            }
        }
        if (!foundOne) {
            if (buildSettingInfoSubpathList.count == 0) {
                NSLog(@"Empty array of subpaths at index %lu", [buildSettingInfoSubpaths indexOfObject:buildSettingInfoSubpathList]);
            } else if (buildSettingInfoSubpathList.count == 1) {
                NSLog(@"Could not read settings strings at path: %@", buildSettingInfoSubpathList[0]);
            } else {
                NSLog(@"Could not read settings strings at these paths: %@", buildSettingInfoSubpathList);
            }
        }
    }

    _buildSettingInfoDictionary = infoStringFile;
}


@end
