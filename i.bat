@echo ---------------------------------------------------------
@echo Copying base ROM (mother3.gba) to new test ROM (test.gba)
@echo ---------------------------------------------------------
@echo.
@copy mother3j.gba test.gba
@echo.
@echo.
@echo ---------------------------------------------------------
@echo Compiling .asm files and inserting all new data files
@echo ---------------------------------------------------------
@echo.
@xkas test.gba m3hack.asm
@echo.
@echo.
@echo COMPLETE!
@echo.
@PAUSE