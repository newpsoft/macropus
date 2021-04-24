if (BUILD_TESTING)
	enable_testing(true)
	include(CTest)

	if (TARGET tst_Macropus)
		add_test(tst_Macropus tst_Macropus)
	endif (TARGET tst_Macropus)

	set(CTEST_PROJECT_NAME "Macropus")
	set(CTEST_SOURCE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
	set(CTEST_BINARY_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}")
endif (BUILD_TESTING)
