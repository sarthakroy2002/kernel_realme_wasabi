#!/bin/bash

function compile()
{
rm -rf AnyKernel
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G
export ARCH=arm64
export KBUILD_BUILD_HOST=neolit
export KBUILD_BUILD_USER="sarthakroy2002"
if [ ! -d "clang" ]; then
	wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r487747.tar.gz -O "aosp-clang.tar.gz"
	mkdir clang && tar -xf aosp-clang.tar.gz -C clang && rm -rf aosp-clang.tar.gz
fi
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32


[ -d "out" ] && rm -rf out || mkdir -p out

make O=out ARCH=arm64 wasabi_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                        ARCH=$ARCH \
                        CC="clang" \
                        CLANG_TRIPLE=aarch64-linux-gnu- \
                        CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
                        CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
            		LLVM=1 \
                        LD=ld.lld \
                        AR=llvm-ar \
                        NM=llvm-nm \
                        OBJCOPY=llvm-objcopy \
                        OBJDUMP=llvm-objdump \
                        STRIP=llvm-strip \
                        CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zupload()
{
git clone --depth=1 https://github.com/sarthakroy2002/AnyKernel3.git -b RMX2001 AnyKernel
cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
cd AnyKernel
zip -r9 Test-OSS-KERNEL-wasabi-NEOLIT.zip *
curl -sL https://git.io/file-transfer | sh
./transfer wet Test-OSS-KERNEL-wasabi-NEOLIT.zip
}

compile
zupload
