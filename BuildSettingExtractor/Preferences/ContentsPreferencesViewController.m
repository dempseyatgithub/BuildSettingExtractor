//
//  ContentsPreferencesViewController.m
//  BuildSettingExtractor
//
//  Created by James Dempsey on 2/14/20.
//  Copyright © 2020 Tapas Software. All rights reserved.
//

#import "ContentsPreferencesViewController.h"
#import "AppConstants+Categories.h"
#import "BuildSettingExtractor.h"

@interface ContentsPreferencesViewController () <NSTextFieldDelegate>
@property (unsafe_unretained) IBOutlet NSTextView *exampleOutputTextView;
@property (weak) IBOutlet NSTextField *linesBetweenSettingsTextField;
@property (weak) IBOutlet NSStepper *linesBetweenSettingsStepper;
@property (weak) IBOutlet NSTextField *linesBetweenSettingsLabel;
@end

@implementation ContentsPreferencesViewController

- (NSSize)preferredContentSize {
    return NSMakeSize(744.0, 352.0);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *defaultKeys = @[TPSIncludeBuildSettingInfoComments, TPSLinesBetweenBuildSettingsWithInfo, TPSLinesBetweenBuildSettings, TPSAlignBuildSettingValues];
    for (NSString *key in defaultKeys) {
        [[NSUserDefaults standardUserDefaults] addObserver:self forKeyPath:key options:0 context:nil];
    }
}

- (void)viewWillAppear {
    [super viewWillAppear];
    [self updateUserInterface];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [self updateUserInterface];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    NSInteger newValue = self.linesBetweenSettingsTextField.integerValue;
    [self setLineSpacing:newValue];
}

- (IBAction)lineSpacingStepperChanged:(id)sender {
    NSInteger newValue = self.linesBetweenSettingsStepper.integerValue;
    [self setLineSpacing:newValue];
}
- (IBAction)lineSpacingTextFieldChanged:(id)sender {
    NSInteger newValue = self.linesBetweenSettingsTextField.integerValue;
    [self setLineSpacing:newValue];
}

- (void)setLineSpacing:(NSInteger)value {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL includeBuildSettingsInfo = [defaults boolForKey:TPSIncludeBuildSettingInfoComments];
    NSString *lineSpacingKey = includeBuildSettingsInfo ? TPSLinesBetweenBuildSettingsWithInfo : TPSLinesBetweenBuildSettings;
    [defaults setInteger:value forKey:lineSpacingKey];
}

- (void)updateUserInterface {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL includeBuildSettingsInfo = [defaults boolForKey:TPSIncludeBuildSettingInfoComments];
    NSString *lineSpacingKey = includeBuildSettingsInfo ? TPSLinesBetweenBuildSettingsWithInfo : TPSLinesBetweenBuildSettings;
    NSInteger linesBetweenSettings = [defaults integerForKey:lineSpacingKey];
    [self updateLineSpacingControlsWithLineSpacing:linesBetweenSettings];
    [self updateSampleOutputWithLineSpacing:linesBetweenSettings];
}

- (void)updateLineSpacingControlsWithLineSpacing:(NSInteger)linesBetweenSettings {
    self.linesBetweenSettingsTextField.integerValue = linesBetweenSettings;
    self.linesBetweenSettingsStepper.integerValue = linesBetweenSettings;
    self.linesBetweenSettingsLabel.stringValue = linesBetweenSettings == 1 ? @"line between settings" : @"lines between settings";
}

- (void)updateSampleOutputWithLineSpacing:(NSInteger)linesBetweenSettings {
    NSDictionary *sampleSettings = @{@"CLANG_WARN__DUPLICATE_METHOD_MATCH":@"YES",
                                   @"COPY_PHASE_STRIP":@"YES",
                                   @"DEBUG_INFORMATION_FORMAT":@"dwarf-with-dsym",
                                   @"ENABLE_NS_ASSERTIONS":@"NO"};
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL includeBuildSettingsInfo = [defaults boolForKey:TPSIncludeBuildSettingInfoComments];
    BOOL alignBuildSettings = [defaults boolForKey:TPSAlignBuildSettingValues];
    
    NSString *testString = [BuildSettingExtractor exampleBuildFormattingStringForSettings:sampleSettings includeBuildSettingInfoComments:includeBuildSettingsInfo alignBuildSettingValues:alignBuildSettings linesBetweenSettings:linesBetweenSettings];
    self.exampleOutputTextView.string = testString;
}

@end
