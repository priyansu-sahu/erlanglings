@echo off
rem Windows wrapper: `erlanglings list`, `erlanglings run 05`, ...
rem Requires Erlang/OTP on PATH (escript.exe). Install from https://www.erlang.org/downloads
rem or `winget install Erlang.ErlangOTP`.
escript "%~dp0erlanglings" %*
