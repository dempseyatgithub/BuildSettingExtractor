#!/bin/sh

#  ci_post_clone.sh
#  BuildSettingExtractor
#
#  Created by James Dempsey on 6/10/23.
#

if [ $CI_XCODE_CLOUD = "TRUE" ]; then

# Get path to xcconfig files in project
configFolderPath = "$CI_PRIMARY_REPOSITORY_PATH/Config"

# Write private project configuration file
privateProjectConfigPath="$configFolderPath/PrivateProjectConfig.xcconfig"

cat > $privateProjectConfigPath <<- EOF
DEVELOPMENT_TEAM = $CI_TEAM_ID
EOF

# Write private app configuration file
privateAppConfigPath="$configFolderPath/PrivateAppConfig.xcconfig"

cat > $privateAppConfigPath <<- EOF
PRODUCT_BUNDLE_IDENTIFIER = $CI_BUNDLE_ID
EOF

else

echo "CI_XCODE_CLOUD env variable was not TRUE"

fi
