# 1.osgEarth​​ 集成 ​​Cesium Native​​，并优化 ​​OSG（OpenSceneGraph）​​ 的编译依赖

## Q

如果osgearth 集成 cesium-native ，如何集成？ 首先osgearth依赖于osg 和cesium-native，所以集成时主要集成osgearth+osg+cesium-native。
为避免osg集成时太重，编译osg时去掉osg对  gdal 和curl 等osgPlugins，只编译 jpg 、png 这俩osgPlugins，其他的数据相关osgPlugins依赖于cesium-native 是否可以?

## A-YuanbaoAI

要将 **osgEarth** 集成 **Cesium Native**，并优化 **OSG（OpenSceneGraph）** 的编译依赖，可以按照以下方案进行：

---

## **1. 整体架构设计**
✅ **目标**：
- **osgEarth** 依赖 **OSG**（核心渲染）和 **Cesium Native**（3D Tiles 数据加载）。
- **OSG** 仅负责渲染（去掉 GDAL、CURL 等插件），数据加载交给 **Cesium Native**。
- **Cesium Native** 负责处理 3D Tiles、地形、影像等数据（替代 OSG 的部分插件）。

📌 **依赖关系**：
```
osgEarth
├── OSG (轻量化，仅渲染 + JPG/PNG 插件)
└── Cesium Native (数据加载：3D Tiles、地形、CURL 等)
```

---

## **2. 编译 OSG（轻量化）**
### **关键：禁用不必要的 OSG 插件**
在编译 **OSG** 时，仅保留 `jpg`、`png` 插件，禁用其他数据相关插件（如 `gdal`、`curl`、`geos` 等），避免与 **Cesium Native** 功能重叠。

#### **CMake 配置示例**
```bash
cmake \
-DBUILD_OSG_PLUGINS_BY_DEFAULT=OFF \
-DOSG_PLUGIN_SEARCH_INSTALL_DIR_FOR_PLUGINS=ON \
-DDYNAMIC_OPENSCENEGRAPH=ON \
-DOSG_USE_UTF8_FILENAME=ON \
# 仅启用 jpeg 和 png 插件
-DOSG_PLUGIN_JPEG=ON \
-DOSG_PLUGIN_PNG=ON \
# 禁用其他插件
-DOSG_PLUGIN_GDAL=OFF \
-DOSG_PLUGIN_CURL=OFF \
-DOSG_PLUGIN_FREETYPE=OFF \
-DOSG_PLUGIN_GEOS=OFF \
# 其他非必要模块
-DBUILD_OSG_EXAMPLES=OFF \
-DBUILD_OSG_DEPRECATED_SERIALIZERS=OFF \
..
```

#### **验证 OSG 插件**
编译完成后，检查 `lib/osgPlugins-<version>/`，确保只有：
- `libosgdb_jpeg.so`
- `libosgdb_png.so`

---

## **3. 编译 Cesium Native**
### **关键：启用必要的依赖**
Cesium Native 需要处理 **3D Tiles、地形、影像、网络请求**，因此需启用：
- **GDAL**（地理数据）
- **CURL**（网络请求）
- **SQLite3**（3D Tiles 缓存）
- **PROJ**（坐标转换）

#### **CMake 配置示例**
```bash
cmake \
-DCMAKE_BUILD_TYPE=Release \
-DCESIUM_NATIVE_USE_GDAL=ON \
-DCESIUM_NATIVE_USE_CURL=ON \
-DCESIUM_NATIVE_USE_SQLITE3=ON \
-DCESIUM_NATIVE_USE_PROJ=ON \
..
```

---

## **4. 编译 osgEarth**
### **关键：链接 OSG + Cesium Native**
osgEarth 需要同时依赖 **OSG（轻量化）** 和 **Cesium Native（数据加载）**。

#### **CMake 配置示例**
```bash
cmake \
-DCMAKE_BUILD_TYPE=Release \
-DOSG_DIR=/path/to/osg/install/lib/cmake/OpenSceneGraph \
-DCESIUM_NATIVE_DIR=/path/to/cesium-native/install/lib/cmake/CesiumNative \
# 禁用 osgEarth 的 GDAL/CURL 插件（用 Cesium Native 替代）
-DOSGEARTH_USE_GDAL=OFF \
-DOSGEARTH_USE_CURL=OFF \
..
```

---

## **5. 代码集成**
### **关键：用 Cesium Native 替代 OSG 插件**
在代码中，使用 **Cesium Native** 加载数据，然后转换为 OSG 可渲染的格式。

#### **示例：加载 3D Tiles**
```cpp
#include <Cesium3DTiles/Tileset.h>
#include <osgEarth/Registry>

// 创建 Cesium 3D Tiles 加载器
auto pTileset = std::make_shared<Cesium3DTiles::Tileset>("tileset.json");

// 转换为 OSG 节点
osg::ref_ptr<osg::Node> pOsgNode = convertCesiumTilesetToOsg(pTileset);

// 添加到场景
viewer->setSceneData(pOsgNode);
```

#### **数据转换工具函数**
```cpp
osg::Node* convertCesiumTilesetToOsg(std::shared_ptr<Cesium3DTiles::Tileset> pTileset) {
    osg::Group* pRoot = new osg::Group;
    // 遍历 Cesium 3D Tiles 并转换为 OSG 几何体
    for (auto& tile : pTileset->getTiles()) {
        osg::Geode* pGeode = new osg::Geode;
        pGeode->addDrawable(convertToOsgGeometry(tile));
        pRoot->addChild(pGeode);
    }
    return pRoot;
}
```

---

## **6. 运行时依赖**
### **关键：确保动态库正确加载**
- **OSG**：仅需 `libOpenThreads.so`, `libosg.so`, `libosgDB.so`（轻量化）。
- **Cesium Native**：需 `libCesium3DTiles.so`, `libCesiumGltf.so`, `libCesiumGeometry.so`。
- **osgEarth**：需 `libosgEarth.so`, `libosgEarthUtil.so`。

#### **检查动态库**
```bash
ldd /path/to/your/app | grep -E "osg|Cesium"
```

---

## **7. 验证方案**
### **1. 检查 OSG 插件**
```bash
ls /path/to/osg/install/lib/osgPlugins-3.6.5/
# 应只有 jpeg 和 png
```

### **2. 检查 Cesium Native 功能**
```cpp
auto pTileset = std::make_shared<Cesium3DTiles::Tileset>("tileset.json");
assert(pTileset->isValid()); // 确保 3D Tiles 加载正常
```

### **3. 检查 osgEarth 渲染**
```cpp
osgViewer::Viewer viewer;
viewer.setSceneData(pOsgNode);
viewer.run(); // 确保场景渲染正常
```

---

## **8. 优化建议**
- **减少 OSG 插件**：仅保留 `jpeg` 和 `png`，其他数据交给 Cesium Native。
- **共享依赖**：如果 Cesium Native 和 osgEarth 都依赖 GDAL，确保版本一致。
- **缓存管理**：用 Cesium Native 的 `CachingAssetAccessor` 优化网络请求。

---

## **总结**
| 组件 | 职责 | 关键配置 |
|------|------|----------|
| **OSG** | 渲染核心 | 仅编译 `jpeg` 和 `png` 插件 |
| **Cesium Native** | 数据加载（3D Tiles、GDAL、CURL） | 启用 GDAL、CURL、PROJ |
| **osgEarth** | 地理场景整合 | 禁用 GDAL/CURL，链接 Cesium Native |

这样可以避免 OSG 的冗余依赖，同时利用 Cesium Native 的强大数据加载能力。如果需要具体代码示例或调试帮助，可以告诉我！ 🚀