@ECHO OFF

REM Set paths
SET SPHINXBUILD=sphinx-build
SET SOURCEDIR=.
SET BUILDDIR=_build

REM Build the docs
%SPHINXBUILD% -b html %SOURCEDIR% %BUILDDIR%\html
IF ERRORLEVEL 1 EXIT /b %ERRORLEVEL%

ECHO.
ECHO Build finished. The HTML pages are in %BUILDDIR%\html.
