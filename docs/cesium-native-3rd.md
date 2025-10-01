# 1.cpp-httplib 依赖于curl吗

`cpp-httplib` 本身**不依赖于 curl**。

`cpp-httplib` 是一个独立的 C++ HTTP 库，它基于 C++11 标准实现，内部直接使用操作系统的 socket API（如 Linux/recv 等）进行网络通信，不需要需要依赖依赖任何外部 HTTP 库（包括 curl）的支持。

这是它的一个重要特点：作为单头文件库（header-only），`cpp-httplib` 可以直接嵌入到项目中，无需额外链接其他 HTTP 相关库，极大简化了集成流程。

不过需要注意：
- 如果需要启用 HTTPS 功能，`cpp-httplib` 会依赖 OpenSSL 或 LibreSSL（通过宏 `CPPHTTPLIB_OPENSSL_SUPPORT` 开启）
- 它的功能和性能与 curl 有差异，curl 更偏向于命令行工具和全功能客户端，而 `cpp-httplib` 更适合在 C++ 程序中轻量集成 HTTP 服务或客户端功能

总结：`cpp-httplib` 与 curl 是相互独立的，使用 `cpp-httplib` 不需要安装或链接 curl。


===============================
# 2. 3rd/cesium-native/CMakeLists.txt

-- PACKAGE_BASE_DIR /home/abner/programs/vcpkg//packages
-- PACKAGE_BUILD_DIR /mnt/disk2/abner/zdev/nv/oearth02/build_by_sh/ubuntu/3rd/cesium-native/vcpkg_installed/x64-linux/
