@echo off

title EAC BootUnstrapper (EASY-ANTI Cheat workaround for Star Citizen Private Servers) -by mr.Asterisk_CEO inspired by Lug -Helper
setlocal enabledelayedexpansion

REM Get/set directory paths
REM Note: Adjust the wine_prefix accordingly if you are running this on Windows without Wine.

set "wine_prefix=C:\path\to\wine\prefix"

REM Set the EAC directory path and hosts modification
set "eac_dir=%wine_prefix%\drive_c\users\%USERNAME%\AppData\Roaming\EasyAntiCheat"
set "eac_hosts=127.0.0.1 modules-cdn.eac-prod.on.epicgames.com"

REM Check if the EAC workaround has already been fully applied
findstr /C:"%eac_hosts% #Star Citizen EAC workaround" %SystemRoot%\System32\drivers\etc\hosts >nul
set "hosts_exist=!errorlevel!"

if %hosts_exist% equ 0 (
    REM Hosts workaround is in place
    REM Check if we still need to delete the EAC directory
    if exist "%eac_dir%" (
        set "delete_eac_dir=true"
        set "eac_message=Your hosts file is already modified with the Easy Anti-Cheat workaround. The following directory must still be deleted: %eac_dir%"
    )
) else (
    REM Hosts workaround is needed
    set "apply_eac_hosts=true"
    set "eac_message=The following entry will be added to your hosts file: %eac_hosts%\n\nTo revert these changes, delete the marked EAC workaround line in your hosts file and relaunch the game.\nDo you want to proceed?"

    REM Check if we also need to delete the EAC directory
    if exist "%eac_dir%" (
        set "delete_eac_dir=true"
        set "eac_message=!eac_message!\n\nThe following directory will be deleted: %eac_dir%"
    )
)

REM Finish up the message
set "eac_message=!eac_message!\n\nEasy Anti-Cheat workaround has been deployed!"

REM Check if the EAC workaround has already been fully applied
if !apply_eac_hosts! equ true (
    message info !eac_message!
    exit /b 0
)

REM Display the message
set /P "=!eac_message! (Y/N): " <nul
set "choice="
choice /c YN /n /m ""
if !errorlevel! equ 1 (
    REM Apply the hosts workaround if needed
    if !apply_eac_hosts! equ true (
        debug_print continue "Editing hosts file..."
        REM Try to modify hosts file
        echo.!eac_hosts! #Star Citizen EAC workaround>>%SystemRoot%\System32\drivers\etc\hosts
        if !errorlevel! equ 1 (
            message error "Authentication failed or there was an error modifying hosts file.\nSee terminal for more information.\n\nReturning to main menu."
            exit /b 0
        )
    )

    REM Delete the EAC directory if it exists
    if !delete_eac_dir! equ true (
        debug_print continue "Deleting !eac_dir!..."
        rmdir /s /q "!eac_dir!"
    )

    message info "Easy Anti-Cheat workaround has been deployed!"
)

exit /b 0
