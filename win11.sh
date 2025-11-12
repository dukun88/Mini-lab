 #!/bin/sh

performance_cores=$(awk '
  /^processor/ { proc=$3 } 
  /^CPU part/ {
    if ($4 == "0x023" || $4 == "0x025" || $4 == "0x029" || $4 == "0x033" || $4 == "0x035" || $4 == "0x039")
      procs=procs ? procs","proc : proc
  } END { print procs }
' /proc/cpuinfo)

taskset -c "$performance_cores" \
  qemu-system-aarch64 \
    -display sdl,gl=on \
    -cpu host \
    -M virt \
    -enable-kvm \
    -m 2G \
    -smp 2 \
    -bios /usr/share/edk2/aarch64/QEMU_EFI.fd \
    -hda win11.qcow2 \
    -device qemu-xhci \
    -device ramfb \
    -device usb-storage,drive=install \
    -drive if=none,id=install,format=raw,media=cdrom,file=windows-11.iso \
    -device usb-storage,drive=virtio-drivers \
    -drive if=none,id=virtio-drivers,format=raw,media=cdrom,file=virtio-win-0.1.285.iso \
    -object rng-random,filename=/dev/urandom,id=rng0 \
    -device virtio-rng-pci,rng=rng0 \
    -audio driver=pipewire,model=virtio \
    -device usb-kbd \
    -device usb-tablet \
    -nic user,model=virtio-net-pci
