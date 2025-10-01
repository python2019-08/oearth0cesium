#!/bin/bash
 
 
git clone https://github.com/CesiumGS/cesium-native.git 3rd/cesium-native
cd ./3rd/cesium-native  
# git checkout -b  my-2025-sep27-181657  6a7a10a0c70f38cb5e825fb3caf9aa3a166b1180
git checkout -b  my-v0.45.0 tags/v0.45.0
cd ../../



# "url": "https://github.com/chromium/chromium/tree/15996b5d2322b634f4197447b10289bddc2b0b32/third_party/modp_b64",
# "version": "15996b5d2322b634f4197447b10289bddc2b0b32", 
git clone https://github.com/chromium/chromium  3rd/chromium
git checkout 15996b5d2322b634f4197447b10289bddc2b0b32
3rd/chromium
cp -r third_party/modp_b64   3rd/modp_b64
cd ../../


git clone https://github.com/microsoft/GSL  3rd/gsl


git clone  https://github.com/google/s2geometry   3rd/s2geometry


git clone  https://github.com/uriparser/uriparser 3rd/uriparser



git clone https://github.com/openscenegraph/OpenSceneGraph.git  3rd/osg
cd ./3rd/osg 
git checkout -b  my-2022-dec01-181731  2e4ae2ea94595995c1fc56860051410b0c0be605
cd ../../


git clone https://github.com/google/draco  3rd/osgdraco


# git clone https://github.com/gabime/spdlog.git  3rd/spdlog
# cd 3rd/spdlog
# git checkout  v1.11.4
# cd ../../
# # 编译并安装
# cmake .. -DSPDLOG_BUILD_EXAMPLE=OFF  # 禁用示例程序
# make -j$(nproc)
# sudo make install


git clone https://github.com/gwaldron/osgearth.git 3rd/osgearth
cd ./3rd/osgearth 
git submodule update --init --recursive
git checkout  -b my-2025Sep12-093115    928195eb74d85eac21c0c727af0fafc6d01be87c  # master
cd ../../

