cmake_minimum_required(VERSION 3.10)
project(modp_b64 VERSION 1.0 LANGUAGES CXX)

# 设置C++标准
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 库源文件
set(LIB_SOURCES
    modp_b64.cc 
)

 

# 生成库
add_library(${PROJECT_NAME}   ${LIB_SOURCES})

# 包含头文件目录
target_include_directories(${PROJECT_NAME}
    PUBLIC
        $<INSTALL_INTERFACE:include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/
)

# 平台特定配置
if(ANDROID)
    # Android平台特定设置
    message(STATUS "Configuring for Android")
    
    # Android日志库链接
    target_link_libraries(${PROJECT_NAME} log)
    
    # Android特定编译选项
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall
        -Wextra
        -fexceptions  # 启用异常处理
    )
    
else()
    # Ubuntu平台特定设置
    message(STATUS "Configuring for Ubuntu")
    
    # Ubuntu特定编译选项
    target_compile_options(${PROJECT_NAME} PRIVATE
        -Wall
        -Wextra
        -O0
    )
endif()
 

# 安装配置
install(TARGETS ${PROJECT_NAME}
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    INCLUDES DESTINATION include
)

# install(DIRECTORY include/ DESTINATION include)
install(FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/modp_b64.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/modp_b64_data.h"
    DESTINATION include/modp_b64 ) 

 