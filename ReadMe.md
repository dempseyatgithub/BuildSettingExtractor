BuildSettingExtractor Read Me
=================================

This is a utility to extract build configuration settings from an Xcode project into a set of xcconfig files.

If you decide to move Xcode build settings out of your project file and into xcconfig files, this utility can make that initial move easier.  It’s also an easy way for the curious to take a look at the build settings in a project without fear of accidentally changing them.

For each target and the project itself, BuildSettingExtractor will generate one xcconfig file per build configuration plus a shared xcconfig file with all shared build settings for that target.

Using the app:

1. Launch BuildSettingExtractor
2. Drag an Xcode Project file (xcodeproj) to the app window
3. Choose a destination folder

**Notes**

- BuildSettingExtractor does not alter the original Xcode project file.
- BuildSettingExtractor does not update existing xcconfig files, it does a one-time extraction.
- BuildSettingExtractor does not hoist common target build settings to the project level.
- Do not taunt BuildSettingExtractor.

**Version History**

*Version 1.0*  
*January 30, 2015*

– Initial version of BuildSettingExtractor.  
– Generates xcconfig files from the build settings in an Xcode project.

*****

*This code is provide as-is with no warranties express or implied.  
Please put projects in source control to guard against things going horribly awry.*
