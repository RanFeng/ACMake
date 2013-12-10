if(ACMAKE_TARGET_LINK_LIBRARIES_INCLUDED)
    return()
endif()
set(ACMAKE_TARGET_LINK_LIBRARIES_INCLUDED TRUE)

include(acmake_target_property)

macro(acmake_target_link_libraries target)
    target_link_libraries(${target} PUBLIC ${ARGN})
    set(_runtime_dirs "")
    get_target_property(_deps ${target} LINK_LIBRARIES)
    foreach(_dep ${_deps})
        acmake_get_target_property(_dirs ${_dep} ACMAKE_RUNTIME_DIRS)
        list(APPEND _runtime_dirs ${_dirs})
    endforeach()
    list(REMOVE_DUPLICATES _runtime_dirs)
    acmake_append_runtime_dirs(${target} ${_runtime_dirs})
endmacro()
