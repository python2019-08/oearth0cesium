#!/bin/bash
# **************************************************************************
# false  ;;;   ./mkubt.sh  >bu.txt 2>&1
echo "mk4ubuntu.sh: param 0=$0"

# 获取脚本的绝对路径（处理符号链接）
SCRIPT_PATH=$(readlink -f "$0")
echo "sh-path: $SCRIPT_PATH"

# 额外：获取脚本所在目录的绝对路径
# Repo_ROOT=$(dirname "$SCRIPT_PATH")
Repo_ROOT=/mnt/disk2/abner/zdev/nv/oearth02/
echo "Repo_ROOT=${Repo_ROOT}"

export VCPKG_ROOT=/home/abner/programs/vcpkg/

echo "============================================================="
# **************************************************************************
isRebuild=true

# ------ 
isFinished_build_cesiumNative=false
isFinished_build_osg=true     # osg-a ..false  
isFinished_build_csprng=true
isFinished_build_modpB64=true
isFinished_build_uriparser=true
isFinished_build_oearth=true  # osgearth-a 
# ------
CMAKE_BUILD_TYPE=Debug #RelWithDebInfo
CMAKE_MAKE_PROGRAM=/usr/bin/make
CMAKE_C_COMPILER=/usr/bin/gcc   # /usr/bin/musl-gcc   # /usr/bin/clang  # 
CMAKE_CXX_COMPILER=/usr/bin/g++ # /usr/bin/musl-gcc # /usr/bin/clang++  #   

# **************************************************************************
# rm -fr ./build   
BuildDir_ubuntu=${Repo_ROOT}/build_by_sh/ubuntu

# INSTALL_PREFIX_root
INSTALL_PREFIX_ubt=${BuildDir_ubuntu}/install
mkdir -p ${INSTALL_PREFIX_ubt} 
 

cmakeCommonParams=(
  "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}"
  "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}"
  "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}"
  "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
  "-DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config"
  "-DCMAKE_FIND_ROOT_PATH=${INSTALL_PREFIX_ubt}"
  "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=ONLY"
  "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
  "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY" # BOTH：先查根路径，再查系统路径    
  "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY" # 头文件仍只查根路径 
  "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER"
  # 是否访问 /usr/include/、/usr/lib/ 等 系统路径；；与 PREFIX_PATH 配合 
  "-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=OFF"
  # 是否访问PATH\LD_LIBRARY_PATH等环境变量
  "-DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=OFF" 
  "-DCMAKE_FIND_LIBRARY_SUFFIXES=.a"
  "-DCMAKE_POSITION_INDEPENDENT_CODE=ON"
  "-DBUILD_SHARED_LIBS=OFF"    
)
  #  -DCMAKE_C_FLAGS= "-fPIC"     
  #  -DCMAKE_CXX_FLAGS="-fPIC" 
echo "cmakeCommonParams=${cmakeCommonParams[@]}"
# **************************************************************************
# functions
prepareBuilding()
{
    local aSubSrcDir="$1"
    local aSubBuildDir="$2"
    local aSubInstallDir="$3"
    local aIsRebuild="$4"
    echo "prepareBuilding(): SrcDir=$aSubSrcDir;  BuildDir=$aSubBuildDir"
    echo "prepareBuilding(): InstallDir=$aSubInstallDir; aIsRebuild=$aIsRebuild" 
    if [ ! -d "${aSubSrcDir}" ]; then
        echo "Folder ${aSubSrcDir}  NOT exist!"
        exit 1001
    fi    
 

    if [ "${aIsRebuild}" = "true" ]; then 
        # echo "${aSubSrcDir} aIsRebuild ==true..1"          
        rm -fr ${aSubBuildDir}
        # 即使此处不创建${aSubBuildDir}，cmake -S -B命令也会创建 
        mkdir -p ${aSubBuildDir}
        
        rm -fr ${aSubInstallDir}
        mkdir -p ${aSubInstallDir}
        # cmake --build 命令会创建 ${aSubInstallDir} 
        echo "${aSubSrcDir} aIsRebuild ==true..2"       
    else
        echo "${aSubSrcDir} aIsRebuild ==false"      
    fi   

    return 0
}

mkSoftLinks()
{
    local fromRootDir="/mnt/disk2/abner/zdev/nv/osgearth0x/build_by_sh/ubuntu/install"
    cd  ${INSTALL_PREFIX_ubt}

    ln -s ${fromRootDir}/libpng         libpng
    ln -s ${fromRootDir}/libjpeg-turbo  libjpeg-turbo
    ln -s ${fromRootDir}/freetype       freetype
    ln -s ${fromRootDir}/xz       xz
    ln -s ${fromRootDir}/zlib     zlib
    ln -s ${fromRootDir}/zstd     zstd
    ln -s ${fromRootDir}/libtiff        libtiff
    ln -s ${fromRootDir}/geos           geos
    ln -s ${fromRootDir}/sqlite         sqlite
    ln -s ${fromRootDir}/boost          boost

    ln -s ${fromRootDir}/curl   curl
    ln -s ${fromRootDir}/gdal   gdal


    ln -s ${fromRootDir}/abseil-cpp  abseil-cpp 
    ln -s ${fromRootDir}/libexpat    libexpat 
    ln -s ${fromRootDir}/libpsl      libpsl
    ln -s ${fromRootDir}/libzip      libzip
    ln -s ${fromRootDir}/openssl     openssl
    ln -s ${fromRootDir}/proj     proj
    ln -s ${fromRootDir}/protobuf protobuf
}

# run mkSoftLinks()
mkSoftLinks 

# **************************************************************************
# **************************************************************************
#  3rd/
# **************************************************************************
 
SrcDIR_3rd=${Repo_ROOT}/3rd 


# +++++++++++++++++++++++++++++++++++++++++++++++
INSTALL_PREFIX_zlib=${INSTALL_PREFIX_ubt}/zlib
INSTALL_PREFIX_png=${INSTALL_PREFIX_ubt}/libpng
INSTALL_PREFIX_jpegTurbo=${INSTALL_PREFIX_ubt}/libjpeg-turbo
INSTALL_PREFIX_tiff=${INSTALL_PREFIX_ubt}/libtiff
INSTALL_PREFIX_freetype=${INSTALL_PREFIX_ubt}/freetype
INSTALL_PREFIX_geos=${INSTALL_PREFIX_ubt}/geos
INSTALL_PREFIX_sqlite=${INSTALL_PREFIX_ubt}/sqlite
INSTALL_PREFIX_boost=${INSTALL_PREFIX_ubt}/boost
INSTALL_PREFIX_zip=${INSTALL_PREFIX_ubt}/libzip
INSTALL_PREFIX_xz=${INSTALL_PREFIX_ubt}/xz
INSTALL_PREFIX_absl=${INSTALL_PREFIX_ubt}/abseil-cpp
INSTALL_PREFIX_zstd=${INSTALL_PREFIX_ubt}/zstd
INSTALL_PREFIX_protobuf=${INSTALL_PREFIX_ubt}/protobuf
INSTALL_PREFIX_openssl=${INSTALL_PREFIX_ubt}/openssl
INSTALL_PREFIX_tiff=${INSTALL_PREFIX_ubt}/libtiff
INSTALL_PREFIX_psl=${INSTALL_PREFIX_ubt}/libpsl
INSTALL_PREFIX_proj=${INSTALL_PREFIX_ubt}/proj
INSTALL_PREFIX_expat=${INSTALL_PREFIX_ubt}/libexpat
INSTALL_PREFIX_curl=${INSTALL_PREFIX_ubt}/curl
INSTALL_PREFIX_gdal=${INSTALL_PREFIX_ubt}/gdal
# +++++++++++++++++++++++++++++++++++++++++++++++


# -------------------------------------------------
# cesium-native
# -------------------------------------------------
INSTALL_PREFIX_cesiumNative=${INSTALL_PREFIX_ubt}/cesium-native 

if [ "${isFinished_build_cesiumNative}" != "true" ] ; then 
    echo "======== Building cesium-native =========" &&  sleep 3 # && set -x     

    SrcDIR_lib=${SrcDIR_3rd}/cesium-native
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/cesium-native 
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_cesiumNative} ${isRebuild}  
    # vcpkg 清单模式：
    # 当通过 CMAKE_TOOLCHAIN_FILE 指定 vcpkg 工具链，且项目根目录存在 vcpkg.json 时，
    # vcpkg 会自动进入「清单模式」，根据 vcpkg.json 中声明的依赖项下载并编译所需库。
    CMAKE_PRESETS_PATH="${SrcDIR_lib}/doc/cmake-presets/" \
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  \
        -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake  \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_cesiumNative}  \
        -DVCPKG_MANIFEST_MODE=OFF \
        -DCESIUM_USE_EZVCPG=OFF   -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}

    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v

    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}
    echo "========== Finished Building cesium-native =========" # &&  set +x
    
fi



# -------------------------------------------------
# osg 
# -----
# (1) before building osg,
#    sudo apt-get install libgl1-mesa-dev  libglu1-mesa-dev  libxext-dev 
# (2) 3rd/osg/CMakeModules里有很多FindXxx.cmake,osg的编译因此优先使用 3rd/osg/CMakeLists.txt里的 
#           SET(CMAKE_MODULE_PATH "${OpenSceneGraph_SOURCE_DIR}/CMakeModules;${CMAKE_MODULE_PATH}")
#     其次用-DCMAKE_PREFIX_PATH="${cmk_prefixPath}"
# (3)3rd/osg/examples/osgstaticviewer
# -------------------------------------------------
INSTALL_PREFIX_osg=${INSTALL_PREFIX_ubt}/osg

if [ "${isFinished_build_osg}" != "true" ] ; then 
    echo "========== building osg 4 ubuntu========== " &&  sleep 1

    SrcDIR_lib=${SrcDIR_3rd}/osg
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/osg
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_osg} ${isRebuild}  

    #################################################################### 
    cmk_prefixPath="${INSTALL_PREFIX_png}"  
    cmk_prefixPath+=";${INSTALL_PREFIX_jpegTurbo}"
    cmk_prefixPath+=";${INSTALL_PREFIX_tiff}"  
    cmk_prefixPath+=";${INSTALL_PREFIX_geos}"   
    cmk_prefixPath+=";${INSTALL_PREFIX_sqlite}"   
    cmk_prefixPath+=";${INSTALL_PREFIX_boost}"  
    echo "==========cmk_prefixPath=${cmk_prefixPath}"   
    # <<osg的间接依赖库>>
    # 依赖关系：osg -->gdal-->curl-->libpsl， 所以OSG 的 CMake 配置需要确保在
    # target_link_libraries 时包含所有 cURL 所依赖的库(osg的间接依赖库)。
    # 这通常在 CMakeLists.txt中通过 find_package(CURL)返回的导入型目标CURL::libCurl获得或直接在
    # CMake -S -B命令中加 -DCMAKE_EXE_LINKER_FLAGS或CMAKE_SHARED_LINKER_FLAGS来添加缺失的库。​ 
    # 
 
 
    #  zlib // freetype // gdal 的搜索优先使用 3rd/osg/CMakeLists.txt里的 CMAKE_MODULE_PATH
    osg_MODULE_PATH=""
    # ------
    libstdcxx_a_path=$(find /usr/lib/gcc/x86_64-linux-gnu -name libstdc++.a)
    # ------
    cmakeParams_osg=( 
    # "-DCMAKE_FIND_ROOT_PATH_MODE_PACKAGE=BOTH" 
    # "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH" # BOTH ：先查根路径，再查系统路径    
    # "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH" # 头文件仍只查根路径 
    # 是否访问 /usr/include/、/usr/lib/ 等 系统路径   
    "-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=ON"
    # 是否访问PATH\LD_LIBRARY_PATH等环境变量
    "-DCMAKE_FIND_USE_SYSTEM_ENVIRONMENT_PATH=ON" 
    "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON"
    )

    # ------
    echo "=== cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find ......"
    # --debug-find    --debug-output   --trace-expand 
    Freetype_DIR=${SrcDIR_lib}/CMakeModules  \
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find  \
            "${cmakeCommonParams[@]}"  "${cmakeParams_osg[@]}" \
            -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"     \
            -DCMAKE_PREFIX_PATH="${cmk_prefixPath}" \
            -DCMAKE_MODULE_PATH="${osg_MODULE_PATH}" \
            -DCMAKE_FIND_LIBRARY_SUFFIXES=".a"        \
            -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_osg}    \
            -DCMAKE_C_FLAGS="-fPIC  -DOSG_GL3_AVAILABLE=1"   \
            -DCMAKE_CXX_FLAGS="-fPIC -std=c++14  -DOSG_GL3_AVAILABLE=1" \
            -DCMAKE_LIBRARY_PATH="/usr/lib/gcc/x86_64-linux-gnu/" \
            -DCMAKE_INCLUDE_PATH="/usr/include/"                   \
            -DCMAKE_DEBUG_POSTFIX=""   \
        -DDYNAMIC_OPENTHREADS=OFF   \
        -DDYNAMIC_OPENSCENEGRAPH=OFF \
        -DANDROID=OFF  -DBUILD_OSG_APPLICATIONS=OFF  -DBUILD_OSG_EXAMPLES=OFF   \
        -DOSG_GL1_AVAILABLE=OFF   \
        -DOSG_GL2_AVAILABLE=OFF   \
        -DOSG_GL3_AVAILABLE=ON    \
        -DOSG_GLES1_AVAILABLE=OFF \
        -DOSG_GLES2_AVAILABLE=OFF \
        -DOSG_GLES3_AVAILABLE=OFF \
        -DOSG_GL_LIBRARY_STATIC=OFF        \
        -DOSG_GL_DISPLAYLISTS_AVAILABLE=OFF \
        -DOSG_GL_MATRICES_AVAILABLE=OFF      \
        -DOSG_GL_VERTEX_FUNCS_AVAILABLE=OFF   \
        -DOSG_GL_VERTEX_ARRAY_FUNCS_AVAILABLE=OFF \
        -DOSG_GL_FIXED_FUNCTION_AVAILABLE=OFF      \
        -DOPENGL_PROFILE="GL3" \
        -DEGL_INCLUDE_DIR=/usr/include/EGL                    \
        -DEGL_LIBRARY=/usr/lib/x86_64-linux-gnu/libEGL.so      \
        -DOPENGL_EGL_INCLUDE_DIR=/usr/include/EGL               \
        -DOPENGL_INCLUDE_DIR=/usr/include/                       \
        -DOPENGL_gl_LIBRARY=/usr/lib/x86_64-linux-gnu/libGL.so    \
        -DOPENGL_glu_LIBRARY="/usr/lib/x86_64-linux-gnu/libGLU.so" \
        -DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config   \
        -DOSG_FIND_3RD_PARTY_DEPS=ON  \
        -DZLIB_USE_STATIC_LIBS=ON \
        -DZLIB_DIR=${SrcDIR_lib}/CMakeModules             \
        -DZLIB_INCLUDE_DIR=${INSTALL_PREFIX_zlib}/include  \
        -DZLIB_LIBRARY=${INSTALL_PREFIX_zlib}/lib/libz.a    \
        -DZLIB_LIBRARIES="${INSTALL_PREFIX_zlib}/lib/libz.a" \
        -DJPEG_DIR=${INSTALL_PREFIX_jpegTurbo}/lib/cmake/libjpeg-turbo \
        -DJPEG_INCLUDE_DIR=${INSTALL_PREFIX_jpegTurbo}/include/libjpeg  \
        -DJPEG_LIBRARY=${INSTALL_PREFIX_jpegTurbo}/lib/libjpeg.a         \
        -DJPEG_LIBRARIES=${INSTALL_PREFIX_jpegTurbo}/lib/libjpeg.a        \
        -DPNG_INCLUDE_DIR=${INSTALL_PREFIX_png}/include/libpng16 \
        -DPNG_LIBRARY=${INSTALL_PREFIX_png}/lib/libpng.a          \
        -DPNG_LIBRARIES=${INSTALL_PREFIX_png}/lib/libpng.a         \
        -DTIFF_INCLUDE_DIR=${INSTALL_PREFIX_tiff}/include   \
        -DTIFF_LIBRARY=${INSTALL_PREFIX_tiff}/lib/libtiff.a  \
        -DTIFF_LIBRARIES=${INSTALL_PREFIX_tiff}/lib/libtiff.a \
        -DFreetype_DIR=${SrcDIR_lib}/CMakeModules                          \
        -DFREETYPE_INCLUDE_DIR=${INSTALL_PREFIX_freetype}/include/freetype2 \
        -DFREETYPE_INCLUDE_DIRS=${INSTALL_PREFIX_freetype}/include/freetype2 \
        -DFREETYPE_LIBRARY=${INSTALL_PREFIX_freetype}/lib/libfreetyped.a      \
        -DFREETYPE_LIBRARIES=${INSTALL_PREFIX_freetype}/lib/libfreetyped.a     \
        -DNO_DEFAULT_PATH=ON \
        -DCMAKE_EXE_LINKER_FLAGS=" \
            -Wl,-Bdynamic -lm -lc -lGL -lGLU -ldl \
            -Wl,--no-as-needed -lX11 -lXext"
        

        # (1)关于-DCURL_LIBRARY="CURL::libcurl" ：
        #  -DCURL_LIBRARY="${INSTALL_PREFIX_curl}/lib/libcurl-d.a"  ## 根据一般的规则，ok
        #  -DCURL_LIBRARIES="CURL::libcurl" ## 根据一般的规则，ok
        #  -DCURL_LIBRARY="CURL::libcurl" ##  特定于osg项目，是ok的，因为osg/src/osgPlugins/curl/CMakeLists.txt中
        #     ## SET(TARGET_LIBRARIES_VARS   CURL_LIBRARY     ZLIB_LIBRARIES)用的是CURL_LIBRARY而不是CURL_LIBRARIES

        # -DCMAKE_EXE_LINKER_FLAGS="${_exeLinkerFlags}" 
        # (2) -Wl,--whole-archive /usr/lib/gcc/x86_64-linux-gnu/11/libstdc++.a -Wl,--no-whole-archive
        #    等价于 -static-libstdc++
        # (3)Glibc 的某些函数（如网络相关）在静态链接时需要动态库支持,使用libc.a和libm.a会导致 collect2: error: ld returned 1 exit status
        #     
        # (4) *****修改 3rd/osg/packaging/cmake/OpenSceneGraphConfig.cmake.in *****：
        # ```
        # if(TARGET @PKG_NAMESPACE@::${component})
        #     # This component has already been found, so we'll skip it
        #     set(OpenSceneGraph_${component}_FOUND TRUE)
        #     set(OPENSCENEGRAPH_${component}_FOUND TRUE)
        #     # continue() ## ************************** 注掉这一行 ***********************
        # endif()
        # ```        
        #  
        # (5) osg/src/osgPlugins/png/CMakeLists.txt中强制 SET(TARGET_LIBRARIES_VARS PNG_LIBRARY ZLIB_LIBRARIES )
        #    而 lib/cmake/PNG/PNGConfig.cmake 中 没提供PNG_LIBRARY
        #    所以 cmake -S -B 必须添加 -DPNG_LIBRARY=${INSTALL_PREFIX_png}/lib/libpng.a
        # (6)针对cmakeCommonParams，特化设置：
        #    -DEGL_LIBRARY=  -DEGL_INCLUDE_DIR=  -DEGL_LIBRARY= 
        #    -DOPENGL_EGL_INCLUDE_DIR=  -DOPENGL_INCLUDE_DIR=  -DOPENGL_gl_LIBRARY=
        #    -DPKG_CONFIG_EXECUTABLE= 

        # -DBoost_ROOT=${INSTALL_PREFIX_boost}  \ ## 现代CMake（>=3.12）官方标准
        # -DBOOST_ROOT=${INSTALL_PREFIX_boost}  \ ## 旧版兼容（FindBoost.cmake传统方式）
        
        #
        # -DCMAKE_STATIC_LINKER_FLAGS=${_LINKER_FLAGS}  
 
    echo "=== cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v"
    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v
    
    echo "=== cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE} --verbose"
    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}   --verbose  
    #################################################################### 
    echo "========== finished building osg 4 ubuntu ========== " &&  sleep 1 

fi    
  


# -------------------------------------------------
# csprng 
# -------------------------------------------------
INSTALL_PREFIX_csprng=${INSTALL_PREFIX_ubt}/csprng
BuildDIR_csprng=${BuildDir_ubuntu}/3rd/csprng
if [ "${isFinished_build_csprng}" != "true" ] ; then 
    echo "========== building csprng 4 ubuntu========== " &&  sleep 1

    SrcDIR_lib=${SrcDIR_3rd}/CSPRNG
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/csprng
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_csprng} ${isRebuild}  

    #################################################################### 
    # osg_MODULE_PATH="" 

    # ------
    echo "=== cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find ......"
    # --debug-find    --debug-output   --trace-expand  
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find  \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_csprng} \
        -DARCH=64  -DLINKAGE=static -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
         
            # -DCMAKE_PREFIX_PATH="${cmk_prefixPath}" \
            # -DCMAKE_MODULE_PATH="${osg_MODULE_PATH}" \ 
 
    echo "=== cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v"
    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v
    
    echo "=== cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE} --verbose"
    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}   --verbose  
    #################################################################### 
    echo "========== finished building csprng 4 ubuntu ========== " &&  sleep 1 

fi    


# -------------------------------------------------
# modp_b64 
# -------------------------------------------------
INSTALL_PREFIX_modpB64=${INSTALL_PREFIX_ubt}/modp_b64

if [ "${isFinished_build_modpB64}" != "true" ] ; then 
    echo "========== building modp_b64 4 ubuntu========== " &&  sleep 1

    SrcDIR_lib=${SrcDIR_3rd}/modp_b64
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/modp_b64
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_modpB64} ${isRebuild}  
  
    echo "=== cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find ......"
    # --debug-find    --debug-output   --trace-expand  
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find  \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_modpB64} \
        -DBUILD_SHARED_LIBS=OFF -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          
 
    echo "=== cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v"
    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v
    
    echo "=== cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE} --verbose"
    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}   --verbose  
    #################################################################### 
    echo "========== finished building modp_b64 4 ubuntu ========== " 
fi      


# -------------------------------------------------
# uriparser 
# -------------------------------------------------
INSTALL_PREFIX_uriparser=${INSTALL_PREFIX_ubt}/uriparser

if [ "${isFinished_build_uriparser}" != "true" ] ; then 
    echo "========== building uriparser 4 ubuntu========== " &&  sleep 1

    SrcDIR_lib=${SrcDIR_3rd}/uriparser
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/uriparser
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_uriparser} ${isRebuild}  
  
    echo "=== cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find ......"
    # --debug-find    --debug-output   --trace-expand  
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find  \
        -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_uriparser} \
        -DBUILD_SHARED_LIBS=OFF \
        -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} \
        -DURIPARSER_BUILD_DOCS=OFF \
        -DURIPARSER_BUILD_TESTS=OFF \
        -DURIPARSER_BUILD_TOOLS=OFF 
        
 
    echo "=== cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v"
    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v
    
    echo "=== cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE} --verbose"
    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}   --verbose  
    #################################################################### 
    echo "========== finished building uriparser 4 ubuntu ========== " 
fi      


# -------------------------------------------------
# osgearth 
# -------------------------------------------------
INSTALL_PREFIX_osgearth=${INSTALL_PREFIX_ubt}/osgearth

if [ "${isFinished_build_oearth}" != "true" ] ; then 
    echo "========== building osgearth 4 ubuntu========== " &&  sleep 1  && set -x

    SrcDIR_lib=${SrcDIR_3rd}/osgearth
    BuildDIR_lib=${BuildDir_ubuntu}/3rd/osgearth 
    prepareBuilding  ${SrcDIR_lib} ${BuildDIR_lib} ${INSTALL_PREFIX_osgearth} ${isRebuild}  

    #################################################################### 
    # /mnt/disk2/abner/zdev/nv/oearth02/build_by_sh/ubuntu/3rd/cesium-native/vcpkg_installed/x64-linux
    cesiumNative_allDeps_rootDIR=${BuildDir_ubuntu}/3rd/cesium-native/vcpkg_installed/x64-linux/
    export PKG_CONFIG_PATH="${INSTALL_PREFIX_osg}/lib/pkgconfig:$PKG_CONFIG_PATH"

    cesiumNative_allDeps_incDIRS="${cesiumNative_allDeps_rootDIR}/include"
    cesiumNative_allDeps_incDIRS+=";${INSTALL_PREFIX_uriparser}/include/uriparser"
    #---- osgEarth -> Protobuf -> (absl + utf8_range)
    #   
    cmk_prefixPath="${INSTALL_PREFIX_zlib}" 
    cmk_prefixPath+=";${cesiumNative_allDeps_rootDIR}/share/s2"  
    cmk_prefixPath+=";${cesiumNative_allDeps_rootDIR}/share"
    cmk_prefixPath+=";${cesiumNative_allDeps_rootDIR}"
    cmk_prefixPath+=";${INSTALL_PREFIX_zip}"
    cmk_prefixPath+=";${INSTALL_PREFIX_xz}"
    cmk_prefixPath+=";${INSTALL_PREFIX_absl}"
    cmk_prefixPath+=";${INSTALL_PREFIX_zstd}"
    cmk_prefixPath+=";${INSTALL_PREFIX_png}"
    cmk_prefixPath+=";${INSTALL_PREFIX_jpegTurbo}"
    cmk_prefixPath+=";${INSTALL_PREFIX_protobuf}"
    cmk_prefixPath+=";${INSTALL_PREFIX_openssl}"
    cmk_prefixPath+=";${INSTALL_PREFIX_tiff}"
    cmk_prefixPath+=";${INSTALL_PREFIX_geos}"
    cmk_prefixPath+=";${INSTALL_PREFIX_psl}"
    cmk_prefixPath+=";${INSTALL_PREFIX_proj}"
    cmk_prefixPath+=";${INSTALL_PREFIX_expat}"
    cmk_prefixPath+=";${INSTALL_PREFIX_freetype}"
    cmk_prefixPath+=";${INSTALL_PREFIX_curl}"
    cmk_prefixPath+=";${INSTALL_PREFIX_sqlite}"
    cmk_prefixPath+=";${INSTALL_PREFIX_gdal}"
    cmk_prefixPath+=";${INSTALL_PREFIX_osg}"
    echo "oearth...cmk_prefixPath=${cmk_prefixPath}"   
    
    # ----
    osgearth_MODULE_PATH="${INSTALL_PREFIX_zlib}/lib/cmake/zlib"  
    echo "oearth...osgearth_MODULE_PATH=${osgearth_MODULE_PATH}"    

    # ----
    cmakeParams_osgearth=(  
    "-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=BOTH" # BOTH：先查根路径，再查系统路径    
    "-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=BOTH"  
    # "-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER"
    # 是否访问 /usr/include/、/usr/lib/ 等 系统路径   
    "-DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=ON" 
#   "-DCMAKE_FIND_PACKAGE_PREFER_CONFIG=OFF"        
    )
    # 2. 清理环境
    unset LD_LIBRARY_PATH
    unset LIBRARY_PATH
    # (1)/usr/share/cmake-3.28/Modules/FindGLEW.cmake中需要用 ENV GLEW_ROOT。
    # (2)在 CMake 命令行中临时设置环境变量（一次性生效），格式为 
    #   GLEW_ROOT=/path/to/GLEW cmake ...  ，无需提前 export。 

                # "${cmakeCommonParams[@]}"  

    # --debug-find    --debug-output 
    GLEW_ROOT="/usr/lib/x86_64-linux-gnu/" \
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  --debug-find   \
            "${cmakeCommonParams[@]}"  "${cmakeParams_osgearth[@]}" \
            -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" \
            -DCMAKE_PREFIX_PATH="${cmk_prefixPath}" \
            -DCMAKE_MODULE_PATH=${osgearth_MODULE_PATH} \
            -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX_osgearth}  \
            -DCMAKE_C_FLAGS="-fPIC -fdiagnostics-show-option -DOSG_GL3_AVAILABLE=1 -U GDAL_DEBUG -DOSGEARTH_LIBRARY=1"   \
            -DCMAKE_CXX_FLAGS="-fPIC -fdiagnostics-show-option -DOSG_GL3_AVAILABLE=1 -U GDAL_DEBUG -DOSGEARTH_LIBRARY=1" \
            -DBUILD_SHARED_LIBS=OFF   \
        -DNRL_STATIC_LIBRARIES=ON  -DOSGEARTH_BUILD_SHARED_LIBS=OFF \
        -DCMAKE_SKIP_RPATH=ON  \
        -DOSGEARTH_BUILD_CESIUM_NODEKIT=ON \
        -DANDROID=OFF \
        -DDYNAMIC_OPENTHREADS=OFF     -DDYNAMIC_OPENSCENEGRAPH=OFF \
        -DOSGEARTH_ENABLE_FASTDXT=OFF \
        -DOSGEARTH_BUILD_TOOLS=ON    -DOSGEARTH_BUILD_EXAMPLES=ON   \
        -DOSGEARTH_BUILD_IMGUI_NODEKIT=OFF \
        -DOSG_GL1_AVAILABLE=OFF \
        -DOSG_GL2_AVAILABLE=OFF  \
        -DOSG_GL3_AVAILABLE=ON    \
        -DOSG_GLES1_AVAILABLE=OFF  \
        -DOSG_GLES2_AVAILABLE=OFF   \
        -DOSG_GLES3_AVAILABLE=OFF    \
        -DOSG_GL_LIBRARY_STATIC=OFF        \
        -DOSG_GL_DISPLAYLISTS_AVAILABLE=OFF \
        -DOSG_GL_MATRICES_AVAILABLE=OFF      \
        -DOSG_GL_VERTEX_FUNCS_AVAILABLE=OFF   \
        -DOSG_GL_VERTEX_ARRAY_FUNCS_AVAILABLE=OFF \
        -DOSG_GL_FIXED_FUNCTION_AVAILABLE=OFF      \
        -DOPENGL_PROFILE="GL3" \
        -DGLEW_USE_STATIC_LIBS=OFF \
        -DMATH_LIBRARY="/usr/lib/x86_64-linux-gnu/libm.so" \
        -DEGL_LIBRARY=/usr/lib/x86_64-linux-gnu/libEGL.so   \
        -DEGL_INCLUDE_DIR=/usr/include/EGL                   \
        -DEGL_LIBRARY=/usr/lib/x86_64-linux-gnu/libEGL.so     \
        -DOPENGL_EGL_INCLUDE_DIR=/usr/include/EGL              \
        -DOPENGL_INCLUDE_DIR=/usr/include/GL                    \
        -DOPENGL_gl_LIBRARY=/usr/lib/x86_64-linux-gnu/libGL.so   \
        -DPKG_CONFIG_EXECUTABLE=/usr/bin/pkg-config               \
        -DCESIUM_NATIVE_DIR=${INSTALL_PREFIX_cesiumNative}        \
        -DCESIUM_NATIVE_DEPS_DIR=${cesiumNative_allDeps_rootDIR}   \
        -DCESIUM_NATIVE_DEP_CSPRNG_DIR=${BuildDIR_csprng}           \
        -DCESIUM_NATIVE_DEP_modpB64_DIR=${INSTALL_PREFIX_modpB64}    \
        -DCESIUM_NATIVE_DEP_uriparser_DIR=${INSTALL_PREFIX_uriparser} \
        -DCesiumNative_allDeps_incDIRS=${cesiumNative_allDeps_incDIRS} \
        -DOpenSceneGraph_FIND_QUIETLY=OFF  \
        -DOSG_DIR=${INSTALL_PREFIX_osg}     \
        -DOPENSCENEGRAPH_INCLUDE_DIR=${INSTALL_PREFIX_osg}/include \
        -DZLIB_ROOT_DIR="${INSTALL_PREFIX_zlib}"  \
        -DZSTD_LIBRARY="${INSTALL_PREFIX_zstd}/lib/libzstd.a"  \
        -DZLIB_INCLUDE_DIR="${INSTALL_PREFIX_zlib}/include" \
        -DZLIB_LIBRARY="${INSTALL_PREFIX_zlib}/lib/libz.a"   \
        -DPNG_INCLUDE_DIR="${INSTALL_PREFIX_png}/include/"   \
        -DPNG_LIBRARY="${INSTALL_PREFIX_png}/lib/libpng.a"   \
        -DJPEG_INCLUDE_DIR=${INSTALL_PREFIX_jpegTurbo}/include  \
        -DJPEG_LIBRARY=${INSTALL_PREFIX_jpegTurbo}/lib/libjpeg.a \
        -DTIFF_INCLUDE_DIR=${INSTALL_PREFIX_tiff}/include  \
        -DTIFF_LIBRARY=${INSTALL_PREFIX_tiff}/lib/libtiff.a \
        -DFREETYPE_ROOT=${INSTALL_PREFIX_freetype}                    \
        -DFREETYPE_INCLUDE_DIR=${INSTALL_PREFIX_freetype}/include      \
        -DFREETYPE_LIBRARY=${INSTALL_PREFIX_freetype}/lib/libfreetyped.a \
        -DCURL_ROOT=${INSTALL_PREFIX_curl}                  \
        -DCURL_INCLUDE_DIR=${INSTALL_PREFIX_curl}/include    \
        -DCURL_LIBRARY=${INSTALL_PREFIX_curl}/lib/libcurl-d.a \
        -DSQLite3_INCLUDE_DIR=${INSTALL_PREFIX_sqlite}/include     \
        -DSQLite3_LIBRARIES=${INSTALL_PREFIX_sqlite}/lib/libsqlite3.a \
        -DGEOS_DIR="${INSTALL_PREFIX_geos}/lib/cmake/GEOS/"  \
        -Dgeos_DIR="${INSTALL_PREFIX_geos}/lib/cmake/GEOS/"  \
        -DGEOS_INCLUDE_DIR=${INSTALL_PREFIX_geos}/include  \
        -DPROJ_INCLUDE_DIR=${INSTALL_PREFIX_proj}/include  \
        -DPROJ_LIBRARY=${INSTALL_PREFIX_proj}/lib/libproj.a \
        -DPROJ4_LIBRARY=${INSTALL_PREFIX_proj}/lib/libproj.a \
        -DGDAL_ROOT=${INSTALL_PREFIX_gdal}                \
        -DGDAL_INCLUDE_DIR=${INSTALL_PREFIX_gdal}/include  \
        -DGDAL_LIBRARY=${INSTALL_PREFIX_gdal}/lib/libgdal.a \
        -DOpenSSL_DIR="${INSTALL_PREFIX_openssl}/lib64/cmake/OpenSSL"     \
        -DOPENSSL_SSL_LIBRARY=${INSTALL_PREFIX_openssl}/lib64/libssl.a     \
        -DSSL_EAY_RELEASE=${INSTALL_PREFIX_openssl}/lib64/libssl.a          \
        -DOPENSSL_CRYPTO_LIBRARY=${INSTALL_PREFIX_openssl}/lib64/libcrypto.a \
        -Dabsl_DIR="${INSTALL_PREFIX_protobuf}/lib/cmake/absl/"           \
        -Dutf8_range_DIR="${INSTALL_PREFIX_protobuf}/lib/cmake/utf8_range" \
        -Dprotobuf_DIR="${INSTALL_PREFIX_protobuf}/lib/cmake/protobuf/"     \
        -DLIB_EAY_RELEASE=""  \
        -DCMAKE_EXE_LINKER_FLAGS=" \
          -Wl,--whole-archive  -fvisibility=hidden   -Wl,--no-whole-archive   \
          -Wl,-Bdynamic -lstdc++  -lGL -lGLU -ldl -lm -lc -lpthread -lrt     \
          -Wl,--no-as-needed -lX11 -lXext "  
 
 
        # -DGEOS_DIR=${INSTALL_PREFIX_geos}/lib/cmake/GEOS  \
        # (0) osgearth 编译时发生 类型转换错误​​（invalid conversion from 'void*' to 'OGRLayerH'）,
        #     用-DCMAKE_C_FLAGS="-U GDAL_DEBUG" 解决

        # (1)   GDAL -->|依赖| GEOS_C[libgeos_c.a] -->|依赖| GEOS[libgeos.a] -->|依赖| stdc++[libstdc++]
        #  osgearth ->GEOS::geos_c ; osgearth -> gdal -> GEOS::GEOS
        #   GEOS 自身的 install/geos/lib/cmake/GEOS/geos-config.cmake 生成 GEOS::geos 目标 ,
        #   GDAL 自带的 install/gdal/lib/cmake/gdal/packages/FindGEOS.cmake 生成 GEOS::GEOS 目标。
        #   osgearth 的cmakelists.txt中需要GEOS::geos_c，osgearth依赖gdal，而gdal需要GEOS::GEOS,因为
        #   gdal/lib/cmake/gdal/GDAL-targets.cmake  有
        # ```
        # set_target_properties(GDAL::GDAL PROPERTIES
        #     INTERFACE_COMPILE_DEFINITIONS "\$<\$<CONFIG:DEBUG>:GDAL_DEBUG>"
        #     INTERFACE_INCLUDE_DIRECTORIES "${_IMPORT_PREFIX}/include"
        #     INTERFACE_LINK_LIBRARIES "\$<LINK_ONLY:ZLIB::ZLIB>;。。。。。。。。。。。\$<LINK_ONLY:GEOS::GEOS>。。。。
        # ```
        # (2)remark: osgearth/src/osgEarth/CMakeLists.txt 
        # ```
        # OPTION(NRL_STATIC_LIBRARIES "Link osgEarth against static GDAL and cURL, including static OpenSSL, Proj4, JPEG, PNG, and TIFF." OFF)
        # if(NOT NRL_STATIC_LIBRARIES)
        # LINK_WITH_VARIABLES(${LIB_NAME} OSG_LIBRARY ... CURL_LIBRARY GDAL_LIBRARY OSGMANIPULATOR_LIBRARY)
        # else(NOT NRL_STATIC_LIBRARIES)
        # LINK_WITH_VARIABLES(${LIB_NAME} OSG_LIBRARY ... CURL_LIBRARY GDAL_LIBRARY OSGMANIPULATOR_LIBRARY 
        #                           SSL_EAY_RELEASE LIB_EAY_RELEASE 
        #                           TIFF_LIBRARY PROJ4_LIBRARY PNG_LIBRARY JPEG_LIBRARY)
        # endif(NOT NRL_STATIC_LIBRARIES)
        # ```
        # (3)
        # OSGDB_LIBRARY  OSGGA_LIBRARY OSGMANIPULATOR_LIBRARY OSGSHADOW_LIBRARY 
        # OSGSIM_LIBRARY OSGTEXT_LIBRARY OSGUTIL_LIBRARY 
        # OSGVIEWER_LIBRARY OSG_LIBRARY
        # (4)
        #  -DPROTOBUF_LIBRARY=${INSTALL_PREFIX_protobuf}/lib/libprotobuf.a \
        #  -DPROTOBUF_INCLUDE_DIR=${INSTALL_PREFIX_protobuf}/include        \
    echo "ee====cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v" 
    cmake --build ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}  -j$(nproc) -v
    
    echo "cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}" 
    cmake --install ${BuildDIR_lib} --config ${CMAKE_BUILD_TYPE}     
    #################################################################### 
    echo "========== finished building osgearth 4 ubuntu ========== "   && set +x

fi    

 
 
# **************************************************************************
# **************************************************************************
#  src/
# ************************************************************************** 
SrcDIR_src=${Repo_ROOT}/src 