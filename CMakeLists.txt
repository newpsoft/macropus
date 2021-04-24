cmake_minimum_required(VERSION 3.5)

# Require Qt and C++
set(MCR_NOEXTRAS OFF CACHE BOOL "Do not include extra functionality, or any C++." FORCE)
set(MCR_NOQT OFF CACHE BOOL "Do not include any QT functionality." FORCE)

# Defines LIBMACRO_TARGET
add_subdirectory(libmacro)
# Defines MCR_VER, MCR_VER_MAJ, MCR_VER_MIN, MCR_DEBUG, MCR_PLATFORM
include(libmacro/libmacro.cmake)
# Defines GIT_EXECUTABLE, GIT_REVISION, GIT_BRANCH
include(libmacro/git.cmake)

if (windows AND CMAKE_BUILD_TYPE MATCHES "^[Rr]el" OR CMAKE_BUILD_TYPE MATCHES "^[Mm]in")
	option(BUILD_SIGNED "Sign an elevated executable." ON)
else ()
	option(BUILD_SIGNED "Sign an elevated executable." OFF)
endif ()

project(Macropus VERSION ${MCR_VER}.${GIT_REVISION} HOMEPAGE_URL "https://sites.google.com/view/newparadigmsoftware" LANGUAGES C CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
include_directories(include)
include_directories(libmacro)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 COMPONENTS Core Quick Widgets Qml Svg Test
	QuickTest REQUIRED)
# TODO Thread optional with event loop
find_package(Threads REQUIRED)
find_package(OpenSSL REQUIRED)

# Windows resolve libmacro at runtime
if (windows)
	set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
	set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
	set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
	set_target_properties(libmacro
		PROPERTIES
		ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
		LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
		RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
	)
	if (TARGET tst_libmacro)
		set_target_properties(tst_libmacro
			PROPERTIES
			ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
			LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
		)
	endif (TARGET tst_libmacro)
	if (TARGET tst_intercept)
		set_target_properties(tst_intercept
			PROPERTIES
			ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
			LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
			RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
		)
	endif (TARGET tst_intercept)
endif (windows)
set(COMMON_DEFINES
	-DVERSION=${MCR_VER}.${GIT_REVISION}
	-DGIT_BRANCH=${GIT_BRANCH}
	-DGIT_REVISION=${GIT_REVISION}
	"-DPWD=${CMAKE_CURRENT_SOURCE_DIR}"
	)
# Base sources
file(GLOB COMMON_SRC
	src/*.cpp
	src/${MCR_PLATFORM}/*.cpp
	)
file(GLOB_RECURSE COMMON_HEADERS include/*.h)
if (MCR_DEBUG)
	file(GLOB_RECURSE QML_SOURCES LIST_DIRECTORIES false qml/*.qml qml/*.js qml/*qmldir)
endif (MCR_DEBUG)
set(COMMON_LIBRARIES mcr::Libmacro Qt5::Core Qt5::Quick
	Qt5::Qml Qt5::Svg)
# Debug with live files, but we need icons and qtquickcontrols2.conf resources.
if (MCR_DEBUG)
	file(GLOB APP_SRC "app/main.cpp" qtquickcontrols2.qrc)
else (MCR_DEBUG)
	file(GLOB APP_SRC "app/main.cpp" qml.qrc)
endif (MCR_DEBUG)

# config files
if (windows)
	# Executable option for windowed applications
	set(WIN32_FLAG "WIN32")
	set(RC_OUT "${CMAKE_CURRENT_BINARY_DIR}/macropus.rc")
	configure_file(macropus.rc.in "${RC_OUT}" @ONLY)
	file(GLOB MACROPUS_EXTRA_FILES "${RC_OUT}")
else ()
	set(WIN32_FLAG "")
	set(MACROPUS_EXTRA_FILES "")
endif ()

# Macropus target
add_executable(${PROJECT_NAME} ${WIN32_FLAG} ${APP_SRC}
	${COMMON_SRC} ${COMMON_HEADERS} ${MACROPUS_EXTRA_FILES}
	${QML_SOURCES})
target_compile_definitions(${PROJECT_NAME} PRIVATE ${COMMON_DEFINES}
	$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE ${COMMON_LIBRARIES})
add_dependencies(${PROJECT_NAME} mcr::Libmacro)

if (windows AND BUILD_SIGNED)
	find_program(SignTool SignTool.exe)
	# Able to sign with testing cert
	if (NOT "${SignTool}" STREQUAL "")
		target_link_options(${PROJECT_NAME} PRIVATE "/MANIFESTUAC:level=\"requireAdministrator\" uiAccess=\"false\"")
		add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
			COMMAND "${CMAKE_COMMAND}" -E
				env "${SignTool}" sign
					/f "${CMAKE_CURRENT_SOURCE_DIR}/newpsoft-unnofficial.pfx"
					\"$<TARGET_FILE:${PROJECT_NAME}>\"
			COMMENT "Signing ${PROJECT_NAME} executable with testing signature newpsoft-unnofficial.pfx..."
			)
	endif ()
endif (windows AND BUILD_SIGNED)

file(GLOB_RECURSE QML_TEST_ALL test/*.qml test/*.js)
# Qt testing libraries are only available for release builds
if (NOT MCR_DEBUG)
	# Testing targets; Require QUICK_TEST_SOURCE_DIR = find tst_*.qml in source
	# MACROPUS_NOQRC = QML files are not in a qrc file, load from local files.
	add_executable(tst_Macropus ${WIN32_FLAG}
		${COMMON_SRC} ${COMMON_HEADERS} test/tst_Macropus.h
		test/tst_Macropus.cpp ${QML_TEST_ALL} qtquickcontrols2.qrc)
	target_compile_definitions(tst_Macropus PRIVATE ${COMMON_DEFINES}
		$<$<CONFIG:RelWithDebInfo>:QT_QML_DEBUG>
		"QUICK_TEST_SOURCE_DIR=\"${CMAKE_CURRENT_SOURCE_DIR}/test\""
		MACROPUS_NOQRC
		)
	target_link_libraries(tst_Macropus PUBLIC ${COMMON_LIBRARIES} Qt5::QuickTest)
	add_dependencies(tst_Macropus mcr::Libmacro)
endif (NOT MCR_DEBUG)
# Trial, design, and manual test center
add_executable(play ${WIN32_FLAG}
	${COMMON_SRC} ${COMMON_HEADERS} test/play.cpp
	${QML_TEST_ALL} qtquickcontrols2.qrc)
target_compile_definitions(play PRIVATE ${COMMON_DEFINES}
	$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
	MACROPUS_NOQRC
	)
target_link_libraries(play PUBLIC ${COMMON_LIBRARIES} Qt5::QuickTest)
add_dependencies(play mcr::Libmacro)

# Make files visible in editor, and use astyle in-editor.
add_custom_target(MACROPUS_DISTFILES SOURCES
	macropus.astylerc
	style
	todo.txt
	.github/workflows/build.yml
	)
add_custom_target(TEST_ASSETS SOURCES
	test/assets/serialized.mcr
	test/assets/optimized.mcr
	)

# Windows package everything to base directory, otherwise lib is separate.
if (windows)
	install(TARGETS ${PROJECT_NAME} DESTINATION /)
else ()
	install(TARGETS ${PROJECT_NAME} DESTINATION bin)
endif (windows)

# Option to build tests
include(coverage.cmake)
# Platform variables and MCR_DEBUG required from libmacro.cmake
# Requires DEPLOYQT_TARGET
set(DEPLOYQT_TARGET ${PROJECT_NAME})
set(QMLDIR "${CMAKE_CURRENT_SOURCE_DIR}/qml")
include(libmacro/deployqt.cmake)
include(cpack.cmake)
