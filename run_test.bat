@echo off
flutter test --verbose > error_verbose.txt 2>&1
notepad error_verbose.txt
