#!/bin/sh

#  ci_post_clone.sh
#  CloudBuildTestbed
#
#  Created by James Dempsey on 6/10/23.
#

if [ $CI_XCODE_CLOUD = "TRUE" ]; then

# Write private project configuration file
privateProjectConfigPath="$CI_PRIMARY_REPOSITORY_PATH/Config/PrivateProjectConfig.xcconfig"

cat > $privateProjectConfigPath <<- EOF
DEVELOPMENT_TEAM = $CI_TEAM_ID
EOF

# Write private app configuration file
privateAppConfigPath="$CI_PRIMARY_REPOSITORY_PATH/Config/PrivateAppConfig.xcconfig"

cat > $privateAppConfigPath <<- EOF
PRODUCT_BUNDLE_IDENTIFIER = $TS_PRODUCT_BUNDLE_IDENTIFIER
EOF

else

echo "CI_XCODE_CLOUD env variable was not TRUE"

fi
