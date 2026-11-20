
REM (╯°□°）╯︵ ┻━┻
REM Settings for Windows to be able to run VirtualBox with Linux :-)
REM ¯\_(ツ)_/¯

@echo off

REM ============================================================
REM Disable Virtualization-Based Security (VBS) / Device Guard
REM ============================================================

REM Disable System Guard
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\SystemGuard" /v Enabled /t REG_DWORD /d 0 /f

REM Disable Virtualization-Based Security (VBS)
reg add "HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard" /v EnableVirtualizationBasedSecurity /t REG_DWORD /d 0 /f

REM Disable Credential Guard configuration
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v LsaCfgFlags /t REG_DWORD /d 0 /f


REM ============================================================
REM Prevent Windows hypervisor and Virtual Secure Mode from
REM starting during boot
REM ============================================================

REM Disable Hyper-V hypervisor launch at boot
bcdedit.exe /set hypervisorlaunchtype off

REM Disable Virtual Secure Mode (VSM) launch at boot
bcdedit.exe /set vsmlaunchtype Off


REM ============================================================
REM Disable Windows virtualization optional features
REM ============================================================

REM Disable Microsoft Hyper-V and its components
dism /online /disable-feature /featurename:Microsoft-Hyper-V-All /norestart

REM Disable Virtual Machine Platform (used by WSL2 and other virtualization)
dism /online /disable-feature /featurename:VirtualMachinePlatform /norestart

REM Disable Windows Hypervisor Platform
dism /online /disable-feature /featurename:HypervisorPlatform /norestart


REM ============================================================
REM A reboot is required for the changes above to take effect
REM ============================================================

