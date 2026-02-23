@echo off
setlocal enabledelayedexpansion
set "APP_HOME=%~dp0"
set "APP_HOME=!APP_HOME:~0,-1!"
set "CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar"

if exist "%JAVA_HOME%\bin\java.exe" (
    set JAVA_EXE=%JAVA_HOME%\bin\java.exe
) else (
    set JAVA_EXE=java.exe
)

"%JAVA_EXE%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*
