:: build nectcdf-cxx4 first
::
rem set NC_BUILD_TYPE=Release
rem mkdir %SRC_DIR%\netcdf-cxx4\build
rem cd %SRC_DIR%\netcdf-cxx4\build
rem cmake -G "Visual Studio 15 2017 Win64" ^
rem     -DBUILD_SHARED_LIBS=OFF ^
rem     -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
rem     -DCMAKE_LIBRARY_PATH="%LIBRARY_LIB%" ^
rem     -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
rem     -DNETCDF_LIB_NAME="netcdf" ^
rem     -DHDF5_LIB_NAME="hdf5" ^
rem     %SRC_DIR%\netcdf-cxx4
rem if errorlevel 1 exit \b 1
rem cmake --build . --config %NC_BUILD_TYPE%
rem if errorlevel 1 exit \b 1
rem cmake --build . --config %NC_BUILD_TYPE% --target install
rem if errorlevel 1 exit \b 1

:: workaround for bug in win-64/boost-1.73.0-py38_11
if not exist "%LIBRARY_PREFIX%\include\boost\python.hpp" (
    if exist "%LIBRARY_PREFIX%\include\boost\python\python.hpp" (
        copy "%LIBRARY_PREFIX%\include\boost\python\python.hpp" "%LIBRARY_PREFIX%\include\boost"
    )
)
:: now build escript
::
cd %SRC_DIR%\escript
call scons -j%CPU_COUNT% ^
    options_file="scons\templates\windows_msvc141_options.py" ^
    compressed_files=0 ^
    boost_prefix=%LIBRARY_INC%,%LIBRARY_LIB% ^
    pythonlibpath=%LIBRARY_LIB% ^
    prefix="%PREFIX%" ^
    netcdf="no" ^
    build_dir="%BUILD_PREFIX%\escript_build" ^
    build_full
if errorlevel 1 exit \b 1

:: type config.log
copy /y %SRC_DIR%\escript\LICENSE %SRC_DIR%\LICENSE
copy /y %PREFIX%\esys %SP_DIR%\esys
copy /y %BUILD_PREFIX%\escript_build\scripts\release_sanity.py %TEMP%\release_sanity.py
