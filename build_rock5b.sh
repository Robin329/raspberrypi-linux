#!/bin/sh
#
# Compile Rasiberry kernel scripts.
#

usage() {
    echo
    echo "---------------------------"
    echo "Usage:"
    echo "     ./build.sh [-h] "
    echo "                [-c:config]"
    echo "                [-m:{menuconfig|modules}]"
    echo "                [-b:build]"
    echo "                [-d:dtbs]"
    echo "                [-i:image | install]"
    echo "---------------------------"
    echo
}

copy_result() {
    echo "== copy to server =="
    cp -raf build/arch/arm64/boot/Image* build/arch/arm64/boot/dts/broadcom/*.dtb ~/Home/workspace/project/rpi_boot/
    echo "== copy END       =="
}

while getopts "hc:a:m:d:i:" opt; do

    case $opt in
    h)
        usage
        ;;
    c)
        echo "./build.sh -c $OPTARG"
        if [ "$OPTARG" = "config" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig O=build
        else
            echo "ERROR input params!!!"
            echo "Please input Right params!"
            echo
        fi
        exit 0
        ;;
    d)
        echo "./build.sh -d $OPTARG"
        if [ "$OPTARG" = "dtbs" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- dtbs O=build
            cp -rf build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /home/rock/tftpboot
        else
            echo "ERROR input params!!!"
            echo "Please input Right params!"
            echo
        fi
        exit 0
        ;;
    i)
        echo "./build.sh -d $OPTARG"
        if [ "$OPTARG" = "image" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs -j44 O=build
            cp -rf build/arch/arm64/boot/Image /home/rock/tftpboot/Image_rpi
            cp -rf build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /home/rock/tftpboot
            ./scripts/clang-tools/gen_compile_commands.py -d build/
        elif [ "$OPTARG" = "install" ]; then
            sudo make O=build INSTALL_MOD_PATH=/home/rock/nfs_rootfs modules_install -j32
        else
            echo "ERROR input params!!!"
            echo "Please input Right params!"
            echo
        fi
        exit 0
        ;;
    a)
        echo "./build.sh -a $OPTARG"
        if [ "$OPTARG" = "all" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- bcm2711_defconfig O=build
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- Image modules dtbs -j44 O=build
            sudo make O=build INSTALL_MOD_PATH=/home/rock/nfs_rootfs modules_install -j32
            cp -rf build/arch/arm64/boot/dts/broadcom/bcm2711-rpi-4-b.dtb /home/rock/tftpboot
            cp -rf build/arch/arm64/boot/Image /home/rock/tftpboot/Image_rpi
            ./scripts/clang-tools/gen_compile_commands.py -d build/
        else
            echo "ERROR input params!!!"
            echo "Please input Right params!"
            echo
        fi
        exit 0
        ;;
    m)
        echo "./build.sh -m $OPTARG"
        if [ "$OPTARG" = "menuconfig" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig O=build
        elif [ "$OPTARG" = "modules" ]; then
            make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- modules O=build
        else
            echo "ERROR input params!!!"
            echo "Please input Right params!"
            echo
        fi
        exit 0
        ;;
    ?)
        usage
        exit 1
        ;;
    esac
done
usage
