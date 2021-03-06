# warning: don't use this, use acmake_qt_support instead

include(ans.parse_arguments)
include(acmake_copy_dll)
include(acmake_append_runtime_dirs)

macro(filter_files_contain pattern out_var in_var)
    set(${out_var}_temp)
    foreach(file_name ${${in_var}})
        set(z_filter_file_contain_content)
        file(READ ${file_name} z_filter_file_contain_content)
        if(z_filter_file_contain_content MATCHES ${pattern})
            list(APPEND ${out_var}_temp ${file_name})
        endif(z_filter_file_contain_content MATCHES ${pattern})
    endforeach(file_name)
    set(${out_var} ${${out_var}_temp})
endmacro()

MACRO(qt_support)
    PARSE_ARGUMENTS(
        QT_SUPPORT
        "HEADER;UI;RESOURCE;COMPONENTS;VERSION;WORKING_DIRECTORY"
        "COPY_DLL;COPY_SHARED"
        ${ARGN}
        )

    FIND_PACKAGE(Qt4 ${QT_SUPPORT_VERSION} REQUIRED ${QT_SUPPORT_COMPONENTS})
    INCLUDE(${QT_USE_FILE})

    if(${ARGC} GREATER 0)
        list(LENGTH QT_SUPPORT_DEFAULT_ARGS DEFAULT_ARGS_LENGTH)
        if(${DEFAULT_ARGS_LENGTH} EQUAL 2)
            CAR(qt_files ${QT_SUPPORT_DEFAULT_ARGS})
            CDR(QT_SUPPORT_REST ${QT_SUPPORT_DEFAULT_ARGS})
            CAR(qt_libraries ${QT_SUPPORT_REST})
            set(QT_SUPPORT_TARGET)
        elseif(${DEFAULT_ARGS_LENGTH} EQUAL 1)
            CAR(QT_SUPPORT_TARGET ${QT_SUPPORT_DEFAULT_ARGS})
            set(qt_files)
            set(qt_libraries)
        endif()

        SET(project_name ${PROJECT_NAME})

        #FILE(GLOB_RECURSE ${project_name}_source *.cpp)
        FILE(GLOB_RECURSE ${project_name}_header *.h *.hpp)
        FILE(GLOB_RECURSE ${project_name}_ui *.ui)
        FILE(GLOB_RECURSE ${project_name}_resource *.qrc)
        list(APPEND ${project_name}_header ${QT_SUPPORT_HEADER})
        list(APPEND ${project_name}_ui ${QT_SUPPORT_UI})
        list(APPEND ${project_name}_resource ${QT_SUPPORT_RESOURCE})

        filter_files_contain(".*Q_OBJECT.*" ${project_name}_header_temp ${project_name}_header)
        set(${project_name}_header ${${project_name}_header_temp})

        QT4_WRAP_UI(${project_name}_ui_source ${${project_name}_ui})
        INCLUDE_DIRECTORIES(${CMAKE_CURRENT_BINARY_DIR}) #let cmake find generated ui source
        QT4_WRAP_CPP(${project_name}_moc_source ${${project_name}_header})
        QT4_ADD_RESOURCES(${project_name}_resource_source ${${project_name}_resource})

        SET(${project_name}_qt_generated ${${project_name}_ui_source} ${${project_name}_moc_source} ${${project_name}_resource_source})

        if(NOT QT_SUPPORT_TARGET)
            SOURCE_GROUP("Qt Generated" FILES ${${project_name}_qt_generated})
            SET(${qt_files} ${${project_name}_qt_generated})
            SET(${qt_libraries} ${QT_LIBRARIES})
        else()
            set(QT_SUPPORT_FILES ${${project_name}_qt_generated})
            # only create new lib when exists file to be moc
            if(QT_SUPPORT_FILES)
                # generate static library that contains qt moc files
                add_library(${QT_SUPPORT_TARGET}_moc STATIC ${QT_SUPPORT_FILES})
                target_link_libraries(${QT_SUPPORT_TARGET}_moc ${QT_LIBRARIES})
                # make target depend on this new static library
                target_link_libraries(${QT_SUPPORT_TARGET} ${QT_SUPPORT_TARGET}_moc)
            else()
                target_link_libraries(${QT_SUPPORT_TARGET} ${QT_LIBRARIES})
            endif()
            if(QT_SUPPORT_COPY_DLL OR QT_SUPPORT_COPY_SHARED)
                acmake_append_runtime_dirs(${QT_SUPPORT_TARGET} ${QT_BINARY_DIR})
            endif()
        endif()
    endif()
ENDMACRO(qt_support)
