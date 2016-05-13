CURRENT_DIR=$(pwd)

OPT_ACTION=test
OPT_CONFIGURATION=Release

PROJ_SDK_PATH=${CURRENT_DIR}/DerivedData/Build/Products/Release-iphoneos
PROJ_DERIVED_DATA=${CURRENT_DIR}/DerivedData

rm -rf ${PROJ_DERIVED_DATA}
mkdir -p ${PROJ_SDK_PATH}

cp -R ${CURRENT_DIR}/RevSDK/export/RevSDK.framework ${PROJ_SDK_PATH}/RevSDK.framework

xcodebuild ${OPT_ACTION} \
	-workspace RevSDK.xcworkspace \
	-scheme RevTest\ App \
	-destination 'platform=iOS Simulator,OS=9.2,name=iPhone 6' \
	-configuration ${OPT_CONFIGURATION} \
	-derivedDataPath ${PROJ_DERIVED_DATA}

EXIT_CODE=$?
echo "Finished with exit code ${EXIT_CODE}"
exit ${EXIT_CODE}
