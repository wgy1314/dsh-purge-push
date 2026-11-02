@echo off
chcp 65001 >nul 2>&1
setlocal EnableExtensions DisableDelayedExpansion
title DSH 插件一键安装
cd /d "%~dp0"

echo.
echo   ============================================================
echo      DeepSeek Harness 插件一键安装
echo      把本 bat 放进解压出来的插件文件夹，双击即可
echo   ============================================================
echo.

REM ---------- 参数 ----------
set "ROOT="
set "APPDIR="
set "NODE="
set "EXTRA="
:parse_args
if "%~1"=="" goto args_done
if /i "%~1"=="-restart"   (set "EXTRA=%EXTRA% --restart"       & shift & goto parse_args)
if /i "%~1"=="-norestart" (shift & goto parse_args)
if /i "%~1"=="-nobuild"   (set "EXTRA=%EXTRA% --nobuild"       & shift & goto parse_args)
if /i "%~1"=="-root"      (set "ROOT=%~2"                       & shift & shift & goto parse_args)
if /i "%~1"=="-app"       (set "APPDIR=%~2"                     & shift & shift & goto parse_args)
if /i "%~1"=="-profile"   (set "EXTRA=%EXTRA% --profile %~2"    & shift & shift & goto parse_args)
if /i "%~1"=="-h"         goto usage
if /i "%~1"=="-help"      goto usage
set "ROOT=%~1"
shift
goto parse_args
:args_done

REM ---------- 定位 DeepSeek Harness ----------
if defined APPDIR call :use_dir "%APPDIR%"
if not defined NODE call :use_dir "%DSH_APP_DIR%"

set "SCAN=%TEMP%\dsh-appscan-%RANDOM%%RANDOM%.txt"
if not defined NODE powershell -NoProfile -NonInteractive -Command "$o=New-Object System.Collections.Generic.List[string]; $p=Get-Process -Name 'DeepSeek Harness' -ErrorAction SilentlyContinue; if($p){$o.Add((Split-Path $p[0].Path -Parent))}; $k=@('HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'); foreach($i in (Get-ItemProperty $k -ErrorAction SilentlyContinue)){ if($i.DisplayName -like '*DeepSeek Harness*'){ if($i.DisplayIcon){$o.Add((Split-Path ($i.DisplayIcon -replace ',\d+$','') -Parent))} elseif($i.InstallLocation){$o.Add($i.InstallLocation)} }}; $o" >"%SCAN%" 2>nul
if not defined NODE if exist "%SCAN%" for /f "usebackq delims=" %%A in ("%SCAN%") do if not defined NODE call :use_dir "%%~A"
if exist "%SCAN%" del /f /q "%SCAN%" >nul 2>&1
if not defined NODE call :use_dir "%LOCALAPPDATA%\Programs\deepseek-harness"
if not defined NODE call :use_dir "%LOCALAPPDATA%\Programs\DeepSeek Harness"
if not defined NODE call :use_dir "%ProgramFiles%\DeepSeek Harness"
if not defined NODE goto no_app

REM ---------- 插件根目录 ----------
if not defined ROOT set "ROOT=%~dp0."

REM ---------- 释放安装核心 ----------
set "JS=%TEMP%\dsh-plugin-install-%RANDOM%%RANDOM%.mjs"
set "B64=%TEMP%\dsh-plugin-install-%RANDOM%%RANDOM%.b64"
>"%B64%" echo -----BEGIN CERTIFICATE-----
>>"%B64%" echo IyEvdXNyL2Jpbi9lbnYgbm9kZQovKioKICogRFNIIOaPkuS7tuS4gOmUruWuieijheaguOW/g+OA
>>"%B64%" echo ggogKiDnlLEgaW5zdGFsbC1wbHVnaW4uYmF0IOmHiuaUvuWIsCAlVEVNUCUg5ZCO6LCD55So77yM
>>"%B64%" echo 5Lmf5Y+v55u05o6l5omL6LeR77yaCiAqICAgbm9kZSBpbnN0YWxsLXBsdWdpbi5tanMgLS1yb290
>>"%B64%" echo IDzop6Pljovlh7rnmoTmj5Lku7bnm67lvZU+IFstLWFwcCA8RFNIIOWuieijheebruW9lT5dCiAq
>>"%B64%" echo ICAgICAgICAgICAgICAgICAgICAgICAgICAgIFstLXByb2ZpbGUgZGVza3RvcF0gWy0tcmVzdGFy
>>"%B64%" echo dF0gWy0tbm9idWlsZF0KICovCmltcG9ydCBjcnlwdG8gZnJvbSAnbm9kZTpjcnlwdG8nOwppbXBv
>>"%B64%" echo cnQgZnMgZnJvbSAnbm9kZTpmcyc7CmltcG9ydCBvcyBmcm9tICdub2RlOm9zJzsKaW1wb3J0IHBh
>>"%B64%" echo dGggZnJvbSAnbm9kZTpwYXRoJzsKaW1wb3J0IHsgc3Bhd24sIHNwYXduU3luYyB9IGZyb20gJ25v
>>"%B64%" echo ZGU6Y2hpbGRfcHJvY2Vzcyc7Cgpjb25zdCBhcmd2ID0gcHJvY2Vzcy5hcmd2LnNsaWNlKDIpLm1h
>>"%B64%" echo cCgoYSkgPT4gKC9eLVtBLVphLXpdLy50ZXN0KGEpID8gYC0tJHthLnNsaWNlKDEpLnRvTG93ZXJD
>>"%B64%" echo YXNlKCl9YCA6IGEpKTsKY29uc3Qgb3B0ID0gKG5hbWUsIGZhbGxiYWNrKSA9PiB7CiAgY29uc3Qg
>>"%B64%" echo aSA9IGFyZ3YuaW5kZXhPZihgLS0ke25hbWV9YCk7CiAgcmV0dXJuIGkgPj0gMCAmJiBhcmd2W2kg
>>"%B64%" echo KyAxXSAhPT0gdW5kZWZpbmVkICYmICFhcmd2W2kgKyAxXS5zdGFydHNXaXRoKCctLScpID8gYXJn
>>"%B64%" echo dltpICsgMV0gOiBmYWxsYmFjazsKfTsKY29uc3QgZmxhZyA9IChuYW1lKSA9PiBhcmd2LmluY2x1
>>"%B64%" echo ZGVzKGAtLSR7bmFtZX1gKTsKCmNvbnN0IFBST0ZJTEUgPSBTdHJpbmcob3B0KCdwcm9maWxlJywg
>>"%B64%" echo J2Rlc2t0b3AnKSkudG9Mb3dlckNhc2UoKTsKY29uc3QgRFNIX0hPTUUgPSBwcm9jZXNzLmVudi5E
>>"%B64%" echo U0hfSE9NRSB8fCBwYXRoLmpvaW4ob3MuaG9tZWRpcigpLCAnLmRzaCcpOwpjb25zdCBQUk9GSUxF
>>"%B64%" echo X0RJUiA9IHBhdGguam9pbihEU0hfSE9NRSwgJ3Byb2ZpbGVzJywgUFJPRklMRSk7CmNvbnN0IFBM
>>"%B64%" echo VUdJTl9TVE9SRSA9IHBhdGguam9pbihEU0hfSE9NRSwgJ2RzaC1wbHVnaW5zJyk7CmNvbnN0IEpV
>>"%B64%" echo TksgPSBuZXcgU2V0KFsnbm9kZV9tb2R1bGVzJywgJy5naXQnLCAnLmdpdGh1YicsICcuaWRlYScs
>>"%B64%" echo ICcudnNjb2RlJywgJy5EU19TdG9yZScsICdUaHVtYnMuZGInXSk7Cgpjb25zdCBvdXQgPSAocyA9
>>"%B64%" echo ICcnKSA9PiBwcm9jZXNzLnN0ZG91dC53cml0ZShgJHtzfVxuYCk7CmNvbnN0IHN0ZXAgPSAocykg
>>"%B64%" echo PT4gb3V0KGBcbj09PiAke3N9YCk7CmNvbnN0IG9rID0gKHMpID0+IG91dChgICBbT0tdICR7c31g
>>"%B64%" echo KTsKY29uc3Qgbm90ZSA9IChzKSA9PiBvdXQoYCAgICAgJHtzfWApOwpjb25zdCB3YXJuID0gKHMp
>>"%B64%" echo ID0+IG91dChgICBbISFdICR7c31gKTsKZnVuY3Rpb24gZmFpbChtc2csIGhpbnQpIHsKICBvdXQo
>>"%B64%" echo YCAgW1hYXSAke21zZ31gKTsKICBpZiAoaGludCkgb3V0KGBcbiAgICAgICAke2hpbnR9YCk7CiAg
>>"%B64%" echo b3V0KCcnKTsKICBwcm9jZXNzLmV4aXQoMSk7Cn0KCmNvbnN0IHJlYWRKc29uID0gKGZpbGUpID0+
>>"%B64%" echo IEpTT04ucGFyc2UoZnMucmVhZEZpbGVTeW5jKGZpbGUsICd1dGY4JykucmVwbGFjZSgvXlx1RkVG
>>"%B64%" echo Ri8sICcnKSk7CgovKiDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAgMS4g
>>"%B64%" echo 5a6a5L2NIERlZXBTZWVrIEhhcm5lc3Mg4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
>>"%B64%" echo 4pSA4pSAICovCgpjb25zdCBUT09MUyA9IHt9OwoKZnVuY3Rpb24gaXNBcHBEaXIoZGlyKSB7CiAg
>>"%B64%" echo aWYgKCFkaXIpIHJldHVybiBmYWxzZTsKICByZXR1cm4gKAogICAgZnMuZXhpc3RzU3luYyhwYXRo
>>"%B64%" echo LmpvaW4oZGlyLCAnRGVlcFNlZWsgSGFybmVzcy5leGUnKSkgJiYKICAgIGZzLmV4aXN0c1N5bmMo
>>"%B64%" echo cGF0aC5qb2luKGRpciwgJ3Jlc291cmNlcycsICdydW50aW1lJywgJ2NsaScsICdiaW4nLCAnZHNo
>>"%B64%" echo LmNtZCcpKQogICk7Cn0KCmZ1bmN0aW9uIHBzKHNjcmlwdCkgewogIGNvbnN0IHIgPSBzcGF3blN5
>>"%B64%" echo bmMoJ3Bvd2Vyc2hlbGwuZXhlJywgWyctTm9Qcm9maWxlJywgJy1Ob25JbnRlcmFjdGl2ZScsICct
>>"%B64%" echo Q29tbWFuZCcsIHNjcmlwdF0sIHsKICAgIGVuY29kaW5nOiAndXRmOCcsCiAgICB3aW5kb3dzSGlk
>>"%B64%" echo ZTogdHJ1ZSwKICB9KTsKICByZXR1cm4gci5zdGF0dXMgPT09IDAgPyBTdHJpbmcoci5zdGRvdXQg
>>"%B64%" echo fHwgJycpIDogJyc7Cn0KCmZ1bmN0aW9uIGZpbmRBcHBEaXIoKSB7CiAgY29uc3QgY2FuZGlkYXRl
>>"%B64%" echo cyA9IFtdOwogIGNvbnN0IGFkZCA9IChwKSA9PiB7CiAgICBpZiAoIXApIHJldHVybjsKICAgIGNv
>>"%B64%" echo bnN0IGNsZWFuID0gU3RyaW5nKHApLnRyaW0oKS5yZXBsYWNlKC9eInwiJC9nLCAnJyk7CiAgICBp
>>"%B64%" echo ZiAoY2xlYW4gJiYgIWNhbmRpZGF0ZXMuaW5jbHVkZXMoY2xlYW4pKSBjYW5kaWRhdGVzLnB1c2go
>>"%B64%" echo Y2xlYW4pOwogIH07CgogIGFkZChvcHQoJ2FwcCcpKTsKICBhZGQocHJvY2Vzcy5lbnYuRFNIX0FQ
>>"%B64%" echo UF9ESVIpOwogIC8vIOiEmuacrOmAmuW4uOeUsSBEU0gg6Ieq5bim55qEIG5vZGUuZXhlIOi/kOih
>>"%B64%" echo jO+8mjxhcHA+XHJlc291cmNlc1xydW50aW1lXHByaW1hcnktcnVudGltZVxkZXBlbmRlbmNpZXNc
>>"%B64%" echo bm9kZVxiaW5cbm9kZS5leGUKICBhZGQocGF0aC5yZXNvbHZlKHBhdGguZGlybmFtZShwcm9jZXNz
>>"%B64%" echo LmV4ZWNQYXRoKSwgJy4uJywgJy4uJywgJy4uJywgJy4uJywgJy4uJywgJy4uJykpOwoKICBhZGQo
>>"%B64%" echo CiAgICBwcygKICAgICAgIihHZXQtUHJvY2VzcyAtTmFtZSAnRGVlcFNlZWsgSGFybmVzcycgLUVy
>>"%B64%" echo cm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfCBTZWxlY3QtT2JqZWN0IC1GaXJzdCAxKS5QYXRo
>>"%B64%" echo IiwKICAgICkudHJpbSgpLAogICk7CgogIGNvbnN0IHJlZyA9IHBzKAogICAgIiRrPUAoJ0hLQ1U6
>>"%B64%" echo XFxTb2Z0d2FyZVxcTWljcm9zb2Z0XFxXaW5kb3dzXFxDdXJyZW50VmVyc2lvblxcVW5pbnN0YWxs
>>"%B64%" echo XFwqJywnSEtMTTpcXFNvZnR3YXJlXFxNaWNyb3NvZnRcXFdpbmRvd3NcXEN1cnJlbnRWZXJzaW9u
>>"%B64%" echo XFxVbmluc3RhbGxcXConLCdIS0xNOlxcU29mdHdhcmVcXFdPVzY0MzJOb2RlXFxNaWNyb3NvZnRc
>>"%B64%" echo XFdpbmRvd3NcXEN1cnJlbnRWZXJzaW9uXFxVbmluc3RhbGxcXConKTsiICsKICAgICAgIkdldC1J
>>"%B64%" echo dGVtUHJvcGVydHkgJGsgLUVycm9yQWN0aW9uIFNpbGVudGx5Q29udGludWUgfCBXaGVyZS1PYmpl
>>"%B64%" echo Y3QgeyAkXy5EaXNwbGF5TmFtZSAtbGlrZSAnKkRlZXBTZWVrIEhhcm5lc3MqJyB9IHwiICsKICAg
>>"%B64%" echo ICAgIiBGb3JFYWNoLU9iamVjdCB7IGlmICgkXy5EaXNwbGF5SWNvbikgeyAkXy5EaXNwbGF5SWNv
>>"%B64%" echo biAtcmVwbGFjZSAnLFxcZCskJywnJyB9IGVsc2VpZiAoJF8uSW5zdGFsbExvY2F0aW9uKSB7IEpv
>>"%B64%" echo aW4tUGF0aCAkXy5JbnN0YWxsTG9jYXRpb24gJ0RlZXBTZWVrIEhhcm5lc3MuZXhlJyB9IH0iLAog
>>"%B64%" echo ICk7CiAgZm9yIChjb25zdCBsaW5lIG9mIHJlZy5zcGxpdCgvXHI/XG4vKSkgYWRkKGxpbmUpOwoK
>>"%B64%" echo ICBmb3IgKGNvbnN0IHJvb3Qgb2YgWwogICAgcHJvY2Vzcy5lbnYuTE9DQUxBUFBEQVRBICYmIHBh
>>"%B64%" echo dGguam9pbihwcm9jZXNzLmVudi5MT0NBTEFQUERBVEEsICdQcm9ncmFtcycpLAogICAgcHJvY2Vz
>>"%B64%" echo cy5lbnYuUHJvZ3JhbUZpbGVzLAogICAgcHJvY2Vzcy5lbnZbJ1Byb2dyYW1GaWxlcyh4ODYpJ10s
>>"%B64%" echo CiAgXSkgewogICAgaWYgKCFyb290IHx8ICFmcy5leGlzdHNTeW5jKHJvb3QpKSBjb250aW51ZTsK
>>"%B64%" echo ICAgIGZvciAoY29uc3QgbmFtZSBvZiBmcy5yZWFkZGlyU3luYyhyb290KSkgYWRkKHBhdGguam9p
>>"%B64%" echo bihyb290LCBuYW1lKSk7CiAgfQoKICBmb3IgKGNvbnN0IGMgb2YgY2FuZGlkYXRlcykgewogICAg
>>"%B64%" echo Y29uc3QgZGlyID0gYy50b0xvd2VyQ2FzZSgpLmVuZHNXaXRoKCdkZWVwc2VlayBoYXJuZXNzLmV4
>>"%B64%" echo ZScpID8gcGF0aC5kaXJuYW1lKGMpIDogYzsKICAgIGlmIChpc0FwcERpcihkaXIpKSByZXR1cm4g
>>"%B64%" echo ZGlyOwogIH0KICByZXR1cm4gbnVsbDsKfQoKLyog4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
>>"%B64%" echo 4pSA4pSA4pSA4pSAIDIuIOWumuS9jeaPkuS7tuagueebruW9lSDilIDilIDilIDilIDilIDilIDi
>>"%B64%" echo lIDilIDilIDilIDilIDilIDilIAgKi8KCmZ1bmN0aW9uIHJlYWRNYW5pZmVzdChkaXIpIHsKICB0
>>"%B64%" echo cnkgewogICAgcmV0dXJuIHJlYWRKc29uKHBhdGguam9pbihkaXIsICdwYWNrYWdlLmpzb24nKSk7
>>"%B64%" echo CiAgfSBjYXRjaCB7CiAgICByZXR1cm4gbnVsbDsKICB9Cn0KCmZ1bmN0aW9uIHJlc29sdmVQbHVn
>>"%B64%" echo aW5Sb290KHN0YXJ0KSB7CiAgY29uc3QgYmFzZSA9IHBhdGgucmVzb2x2ZShzdGFydCk7CiAgaWYg
>>"%B64%" echo KHJlYWRNYW5pZmVzdChiYXNlKSkgcmV0dXJuIGJhc2U7CiAgaWYgKCFmcy5leGlzdHNTeW5jKGJh
>>"%B64%" echo c2UpKSBmYWlsKGDot6/lvoTkuI3lrZjlnKjvvJoke2Jhc2V9YCk7CgogIGNvbnN0IGtpZHMgPSBm
>>"%B64%" echo cwogICAgLnJlYWRkaXJTeW5jKGJhc2UsIHsgd2l0aEZpbGVUeXBlczogdHJ1ZSB9KQogICAgLmZp
>>"%B64%" echo bHRlcigoZSkgPT4gZS5pc0RpcmVjdG9yeSgpICYmICFKVU5LLmhhcyhlLm5hbWUpKQogICAgLm1h
>>"%B64%" echo cCgoZSkgPT4gcGF0aC5qb2luKGJhc2UsIGUubmFtZSkpCiAgICAuZmlsdGVyKChkKSA9PiByZWFk
>>"%B64%" echo TWFuaWZlc3QoZCkpOwoKICBpZiAoa2lkcy5sZW5ndGggPT09IDEpIHJldHVybiBraWRzWzBdOwog
>>"%B64%" echo IGlmIChraWRzLmxlbmd0aCA+IDEpIHsKICAgIGZhaWwoCiAgICAgICfmlofku7blpLnph4zmnInl
>>"%B64%" echo pJrku70gcGFja2FnZS5qc29u77yM5peg5rOV56Gu5a6a6KaB6KOF5ZOq5LiqJywKICAgICAgYOaK
>>"%B64%" echo iiBiYXQg5ouW5Yiw55uu5qCH5o+S5Lu25paH5Lu25aS56YeM5YaN6L+Q6KGM77yM5oiW55SoIC1S
>>"%B64%" echo b290ICI855uu5b2VPiIg5oyH5a6a77yaXG4gICAgICAgJHtraWRzLmpvaW4oJ1xuICAgICAgICcp
>>"%B64%" echo fWAsCiAgICApOwogIH0KICBmYWlsKCfmsqHmib7liLAgcGFja2FnZS5qc29uIOKAlOKAlCDov5nk
>>"%B64%" echo uI3mmK/kuIDkuKogRFNIIOaPkuS7tuebruW9lScsICflpoLmnpzlroPov5jlnKggcmFyL3ppcCDp
>>"%B64%" echo h4zvvIzor7flhYjop6Pljovlh7rmlofku7blpLnvvJvmraPluLjnm67lvZXph4zlupTmnIkgcGFj
>>"%B64%" echo a2FnZS5qc29uIC8gY29yZGlzLnBhdGNoLnltbCAvIGxpYuOAgicpOwp9CgovKiDilIDilIDilIDi
>>"%B64%" echo lIDilIDilIDilIDilIDilIDilIDilIDilIDilIAgMy4g5bel5YW377ya5aSN5Yi2IC8gQk9NIC8g
>>"%B64%" echo 5pGY6KaBIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqLwoKZnVuY3Rp
>>"%B64%" echo b24gY29weVRyZWUoc3JjLCBkc3QpIHsKICBmcy5jcFN5bmMoc3JjLCBkc3QsIHsKICAgIHJlY3Vy
>>"%B64%" echo c2l2ZTogdHJ1ZSwKICAgIGZvcmNlOiB0cnVlLAogICAgZGVyZWZlcmVuY2U6IGZhbHNlLAogICAg
>>"%B64%" echo ZmlsdGVyOiAoZnJvbSkgPT4gewogICAgICBjb25zdCByZWwgPSBwYXRoLnJlbGF0aXZlKHNyYywg
>>"%B64%" echo ZnJvbSk7CiAgICAgIGlmICghcmVsKSByZXR1cm4gdHJ1ZTsKICAgICAgcmV0dXJuICFKVU5LLmhh
>>"%B64%" echo cyhyZWwuc3BsaXQocGF0aC5zZXApWzBdKTsKICAgIH0sCiAgfSk7Cn0KCi8qKiBEU0gg5a6J6KOF
>>"%B64%" echo 5qCh6aqM5oyJ5Lil5qC8IEpTT04g6K+7IHBhY2thZ2UuanNvbu+8jOW4piBCT00g5Lya6KKr5ouS
>>"%B64%" echo 57ud77yM6L+Z6YeM55u05o6l5L+u5o6J44CCICovCmZ1bmN0aW9uIHN0cmlwQm9tKGZpbGUpIHsK
>>"%B64%" echo ICBpZiAoIWZzLmV4aXN0c1N5bmMoZmlsZSkpIHJldHVybiBmYWxzZTsKICBjb25zdCBidWYgPSBm
>>"%B64%" echo cy5yZWFkRmlsZVN5bmMoZmlsZSk7CiAgaWYgKGJ1Zi5sZW5ndGggPj0gMyAmJiBidWZbMF0gPT09
>>"%B64%" echo IDB4ZWYgJiYgYnVmWzFdID09PSAweGJiICYmIGJ1ZlsyXSA9PT0gMHhiZikgewogICAgZnMud3Jp
>>"%B64%" echo dGVGaWxlU3luYyhmaWxlLCBidWYuc3ViYXJyYXkoMykpOwogICAgcmV0dXJuIHRydWU7CiAgfQog
>>"%B64%" echo IHJldHVybiBmYWxzZTsKfQoKLyoqIOebruW9leWGheWuueaRmOimge+8iOWPquWPluebuOWvuei3
>>"%B64%" echo r+W+hCvlpKflsI/vvInvvIznlKjkuo7noa7orqToo4Xov5vljrvnmoTmmK/kuI3mmK/mnIDmlrDk
>>"%B64%" echo uIDku73jgIIgKi8KZnVuY3Rpb24gdHJlZURpZ2VzdChkaXIpIHsKICBpZiAoIWZzLmV4aXN0c1N5
>>"%B64%" echo bmMoZGlyKSkgcmV0dXJuIG51bGw7CiAgY29uc3QgaXRlbXMgPSBbXTsKICBjb25zdCB3YWxrID0g
>>"%B64%" echo KGQsIHJlbCkgPT4gewogICAgZm9yIChjb25zdCBlIG9mIGZzLnJlYWRkaXJTeW5jKGQsIHsgd2l0
>>"%B64%" echo aEZpbGVUeXBlczogdHJ1ZSB9KSkgewogICAgICBpZiAoSlVOSy5oYXMoZS5uYW1lKSkgY29udGlu
>>"%B64%" echo dWU7CiAgICAgIGNvbnN0IHIgPSByZWwgPyBgJHtyZWx9LyR7ZS5uYW1lfWAgOiBlLm5hbWU7CiAg
>>"%B64%" echo ICAgIGlmIChlLmlzRGlyZWN0b3J5KCkpIHdhbGsocGF0aC5qb2luKGQsIGUubmFtZSksIHIpOwog
>>"%B64%" echo ICAgICBlbHNlIGlmIChlLmlzRmlsZSgpKSBpdGVtcy5wdXNoKGAke3J9OiR7ZnMuc3RhdFN5bmMo
>>"%B64%" echo cGF0aC5qb2luKGQsIGUubmFtZSkpLnNpemV9YCk7CiAgICB9CiAgfTsKICB3YWxrKGRpciwgJycp
>>"%B64%" echo OwogIGl0ZW1zLnNvcnQoKTsKICByZXR1cm4gY3J5cHRvLmNyZWF0ZUhhc2goJ3NoYTI1NicpLnVw
>>"%B64%" echo ZGF0ZShpdGVtcy5qb2luKCdcbicpKS5kaWdlc3QoJ2hleCcpLnNsaWNlKDAsIDE2KTsKfQoKLyog
>>"%B64%" echo 4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSAIDQuIOS+nei1liAvIOaehOW7
>>"%B64%" echo uiDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAgKi8KCmZ1bmN0aW9uIGVu
>>"%B64%" echo dHJ5Q2FuZGlkYXRlcyhtYW5pZmVzdCkgewogIGNvbnN0IGxpc3QgPSBbXTsKICBjb25zdCBleHAg
>>"%B64%" echo PSBtYW5pZmVzdC5leHBvcnRzOwogIGlmICh0eXBlb2YgZXhwID09PSAnc3RyaW5nJykgbGlzdC5w
>>"%B64%" echo dXNoKGV4cCk7CiAgZWxzZSBpZiAoZXhwICYmIHR5cGVvZiBleHAgPT09ICdvYmplY3QnKSB7CiAg
>>"%B64%" echo ICBjb25zdCBkb3QgPSBleHBbJy4nXTsKICAgIGlmICh0eXBlb2YgZG90ID09PSAnc3RyaW5nJykg
>>"%B64%" echo bGlzdC5wdXNoKGRvdCk7CiAgICBlbHNlIGlmIChkb3QgJiYgdHlwZW9mIGRvdCA9PT0gJ29iamVj
>>"%B64%" echo dCcpIHsKICAgICAgZm9yIChjb25zdCBrZXkgb2YgWydkZWZhdWx0JywgJ2ltcG9ydCcsICdub2Rl
>>"%B64%" echo JywgJ3JlcXVpcmUnXSkgewogICAgICAgIGlmICh0eXBlb2YgZG90W2tleV0gPT09ICdzdHJpbmcn
>>"%B64%" echo KSBsaXN0LnB1c2goZG90W2tleV0pOwogICAgICB9CiAgICB9CiAgfQogIGlmICh0eXBlb2YgbWFu
>>"%B64%" echo aWZlc3QubWFpbiA9PT0gJ3N0cmluZycpIGxpc3QucHVzaChtYW5pZmVzdC5tYWluKTsKICByZXR1
>>"%B64%" echo cm4gbGlzdC5maWx0ZXIoKHApID0+IHAgJiYgIXAuaW5jbHVkZXMoJyonKSk7Cn0KCmZ1bmN0aW9u
>>"%B64%" echo IGhhc0VudHJ5KGRpciwgbWFuaWZlc3QpIHsKICBjb25zdCBmaWxlcyA9IGVudHJ5Q2FuZGlkYXRl
>>"%B64%" echo cyhtYW5pZmVzdCkubWFwKChwKSA9PiBwYXRoLmpvaW4oZGlyLCBwLnJlcGxhY2UoL15cLlwvLywg
>>"%B64%" echo JycpKSk7CiAgaWYgKGZpbGVzLmxlbmd0aCA9PT0gMCkgcmV0dXJuIHRydWU7CiAgcmV0dXJuIGZp
>>"%B64%" echo bGVzLnNvbWUoKGYpID0+IGZzLmV4aXN0c1N5bmMoZikpOwp9CgpmdW5jdGlvbiBydW5QbnBtKGN3
>>"%B64%" echo ZCwgYXJncywgbGFiZWwpIHsKICBub3RlKGAke2xhYmVsfSAuLi5gKTsKICBjb25zdCByID0gc3Bh
>>"%B64%" echo d25TeW5jKHByb2Nlc3MuZXhlY1BhdGgsIFtUT09MUy5wbnBtTWpzLCAuLi5hcmdzXSwgewogICAg
>>"%B64%" echo Y3dkLAogICAgZW5jb2Rpbmc6ICd1dGY4JywKICAgIHdpbmRvd3NIaWRlOiB0cnVlLAogICAgZW52
>>"%B64%" echo OiB7IC4uLnByb2Nlc3MuZW52LCBucG1fY29uZmlnX3VwZGF0ZV9ub3RpZmllcjogJ2ZhbHNlJyB9
>>"%B64%" echo LAogIH0pOwogIGNvbnN0IHRleHQgPSBgJHtyLnN0ZG91dCB8fCAnJ30ke3Iuc3RkZXJyIHx8ICcn
>>"%B64%" echo fWAudHJpbSgpOwogIGlmICh0ZXh0KSBvdXQodGV4dC5zcGxpdCgvXHI/XG4vKS5tYXAoKGwpID0+
>>"%B64%" echo IGAgICAgIHwgJHtsfWApLmpvaW4oJ1xuJykpOwogIHJldHVybiByLnN0YXR1cyA9PT0gMDsKfQoK
>>"%B64%" echo ZnVuY3Rpb24gZW5zdXJlQnVpbHQoZGlyLCBtYW5pZmVzdCwgc2tpcCkgewogIGlmIChza2lwKSBy
>>"%B64%" echo ZXR1cm4gdHJ1ZTsKICBpZiAoaGFzRW50cnkoZGlyLCBtYW5pZmVzdCkpIHsKICAgIG5vdGUoJ+WF
>>"%B64%" echo peWPo+aWh+S7tuW3suWtmOWcqO+8jOi3s+i/h+aehOW7uicpOwogICAgcmV0dXJuIHRydWU7CiAg
>>"%B64%" echo fQogIGlmICghbWFuaWZlc3Quc2NyaXB0cyB8fCAhbWFuaWZlc3Quc2NyaXB0cy5idWlsZCkgewog
>>"%B64%" echo ICAgd2Fybign5YWl5Y+j5paH5Lu257y65aSx5LiU5rKh5pyJIGJ1aWxkIOiEmuacrO+8jOi3s+i/
>>"%B64%" echo h+aehOW7uicpOwogICAgcmV0dXJuIHRydWU7CiAgfQogIHdhcm4oJ+ajgOa1i+WIsOa6kOeggeeJ
>>"%B64%" echo iO+8iOWFpeWPo+aWh+S7tuWwmuacqueUn+aIkO+8ie+8jOW8gOWni+ijheS+nei1luW5tuaehOW7
>>"%B64%" echo uicpOwogIHJ1blBucG0oZGlyLCBbJ2luc3RhbGwnLCAnLS1jb25maWcuZGFuZ2Vyb3VzbHlBbGxv
>>"%B64%" echo d0FsbEJ1aWxkcz10cnVlJywgJy0tcmVwb3J0ZXI9YXBwZW5kLW9ubHknXSwgJ+WuieijheaehOW7
>>"%B64%" echo uuS+nei1licpOwogIGlmICghcnVuUG5wbShkaXIsIFsncnVuJywgJ2J1aWxkJ10sICfmiafooYwg
>>"%B64%" echo bnBtIHJ1biBidWlsZCcpKSB7CiAgICB3YXJuKCfmnoTlu7rlpLHotKXvvIzmj5Lku7blj6/og73m
>>"%B64%" echo l6Dms5XliqDovb0nKTsKICAgIHJldHVybiBmYWxzZTsKICB9CiAgcmV0dXJuIGhhc0VudHJ5KGRp
>>"%B64%" echo ciwgbWFuaWZlc3QpOwp9CgovKiDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
>>"%B64%" echo lIAgNS4g6KOF6L+b5o+S5Lu25LuTIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
>>"%B64%" echo gOKUgCAqLwoKZnVuY3Rpb24gc3RhZ2VBbmRDb21taXQoc3JjLCBwa2dOYW1lLCBtYW5pZmVzdCwg
>>"%B64%" echo c2tpcEJ1aWxkKSB7CiAgZnMubWtkaXJTeW5jKFBMVUdJTl9TVE9SRSwgeyByZWN1cnNpdmU6IHRy
>>"%B64%" echo dWUgfSk7CiAgY29uc3QgZGlyTmFtZSA9IHBrZ05hbWUucmVwbGFjZSgvW1xcLzoqPyI8PnxdL2cs
>>"%B64%" echo IChtKSA9PiAobSA9PT0gJy8nID8gJ19fJyA6ICdfJykpOwogIGNvbnN0IGRlc3QgPSBwYXRoLmpv
>>"%B64%" echo aW4oUExVR0lOX1NUT1JFLCBkaXJOYW1lKTsKICBjb25zdCBzdGFtcCA9IG5ldyBEYXRlKCkudG9J
>>"%B64%" echo U09TdHJpbmcoKS5yZXBsYWNlKC9bLTpUXS9nLCAnJykuc2xpY2UoMCwgMTQpOwogIGNvbnN0IHN0
>>"%B64%" echo YWdpbmcgPSBgJHtkZXN0fS5uZXctJHtzdGFtcH1gOwoKICBmcy5ybVN5bmMoc3RhZ2luZywgeyBy
>>"%B64%" echo ZWN1cnNpdmU6IHRydWUsIGZvcmNlOiB0cnVlIH0pOwogIGNvcHlUcmVlKHNyYywgc3RhZ2luZyk7
>>"%B64%" echo CiAgaWYgKHN0cmlwQm9tKHBhdGguam9pbihzdGFnaW5nLCAncGFja2FnZS5qc29uJykpKSBub3Rl
>>"%B64%" echo KCflt7LljrvmjokgcGFja2FnZS5qc29uIOeahCBCT03vvIjlkKbliJkgRFNIIOagoemqjOS8muaL
>>"%B64%" echo kue7ne+8iScpOwogIHN0cmlwQm9tKHBhdGguam9pbihzdGFnaW5nLCAnY29yZGlzLnBhdGNoLnlt
>>"%B64%" echo bCcpKTsKCiAgY29uc3QgYnVpbHQgPSBlbnN1cmVCdWlsdChzdGFnaW5nLCBtYW5pZmVzdCwgc2tp
>>"%B64%" echo cEJ1aWxkKTsKICAvLyDmnoTlu7rnlKjnmoQgbm9kZV9tb2R1bGVzIOS4jei/myBwcm9maWxl77yM
>>"%B64%" echo 6L+Q6KGM5pe25L6d6LWW55SxIHByb2ZpbGUg6Ieq5bex6KOFCiAgZnMucm1TeW5jKHBhdGguam9p
>>"%B64%" echo bihzdGFnaW5nLCAnbm9kZV9tb2R1bGVzJyksIHsgcmVjdXJzaXZlOiB0cnVlLCBmb3JjZTogdHJ1
>>"%B64%" echo ZSB9KTsKCiAgbGV0IHJlcGxhY2VkID0gZmFsc2U7CiAgaWYgKGZzLmV4aXN0c1N5bmMoZGVzdCkp
>>"%B64%" echo IHsKICAgIGNvbnN0IG9sZCA9IGAke2Rlc3R9Lm9sZC0ke3N0YW1wfWA7CiAgICBmcy5ybVN5bmMo
>>"%B64%" echo b2xkLCB7IHJlY3Vyc2l2ZTogdHJ1ZSwgZm9yY2U6IHRydWUgfSk7CiAgICBmcy5yZW5hbWVTeW5j
>>"%B64%" echo KGRlc3QsIG9sZCk7CiAgICBmcy5yZW5hbWVTeW5jKHN0YWdpbmcsIGRlc3QpOwogICAgZnMucm1T
>>"%B64%" echo eW5jKG9sZCwgeyByZWN1cnNpdmU6IHRydWUsIGZvcmNlOiB0cnVlIH0pOwogICAgcmVwbGFjZWQg
>>"%B64%" echo PSB0cnVlOwogIH0gZWxzZSB7CiAgICBmcy5yZW5hbWVTeW5jKHN0YWdpbmcsIGRlc3QpOwogIH0K
>>"%B64%" echo ICByZXR1cm4geyBkZXN0LCByZXBsYWNlZCwgYnVpbHQgfTsKfQoKLyoqIOWNh+e6p+aXtuW/hemh
>>"%B64%" echo u+WFiOWIoOaOieaXp+eahOmCo+S7ve+8jOWQpuWImSBwbnBtIOiupOS4uiBmaWxlOiDkvp3otZbm
>>"%B64%" echo sqHlj5jvvIzkvJrkv53nlZnml6flhoXlrrnjgIIgKi8KZnVuY3Rpb24gcHJ1bmVJbnN0YWxsZWRD
>>"%B64%" echo b3B5KHBrZ05hbWUpIHsKICBjb25zdCBubSA9IHBhdGguam9pbihQUk9GSUxFX0RJUiwgJ25vZGVf
>>"%B64%" echo bW9kdWxlcycpOwogIGNvbnN0IHRhcmdldHMgPSBbcGF0aC5qb2luKG5tLCAuLi5wa2dOYW1lLnNw
>>"%B64%" echo bGl0KCcvJykpXTsKICB0cnkgewogICAgZm9yIChjb25zdCBlbnRyeSBvZiBmcy5yZWFkZGlyU3lu
>>"%B64%" echo YyhwYXRoLmpvaW4obm0sICcucG5wbScpKSkgewogICAgICBpZiAoZW50cnkuaW5jbHVkZXMocGtn
>>"%B64%" echo TmFtZSkpIHRhcmdldHMucHVzaChwYXRoLmpvaW4obm0sICcucG5wbScsIGVudHJ5KSk7CiAgICB9
>>"%B64%" echo CiAgfSBjYXRjaCB7CiAgICAvKiDmsqHmnIkgLnBucG0g5bCx6Lez6L+HICovCiAgfQogIGxldCBj
>>"%B64%" echo bGVhbiA9IHRydWU7CiAgZm9yIChjb25zdCB0IG9mIHRhcmdldHMpIHsKICAgIGlmICghZnMuZXhp
>>"%B64%" echo c3RzU3luYyh0KSkgY29udGludWU7CiAgICB0cnkgewogICAgICBmcy5ybVN5bmModCwgeyByZWN1
>>"%B64%" echo cnNpdmU6IHRydWUsIGZvcmNlOiB0cnVlLCBtYXhSZXRyaWVzOiAzLCByZXRyeURlbGF5OiAxMjAg
>>"%B64%" echo fSk7CiAgICB9IGNhdGNoIChlcnJvcikgewogICAgICBjbGVhbiA9IGZhbHNlOwogICAgICB3YXJu
>>"%B64%" echo KGDml6Dms5XliKDpmaTml6flia/mnKwgJHt0fe+8iCR7ZXJyb3IuY29kZSB8fCBlcnJvci5tZXNz
>>"%B64%" echo YWdlfe+8ieKAlOKAlCDlpJrljYrmmK8gRFNIIOato+WcqOi/kOihjGApOwogICAgfQogIH0KICBy
>>"%B64%" echo ZXR1cm4gY2xlYW47Cn0KCi8qIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
>>"%B64%" echo gCA2LiDlrpjmlrkgQ0xJIOWuieijhSDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
>>"%B64%" echo lIDilIAgKi8KCmZ1bmN0aW9uIHJ1bkRzaENsaShhcmdzKSB7CiAgY29uc3QgZW52ID0gewogICAg
>>"%B64%" echo Li4ucHJvY2Vzcy5lbnYsCiAgICBFTEVDVFJPTl9SVU5fQVNfTk9ERTogJzEnLAogICAgRFNIX0RF
>>"%B64%" echo U0tUT1BfTk9ERV9FWEVDVVRBQkxFOiBUT09MUy5leGUsCiAgICBQQVRIOiBgJHtwYXRoLmpvaW4o
>>"%B64%" echo VE9PTFMuYXBwLCAncmVzb3VyY2VzJywgJ3J1bnRpbWUnLCAnYmluJyl9OyR7cHJvY2Vzcy5lbnYu
>>"%B64%" echo UEFUSCB8fCAnJ31gLAogIH07CiAgY29uc3QgZGlyZWN0ID0gc3Bhd25TeW5jKFRPT0xTLmV4ZSwg
>>"%B64%" echo WyctLWV4cG9zZS1pbnRlcm5hbHMnLCBUT09MUy5jbGlKcywgLi4uYXJnc10sIHsKICAgIGVuY29k
>>"%B64%" echo aW5nOiAndXRmOCcsCiAgICB3aW5kb3dzSGlkZTogdHJ1ZSwKICAgIGN3ZDogRFNIX0hPTUUsCiAg
>>"%B64%" echo ICBlbnYsCiAgfSk7CiAgaWYgKGRpcmVjdC5zdGF0dXMgIT09IG51bGwpIHJldHVybiBkaXJlY3Q7
>>"%B64%" echo CiAgcmV0dXJuIHNwYXduU3luYygKICAgIHByb2Nlc3MuZW52LkNvbVNwZWMgfHwgJ2NtZC5leGUn
>>"%B64%" echo LAogICAgWycvZCcsICcvYycsIGAiJHtUT09MUy5kc2hDbWR9IiAke2FyZ3Muam9pbignICcpfWBd
>>"%B64%" echo LAogICAgeyBlbmNvZGluZzogJ3V0ZjgnLCB3aW5kb3dzSGlkZTogdHJ1ZSwgY3dkOiBEU0hfSE9N
>>"%B64%" echo RSwgZW52IH0sCiAgKTsKfQoKZnVuY3Rpb24gYWRkRGVwZW5kZW5jeShkZXN0KSB7CiAgY29uc3Qg
>>"%B64%" echo c3BlYyA9IGBmaWxlOiR7ZGVzdC5yZXBsYWNlKC9cXC9nLCAnLycpfWA7CiAgY29uc3QgciA9IHJ1
>>"%B64%" echo bkRzaENsaShbJ3BsdWdpbicsICctLXByb2ZpbGUnLCBQUk9GSUxFLCAnYWRkJywgc3BlYywgJy0t
>>"%B64%" echo cmVwb3J0ZXI9YXBwZW5kLW9ubHknXSk7CiAgY29uc3QgdGV4dCA9IGAke3Iuc3Rkb3V0IHx8ICcn
>>"%B64%" echo fSR7ci5zdGRlcnIgfHwgJyd9YC50cmltKCk7CiAgaWYgKHRleHQpIG91dCh0ZXh0LnNwbGl0KC9c
>>"%B64%" echo cj9cbi8pLm1hcCgobCkgPT4gYCAgICAgfCAke2x9YCkuam9pbignXG4nKSk7CiAgcmV0dXJuIHsg
>>"%B64%" echo Y29kZTogci5zdGF0dXMsIHRleHQgfTsKfQoKLyog4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA4pSA
>>"%B64%" echo 4pSA4pSA4pSA4pSAIDcuIOWQr+eUqO+8iOWGmeWFpSBidW5kbGVz77yJIOKUgOKUgOKUgOKUgOKU
>>"%B64%" echo gOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgCAqLwoKZnVuY3Rpb24gZW5hYmxlQnVuZGxlKHBrZ05h
>>"%B64%" echo bWUpIHsKICBjb25zdCBmaWxlID0gcGF0aC5qb2luKFBST0ZJTEVfRElSLCAncGFja2FnZS5qc29u
>>"%B64%" echo Jyk7CiAgY29uc3QganNvbiA9IHJlYWRKc29uKGZpbGUpOwogIGpzb24uZHNoID0ganNvbi5kc2gg
>>"%B64%" echo fHwge307CiAganNvbi5kc2gucHJvZmlsZSA9IGpzb24uZHNoLnByb2ZpbGUgfHwge307CiAgY29u
>>"%B64%" echo c3QgYnVuZGxlcyA9IEFycmF5LmlzQXJyYXkoanNvbi5kc2gucHJvZmlsZS5idW5kbGVzKSA/IGpz
>>"%B64%" echo b24uZHNoLnByb2ZpbGUuYnVuZGxlcyA6IFtdOwogIGNvbnN0IGFscmVhZHkgPSBidW5kbGVzLmlu
>>"%B64%" echo Y2x1ZGVzKHBrZ05hbWUpOwogIGlmICghYWxyZWFkeSkgYnVuZGxlcy5wdXNoKHBrZ05hbWUpOwog
>>"%B64%" echo IGpzb24uZHNoLnByb2ZpbGUuYnVuZGxlcyA9IGJ1bmRsZXM7CiAgZnMuY29weUZpbGVTeW5jKGZp
>>"%B64%" echo bGUsIGAke2ZpbGV9LmJha2ApOwogIGZzLndyaXRlRmlsZVN5bmMoZmlsZSwgYCR7SlNPTi5zdHJp
>>"%B64%" echo bmdpZnkoanNvbiwgbnVsbCwgMil9XG5gLCAndXRmOCcpOwogIHJldHVybiB7IGFscmVhZHksIHRv
>>"%B64%" echo dGFsOiBidW5kbGVzLmxlbmd0aCB9Owp9CgovKiDilIDilIDilIDilIDilIDilIDilIDilIDilIDi
>>"%B64%" echo lIDilIDilIDilIAgOC4g6YeN5ZCvIOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKUgOKU
>>"%B64%" echo gOKUgCAqLwoKZnVuY3Rpb24gYXBwUnVubmluZygpIHsKICBjb25zdCByID0gc3Bhd25TeW5jKCd0
>>"%B64%" echo YXNrbGlzdC5leGUnLCBbJy9GSScsICdJTUFHRU5BTUUgZXEgRGVlcFNlZWsgSGFybmVzcy5leGUn
>>"%B64%" echo LCAnL05IJ10sIHsKICAgIGVuY29kaW5nOiAndXRmOCcsCiAgICB3aW5kb3dzSGlkZTogdHJ1ZSwK
>>"%B64%" echo ICB9KTsKICByZXR1cm4gL0RlZXBTZWVrIEhhcm5lc3NcLmV4ZS9pLnRlc3Qoci5zdGRvdXQgfHwg
>>"%B64%" echo JycpOwp9CgpmdW5jdGlvbiByZXN0YXJ0QXBwKCkgewogIGlmIChhcHBSdW5uaW5nKCkpIHsKICAg
>>"%B64%" echo IG5vdGUoJ+WFs+mXrSBEU0ggLi4uJyk7CiAgICBzcGF3blN5bmMoJ3Rhc2traWxsLmV4ZScsIFsn
>>"%B64%" echo L0lNJywgJ0RlZXBTZWVrIEhhcm5lc3MuZXhlJywgJy9UJywgJy9GJ10sIHsgd2luZG93c0hpZGU6
>>"%B64%" echo IHRydWUgfSk7CiAgICBjb25zdCB1bnRpbCA9IERhdGUubm93KCkgKyAxMDAwMDsKICAgIHdoaWxl
>>"%B64%" echo IChhcHBSdW5uaW5nKCkgJiYgRGF0ZS5ub3coKSA8IHVudGlsKSB7CiAgICAgIHNwYXduU3luYygn
>>"%B64%" echo cGluZy5leGUnLCBbJy1uJywgJzEnLCAnMTI3LjAuMC4xJ10sIHsgd2luZG93c0hpZGU6IHRydWUg
>>"%B64%" echo fSk7CiAgICB9CiAgfQogIG5vdGUoJ+WQr+WKqCBEU0ggLi4uJyk7CiAgc3Bhd24oVE9PTFMuZXhl
>>"%B64%" echo LCBbXSwgeyBkZXRhY2hlZDogdHJ1ZSwgc3RkaW86ICdpZ25vcmUnLCBjd2Q6IFRPT0xTLmFwcCB9
>>"%B64%" echo KS51bnJlZigpOwp9CgovKiDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAg
>>"%B64%" echo bWFpbiDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIDilIAgKi8KCmZ1bmN0aW9u
>>"%B64%" echo IG1haW4oKSB7CiAgb3V0KCcnKTsKICBvdXQoJyAgPT09PT09PT09PT09PT09PT09PT09PT09PT09
>>"%B64%" echo PT09PT09PT09PT09PT09PT09PScpOwogIG91dCgnICAgICBEU0gg5o+S5Lu25LiA6ZSu5a6J6KOF
>>"%B64%" echo ICBpbnN0YWxsLXBsdWdpbicpOwogIG91dCgnICA9PT09PT09PT09PT09PT09PT09PT09PT09PT09
>>"%B64%" echo PT09PT09PT09PT09PT09PT09Jyk7CgogIHN0ZXAoJzEvNiAg5qOA5p+lIERlZXBTZWVrIEhhcm5l
>>"%B64%" echo c3Mg5a6J6KOFJyk7CiAgY29uc3QgYXBwID0gZmluZEFwcERpcigpOwogIGlmICghYXBwKSB7CiAg
>>"%B64%" echo ICBmYWlsKCfmib7kuI3liLAgRGVlcFNlZWsgSGFybmVzcyDlronoo4Xnm67lvZUnLCAn6K+35oyH
>>"%B64%" echo 5a6a5LiA5qyh77yaIGluc3RhbGwtcGx1Z2luLmJhdCAtQXBwICJEOlxc5L2g55qEXFxEZWVwU2Vl
>>"%B64%" echo ayBIYXJuZXNzIOebruW9lSInKTsKICB9CiAgT2JqZWN0LmFzc2lnbihUT09MUywgewogICAgYXBw
>>"%B64%" echo LAogICAgZXhlOiBwYXRoLmpvaW4oYXBwLCAnRGVlcFNlZWsgSGFybmVzcy5leGUnKSwKICAgIGRz
>>"%B64%" echo aENtZDogcGF0aC5qb2luKGFwcCwgJ3Jlc291cmNlcycsICdydW50aW1lJywgJ2NsaScsICdiaW4n
>>"%B64%" echo LCAnZHNoLmNtZCcpLAogICAgY2xpSnM6IHBhdGguam9pbihhcHAsICdyZXNvdXJjZXMnLCAnYXBw
>>"%B64%" echo LmFzYXInLCAnZHNoJywgJ25vZGVfbW9kdWxlcycsICdAZGVlcHNlZWstYWknLCAnZHNoLWRlc2t0
>>"%B64%" echo b3AtaG9zdCcsICdsaWInLCAnY2xpLmpzJyksCiAgICBwbnBtTWpzOiBwYXRoLmpvaW4oYXBwLCAn
>>"%B64%" echo cmVzb3VyY2VzJywgJ3J1bnRpbWUnLCAncHJpbWFyeS1ydW50aW1lJywgJ2RlcGVuZGVuY2llcycs
>>"%B64%" echo ICdwbnBtJywgJ2JpbicsICdwbnBtLm1qcycpLAogIH0pOwogIG9rKGFwcCk7CiAgbm90ZShgRFNI
>>"%B64%" echo X0hPTUUgOiAke0RTSF9IT01FfWApOwogIG5vdGUoYHByb2ZpbGUgIDogJHtQUk9GSUxFfWApOwoK
>>"%B64%" echo ICBjb25zdCBwcm9maWxlUGtnUGF0aCA9IHBhdGguam9pbihQUk9GSUxFX0RJUiwgJ3BhY2thZ2Uu
>>"%B64%" echo anNvbicpOwogIGlmICghZnMuZXhpc3RzU3luYyhwcm9maWxlUGtnUGF0aCkpIHsKICAgIGZhaWwo
>>"%B64%" echo YHByb2ZpbGUgIiR7UFJPRklMRX0iIOi/mOayoeWIneWni+WMlmAsICflhYjmraPluLjlkK/liqjk
>>"%B64%" echo uIDmrKEgRFNI77yM5YaN6L+Q6KGM5pys6ISa5pys44CCJyk7CiAgfQoKICBzdGVwKCcyLzYgIOWu
>>"%B64%" echo muS9jeaPkuS7tuebruW9lScpOwogIGNvbnN0IHJvb3QgPSByZXNvbHZlUGx1Z2luUm9vdChvcHQo
>>"%B64%" echo J3Jvb3QnLCBwcm9jZXNzLmN3ZCgpKSk7CiAgY29uc3QgbWFuaWZlc3QgPSByZWFkTWFuaWZlc3Qo
>>"%B64%" echo cm9vdCk7CiAgaWYgKCFtYW5pZmVzdCB8fCAhbWFuaWZlc3QubmFtZSkgZmFpbCgncGFja2FnZS5q
>>"%B64%" echo c29uIOe8uuWwkSBuYW1lIOWtl+autScpOwogIGNvbnN0IHBrZ05hbWUgPSBtYW5pZmVzdC5uYW1l
>>"%B64%" echo OwogIGNvbnN0IGJ1bmRsZVBhdGNoID0gbWFuaWZlc3QuZHNoICYmIG1hbmlmZXN0LmRzaC5idW5k
>>"%B64%" echo bGUgJiYgbWFuaWZlc3QuZHNoLmJ1bmRsZS5wYXRjaDsKICBvayhgJHtwa2dOYW1lfUAke21hbmlm
>>"%B64%" echo ZXN0LnZlcnNpb24gfHwgJzAuMC4wJ31gKTsKICBub3RlKGDmnaXmupDvvJoke3Jvb3R9YCk7CiAg
>>"%B64%" echo aWYgKCFidW5kbGVQYXRjaCkgd2FybigncGFja2FnZS5qc29uIOayoeaciSBkc2guYnVuZGxlLnBh
>>"%B64%" echo dGNo77yM5LiN5piv5qCH5YeG57uE5ZCI5YyFJyk7CgogIHN0ZXAoJzMvNiAg5pS+6L+b5o+S5Lu2
>>"%B64%" echo 5LuTIH4vLmRzaC9kc2gtcGx1Z2luc++8iOmcgOimgeaXtuWFiOaehOW7uu+8iScpOwogIGNvbnN0
>>"%B64%" echo IHsgZGVzdCwgcmVwbGFjZWQsIGJ1aWx0IH0gPSBzdGFnZUFuZENvbW1pdChyb290LCBwa2dOYW1l
>>"%B64%" echo LCBtYW5pZmVzdCwgZmxhZygnbm9idWlsZCcpKTsKICBvayhgJHtyZXBsYWNlZCA/ICflt7Lmm7Tm
>>"%B64%" echo lrAnIDogJ+W3suWGmeWFpSd977yaJHtkZXN0fWApOwogIGlmICghYnVpbHQpIHdhcm4oJ+WFpeWP
>>"%B64%" echo o+aWh+S7tuS7jeacqueUn+aIkO+8jOmHjeWQr+WQjuWPr+iDveaKpeWKoOi9vemUmeivrycpOwog
>>"%B64%" echo IGNvbnN0IHNvdXJjZURpZ2VzdCA9IHRyZWVEaWdlc3QoZGVzdCk7CgogIHN0ZXAoJzQvNiAg5riF
>>"%B64%" echo 5o6JIHByb2ZpbGUg6YeM55qE5pen5Ymv5pys77yI5Y2H57qn5b+F6ZyA77yJJyk7CiAgaWYgKHBy
>>"%B64%" echo dW5lSW5zdGFsbGVkQ29weShwa2dOYW1lKSkgb2soJ+aXp+WJr+acrOW3sua4heeQhu+8iOmmluas
>>"%B64%" echo oeWuieijheaXtuacrOadpeWwseayoeacie+8iScpOwoKICBzdGVwKCc1LzYgIOWuieijhei/myBw
>>"%B64%" echo cm9maWxl77yI5a6Y5pa5IENMSSArIHBucG3vvIknKTsKICBjb25zdCB7IGNvZGUsIHRleHQgfSA9
>>"%B64%" echo IGFkZERlcGVuZGVuY3koZGVzdCk7CiAgaWYgKGNvZGUgIT09IDApIHsKICAgIGNvbnN0IGhpbnQg
>>"%B64%" echo PSB0ZXh0LnNwbGl0KC9ccj9cbi8pLmZpbmQoKGwpID0+IC9hbGxvdy12ZXJzaW9uL2kudGVzdChs
>>"%B64%" echo KSk7CiAgICBpZiAoaGludCkgZmFpbCgn5o+S5Lu25LiO5b2T5YmNIERTSCDniYjmnKzkuI3lhbzl
>>"%B64%" echo rrknLCBg5a6D57uZ5Ye65LqG5pS+6KGM5ZG95Luk77yI56Gu6K6k6aOO6Zmp5ZCO5omn6KGM77yJ
>>"%B64%" echo 77yaXG4gICAgICAgJHtoaW50LnRyaW0oKX1gKTsKICAgIGZhaWwoJ3BucG0g5a6J6KOF5aSx6LSl
>>"%B64%" echo JywgJ+W4uOingeWOn+WboO+8mue9kee7nC/ku6PnkIbkuI3pgJrjgIFEU0gg5q2j5Y2g55So5paH
>>"%B64%" echo 5Lu244CC5Y+v5YWI6YCA5Ye6IERTSCDlho3ph43ot5HvvJvljp/lp4vmiqXplJnop4HkuIrpnaLm
>>"%B64%" echo l6Xlv5fjgIInKTsKICB9CiAgb2soJ+S+nei1luW3suWuieijhScpOwoKICBzdGVwKCc2LzYgIOWQ
>>"%B64%" echo r+eUqOaPkuS7ticpOwogIGlmIChidW5kbGVQYXRjaCkgewogICAgY29uc3QgeyBhbHJlYWR5LCB0
>>"%B64%" echo b3RhbCB9ID0gZW5hYmxlQnVuZGxlKHBrZ05hbWUpOwogICAgb2soYWxyZWFkeSA/ICfnu4TlkIjl
>>"%B64%" echo jIXlt7LlnKjlkK/nlKjliJfooajkuK0nIDogYOW3suWKoOWFpSBkc2gucHJvZmlsZS5idW5kbGVz
>>"%B64%" echo 77yI5YWxICR7dG90YWx9IOmhue+8iWApOwogIH0gZWxzZSB7CiAgICB3YXJuKCfkuI3mmK/nu4Tl
>>"%B64%" echo kIjljIXvvIzmnKrlhpnlhaUgYnVuZGxlc++8jOmcgOimgeaJi+WKqOWcqCBjb3JkaXMucGF0Y2gu
>>"%B64%" echo eW1sIOaMgui9ve+8micpOwogICAgb3V0KCcnKTsKICAgIG91dCgnICAgICAtIGluc2VydDonKTsK
>>"%B64%" echo ICAgIG91dChgICAgICAgICAgLSBpZDogJHtTdHJpbmcocGtnTmFtZSkucmVwbGFjZSgvXkBbXi9d
>>"%B64%" echo K1wvLywgJycpLnJlcGxhY2UoL1teYS16QS1aMC05LV0vZywgJy0nKX1gKTsKICAgIG91dChgICAg
>>"%B64%" echo ICAgICAgICBuYW1lOiAnJHtwa2dOYW1lfSdgKTsKICAgIG91dCgnICAgICAgICAgICBjb25maWc6
>>"%B64%" echo IHt9Jyk7CiAgfQoKICBjb25zdCBwcm9maWxlUGtnID0gcmVhZEpzb24ocHJvZmlsZVBrZ1BhdGgp
>>"%B64%" echo OwogIGNvbnN0IGluRGVwcyA9IEJvb2xlYW4ocHJvZmlsZVBrZy5kZXBlbmRlbmNpZXMgJiYgcHJv
>>"%B64%" echo ZmlsZVBrZy5kZXBlbmRlbmNpZXNbcGtnTmFtZV0pOwogIGNvbnN0IGluc3RhbGxlZERpciA9IHBh
>>"%B64%" echo dGguam9pbihQUk9GSUxFX0RJUiwgJ25vZGVfbW9kdWxlcycsIC4uLnBrZ05hbWUuc3BsaXQoJy8n
>>"%B64%" echo KSk7CiAgY29uc3QgaW5TdG9yZSA9IGZzLmV4aXN0c1N5bmMoaW5zdGFsbGVkRGlyKTsKICBjb25z
>>"%B64%" echo dCBpbkJ1bmRsZXMgPSBidW5kbGVQYXRjaCA/IChwcm9maWxlUGtnLmRzaD8ucHJvZmlsZT8uYnVu
>>"%B64%" echo ZGxlcyB8fCBbXSkuaW5jbHVkZXMocGtnTmFtZSkgOiB0cnVlOwogIGNvbnN0IGluc3RhbGxlZERp
>>"%B64%" echo Z2VzdCA9IHRyZWVEaWdlc3QoaW5zdGFsbGVkRGlyKTsKICBjb25zdCBmcmVzaCA9IGluU3RvcmUg
>>"%B64%" echo JiYgc291cmNlRGlnZXN0ICYmIGluc3RhbGxlZERpZ2VzdCAmJiBzb3VyY2VEaWdlc3QgPT09IGlu
>>"%B64%" echo c3RhbGxlZERpZ2VzdDsKCiAgc3RlcCgn5qCh6aqMJyk7CiAgb2soaW5EZXBzID8gJ3BhY2thZ2Uu
>>"%B64%" echo anNvbiDkvp3otZblt7LorrDlvZUnIDogJ+S+nei1luacquiusOW9lScpOwogIG9rKGluU3RvcmUg
>>"%B64%" echo PyAnbm9kZV9tb2R1bGVzIOW3suiQveWcsCcgOiAnbm9kZV9tb2R1bGVzIOacquingeivpeWMhScp
>>"%B64%" echo OwogIG9rKGJ1bmRsZVBhdGNoID8gKGluQnVuZGxlcyA/ICdidW5kbGVzIOW3suWQr+eUqCcgOiAn
>>"%B64%" echo YnVuZGxlcyDmnKrlkK/nlKgnKSA6ICdidW5kbGVzIOS4jemAgueUqO+8iOmdnue7hOWQiOWMhe+8
>>"%B64%" echo jOmcgOaJi+WKqOaMgui9ve+8iScpOwogIGlmIChpblN0b3JlICYmIHNvdXJjZURpZ2VzdCkgewog
>>"%B64%" echo ICAgaWYgKGZyZXNoKSBvaygn6KOF6L+b5Y6755qE5bCx5piv5Yia5aSN5Yi255qE6YKj5Lu977yI
>>"%B64%" echo 5YaF5a655LiA6Ie077yJJyk7CiAgICBlbHNlIHdhcm4oJ3Byb2ZpbGUg6YeM55qE5YaF5a655LiO
>>"%B64%" echo 5o+S5Lu25LuT5LiN5LiA6Ie0IOKAlOKAlCDlpJrljYrmmK8gRFNIIOato+WcqOWNoOeUqOaXp+aW
>>"%B64%" echo h+S7tu+8jOmAgOWHuiBEU0gg5ZCO6YeN6LeR5pys6ISa5pysJyk7CiAgfQogIG91dCgnJyk7Cgog
>>"%B64%" echo IGlmICghaW5EZXBzIHx8ICFpblN0b3JlIHx8IChidW5kbGVQYXRjaCAmJiAhaW5CdW5kbGVzKSkg
>>"%B64%" echo ewogICAgd2Fybign5a6J6KOF5bCa5pyq5a6M5YWo5oiQ5Yqf77yM6K+35oqK5LiK6Z2i55qE5pel
>>"%B64%" echo 5b+X5Y+R5oiR44CCJyk7CiAgICBwcm9jZXNzLmV4aXQoMSk7CiAgfQoKICBvdXQoJyAgLS0tLS0t
>>"%B64%" echo LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLScpOwogIGlmIChidW5kbGVQ
>>"%B64%" echo YXRjaCkgewogICAgb3V0KGAgIFtPS10gJHtwa2dOYW1lfSDlronoo4XmiJDlip9gKTsKICAgIG91
>>"%B64%" echo dChmcmVzaCA/ICcgICAgICAg5YaF5a655bey5piv5paw54mIJyA6ICcgICAgICAg5rOo5oSP77ya
>>"%B64%" echo 5YaF5a655Y+v6IO96L+Y5piv5pen54mI77yI6KeB5LiK6Z2i5o+Q56S677yJJyk7CiAgfSBlbHNl
>>"%B64%" echo IHsKICAgIG91dChgICBbT0tdICR7cGtnTmFtZX0g5bey6KOF5YWlIHByb2ZpbGVgKTsKICAgIG91
>>"%B64%" echo dCgnICAgICAgIOi/mOmcgOaMieS4iumdoueahCBZQU1MIOWcqCBjb3JkaXMucGF0Y2gueW1sIOaM
>>"%B64%" echo gui9ve+8jOaJjeS8muiiq+WKoOi9vScpOwogIH0KICBpZiAoZmxhZygncmVzdGFydCcpKSB7CiAg
>>"%B64%" echo ICByZXN0YXJ0QXBwKCk7CiAgICBvaygnRFNIIOW3sumHjeWQrycpOwogIH0gZWxzZSB7CiAgICBv
>>"%B64%" echo dXQoJyAgLT4g6K+36YeN5ZCvIERlZXBTZWVrIEhhcm5lc3PvvIjmiJbliqAgLVJlc3RhcnQg6Ieq
>>"%B64%" echo 5Yqo6YeN5ZCv77yJJyk7CiAgfQogIG91dCgnICAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
>>"%B64%" echo LS0tLS0tLS0tLS0tLS0tLS0tJyk7CiAgb3V0KCcnKTsKfQoKbWFpbigpOwo=
>>"%B64%" echo -----END CERTIFICATE-----
certutil -decode "%B64%" "%JS%" >nul 2>&1
if not exist "%JS%" goto no_payload

REM ---------- 执行 ----------
"%NODE%" "%JS%" --root "%ROOT%" --app "%APPDIR%"%EXTRA%
set "RC=%ERRORLEVEL%"

del /f /q "%JS%" "%B64%" >nul 2>&1
echo.
if not "%RC%"=="0" (
  echo   [失败] 安装未完成（退出码 %RC%）。把上面的日志发我，我直接改。
) else (
  echo   [完成] 重启 DeepSeek Harness 就能看到插件。
)
echo.
pause
exit /b %RC%

:use_dir
if "%~1"=="" exit /b 0
if not exist "%~1\DeepSeek Harness.exe" exit /b 0
if not exist "%~1\resources\runtime\cli\bin\dsh.cmd" exit /b 0
set "APPDIR=%~1"
set "NODE=%~1\resources\runtime\primary-runtime\dependencies\node\bin\node.exe"
exit /b 0

:no_app
echo.
echo   [X] 没找到 DeepSeek Harness 安装目录。
echo       指定一次即可： install-plugin.bat -App "D:\你的 DeepSeek Harness 目录"
echo.
pause
exit /b 1

:no_payload
echo.
echo   [X] 内置安装脚本释放失败（certutil）。
echo       改用同目录的 install-plugin.mjs 手动运行：
echo       node install-plugin.mjs --root "插件目录"
echo.
pause
exit /b 1

:usage
echo.
echo   用法： install-plugin.bat [插件目录] [-Restart] [-NoBuild] [-App "DSH 目录"] [-Profile desktop]
echo.
echo     [插件目录]   解压出的插件文件夹（省略则用本 bat 所在目录；也可把文件夹拖到 bat 上）
echo     -Restart     安装完成后自动重启 DSH
echo     -NoBuild     跳过依赖安装与构建
echo     -App         手动指定 DeepSeek Harness 安装目录
echo     -Profile     目标 profile，默认 desktop
echo.
pause
exit /b 0
