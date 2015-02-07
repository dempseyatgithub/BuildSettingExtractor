BuildSettingExtractor Read Me
=================================

This is a utility to extract build configuration settings from an Xcode project into a set of xcconfig files.

If you decide to move Xcode build settings out of your project file and into xcconfig files, this utility can make that initial move easier.  It’s also an easy way for the curious to take a look at the build settings in a project without fear of accidentally changing them.

For each target and the project itself, BuildSettingExtractor will generate one xcconfig file per build configuration plus a shared xcconfig file with all shared build settings for that target.

Using the app:

1. Launch BuildSettingExtractor
2. Drag an Xcode Project file (xcodeproj) to the app window
3. Choose a destination folder

Choose Preferences… (Command-,) from the BuildSettingExtractor menu to set generation options.

###Notes###

- BuildSettingExtractor does not alter the original Xcode project file.
- BuildSettingExtractor does not update existing xcconfig files, it does a one-time extraction.
- BuildSettingExtractor does not hoist shared target build settings to the project level.
- Do not taunt BuildSettingExtractor.

###Generated Files###

The generated xcconfig files include build setting explanations gleaned from Xcode:
 
	// Framework Search Paths
	// 
	// This is a list of paths to folders containing frameworks to be searched by the
	// compiler for both included or imported header files when compiling C, Objective-C,
	// C++, or Objective-C++, and by the linker for frameworks used by the product. Paths are
	// delimited by whitespace, so any paths with spaces in them need to be properly quoted.
	// [-F]
	
	FRAMEWORK_SEARCH_PATHS = $(DEVELOPER_FRAMEWORKS_DIR) $(inherited)
	
	
	// Info.plist File
	// 
	// This is the project-relative path to the plist file that contains the Info.plist
	// information used by bundles.

    INFOPLIST_FILE = BuildSettingExtractorTests/BuildSettingExtractorTests-Info.plist

These comments can be turned off in the Preferences sheet for a more compact file:

	FRAMEWORK_SEARCH_PATHS = $(DEVELOPER_FRAMEWORKS_DIR) $(inherited)
	INFOPLIST_FILE = BuildSettingExtractorTests/BuildSettingExtractorTests-Info.plist

###Version History###

*Version 1.1*  
*February 7, 2015*

– Added build settings explaination comments gleaned from Xcode.  
– Files are shown in Finder after they are generated.  
– Both options can be turned off in new Preferences pane.  
– Extraction and file generation now occurs in the background.

*Version 1.0*  
*January 31, 2015*

– Initial version of BuildSettingExtractor.  
– Generates xcconfig files from the build settings in an Xcode project.

*****

*This code is provide as-is with no warranties express or implied.  
Please put projects in source control to guard against things going horribly awry.*
