#[=======================================================================[.rst:

Copyright 2019 Amine Ben Hassouna <amine.benhassouna@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-------
FindVNC
-------

Locate the LibVNCServer and LibVNCClient libraries

This module defines the following 'IMPORTED' target:

::

  VNC::Server
    The LibVNCServer library, if found.

  VNC::Client
    The LibVNCClient library, if found.



This module will set the following variables in your project:

::

  LIBVNCSERVER_LIBRARIES
    The name of the LibVNCServer library to link against

  LIBVNCSERVER_INCLUDE_DIRS
    Where to find the LibVNCServer headers

  LIBVNCSERVER_FOUND
    If false, do not try to link against LibVNCServer

  LIBVNCCLIENT_LIBRARIES
    The name of the LibVNCClient library to link against

  LIBVNCCLIENT_INCLUDE_DIRS
    Where to find the LibVNCClient headers

  LIBVNCCLIENT_FOUND
    If false, do not try to link against LibVNCClient

  LIBVNCSERVER_VERSION_STRING
    Human-readable string containing the version of LibVNCServer/LibVNCClient



This module responds to the following cache variables:

::

  LIBVNCSERVER_PATH
    Set a custom LibVNCServer/LibVNCClient library path (default: empty)

  LIBVNCSERVER_NO_DEFAULT_PATH
    Disable search LibVNCServer/LibVNCClient library in default path.
      If LIBVNCSERVER_PATH (default: ON)
      Else (default: OFF)

  LIBVNCSERVER_INCLUDE_DIR
    LibVNCServer/LibVNCClient headers path.

  LIBVNCSERVER_LIBRARY
    LibVNCServer library (.dll, .so, .a, etc) path.

  LIBVNCCLIENT_LIBRARY
    LibVNCClient library (.dll, .so, .a, etc) path.

#]=======================================================================]

# Define options for searching LibVNCServer/LibVNCClient library in a custom path
set(LIBVNCSERVER_PATH "" CACHE STRING "Custom LibVNCServer/LibVNCClient library path")

set(_LIBVNCSERVER_NO_DEFAULT_PATH OFF)
if(LIBVNCSERVER_PATH)
  set(_LIBVNCSERVER_NO_DEFAULT_PATH ON)
endif()

set(LIBVNCSERVER_NO_DEFAULT_PATH ${_LIBVNCSERVER_NO_DEFAULT_PATH}
    CACHE BOOL "Disable search LibVNCServer/LibVNCClient library in default path")
unset(_LIBVNCSERVER_NO_DEFAULT_PATH)

set(LIBVNCSERVER_NO_DEFAULT_PATH_CMD)
if(LIBVNCSERVER_NO_DEFAULT_PATH)
  set(LIBVNCSERVER_NO_DEFAULT_PATH_CMD NO_DEFAULT_PATH)
endif()

# Search for the LibVNCServer/LibVNCClient include directory
find_path(LIBVNCSERVER_INCLUDE_DIR rfb/rfb.h
  HINTS ${LIBVNCSERVER_NO_DEFAULT_PATH_CMD}
  PATH_SUFFIXES include
  PATHS ${LIBVNCSERVER_PATH}
  DOC "Where the LibVNCServer/LibVNCClient headers can be found"
)

# Search for the LibVNCServer library
find_library(LIBVNCSERVER_LIBRARY
  NAMES vncserver
  HINTS ${LIBVNCSERVER_NO_DEFAULT_PATH_CMD}
  PATH_SUFFIXES lib
  PATHS ${LIBVNCSERVER_PATH}
  DOC "Where the LibVNCServer library can be found"
)

set(LIBVNCSERVER_LIBRARIES ${LIBVNCSERVER_LIBRARY})
set(LIBVNCSERVER_INCLUDE_DIRS ${LIBVNCSERVER_INCLUDE_DIR})


# Search for the LibVNCClient library
find_library(LIBVNCCLIENT_LIBRARY
  NAMES vncclient
  HINTS ${LIBVNCSERVER_NO_DEFAULT_PATH_CMD}
  PATH_SUFFIXES lib
  PATHS ${LIBVNCSERVER_PATH}
  DOC "Where the LibVNCClient library can be found"
)

set(LIBVNCCLIENT_LIBRARIES ${LIBVNCCLIENT_LIBRARY})
set(LIBVNCCLIENT_INCLUDE_DIRS ${LIBVNCSERVER_INCLUDE_DIR})


# Read LibVNCServer/LibVNCClient version
if(LIBVNCSERVER_INCLUDE_DIR AND EXISTS "${LIBVNCSERVER_INCLUDE_DIR}/rfb/rfbconfig.h")
  file(STRINGS "${LIBVNCSERVER_INCLUDE_DIR}/rfb/rfbconfig.h" LIBVNCSERVER_VERSION_LINE REGEX "^#define[ \t]+LIBVNCSERVER_VERSION[ \t]+\"[0-9]+\.[0-9]+\.[0-9]+\"$")
  string(REGEX REPLACE "^#define[ \t]+LIBVNCSERVER_VERSION[ \t]+\"([0-9]+\.[0-9]+\.[0-9]+)\"$" "\\1" LIBVNCSERVER_VERSION_STRING "${LIBVNCSERVER_VERSION_LINE}")
endif()

include(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibVNCServer
                                  REQUIRED_VARS LIBVNCSERVER_LIBRARIES LIBVNCSERVER_INCLUDE_DIRS
                                  VERSION_VAR LIBVNCSERVER_VERSION_STRING)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibVNCClient
                                  REQUIRED_VARS LIBVNCCLIENT_LIBRARIES LIBVNCCLIENT_INCLUDE_DIRS
                                  VERSION_VAR LIBVNCSERVER_VERSION_STRING)

mark_as_advanced(LIBVNCSERVER_PATH
                 LIBVNCSERVER_NO_DEFAULT_PATH
                 LIBVNCSERVER_LIBRARY
                 LIBVNCCLIENT_LIBRARY
                 LIBVNCSERVER_INCLUDE_DIR)


# VNC:: targets
if(LIBVNCSERVER_FOUND)
  # VNC::Server target
  if(LIBVNCSERVER_LIBRARY AND NOT TARGET VNC::Server)
    add_library(VNC::Server UNKNOWN IMPORTED)
    set_target_properties(VNC::Server PROPERTIES
                          IMPORTED_LOCATION "${LIBVNCSERVER_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${LIBVNCSERVER_INCLUDE_DIR}")
  endif()
endif()

if(LIBVNCCLIENT_FOUND)
  # VNC::Client target
  if(LIBVNCCLIENT_LIBRARY AND NOT TARGET VNC::Client)
    add_library(VNC::Client UNKNOWN IMPORTED)
    set_target_properties(VNC::Client PROPERTIES
                          IMPORTED_LOCATION "${LIBVNCCLIENT_LIBRARY}"
                          INTERFACE_INCLUDE_DIRECTORIES "${LIBVNCSERVER_INCLUDE_DIR}")
  endif()
endif()
