# BuildSettingInfoSubpaths

An overview of the structure and keys in the BuildSettingInfoSubpaths.plist file.

## Overview
BuildSettingExtractor gleans information about build settings from files within the Xcode app bundle. The `BuildSettingInfoSubpaths.plist` file is a listing of the paths to those files. All paths in the plist file are relative to the `Xcode.app` app wrapper.

The build setting info is sometimes contained in `.strings` files and sometimes in `.xcspec` files.

## Arrays of subpaths
From release to release of Xcode, sometimes the same logical file will have a new path or file name. For instance, many had _English.lproj_ as part of the path, which was changed to _en.lproj_ in subsequent releases. More recently, file names have been gradually being renamed to use a reverse-DNS naming style.

Rather than keep detailed versioning bookkeeping, each array contains a list of paths, at least one of which should be found. If what is conceptually the same file has a different path or file name in a new release, the new path should be added to the array. Ideally it should be added to the beginning of the array, since it will be found sooner when searching more recent Xcode versions. In practice, these arrays are so short the difference is negligible.

## Keys
### subpaths
#### An array of arrays of subpath strings
Each item is an array of paths representing one logical file containing build setting info. The assumption is that at least one of these paths is valid across all versions of Xcode.

Add an entry to a subpath array in this key if the path or filename of an existing entry has changed in a new version of Xcode. Theoretically, any new file containing build setting info would be added to the _ introducedSubpathsByVersion_ key since the file does not exist in prior versions of Xcode.

### deprecatedSubpathsByVersion
#### A dictionary with Xcode version as the key and an array of arrays of subpath strings as the value.
Each key is a version string matching the version string found for the key `DTXcode` in the Xcode `Info.plist` file. The version number matches the version the file was first removed.

The value for each key is an array that works in the same manner as an entry in the subpaths array.

Add to this key when a build setting info file is removed completely. This prevents a warning / error / test failure when using newer Xcode versions as the build info source, but still allows the file to be successfully included when using older Xcode versions as the build info source.

### introducedSubpathsByVersion
#### A dictionary with Xcode version as the key and an array of arrays of subpath strings as the value.
Each key is a version string matching the version string found for the key `DTXcode` the Xcode `Info.plist` file. The version number matches the version the file first appeared.

The value for each key is an array that works in the same manner as an entry in the subpaths array.

Add to this key when a completely new build setting info file is added. This prevents a warning / error / test failure when using older Xcode versions as the build info source, but allows the file to be successfully included when using newer Xcode versions as the build info source.

Note that, just as with the subpaths values, any subpath introduced here is represented as an array. If the path or filename changes for the same logical file, the new subpath should be added to the array.

### backstopSettingInfo
#### A dictionary with string keys and values
Sometimes Xcode does not have a title or description defined for a build setting, or alternately, the file that provides that information has been elusive.

This dictionary provides that missing information as a backstop in case the information is not found by searching the build info files specified by the other keys.

The keys take the form `\[_BuildSettingName_\]-name` for the human-readable title of the build setting and `\[_BuildSettingName_\]-description` for the description of the setting.

The keys match the format of keys found in the various `.strings` files containing build setting info.
