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

### Notes ###

- BuildSettingExtractor does not alter the original Xcode project file.
- BuildSettingExtractor does not update existing xcconfig files, it does a one-time extraction.
- BuildSettingExtractor does not hoist shared target build settings to the project level.
- Do not taunt BuildSettingExtractor.

### Generated Files ###

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

### Version History ###

*Version 1.3*
*Sep 25, 2018*

– Added Dark Mode support.  
– Built with Xcode 10.0 on macOS 10.14 Mojave.  

*Version 1.2.8*
*Sep 24, 2018*

– Updated list of build setting description files to include Apple Clang file.  
– Fixed crash when xcspec file was not found when reading build setting descriptions.  
– Tested Xcode 10.0-compatible project files with Xcode 10.  
– Tested build setting descriptions with Xcode 10.  
– This the last version that will build cleanly on macOS 10.13 and earlier.  
– Built with Xcode 9.4.1 on macOS 10.13.6 High Sierra.  

*Version 1.2.7*
*Aug 19, 2018*

– Added alert to notify users if the selected project contains no build settings.  
– Added names and descriptions for some common settings without info.  
– Updated to extract build settings from Xcode 9.3-compatible project files.  
– Updated to extract build settings from Xcode 10.0-compatible project files. (Tested with beta 6.)  
– Made changes to prepare for Mojave Dark Mode.  

*Version 1.2.6*
*Nov 3, 2017*

– Added menu item to choose Xcode project.  
– Removed unused menu items.  
– Added window minimum size.  
– Updated window with options more befitting a single-window app.  
– Improved support for reading build setting descriptions from xcspec files.  
– Updated list of build setting description files to include Swift xcspec file.  

*Version 1.2.5*
*Jun 13, 2017*

– Resolve possible naming conflict between generated project and target files.  
– Updated list of build setting description files to include LLDB 8.1 file.  
– Updated list of build setting description files to include LLDB 9.0 file.  
– Fixed incorrect Markdown in the ReadMe file.  

*Version 1.2.4*  
*Nov 14, 2016*

– Updated list of build setting description files to include LLDB 7.1 file.  
– Updated list of build setting description files to include LLDB 8.0 file.  
– Added support for reading build setting descriptions from xcspec files.  
– Updated to extract build settings from Xcode 6.3-compatible project files.  
– Updated to extract build settings from Xcode 8.0-compatible project files.

*Version 1.2.3*  
*Nov 9, 2015*
  
– Updated list of build setting description files to include new LLDB 7.0 file.  
– No longer inexplicably using return instead of newline character in two spots.

*Version 1.2.2*  
*May 25, 2015*

– Added brand new app icon.  
– Removed default Credits.rtf file.

*Version 1.2.1*  
*May 16, 2015*

– Updated list of build setting description files to include new LLDB 6.1 file.

*Version 1.2*  
*May 16, 2015*

– Added options for generated file names in Preferences. (Thank you [Alex Curylo](https://github.com/alexcurylo)!)

*Version 1.1.1*  
*May 12, 2015*

– Fixed crash on Mavericks.  

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
