fontsize 1.0
border 1 1
echo ----------------------------
echo ---- Loading SNESticle -----
echo ----------------------------
echo RETROLauncher v1.0
version
store IRX/usbd.irx
store IRX/usbhdfsd.irx
store IRX/poweroff.irx
store IRX/ps2dev9.irx
store IRX/ps2fs.irx

iopreset
load int:iomanx.irx
load int:filexio.irx
load int:usbd.irx
load int:usbhdfsd.irx
load int:poweroff.irx
load int:ps2dev9.irx
load int:ps2fs.irx -m 4 -o 10 -n 40

set prompt "$$CD>"
set RSH_DIR "$CD"
run SNESticle
