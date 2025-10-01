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
