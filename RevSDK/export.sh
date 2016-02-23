BASE_DIR=.
THE_ACTION=build
SDK_IPHONEOS=iphoneos
SDK_SIMULATOR=iphonesimulator
SDK_UNIVERSAL=universal

REV_PROJ_DIR=${BASE_DIR}
REV_PROJ_PATH=${REV_PROJ_DIR}/RevSDK.xcodeproj
REV_PROJ_TARGET=RevSDK
REV_PROJ_NAME=RevSDK
REV_PROJ_CONFIG=Release
REV_PROJ_EXPORT_DIR=${REV_PROJ_DIR}/export
REV_PROJ_BUILD_DIR=${REV_PROJ_EXPORT_DIR}/build
REV_PROJ_OBJROOT=${REV_PROJ_BUILD_DIR}/Intermediates
REV_PROJ_BUILD_ROOT=${REV_PROJ_BUILD_DIR}
REV_PROJ_SYMROOT=${REV_PROJ_BUILD_DIR}
REV_IPHONEOS_BUILD_DIR=${REV_PROJ_BUILD_DIR}/${REV_PROJ_CONFIG}-${SDK_IPHONEOS}
REV_SIMULATOR_BUILD_DIR=${REV_PROJ_BUILD_DIR}/${REV_PROJ_CONFIG}-${SDK_SIMULATOR}
REV_UNIVERSAL_BUILD_DIR=${REV_PROJ_BUILD_DIR}/${REV_PROJ_CONFIG}-${SDK_UNIVERSAL}

QUIC_PROJ_DIR=${BASE_DIR}/RevSDK/quicrepack
QUIC_PROJ_PATH=${QUIC_PROJ_DIR}/quicrepack.xcodeproj
QUIC_PROJ_TARGET=quicrepack
QUIC_PROJ_NAME=quicrepack
QUIC_PROJ_CONFIG=Release
QUIC_PROJ_BUILD_DIR=./build
QUIC_PROJ_OBJROOT=${QUIC_PROJ_BUILD_DIR}/Intermediates
QUIC_PROJ_BUILD_ROOT=${QUIC_PROJ_BUILD_DIR}
QUIC_PROJ_SYMROOT=${QUIC_PROJ_BUILD_DIR}
QUIC_IPHONEOS_BUILD_DIR=${QUIC_PROJ_BUILD_DIR}/t-${QUIC_PROJ_CONFIG}-${SDK_IPHONEOS}
QUIC_SIMULATOR_BUILD_DIR=${QUIC_PROJ_BUILD_DIR}/t-${QUIC_PROJ_CONFIG}-${SDK_SIMULATOR}

#rm -rf "${REV_PROJ_EXPORT_DIR}"
#rm -rf "${QUIC_PROJ_DIR}/build/"

mkdir -p "${REV_PROJ_EXPORT_DIR}"

xcodebuild -project "${QUIC_PROJ_PATH}" -target "${QUIC_PROJ_TARGET}" -configuration "${QUIC_PROJ_CONFIG}" -sdk ${SDK_IPHONEOS} BUILD_DIR="${QUIC_PROJ_BUILD_DIR}" OBJROOT="${QUIC_PROJ_OBJROOT}" BUILD_ROOT="${QUIC_PROJ_BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${QUIC_IPHONEOS_BUILD_DIR}" SYMROOT="${QUIC_PROJ_SYMROOT}" ARCHS='arm64 armv7 armv7s' VALID_ARCHS='arm64 armv7 armv7s' ${THE_ACTION}
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "QUIC for ARM failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

xcodebuild -project "${QUIC_PROJ_PATH}" -target "${QUIC_PROJ_TARGET}" -configuration "${QUIC_PROJ_CONFIG}" -sdk ${SDK_SIMULATOR} BUILD_DIR="${QUIC_PROJ_BUILD_DIR}" OBJROOT="${QUIC_PROJ_OBJROOT}" BUILD_ROOT="${QUIC_PROJ_BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${QUIC_SIMULATOR_BUILD_DIR}" SYMROOT="${QUIC_PROJ_SYMROOT}" ARCHS='x86_64 i386' VALID_ARCHS='x86_64 i386' ${THE_ACTION}
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "QUIC for x86 failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

mkdir -p "${QUIC_PROJ_DIR}/build/${QUIC_PROJ_CONFIG}-${SDK_IPHONEOS}/"

lipo -create "${QUIC_PROJ_DIR}/build/t-${QUIC_PROJ_CONFIG}-${SDK_IPHONEOS}/lib${QUIC_PROJ_NAME}.a" "${QUIC_PROJ_DIR}/build/t-${QUIC_PROJ_CONFIG}-${SDK_SIMULATOR}/lib${QUIC_PROJ_NAME}.a" -output "${QUIC_PROJ_DIR}/build/${QUIC_PROJ_CONFIG}-${SDK_IPHONEOS}/lib${QUIC_PROJ_NAME}.a"
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "QUIC link failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

xcodebuild -project "${REV_PROJ_PATH}" -target "${REV_PROJ_TARGET}" -configuration "${REV_PROJ_CONFIG}" -sdk ${SDK_IPHONEOS} BUILD_DIR="${REV_PROJ_BUILD_DIR}" OBJROOT="${REV_PROJ_OBJROOT}" BUILD_ROOT="${REV_PROJ_BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${REV_IPHONEOS_BUILD_DIR}" SYMROOT="${REV_PROJ_SYMROOT}" ARCHS='arm64 armv7 armv7s' VALID_ARCHS='arm64 armv7 armv7s' ${THE_ACTION} CODE_SIGN_IDENTITY="iPhone Developer"
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "SDK for ARM failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

xcodebuild -project "${REV_PROJ_PATH}" -target "${REV_PROJ_TARGET}" -configuration "${REV_PROJ_CONFIG}" -sdk ${SDK_SIMULATOR} BUILD_DIR="${REV_PROJ_BUILD_DIR}" OBJROOT="${REV_PROJ_OBJROOT}" BUILD_ROOT="${REV_PROJ_BUILD_ROOT}" CONFIGURATION_BUILD_DIR="${REV_SIMULATOR_BUILD_DIR}" SYMROOT="${REV_PROJ_SYMROOT}" ARCHS='x86_64 i386' VALID_ARCHS='x86_64 i386' ${THE_ACTION} CODE_SIGN_IDENTITY="iPhone Developer"
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "SDK for x86 failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

mkdir -p "${REV_UNIVERSAL_BUILD_DIR}"

REV_BUILD_IPHONEOS=${REV_PROJ_NAME}-${SDK_IPHONEOS}
REV_BUILD_SIMULATOR=${REV_PROJ_NAME}-${SDK_SIMULATOR}
REV_BUILD_UNIVERSAL=${REV_PROJ_NAME}-${SDK_UNIVERSAL}

cp -R "${REV_IPHONEOS_BUILD_DIR}/${REV_PROJ_NAME}.framework" "${REV_UNIVERSAL_BUILD_DIR}/${REV_PROJ_NAME}.framework"

lipo -create "${REV_IPHONEOS_BUILD_DIR}/${REV_PROJ_NAME}.framework/${REV_PROJ_NAME}" "${REV_SIMULATOR_BUILD_DIR}/${REV_PROJ_NAME}.framework/${REV_PROJ_NAME}" -output "${REV_UNIVERSAL_BUILD_DIR}/${REV_PROJ_NAME}.framework/${REV_PROJ_NAME}"
EXIT_CODE=$?
if [[ $EXIT_CODE -ne 0 ]]; 
  then 
  	echo "REV link failed with exit code ${EXIT_CODE}"
   	exit ${EXIT_CODE}
  fi

cp -R "${REV_UNIVERSAL_BUILD_DIR}/${REV_PROJ_NAME}.framework" "${REV_PROJ_EXPORT_DIR}/${REV_PROJ_NAME}.framework"

echo "INFO: Preparing a ZIP file with the freshly compiled SDK framework..."

if [ -z "$BUILD_NUMBER" ]; then
        echo "WARNING: BUILD_NUMBER environment variable is empty - setting it to 0"
        BUILD_NUMBER=0
fi

cd ${REV_PROJ_EXPORT_DIR}

VERSION=1.0.$BUILD_NUMBER
FRAMEWORK=${REV_PROJ_NAME}.framework

if [ -d "$FRAMEWORK" ]; then
        FILE="${FRAMEWORK}-${VERSION}.zip"
        echo "INFO: Packing the framework to file $FILE..."
        zip -r $FILE $FRAMEWORK
fi
