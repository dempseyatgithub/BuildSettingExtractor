#!/bin/sh

#  ci_post_clone.sh
#  CloudBuildTestbed
#
#  Created by James Dempsey on 6/10/23.
#

if [ $CI = "TRUE" ]; then

# Write private project configuration file
privateProjectConfigPath="$CI_PRIMARY_REPOSITORY_PATH/Config/PrivateProjectConfig.xcconfig"

cat > $privateProjectConfigPath <<- EOF
DEVELOPMENT_TEAM = $TS_DEVELOPMENT_TEAM
EOF

# Write private app configuration file
privateAppConfigPath="$CI_PRIMARY_REPOSITORY_PATH/Config/PrivateAppConfig.xcconfig"

cat > $privateAppConfigPath <<- EOF
PRODUCT_BUNDLE_IDENTIFIER = $TS_PRODUCT_BUNDLE_IDENTIFIER
EOF

else
echo "CI env variable was not TRUE"
fi
