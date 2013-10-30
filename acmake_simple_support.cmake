# warning: do not use this directly, use acmake_xxx_support instead
if(ACMAKE_SIMPLE_SUPPORT_INCLUDED)
    return()
endif()
set(ACMAKE_SIMPLE_SUPPORT_INCLUDED TRUE)

include(acmake_common)
include(acmake_find_package)
include(acmake_target_property)

# usage: acmake_simple_support(<target> <library>)
# 
# XXX_HOME will be considered
macro(acmake_simple_support TARGET LIBRARY)
    string(TOUPPER ${LIBRARY} UPPER_LIBRARY)
    if(EXISTS "${${LIBRARY}_HOME}")
        list(APPEND CMAKE_PREFIX_PATH "${${LIBRARY}_HOME}")
    endif()
    if(EXISTS "${${UPPER_LIBRARY}_HOME}")
        list(APPEND CMAKE_PREFIX_PATH "${${UPPER_LIBRARY}_HOME}")
    endif()
    acmake_find_package(${LIBRARY} REQUIRED)
    if(${LIBRARY}_INCLUDE_DIRS)
        target_include_directories(${TARGET} PUBLIC ${${LIBRARY}_INCLUDE_DIRS})
    endif()
    if(${UPPER_LIBRARY}_INCLUDE_DIRS)
        target_include_directories(${TARGET} PUBLIC ${${UPPER_LIBRARY}_INCLUDE_DIRS})
    endif()
    if(${LIBRARY}_LIBRARIES)
        target_link_libraries(${TARGET} LINK_PUBLIC ${${LIBRARY}_LIBRARIES})
    endif()
    if(${UPPER_LIBRARY}_LIBRARIES)
        target_link_libraries(${TARGET} LINK_PUBLIC ${${UPPER_LIBRARY}_LIBRARIES})
    endif()
    if(${UPPER_LIBRARY}_RUNTIME_DIRS)
        acmake_append_runtime_dirs(${TARGET} ${${UPPER_LIBRARY}_RUNTIME_DIRS})
    endif()
endmacro()
