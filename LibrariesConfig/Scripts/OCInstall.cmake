########################################################################
# Installation stuff - create & export config files
#
message(STATUS "============== OCINSTALL ================")
message(STATUS "ARCHITECTURE_MPI_PATH: ${ARCHITECTURE_MPI_PATH}")
message(STATUS "OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX: ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX}")
string(REPLACE "${ARCHITECTURE_MPI_PATH}" "" OPENCMISS_EXPORT_INSTALL_PREFIX ${OPENCMISS_LIBRARIES_INSTALL_MPI_PREFIX})
message(STATUS "OPENCMISS_EXPORT_INSTALL_PREFIX: ${OPENCMISS_EXPORT_INSTALL_PREFIX}")
set(CMAKE_INSTALL_PREFIX "${OPENCMISS_EXPORT_INSTALL_PREFIX}")
if (ARCHITECTURE_MPI_PATH)
    set(INSTALL_PATH_MPI ${ARCHITECTURE_MPI_PATH})
else ()
    set(INSTALL_PATH_MPI ".")
endif ()
message(STATUS "OPENCMISS_EXPORT_INSTALL_PREFIX: '${OPENCMISS_EXPORT_INSTALL_PREFIX}'")

function(messaged MSG)
    #message(STATUS "OCInstall: ${MSG}")
endfunction()

###########################################################################################
# Helper functions

# Transforms a given list named VARNAME of paths.
# At first determines the relative path to RELATIVE_TO_DIR and then prefixes
# a variable named IMPORT_PREFIX_VARNAME to it, so that use of that list
# will have dynamically computed prefixes.
function(relativizePathList VARNAME RELATIVE_TO_DIR IMPORT_PREFIX_VARNAME)
    set(REL_LIST )
    foreach(path ${${VARNAME}})
        get_filename_component(path_abs "${path}" ABSOLUTE)
        messaged("Relativizing\n${path}\nto\n${RELATIVE_TO_DIR}")
        file(RELATIVE_PATH RELPATH "${RELATIVE_TO_DIR}" "${path_abs}")
        #getRelativePath("${path_abs}" "${RELATIVE_TO_DIR}" RELPATH)
        list(APPEND REL_LIST "\${${IMPORT_PREFIX_VARNAME}}/${RELPATH}")
    endforeach()
    set(${VARNAME} ${REL_LIST} PARENT_SCOPE)
endfunction()

function(do_export CFILE VARS)
    message(STATUS "Exporting OpenCMISS build context: ${CFILE}")
    file(WRITE ${CFILE} "#Exported OpenCMISS configuration\r\n")
    file(APPEND ${CFILE} "#DO NOT EDIT THIS FILE. ITS GENERATED BY THE OPENCMISS BUILD ENVIRONMENT\r\n")
    file(APPEND ${CFILE} "get_filename_component(_OPENCMISS_CONTEXT_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" DIRECTORY)\r\n")
    foreach(VARNAME ${VARS})
        if (DEFINED ${VARNAME})
            if (VARNAME MATCHES "^OPENCMISS_")
                file(APPEND ${CFILE} "set(CONTEXT_${VARNAME} ${${VARNAME}})\r\n")
            else ()
                file(APPEND ${CFILE} "set(${VARNAME} ${${VARNAME}})\r\n")
            endif ()
        endif()    
    endforeach()
endfunction()

###########################################################################################
# Create context.cmake in arch-path dir

# Create a copy to not destroy the original (its being used somewhere later maybe)
set(OPENCMISS_PREFIX_PATH_IMPORT ${OPENCMISS_PREFIX_PATH})
relativizePathList(OPENCMISS_PREFIX_PATH_IMPORT "${OPENCMISS_DEPENDENCIES_INSTALL_MPI_PREFIX}" _OPENCMISS_CONTEXT_IMPORT_PREFIX)
set(OPENCMISS_LIBRARY_PATH_IMPORT ${OPENCMISS_LIBRARY_PATH})
relativizePathList(OPENCMISS_LIBRARY_PATH_IMPORT "${OPENCMISS_DEPENDENCIES_INSTALL_MPI_PREFIX}" _OPENCMISS_CONTEXT_IMPORT_PREFIX)
list(REMOVE_DUPLICATES OPENCMISS_LIBRARY_PATH_IMPORT)
list(REMOVE_DUPLICATES OPENCMISS_PREFIX_PATH_IMPORT)

# Introduce prefixed variants of variables so we can check against them
set(OPENCMISS_CXX_COMPILER "${CMAKE_CXX_COMPILER}")
set(OPENCMISS_Fortran_COMPILER "${CMAKE_Fortran_COMPILER}")

set(EXPORT_VARS
    OPENCMISS_PREFIX_PATH_IMPORT
    OPENCMISS_LIBRARY_PATH_IMPORT
    OPENCMISS_TOOLCHAIN
    OPENCMISS_MPI
    OPENCMISS_CXX_COMPILER
    OPENCMISS_Fortran_COMPILER
    OPENCMISS_MPI_HOME
    OPENCMISS_MPI_VERSION
    BLA_VENDOR
    #FORTRAN_MANGLING
)

# Export component info
foreach(COMPONENT ${OPENCMISS_COMPONENTS})
    list(APPEND EXPORT_VARS OC_USE_${COMPONENT} OC_SYSTEM_${COMPONENT})
    if (${COMPONENT}_VERSION)
        list(APPEND EXPORT_VARS ${COMPONENT}_VERSION)
    endif()
endforeach()

set(OPENCMISS_CONTEXT ${CMAKE_CURRENT_BINARY_DIR}/export/context.cmake)
do_export(${OPENCMISS_CONTEXT} "${EXPORT_VARS}")

message(STATUS "INSTALL_PATH_MPI: ${INSTALL_PATH_MPI}")
# Install it
install(
    FILES ${OPENCMISS_CONTEXT}
    DESTINATION "${INSTALL_PATH_MPI}"
    COMPONENT Development
)
unset(EXPORT_VARS)

###########################################################################################
# Create opencmiss-config.cmake

message(STATUS "CMAKE_MODULE_PATH: ${CMAKE_MODULE_PATH}")
set(OPENCMISS_MODULE_PATH_EXPORT
    ${OPENCMISS_CMAKE_MODULE_PATH}/FindModuleWrappers
    ${OPENCMISS_CMAKE_MODULE_PATH}/Modules
    ${OPENCMISS_CMAKE_MODULE_PATH}/Modules/OpenCMISS
    ${OPENCMISS_EXPORT_INSTALL_PREFIX}/cmake)
relativizePathList(OPENCMISS_MODULE_PATH_EXPORT "${OPENCMISS_EXPORT_INSTALL_PREFIX}" _OPENCMISS_IMPORT_PREFIX)

if (OC_DEVELOPER AND NOT OPENCMISS_INSTALLATION_SUPPORT_EMAIL)
    message(WARNING "Dear developer! Please set the OPENCMISS_INSTALLATION_SUPPORT_EMAIL variable in OpenCMISSInstallationConfig.cmake "
                    "to your eMail address so that people using your installation can contact you for support. Thanks!")
endif()
# Check if there are defaults - otherwise use the current build's settings
if (NOT OC_DEFAULT_MPI)
    set(OC_DEFAULT_MPI ${MPI})
endif()
if (NOT OC_DEFAULT_MPI_BUILD_TYPE)
    set(OC_DEFAULT_MPI_BUILD_TYPE ${OPENCMISS_MPI_BUILD_TYPE})
endif()

# There's litte to configure yet, but could become more
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Templates/opencmisslibs-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/export/opencmisslibs-config.cmake @ONLY
)

# Version file
include(CMakePackageConfigHelpers)
WRITE_BASIC_PACKAGE_VERSION_FILE(
    ${CMAKE_CURRENT_BINARY_DIR}/export/opencmisslibs-config-version.cmake
    COMPATIBILITY AnyNewerVersion
)
install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/export/opencmisslibs-config.cmake
        ${CMAKE_CURRENT_BINARY_DIR}/export/opencmisslibs-config-version.cmake
    DESTINATION ${COMMON_PACKAGE_CONFIG_DIR}
    COMPONENT Development
)

# Install mingw libraries if we built with mingw
# Needs checking - maybe the bundle stuff in iron (for windows) can do this automatically.
if (MINGW AND WIN32)
    get_filename_component(COMPILER_BIN_DIR ${CMAKE_C_COMPILER} PATH)
    file(GLOB MINGW_DLLS "${COMPILER_BIN_DIR}/*.dll")
    install(FILES ${MINGW_DLLS}
        DESTINATION ${INSTALL_PATH_MPI}/bin
        COMPONENT Runtime)
endif()

# Additional User SDK files
set(USERSDK_RESOURCE_DIR Resources)
# Add the OpenCMISSLibs.cmake file to the UserSDK - it is a tool to help find the correct installation paths.
# May reintroduce this concept if there is a need, we may have created an alternative which renders this irrelevant.
#install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/Packaging/OpenCMISSLibs.cmake
#    DESTINATION ${COMMON_PACKAGE_CONFIG_DIR}
#    COMPONENT UserSDK)
    
message(STATUS "OpenCMISSLibs_VERSION: v${OpenCMISSLibs_VERSION}")
if (OPENCMISS_DEVEL_ALL)
    set(_VERSION_BRANCH devel)
else ()
    set(_VERSION_BRANCH v${OpenCMISSLibs_VERSION})
endif ()
if(NOT EXISTS ${CMAKE_INSTALL_PREFIX}/${USERSDK_RESOURCE_DIR}/Examples)
    foreach(_test_example ${OC_TEST_EXAMPLES})
        install(CODE "
           file(MAKE_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}/${USERSDK_RESOURCE_DIR}/Examples\")
           execute_process(COMMAND ${GIT_EXECUTABLE} clone -b ${_VERSION_BRANCH} https://github.com/OpenCMISS-Examples/${_test_example}
               WORKING_DIRECTORY \"\${CMAKE_INSTALL_PREFIX}/${USERSDK_RESOURCE_DIR}/Examples\")
           "
           COMPONENT UserSDK)
    endforeach()
endif()
unset(_VERSION_BRANCH)
message(STATUS "============== OCINSTALL ================")
