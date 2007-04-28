
# determine the compiler to use for C programs
# NOTE, a generator may set CMAKE_C_COMPILER before
# loading this file to force a compiler.
# use environment variable CCC first if defined by user, next use 
# the cmake variable CMAKE_GENERATOR_CC which can be defined by a generator
# as a default compiler

IF(NOT CMAKE_C_COMPILER)
  SET(CMAKE_CXX_COMPILER_INIT NOTFOUND)

  # prefer the environment variable CC
  IF($ENV{CC} MATCHES ".+")
    GET_FILENAME_COMPONENT(CMAKE_C_COMPILER_INIT $ENV{CC} PROGRAM PROGRAM_ARGS CMAKE_C_FLAGS_ENV_INIT)
    IF(CMAKE_C_FLAGS_ENV_INIT)
      SET(CMAKE_C_COMPILER_ARG1 "${CMAKE_C_FLAGS_ENV_INIT}" CACHE STRING "First argument to C compiler")
    ENDIF(CMAKE_C_FLAGS_ENV_INIT)
    IF(EXISTS ${CMAKE_C_COMPILER_INIT})
    ELSE(EXISTS ${CMAKE_C_COMPILER_INIT})
      MESSAGE(FATAL_ERROR "Could not find compiler set in environment variable CC:\n$ENV{CC}.") 
    ENDIF(EXISTS ${CMAKE_C_COMPILER_INIT})
  ENDIF($ENV{CC} MATCHES ".+")

  # next try prefer the compiler specified by the generator
  IF(CMAKE_GENERATOR_CC) 
    IF(NOT CMAKE_C_COMPILER_INIT)
      SET(CMAKE_C_COMPILER_INIT ${CMAKE_GENERATOR_CC})
    ENDIF(NOT CMAKE_C_COMPILER_INIT)
  ENDIF(CMAKE_GENERATOR_CC)

  # finally list compilers to try
  IF(CMAKE_C_COMPILER_INIT)
    SET(CMAKE_C_COMPILER_LIST ${CMAKE_C_COMPILER_INIT})
  ELSE(CMAKE_C_COMPILER_INIT)
    SET(CMAKE_C_COMPILER_LIST gcc cc cl bcc xlc)
  ENDIF(CMAKE_C_COMPILER_INIT)

  # Find the compiler.
  FIND_PROGRAM(CMAKE_C_COMPILER NAMES ${CMAKE_C_COMPILER_LIST} DOC "C compiler")
  IF(CMAKE_C_COMPILER_INIT AND NOT CMAKE_C_COMPILER)
    SET(CMAKE_C_COMPILER "${CMAKE_C_COMPILER_INIT}" CACHE FILEPATH "C compiler" FORCE)
  ENDIF(CMAKE_C_COMPILER_INIT AND NOT CMAKE_C_COMPILER)
ENDIF(NOT CMAKE_C_COMPILER)
MARK_AS_ADVANCED(CMAKE_C_COMPILER)  
GET_FILENAME_COMPONENT(COMPILER_LOCATION "${CMAKE_C_COMPILER}"
  PATH)

FIND_PROGRAM(CMAKE_AR NAMES ar PATHS ${COMPILER_LOCATION} )

FIND_PROGRAM(CMAKE_RANLIB NAMES ranlib)
IF(NOT CMAKE_RANLIB)
   SET(CMAKE_RANLIB : CACHE INTERNAL "noop for ranlib")
ENDIF(NOT CMAKE_RANLIB)
MARK_AS_ADVANCED(CMAKE_RANLIB)

# Build a small source file to identify the compiler.
IF(${CMAKE_GENERATOR} MATCHES "Visual Studio")
  SET(CMAKE_C_COMPILER_ID_RUN 1)
  SET(CMAKE_C_PLATFORM_ID "Windows")

  # TODO: Set the compiler id.  It is probably MSVC but
  # the user may be using an integrated Intel compiler.
  # SET(CMAKE_C_COMPILER_ID "MSVC")
ENDIF(${CMAKE_GENERATOR} MATCHES "Visual Studio")
IF(NOT CMAKE_C_COMPILER_ID_RUN)
  SET(CMAKE_C_COMPILER_ID_RUN 1)

  # Try to identify the compiler.
  SET(CMAKE_C_COMPILER_ID)
  INCLUDE(${CMAKE_ROOT}/Modules/CMakeDetermineCompilerId.cmake)
  CMAKE_DETERMINE_COMPILER_ID(C ${CMAKE_ROOT}/Modules/CMakeCCompilerId.c)

  # Set old compiler and platform id variables.
  IF("${CMAKE_C_COMPILER_ID}" MATCHES "GNU")
    SET(CMAKE_COMPILER_IS_GNUCC 1)
  ENDIF("${CMAKE_C_COMPILER_ID}" MATCHES "GNU")
  IF("${CMAKE_C_PLATFORM_ID}" MATCHES "MinGW")
    SET(CMAKE_COMPILER_IS_MINGW 1)
  ELSEIF("${CMAKE_C_PLATFORM_ID}" MATCHES "Cygwin")
    SET(CMAKE_COMPILER_IS_CYGWIN 1)
  ENDIF("${CMAKE_C_PLATFORM_ID}" MATCHES "MinGW")
ENDIF(NOT CMAKE_C_COMPILER_ID_RUN)

# configure variables set in this file for fast reload later on
CONFIGURE_FILE(${CMAKE_ROOT}/Modules/CMakeCCompiler.cmake.in 
               "${CMAKE_PLATFORM_ROOT_BIN}/CMakeCCompiler.cmake" IMMEDIATE)
MARK_AS_ADVANCED(CMAKE_AR)

SET(CMAKE_C_COMPILER_ENV_VAR "CC")
