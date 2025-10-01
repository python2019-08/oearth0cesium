# 1.如何不用cp 而在cmake命令中指定  doc/cmake-presets/CMakeUserPresets.json 

```sh
# 3rd/cesium-native/doc/topics/developer-setup.md
cp doc/cmake-presets/CMakeUserPresets.json .
cmake --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
cmake --build build 
```
如何不用cp 而在cmake命令中指定  doc/cmake-presets/CMakeUserPresets.json

如果你想在 **不手动复制 `CMakeUserPresets.json`** 的情况下，直接在 `cmake` 命令中指定它的路径，可以使用 `--user-preset` 或 `--preset` 参数（取决于 CMake 版本）。以下是几种方法：

---

## **方法 1：使用 `--preset` 并指定相对路径（CMake 3.21+）**
如果你的 `CMakeUserPresets.json` 在 `doc/cmake-presets/` 目录下，你可以直接：
```bash
cmake --preset=doc/cmake-presets/vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
但前提是 `vcpkg-linux` 预设定义在 `doc/cmake-presets/CMakeUserPresets.json` 中。

---

## **方法 2：使用 `--user-preset`（CMake 3.23+）**
如果 `CMakeUserPresets.json` 不在默认搜索路径（`CMakePresets.json` 同级目录），你可以：
```bash
cmake --user-preset=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
但 `--user-preset` 参数在 CMake 3.23 才引入，早期版本不支持。

---

## **方法 3：使用 `-S` 指定源码目录（推荐）**
如果 `CMakeLists.txt` 在项目根目录，而 `CMakeUserPresets.json` 在 `doc/cmake-presets/` 下，你可以：
```bash
cmake -S . --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
CMake 会自动搜索 `CMakePresets.json` 和 `CMakeUserPresets.json` 在 `-S` 指定的目录及其子目录。

---

## **方法 4：设置 `CMAKE_PRESETS_PATH` 环境变量**
```bash
export CMAKE_PRESETS_PATH="doc/cmake-presets/"
cmake --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
这样 CMake 会自动查找 `CMAKE_PRESETS_PATH` 下的预设文件。

---

## **方法 5：直接传递 `--list-presets` 检查**
如果 CMake 找不到预设，可以先检查：
```bash
cmake --list-presets --preset-file=doc/cmake-presets/CMakeUserPresets.json
```
然后手动指定 `--preset-file`：
```bash
cmake --preset-file=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```

---

## **最终推荐方案**
✅ **如果你的 CMake 版本 ≥ 3.23**，最佳方式是：
```bash
cmake --user-preset=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
✅ **如果 CMake 版本 < 3.23**，可以：
```bash
cmake -S . --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```
或者：
```bash
cmake --preset-file=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux -DCMAKE_BUILD_TYPE=Debug
```

---

### **总结**
| 方法 | 适用 CMake 版本 | 命令示例 |
|------|----------------|----------|
| `--user-preset` | ≥ 3.23 | `cmake --user-preset=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux` |
| `-S` 指定源码目录 | ≥ 3.21 | `cmake -S . --preset=vcpkg-linux` |
| `--preset-file` | ≥ 3.21 | `cmake --preset-file=doc/cmake-presets/CMakeUserPresets.json --preset=vcpkg-linux` |
| `CMAKE_PRESETS_PATH` | ≥ 3.21 | `export CMAKE_PRESETS_PATH="doc/cmake-presets/" && cmake --preset=vcpkg-linux` |

如果你的 CMake 版本较低（< 3.21），建议升级 CMake 或手动 `cp` 文件。


==================================================================
# 2.cesium-native/CMakeLists.txt中 哪句用于指定vcpkg要下载的代码

在 `cesium-native/CMakeLists.txt` 中，用于指定 vcpkg 要下载的代码（依赖包）的核心配置是通过定义包列表并传递给 `ezvcpkg_fetch` 函数实现的，主要涉及以下部分：

1. **包列表定义**：
   明确列出了需要 vcpkg 下载的所有依赖包，分为公共依赖、私有依赖和测试依赖：
   ```cmake
   # 公共依赖（用于公共头文件，需要分发头文件和二进制文件）
   set(PACKAGES_PUBLIC asyncplusplus expected-lite fmt glm rapidjson spdlog stb ada-url)
   
   # 私有依赖（用于代码实现，仅需分发二进制文件）
   set(PACKAGES_PRIVATE
       abseil draco ktx modp-base64 meshoptimizer openssl s2geometry
       libjpeg-turbo sqlite3 tinyxml2 libwebp zlib-ng picosha2
       earcut-hpp cpp-httplib[core] libmorton zstd
   )
   
   # 根据平台条件添加额外依赖
   if(NOT IOS AND NOT VCPKG_CMAKE_SYSTEM_NAME MATCHES "iOS")
       list(APPEND PACKAGES_PRIVATE blend2d asmjit)
   else()
       list(APPEND PACKAGES_PRIVATE blend2d[core])
   endif()
   
   # 可选依赖（根据配置决定是否添加）
   if(NOT CESIUM_DISABLE_CURL)
       list(APPEND PACKAGES_PRIVATE curl)
   endif()
   
   # 测试依赖
   set(PACKAGES_TEST doctest)
   ```

2. **执行下载的核心命令**：
   当启用 `CESIUM_USE_EZVCPKG` 时，通过 `ezvcpkg_fetch` 函数指定要下载的包列表：
   ```cmake
   if(CESIUM_USE_EZVCPKG)
       set(PACKAGES_ALL ${PACKAGES_PUBLIC})
       list(APPEND PACKAGES_ALL ${PACKAGES_PRIVATE})
       list(APPEND PACKAGES_ALL ${PACKAGES_TEST})
   
       ezvcpkg_fetch(
           COMMIT 2025.09.17  # 指定 vcpkg 的版本/commit
           PACKAGES ${PACKAGES_ALL}  # 要下载的所有依赖包
           CLEAN_BUILDTREES  # 清理构建目录节省空间
           UPDATE_TOOLCHAIN  # 更新工具链以找到下载的包
           SERIALIZE  # 强制包安装序列化（避免 CI 超时）
       )
   endif()
   ```

**总结**：`PACKAGES_PUBLIC`、`PACKAGES_PRIVATE`、`PACKAGES_TEST` 定义了需要下载的依赖包，最终通过 `ezvcpkg_fetch` 的 `PACKAGES ${PACKAGES_ALL}` 指令告诉 vcpkg 具体要下载哪些代码包。`COMMIT 2025.09.17` 则指定了 vcpkg 自身的版本，确保依赖下载的兼容性。

=============================================
# 3.但是我已经通过设置CMAKE_TOOLCHAIN_FILE而CESIUM_USE_EZVCPKG=OFF了，ezvcpkg_fetch没被调用
```
    CMAKE_PRESETS_PATH="${SrcDIR_lib}/doc/cmake-presets/" \
    cmake -S ${SrcDIR_lib} -B ${BuildDIR_lib}  \
        -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake  \
        -DCESIUM_USE_EZVCPG=OFF   -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
```

当 `CESIUM_USE_EZVCPKG=OFF` 且通过 `-DCMAKE_TOOLCHAIN_FILE` 指定了 vcpkg 工具链时，Cesium Native 会直接使用 vcpkg 的常规模式（而非 ezvcpkg 辅助工具）来管理依赖。此时，vcpkg 要下载的代码由项目根目录下的 **`vcpkg.json`** 文件（而非 CMakeLists.txt 中的变量）指定。

### 原理说明：
1. **vcpkg 清单模式**：  
   当通过 `CMAKE_TOOLCHAIN_FILE` 指定 vcpkg 工具链，且项目根目录存在 `vcpkg.json` 时，vcpkg 会自动进入「清单模式」，根据 `vcpkg.json` 中声明的依赖项下载并编译所需库。

2. **依赖声明位置**：  
   此时 `CMakeLists.txt` 中定义的 `PACKAGES_PUBLIC`、`PACKAGES_PRIVATE` 等变量仅用于后续的编译链接（如 `find_package` 查找依赖），而 **实际下载的依赖由 `vcpkg.json` 控制**。

3. **典型的 `vcpkg.json` 内容**（Cesium Native 项目中）：  
   该文件会列出所有需要的依赖，例如：
   ```json
   {
     "name": "cesium-native",
     "version": "0.51.0",
     "dependencies": [
       "asyncplusplus",
       "expected-lite",
       "fmt",
       "glm",
       "rapidjson",
       "spdlog",
       "stb",
       "ada-url",
       "abseil",
       "draco",
       "ktx",
       "modp-base64",
       "meshoptimizer",
       "openssl",
       "s2geometry",
       // ... 其他依赖
     ],
     "features": {
       "curl": {
         "dependencies": ["curl"]
       }
     }
   }
   ```

### 总结：
当 `CESIUM_USE_EZVCPKG=OFF` 时，vcpkg 下载的代码由项目根目录的 **`vcpkg.json`** 文件指定，而非 CMakeLists.txt 中的变量。CMakeLists.txt 中的 `PACKAGES_*` 变量仅用于后续的依赖查找和链接配置。

如果需要修改依赖（如添加/移除包），应直接编辑 `vcpkg.json` 文件，vcpkg 会在构建时自动根据该文件下载所需代码。