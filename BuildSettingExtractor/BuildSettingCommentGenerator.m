//
//  BuildSettingCommentGenerator.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/3/15.
//  Copyright (c) 2015 Tapas Software. All rights reserved.
//

#define MAX_LINE_LENGTH 87 // For 90 columns, minus three (comment slashes and a space)

#import "BuildSettingCommentGenerator.h"
#import "BuildSettingInfoSource.h"
#import "Constants+Categories.h"

@interface BuildSettingCommentGenerator ()

@property (strong, nonatomic) BuildSettingInfoSource *infoSource;

@property (strong, nonatomic) NSDictionary *buildSettingInfoDictionary;

// Some build setting info uses the Xcode flavor of Markdown for option lists.
// In Xcode, these show up as bulletted lists with option names emphasized.
// In plain text the emphasis does not look as good.
// This regex matches the common pattern "* *OptionName:*" and replaces it with "* OptionName:"
@property (strong, nonatomic) NSRegularExpression *regex;

@end


@implementation BuildSettingCommentGenerator

- (instancetype)init
{
    [NSException raise:NSInternalInconsistencyException format:@"You must use -initWithBuildSettingInfoSource: to initialize instances of BuildSettingCommentGenerator."];
    return nil;
}

- (instancetype)initWithBuildSettingInfoSource:(BuildSettingInfoSource *)infoSource
{
    self = [super init];
    if (self) {
         self.regex = [NSRegularExpression regularExpressionWithPattern:@"^\\*\\h\\*(.+?)\\*" options:NSRegularExpressionAnchorsMatchLines error:nil];
        self.infoSource = infoSource;
    }
    return self;
}

- (NSString *)commentForBuildSettingWithName:(NSString *)buildSettingName {
    NSMutableString *comment = [[NSMutableString alloc] init];

    NSString *presentationName = [self presentationNameForKey:buildSettingName];
    NSString *settingDescription = [self descriptionForKey:buildSettingName];

    if (presentationName || settingDescription) {

        if (settingDescription) {
            settingDescription = [self processedDescriptionString:settingDescription forKey:buildSettingName];
        }
        if (presentationName) {
            [comment appendFormat:@"// %@\n", presentationName];
        }
        if (settingDescription) {
            [comment appendFormat:@"// %@\n", settingDescription];
        }
        [comment appendString:@"\n"];
    }

    return comment;
}

- (NSString *)presentationNameForKey:(NSString *)key {
    if (!self.buildSettingInfoDictionary) {
        [self loadBuildSettingInfo:nil];
    }

    NSString *processedKey = [key tps_baseBuildSettingName]; // strip any conditional part of build setting

    processedKey = [self displayNameKeyForSetting:processedKey];
    return self.buildSettingInfoDictionary[processedKey];
}

- (NSString *)descriptionForKey:(NSString *)key {
    if (!self.buildSettingInfoDictionary) {
        [self loadBuildSettingInfo:nil];
    }

    NSString *processedKey = [key tps_baseBuildSettingName]; // strip any conditional part of build setting

    processedKey = [self descriptionKeyForSetting:processedKey];
    return self.buildSettingInfoDictionary[processedKey];
}

- (NSString *)processedCurrentLine:(NSString *)currentLine {
    
    // Trim whitespace
    currentLine = [currentLine stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    // Process Markdown option list item
    if ([currentLine hasPrefix:@"*"]) {
        currentLine = [self.regex stringByReplacingMatchesInString:currentLine options:0 range:NSMakeRange(0, [currentLine length]) withTemplate:@"* $1"];
    }

    // Add newline and comment prefix
    currentLine = [NSString stringWithFormat:@"\n// %@", currentLine];

    return currentLine;
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
                // Process current line
                currentLine = [self processedCurrentLine:currentLine];
                // Add to processed string
                processedString = [processedString stringByAppendingString:currentLine];
                // reset line count and set current line to token that didn't fit.
                characterCount = wordish.length + 1;
                currentLine = [NSString stringWithFormat:@"%@ ", wordish];
            }
        }

        // Append the most recent line if there is any
        if (![currentLine isEqualToString:@""]) {
            // Process current line
            currentLine = [self processedCurrentLine:currentLine];
            // Add to processed string
            processedString = [processedString stringByAppendingString:currentLine];
        }

    }

    return processedString;
}

// Returns an array of error strings describing unread build setting info files
- (BOOL)loadBuildSettingInfo:(NSError **)error {

    NSMutableArray *subpathReadingErrorStrings = [[NSMutableArray alloc] init];

    NSString *defaultXcodePath = self.infoSource.resolvedURL.path;
    NSInteger xcodeVersion = self.infoSource.resolvedVersion;

    // Load subpaths
    NSURL *buildSettingInfoPlistURL = [[NSBundle mainBundle] URLForResource:@"BuildSettingInfoSubpaths" withExtension:@"plist"];
    NSDictionary *buildSettingInfoDict = [NSDictionary dictionaryWithContentsOfURL:buildSettingInfoPlistURL];
    NSArray *buildSettingInfoSubpaths = buildSettingInfoDict[@"subpaths"];

    NSMutableDictionary *infoStringFile = [NSMutableDictionary new];

    // A spot to put additional setting info. If a more official version is read in, it replaces the backstop info.
    NSDictionary *backstopSettingsInfo = buildSettingInfoDict[@"backstopSettingInfo"];
    [infoStringFile addEntriesFromDictionary:backstopSettingsInfo];

    // Add deprecated subpaths that are valid in the version of Xcode we are using
    NSMutableArray *subpathsToAdd = nil;
    NSDictionary *deprecatedSubpaths = buildSettingInfoDict[@"deprecatedSubpathsByVersion"];
    for (NSString *versionKey in [deprecatedSubpaths allKeys]) {
        NSInteger maxVersion = [versionKey integerValue];
        if (xcodeVersion < maxVersion) {
            if (!subpathsToAdd) {
                subpathsToAdd = [NSMutableArray array];
            }
            [subpathsToAdd addObjectsFromArray:deprecatedSubpaths[versionKey]];
        }
    }
    if (subpathsToAdd) {
        buildSettingInfoSubpaths = [buildSettingInfoSubpaths arrayByAddingObjectsFromArray:subpathsToAdd];
    }
    
    // Add introduced subpaths that are valid in the version of Xcode we are using
    subpathsToAdd = nil;
    NSDictionary *introducedSubpaths = buildSettingInfoDict[@"introducedSubpathsByVersion"];
    for (NSString *versionKey in [introducedSubpaths allKeys]) {
        NSInteger minVersion = [versionKey integerValue];
        if (xcodeVersion >= minVersion) {
            if (!subpathsToAdd) {
                subpathsToAdd = [NSMutableArray array];
            }
            [subpathsToAdd addObjectsFromArray:introducedSubpaths[versionKey]];
        }
    }
    if (subpathsToAdd) {
        buildSettingInfoSubpaths = [buildSettingInfoSubpaths arrayByAddingObjectsFromArray:subpathsToAdd];
    }


    // Rather than track exactly what Xcode versions contain which files, group versions of an expected file in an array.
    // Log if no file in the group can be read in.
    for (NSArray *buildSettingInfoSubpathList in buildSettingInfoSubpaths) {
        BOOL foundOne = NO;
        for (NSString *subpath in buildSettingInfoSubpathList) {
            NSString *pathExtension = [subpath pathExtension];
            NSString *fullpath = [defaultXcodePath stringByAppendingPathComponent:subpath];
            NSDictionary *dictionary = nil;
            if ([pathExtension isEqualToString:@"strings"]) {
                dictionary = [NSDictionary dictionaryWithContentsOfFile:fullpath];
            } else if ([pathExtension isEqualToString:@"xcspec"]) {
                dictionary = [self xcspecFileBuildSettingInfoForPath:fullpath];
            }
            if (dictionary) {
                // Remove empty string values that may be masking backstop values
                NSDictionary *processedDictionary = [dictionary tps_dictionaryByRemovingEmptyStringValues];
                [infoStringFile addEntriesFromDictionary:processedDictionary];
            }
            if (dictionary || foundOne) {
                foundOne = YES;
            }
        }
        if (!foundOne) {
            NSString *errorString = nil;
            if (buildSettingInfoSubpathList.count == 0) {
                errorString = [NSString stringWithFormat: @"Empty array of subpaths at index %lu", [buildSettingInfoSubpaths indexOfObject:buildSettingInfoSubpathList]];
            } else if (buildSettingInfoSubpathList.count == 1) {
                errorString = [NSString stringWithFormat:@"Could not read settings strings at path: %@", buildSettingInfoSubpathList[0]];
            } else {
                errorString = [NSString stringWithFormat:@"Could not read settings strings at these paths: %@", buildSettingInfoSubpathList];
            }
            [subpathReadingErrorStrings addObject:errorString];
        }
    }

    _buildSettingInfoDictionary = infoStringFile;
    
    BOOL success = subpathReadingErrorStrings.count == 0;
    
    if (!success && error) {
        *error = [NSError errorForSettingInfoFilesNotFound:subpathReadingErrorStrings]; 
    }

    return success;
}

- (NSDictionary *)xcspecFileBuildSettingInfoForPath:(NSString *)path {
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    NSMutableDictionary *buildSettingInfo = [NSMutableDictionary dictionary];
    NSError *error = nil;
    NSData *plistData = [[NSData alloc] initWithContentsOfURL:fileURL];
    // If we can't read the file, behave like +dictionaryWithContentsOfFile: and return nil
    if (!plistData) {
        return nil;
    }
    id plist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:&error];
    if ([plist isKindOfClass:[NSArray class]]) {
        NSArray *specs = (NSArray *)plist;
        for (id spec in specs) {
            if ([spec isKindOfClass:[NSDictionary class]]) {
                NSDictionary *specDict = (NSDictionary *)spec;
                NSString *specType = specDict[@"Type"];
                if ([specType isEqualToString:@"BuildSystem"] || ([specType isEqualToString:@"Compiler"])) {
                    
                    id options = specDict[@"Options"];
                    if (!options) options = specDict[@"Properties"];
                    
                    if ([options isKindOfClass:[NSArray class]]) {
                        for (id option in options) {
                            if ([option isKindOfClass:[NSDictionary class]]) {
                                NSString *name = option[@"Name"];
                                NSString *desc = option[@"Description"];
                                NSString *displayName = option[@"DisplayName"];
                                
                                if (name && desc && displayName) {
                                    [buildSettingInfo setValue:displayName forKey:[self displayNameKeyForSetting:name]];
                                    [buildSettingInfo setValue:desc forKey:[self descriptionKeyForSetting:name]];
                                }
                            }
                        }
                    }
                }
                
            }
        }
    }
    
    return buildSettingInfo;
}

- (NSString *)displayNameKeyForSetting:(NSString *)settingName {
    return [NSString stringWithFormat:@"[%@]-name", settingName];
}

- (NSString *)descriptionKeyForSetting:(NSString *)settingName {
    return [NSString stringWithFormat:@"[%@]-description", settingName];
}

@end
