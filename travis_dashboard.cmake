# Client maintainer: jchris.fillionr@kitware.com
execute_process(COMMAND hostname OUTPUT_VARIABLE hostname OUTPUT_STRIP_TRAILING_WHITESPACE)
set(CTEST_SITE "${hostname}")
set(CTEST_DASHBOARD_ROOT $ENV{TRAVIS_BUILD_DIR}/..)
get_filename_component(compiler_name $ENV{CC} NAME)
string(SUBSTRING $ENV{TRAVIS_COMMIT} 0 7 commit)
set(CTEST_BUILD_NAME "$ENV{TRAVIS_OS_NAME}-${compiler_name}_$ENV{TRAVIS_BRANCH}_${commit}")
set(CTEST_CONFIGURATION_TYPE Release)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-j4")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 8)

set(dashboard_model Experimental)
set(dashboard_track Travis-CI)

function(downloadFile url dest)
 file(DOWNLOAD ${url} ${dest} STATUS status)
 list(GET status 0 error_code)
 list(GET status 1 error_msg)
 if(error_code)
   message(FATAL_ERROR "error: Failed to download ${url} - ${error_msg}")
 endif()
endfunction()

# Download and include driver script
set(url https://raw.githubusercontent.com/davidsansome/python-cmake-buildsystem/dashboard/python_common.cmake)
set(dest ${CTEST_SCRIPT_DIRECTORY}/python_common.cmake)
downloadfile(${url} ${dest})
include(${dest})

# Upload link to travis
set(travis_url "/tmp/travis.url")
file(WRITE ${travis_url} "https://travis-ci.org/$ENV{TRAVIS_REPO_SLUG}/builds/$ENV{TRAVIS_BUILD_ID}")
ctest_upload(FILES ${travis_url})
ctest_submit(PARTS Upload)
file(REMOVE ${travis_url})
