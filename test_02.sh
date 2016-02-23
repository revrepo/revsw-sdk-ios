SDK_PATH=./DerivedData/Build/Products/Release-iphoneos

rm -rf ./DerivedData
mkdir -p ${SDK_PATH}

cp -R ./RevSDK/export/RevSDK.framework ${SDK_PATH}/RevSDK.framework

xcodebuild test \
-workspace RevSDK.xcworkspace \
-scheme RevTest\ App \
-destination 'platform=iOS Simulator,OS=9.2,name=iPhone 6' \

EXIT_CODE=$?
echo ${EXIT_CODE}
exit ${EXIT_CODE}
