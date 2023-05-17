DISKSIZE=5G
RAMSIZE=1G
OPENBSD_VERSION=73
TELNET_CONSOLE=

QEMU_FLAGS=
ifneq ($(TELNET_CONSOLE),)
QEMU_FLAGS+=-serial tcp::${TELNET_CONSOLE},server,telnet,wait
endif

all:
	@echo openbsd-arm64
	@echo openbsd-sparc64
	@echo debian10-ppc

arm64:
	qemu-system-aarch64 \
		-M virt \
		-m ${RAMSIZE} \
		-cpu host \
		-smp 6 \
		-machine type=virt,accel=hvf \
		-bios QEMU_EFI.fd \
		-drive file=obsd-arm64.qcow2,if=none,id=drive0,format=qcow2 \
		-device virtio-blk-device,drive=drive0 \
		-nographic $(QEMU_FLAGS)
install:
	qemu-system-aarch64 \
		-M virt \
		-m 512 \
		-cpu cortex-a57 \
		-bios QEMU_EFI.fd \
		-drive file=miniroot72.img,format=raw,id=drive1 \
		-drive file=obsd-arm64.qcow2,if=none,id=drive0,format=qcow2 \
		-nographic $(QEMU_FLAGS)

down:
	wget http://releases.linaro.org/components/kernel/uefi-linaro/latest/release/qemu64/QEMU_EFI.fd
	qemu-img create -f qcow2 obsd-arm64.qcow2 ${DISKSIZE}

obsd-ppc64.qcow2:
	qemu-img create -f qcow2 obsd-ppc64.qcow2 ${DISKSIZE}

.PHONY: ppc64 ppc
ppc64: obsd-ppc64.qcow2
	mkdir -p ppc64
	cd ppc64 && wget -c https://cdn.openbsd.org/pub/OpenBSD/7.2/powerpc64/miniroot72.img
	cd ppc64 && wget -c https://cdn.openbsd.org/pub/OpenBSD/7.2/powerpc64/install72.img
#./qemu-system-ppc -L pc-bios -boot d -M mac99,via=pmu -m 512 -hda <hd image file> -cdrom <iso file of installation media> \
-netdev user,id=mynet0 -device sungem,netdev=mynet0
	qemu-system-ppc64 -cpu g4 \
		-L pc-bios \
		-M mac99,via=pmu \
		-m 2048 \
		-device pci-ohci -usb \
		-net nic,model=ne2k_pci -net user \
		-netdev user,id=mynet0 -device sungem,netdev=mynet0 \
		-device usb-audio \
		-hda ppc64/miniroot72.img \
		-cdrom ppc64/install72.img \
		-drive file=ppc64/miniroot72.img,format=raw \
		-drive file=obsd-ppc64.qcow2,if=none,id=drive0,format=qcow2 \
		-boot c \
		-nographic $(QEMU_FLAGS)

obsd-ppc.qcow2:
	qemu-img create -f qcow2 obsd-ppc.qcow2 ${DISKSIZE}

# http://gemmei.ftp.acc.umu.se/mirror/cdimage/ports/10.0/powerpc/iso-cd/debian-10.0-powerpc-NETINST-1.iso
debian10-ppc ppc: obsd-ppc.qcow2
	wget http://gemmei.ftp.acc.umu.se/mirror/cdimage/ports/10.0/powerpc/iso-cd/debian-10.0-powerpc-NETINST-1.iso
	mkdir -p ppc
	cd ppc && wget -c https://cdn.openbsd.org/pub/OpenBSD/7.2/macppc/cd72.iso
#./qemu-system-ppc -L pc-bios -boot d -M mac99,via=pmu -m 512 -hda <hd image file> -cdrom <iso file of installation media> \
-netdev user,id=mynet0 -device sungem,netdev=mynet0
	qemu-system-ppc -cpu g4 \
		-L pc-bios \
		-M mac99,via=pmu-adb \
		-m 1024 \
		-netdev user,id=mynet0 -device sungem,netdev=mynet0 \
		-drive file=obsd-ppc.qcow2,if=none,id=drive0,format=qcow2 \
		-cdrom ppc/debppc.iso \
		-boot d \
		-nographic $(QEMU_FLAGS)

#-serial tcp::4450,server,telnet,wait

obsd-sparc64.qcow2:
	qemu-img create -f qcow2 obsd-sparc64.qcow2 ${DISKSIZE}

# https://codemadness.org/openbsd-sparc64-vm.html
# sparc station bootrom files https://github.com/andarazoroflove/sparc
openbsd-sparc64: obsd-sparc64.qcow2
	mkdir -p sparc64
	cd sparc64 && wget -c https://cdn.openbsd.org/pub/OpenBSD/7.2/sparc64/cd72.iso
	qemu-system-sparc64 \
		-machine sun4u,usb=off \
		-smp 1,sockets=1,cores=1,threads=1 \
		-rtc base=utc \
		-m 1024 \
		-boot d \
		-drive file=obsd-sparc64.qcow2,if=none,id=drive-ide0-0-1,format=qcow2,cache=none \
		-cdrom sparc64/cd72.iso \
		-device ide-hd,bus=ide.0,unit=0,drive=drive-ide0-0-1,id=ide0-0-1 \
		-msg timestamp=on \
		-nographic $(QEMU_FLAGS) \
		-net nic,model=ne2k_pci -net user

#-serial pty -nographic

.PHONY: openbsd-sparc64
