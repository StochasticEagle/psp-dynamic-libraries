PY = $(shell which python3)
PSPDEV = $(shell psp-config --pspdev-path)
BUILDTOOLS = $(PSPDEV)/share/psp-cfw-sdk/build-tools

all:
	mkdir -p dist/LIBS
	cp pre-built/*.prx dist/LIBS/
	$(MAKE) -C idStorageRegen
	cp idStorageRegen/idsregeneration.prx dist/LIBS/
	$(MAKE) -C IOPrivileged
	cp IOPrivileged/iop.prx dist/LIBS/
	$(MAKE) -C IPL_Updater
	cp IPL_Updater/ipl_update.prx dist/LIBS/
	$(MAKE) -C KBooti_Updater
	cp KBooti_Updater/kbooti_update.prx dist/LIBS/
	$(MAKE) -C PSPAV
	cp PSPAV/pspav.prx dist/LIBS/
	$(MAKE) -C PSPFTP
	cp PSPFTP/pspftp.prx dist/LIBS/
	$(MAKE) -C PSPIdentHelper
	cp PSPIdentHelper/kpspident.prx dist/LIBS/
	$(MAKE) -C USBDeviceDriver
	cp USBDeviceDriver/usbdevice.prx dist/LIBS/
	echo 'All Done!'

clean:
	$(MAKE) -C idStorageRegen clean
	$(MAKE) -C IOPrivileged clean
	$(MAKE) -C IPL_Updater clean
	$(MAKE) -C KBooti_Updater clean
	$(MAKE) -C PSPAV clean
	$(MAKE) -C PSPFTP clean
	$(MAKE) -C PSPIdentHelper clean
	$(MAKE) -C USBDeviceDriver clean
	rm -rf dist
