cmake_minimum_required(VERSION 3.21)
project(TVPlayout VERSION 0.2.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 6.5 REQUIRED COMPONENTS Quick Multimedia)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(tv-playout
    src/main.cpp
)

qt_add_qml_module(tv-playout
    URI TVPlayout
    VERSION 1.0
    QML_FILES
        src/Main.qml
)

target_link_libraries(tv-playout
    PRIVATE Qt6::Quick Qt6::Multimedia
)

if(APPLE)
    set_target_properties(tv-playout PROPERTIES
        MACOSX_BUNDLE TRUE
        MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
        MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION}
    )
endif()
