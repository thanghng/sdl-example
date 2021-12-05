# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

#  Copyright 2019 Amine Ben Hassouna <amine.benhassouna@gmail.com>
#  Copyright 2000-2019 Kitware, Inc. and Contributors
#  All rights reserved.

#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:

#  * Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.

#  * Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.

#  * Neither the name of Kitware, Inc. nor the names of Contributors
#    may be used to endorse or promote products derived from this
#    software without specific prior written permission.

#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
#  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
#  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
#  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
#  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
#  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#[=======================================================================[.rst:
FindSDL2
--------

Locate SDL2 library

This module defines the following 'IMPORTED' targets:

::

  SDL2::Core
    The SDL2 library, if found.
    Libraries should link to SDL2::Core

  SDL2::Main
    The SDL2main library, if found.
    Applications should link to SDL2::Main instead of SDL2::Core



This module will set the following variables in your project:

::

  SDL2_INCLUDE_DIRS, where to find SDL.h
  SDL2_FOUND, if false, do not try to link to SDL2
  SDL2MAIN_FOUND, if false, do not try to link to SDL2main
  SDL2_VERSION_STRING, human-readable string containing the version of SDL2



This module responds to the following cache variables:

::

  SDL2_PATH
    Set a custom SDL2 Library path (default: empty)

  SDL2_NO_DEFAULT_PATH
    Disable search SDL2 Library in default path.
      If SDL2_PATH (default: ON)
      Else (default: OFF)

  SDL2_INCLUDE_DIR
    SDL2 headers path.

  SDL2_LIBRARY
    SDL2 Library (.dll, .so, .a, etc) path.

  SDL2MAIN_LIBRAY
    SDL2main Library (.a) path.


Don't forget to include SDLmain.h and SDLmain.m in your project for the
OS X framework based version. (Other versions link to -lSDL2main which
this module will try to find on your behalf.) Also for OS X, this
module will automatically add the -framework Cocoa on your behalf.


$SDL2DIR is an environment variable that would correspond to the
./configure --prefix=$SDL2DIR used in building SDL2.  l.e.galup 9-20-02



Created by Amine Ben Hassouna:
  Adapt FindSDL.cmake to SDL2 (FindSDL2.cmake).
  Add cache variables for more flexibility:
    SDL2_PATH, SDL2_NO_DEFAULT_PATH (for details, see doc above).
  Mark 'Threads' as a required dependency for non-OSX systems.
  Modernize the FindSDL2.cmake module by creating specific targets:
    SDL2::Core and SDL2::Main (for details, see doc above).


Original FindSDL.cmake module:
  Modified by Eric Wing.  Added code to assist with automated building
  by using environmental variables and providing a more
  controlled/consistent search behavior.  Added new modifications to
  recognize OS X frameworks and additional Unix paths (FreeBSD, etc).
  Also corrected the header search path to follow "proper" SDL
  guidelines.  Added a search for SDLmain which is needed by some
  platforms.  Added a search for threads which is needed by some
  platforms.  Added needed compile switches for MinGW.

On OSX, this will prefer the Framework version (if found) over others.
People will have to manually change the cache value of SDL2_LIBRARY to
override this selection or set the SDL2_PATH variable or the CMake
environment CMAKE_INCLUDE_PATH to modify the search paths.

Note that the header path has changed from SDL/SDL.h to just SDL.h
This needed to change because "proper" SDL convention is #include
"SDL.h", not <SDL/SDL.h>.  This is done for portability reasons
because not all systems place things in SDL/ (see FreeBSD).
#]=======================================================================]

# Define options for searching SDL2 Library in a custom path

set(SDL2_PATH "" CACHE STRING "Custom SDL2 Library path")

set(_SDL2_NO_DEFAULT_PATH OFF)
if(SDL2_PATH)
    set(_SDL2_NO_DEFAULT_PATH ON)
endif()

set(SDL2_NO_DEFAULT_PATH ${_SDL2_NO_DEFAULT_PATH}
        CACHE BOOL "Disable search SDL2 Library in default path")
unset(_SDL2_NO_DEFAULT_PATH)

set(SDL2_NO_DEFAULT_PATH_CMD)
if(SDL2_NO_DEFAULT_PATH)
    set(SDL2_NO_DEFAULT_PATH_CMD NO_DEFAULT_PATH)
endif()

# Search for the SDL2 include directory
find_path(SDL2_INCLUDE_DIR SDL.h
        HINTS
        ENV SDL2DIR
        ${SDL2_NO_DEFAULT_PATH_CMD}
        PATH_SUFFIXES SDL2
        # path suffixes to search inside ENV{SDL2DIR}
        include/SDL2 include
        PATHS ${SDL2_PATH}
        DOC "Where the SDL2 headers can be found"
        )

set(SDL2_INCLUDE_DIRS "${SDL2_INCLUDE_DIR}")

if(MSVC)
    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(VC_LIB_PATH_SUFFIX lib/x64)
    else()
        set(VC_LIB_PATH_SUFFIX lib/x86)
    endif()
else()
    set(VC_LIB_PATH_SUFFIX lib)
endif()

find_library(SDL2_LIBRARY_RELEASE
        NAMES SDL2
        HINTS
        ENV SDL2DIR
        ${SDL2_NO_DEFAULT_PATH_CMD}
        PATH_SUFFIXES lib ${VC_LIB_PATH_SUFFIX}
        PATHS ${SDL2_PATH}
        DOC "Where the SDL2 Library can be found"
        )

find_library(SDL2_LIBRARY_DEBUG
        NAMES SDL2d
        HINTS
        ENV SDL2DIR
        ${SDL2_NO_DEFAULT_PATH_CMD}
        PATH_SUFFIXES lib ${VC_LIB_PATH_SUFFIX}
        PATHS ${SDL2_PATH}
        DOC "Where the SDL2 Library (debug version) can be found"
        )

include(SelectLibraryConfigurations)
select_library_configurations(SDL2)

if(NOT SDL2_INCLUDE_DIR MATCHES ".framework")
    # Non-OS X framework versions expect you to also dynamically link to
    # SDL2main. This is mainly for Windows and OS X. Other (Unix) platforms
    # seem to provide SDL2main for compatibility even though they don't
    # necessarily need it.

    if(SDL2_PATH)
        set(SDL2MAIN_LIBRARY_PATHS "${SDL2_PATH}")
    endif()

    if(NOT SDL2_NO_DEFAULT_PATH)
        set(SDL2MAIN_LIBRARY_PATHS
                /sw
                /opt/local
                /opt/csw
                /opt
                "${SDL2MAIN_LIBRARY_PATHS}"
                )
    endif()

    find_library(SDL2MAIN_LIBRARY
            NAMES SDL2main
            HINTS
            ENV SDL2DIR
            ${SDL2_NO_DEFAULT_PATH_CMD}
            PATH_SUFFIXES lib ${VC_LIB_PATH_SUFFIX}
            PATHS ${SDL2MAIN_LIBRARY_PATHS}
            DOC "Where the SDL2main library can be found"
            )
    unset(SDL2MAIN_LIBRARY_PATHS)
endif()

# SDL2 may require threads on your system.
# The Apple build may not need an explicit flag because one of the
# frameworks may already provide it.
# But for non-OSX systems, I will use the CMake Threads package.
if(NOT APPLE AND NOT MSVC)
    find_package(Threads QUIET)
    if(NOT Threads_FOUND)
        set(SDL2_THREADS_NOT_FOUND "Could NOT find Threads (Threads is required by SDL2).")
        if(SDL2_FIND_REQUIRED)
            message(FATAL_ERROR ${SDL2_THREADS_NOT_FOUND})
        else()
            if(NOT SDL2_FIND_QUIETLY)
                message(STATUS ${SDL2_THREADS_NOT_FOUND})
            endif()
            return()
        endif()
        unset(SDL2_THREADS_NOT_FOUND)
    endif()
endif()

# MinGW needs an additional link flag, -mwindows
# It's total link flags should look like -lmingw32 -lSDL2main -lSDL2 -mwindows
if(MINGW)
    set(MINGW32_LIBRARY mingw32 "-mwindows" CACHE STRING "link flags for MinGW")
endif()

# Read SDL2 version
if(SDL2_INCLUDE_DIR AND EXISTS "${SDL2_INCLUDE_DIR}/SDL_version.h")
    file(STRINGS "${SDL2_INCLUDE_DIR}/SDL_version.h" SDL2_VERSION_MAJOR_LINE REGEX "^#define[ \t]+SDL_MAJOR_VERSION[ \t]+[0-9]+$")
    file(STRINGS "${SDL2_INCLUDE_DIR}/SDL_version.h" SDL2_VERSION_MINOR_LINE REGEX "^#define[ \t]+SDL_MINOR_VERSION[ \t]+[0-9]+$")
    file(STRINGS "${SDL2_INCLUDE_DIR}/SDL_version.h" SDL2_VERSION_PATCH_LINE REGEX "^#define[ \t]+SDL_PATCHLEVEL[ \t]+[0-9]+$")
    string(REGEX REPLACE "^#define[ \t]+SDL_MAJOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_MAJOR "${SDL2_VERSION_MAJOR_LINE}")
    string(REGEX REPLACE "^#define[ \t]+SDL_MINOR_VERSION[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_MINOR "${SDL2_VERSION_MINOR_LINE}")
    string(REGEX REPLACE "^#define[ \t]+SDL_PATCHLEVEL[ \t]+([0-9]+)$" "\\1" SDL2_VERSION_PATCH "${SDL2_VERSION_PATCH_LINE}")
    set(SDL2_VERSION_STRING ${SDL2_VERSION_MAJOR}.${SDL2_VERSION_MINOR}.${SDL2_VERSION_PATCH})
    unset(SDL2_VERSION_MAJOR_LINE)
    unset(SDL2_VERSION_MINOR_LINE)
    unset(SDL2_VERSION_PATCH_LINE)
    unset(SDL2_VERSION_MAJOR)
    unset(SDL2_VERSION_MINOR)
    unset(SDL2_VERSION_PATCH)
endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(SDL2
        REQUIRED_VARS SDL2_LIBRARY SDL2_INCLUDE_DIR
        VERSION_VAR SDL2_VERSION_STRING)

if(SDL2MAIN_LIBRARY)
    FIND_PACKAGE_HANDLE_STANDARD_ARGS(SDL2main
            REQUIRED_VARS SDL2MAIN_LIBRARY SDL2_INCLUDE_DIR
            VERSION_VAR SDL2_VERSION_STRING)
endif()


mark_as_advanced(SDL2_PATH
        SDL2_NO_DEFAULT_PATH
        SDL2_LIBRARY
        SDL2MAIN_LIBRARY
        SDL2_INCLUDE_DIR)


# SDL2:: targets (SDL2::Core and SDL2::Main)
if(SDL2_FOUND)
    # SDL2::Core target
    if(SDL2_LIBRARY AND NOT TARGET SDL2::Core)
        add_library(SDL2::Core INTERFACE IMPORTED)
        target_include_directories(SDL2::Core INTERFACE "${SDL2_INCLUDE_DIR}")

        if(SDL2_LIBRARY_RELEASE AND SDL2_LIBRARY_DEBUG)
            target_link_libraries(SDL2::Core INTERFACE optimized "${SDL2_LIBRARY_RELEASE}")
            target_link_libraries(SDL2::Core INTERFACE debug "${SDL2_LIBRARY_DEBUG}")
        elseif(SDL2_LIBRARY_RELEASE)
            target_link_libraries(SDL2::Core INTERFACE "${SDL2_LIBRARY_RELEASE}")
        else()
            target_link_libraries(SDL2::Core INTERFACE "${SDL2_LIBRARY}")
        endif()

        if(NOT APPLE AND NOT MSVC)
            # For threads, as mentioned Apple doesn't need this.
            # For more details, please see above.
            target_link_libraries(SDL2::Core INTERFACE Threads::Threads)
        endif()
    endif()

    # SDL2::Main target
    # Applications should link to SDL2::Main instead of SDL2::Core
    # For more details, please see above.
    if(NOT TARGET SDL2::Main)

        if(SDL2_INCLUDE_DIR MATCHES ".framework" OR NOT SDL2MAIN_LIBRARY)
            add_library(SDL2::Main INTERFACE IMPORTED)
            target_link_libraries(SDL2::Main INTERFACE SDL2::Core)
        elseif(SDL2MAIN_LIBRARY)
            # MinGW requires that the mingw32 library is specified before the
            # libSDL2main.a static library when linking.
            # The SDL2::MainInternal target is used internally to make sure that
            # CMake respects this condition.
            add_library(SDL2::MainInternal INTERFACE IMPORTED)
            target_link_libraries(SDL2::MainInternal INTERFACE "${SDL2MAIN_LIBRARY}")
            target_link_libraries(SDL2::MainInternal INTERFACE SDL2::Core)

            add_library(SDL2::Main INTERFACE IMPORTED)

            if(MINGW)
                # MinGW needs an additional link flag '-mwindows' and link to mingw32
                #target_link_options(SDL2::Main INTERFACE "mingw32" "-mwindows")
            endif()

            target_link_libraries(SDL2::Main INTERFACE SDL2::MainInternal)
        endif()

    endif()
endif()
