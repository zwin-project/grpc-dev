mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

BUILD_TYPE ?= Debug

grpc_with_submodules := grpc/third_party/protobuf/README.md
grpc_cpp_plugin_executable := native/${BUILD_TYPE}/bin/grpc_cpp_plugin
protoc_executable := native/${BUILD_TYPE}/bin/protoc

include local.mk

.PHONY: all
all: android native

.PHONY: android
android: android_24_arm64-v8a_21-4-7075529

# Platform 		= android
# MinSDK 			= 24
# ABI 				= arm64-v8a
# NDK Version = 21.4.7075529
# Build Type 	= ${BUILD_TYPE}
.PHONY: android_24_arm64-v8a_21-4-7075529
android_24_arm64-v8a_21-4-7075529: ${grpc_with_submodules} \
																	 ${grpc_cpp_plugin_executable} \
																	 ${protoc_executable}
	cmake \
		-B build/android/24/arm64-v8a/21.4.7075529/${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${mkfile_dir}/android/24/arm64-v8a/21.4.7075529/${BUILD_TYPE} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
	  -DCMAKE_TOOLCHAIN_FILE=${ndk_21_4_7075529_dir}/build/cmake/android.toolchain.cmake \
		-DANDROID_ABI=arm64-v8a \
		-DANDROID_PLATFORM=android-24 \
		-D_gRPC_CPP_PLUGIN=${grpc_cpp_plugin_executable} \
		-D_gRPC_PROTOBUF_PROTOC_EXECUTABLE=${protoc_executable} \
		-GNinja \
		./grpc
	cmake --build build/android/24/arm64-v8a/21.4.7075529/${BUILD_TYPE}
	cmake --install build/android/24/arm64-v8a/21.4.7075529/${BUILD_TYPE}

${grpc_cpp_plugin_executable}: native

${protoc_executable}: native

.PHONY: native
native: ${grpc_with_submodules}
	cmake \
		-B build/native/${BUILD_TYPE} \
		-DCMAKE_INSTALL_PREFIX=${mkfile_dir}/native/${BUILD_TYPE} \
		-DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
		-GNinja \
		./grpc
	cmake --build build/native/${BUILD_TYPE}
	cmake --install build/native/${BUILD_TYPE}

${grpc_with_submodules}:
	$(error Please clone submodules of grpc)
