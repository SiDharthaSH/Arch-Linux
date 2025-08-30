# Installation Steps

## Creating a Bootable USB

1. Download latest Arch Linux ISO file and checksum file like Sha256sums.txt from a closer mirror

  **Download Page**: <https://archlinux.org/download/>

  [Download ISO & Checksum File](https://github.com/user-attachments/assets/63b4dbb9-7750-4759-b9ea-dc0cefdd2da7)

2. Check ISO integrity

  ![Check Sha256sum](./media/sha256sum-check.png)

3. Create a Bootable USB, you can use [balenaEtcher](https://etcher.balena.io/)

  - Plug in and Find your USB
    <a name="Find-Drive"/>

    ```
    ❯ sudo fdisk -l
    Disk /dev/sda: 238.47 GiB, 256060514304 bytes, 500118192 sectors
    Disk model: SM200 2.5 INCH S
    ...

    Disk /dev/sdb: 29.25 GiB, 31406948352 bytes, 61341696 sectors
    Disk model: Cruzer Blade
    ...
    ```

> [!NOTE]
> Here my USB is `/dev/sdb`

  - Flash it

    ```
    ~$ sudo dd if=archlinux-x86_64.iso of=/dev/sdb bs=4M oflag=direct conv=fsync status=progress
    1333788672 bytes (1.3 GB, 1.2 GiB) copied, 6 s, 218 MB/s
    328+1 records in
    328+1 records out
    1378795520 bytes (1.4 GB, 1.3 GiB) copied, 7.2245 s, 191 MB/s
    ```

## Boot and Install

1. Restart your laptop or computer into `One Time Boot Mode`. For me, this means using the `F12` key during bootup and choosing the Bootable USB. Alternatively, you can use the `F2` key to boot into BIOS settings and alter the boot sequence.

2. Select `Arch Linux install medium (x86_64, UEFI)` and wait till you see this prompt where you can enter commands

  ![TTY after boot](media/TTY-after-boot.png)

3. If you are not using an Ethernet cable, setup your Wi-Fi like this

  ```
  ~# iwctl
  NetworkConfigurationEnabled: disabled
  StateDirectory: /var/lib/iwd
  Version: 3.9
  [iwd]# device list
  Devices
  --------------------------------------------------------------------------------
  Name                  Address               Powered     Adapter     Mode
  --------------------------------------------------------------------------------
  wlan0                 ba:f4:8a:c8:9c:28     on          phy0        station

  [iwd]# device wlan0 set-property Powered on
  [iwd]# station wlan0 scan
  [iwd]# station wlan0 get-networks
  Available networks                             *
  --------------------------------------------------------------------------------
  Network name                      Security            Signal
  --------------------------------------------------------------------------------
  >   Redmi 12 5G                       psk                 ****
  Anshuman                          psk                 ****
  ```

> [!NOTE]
> Here my Wi-Fi is `Redmi 12 5G`

  ```
  [iwd]# station wlan0 connect "Redmi 12 5G"
  Type the network passphrase for Redmi 12 5G psk.
  Passphrase: ********
  [iwd]# exit
  ```

4. Check if you are connected to internet

  ```
  ~# ping -c 3 google.com
  PING google.com (2404:6800:4002:813::200e) 56 data bytes
  64 bytes from del11s08-in-x0e.1e100.net (2404:6800:4002:813::200e): icmp_seq=1 ttl=116 time=66.4 ms
  64 bytes from del11s08-in-x0e.1e100.net (2404:6800:4002:813::200e): icmp_seq=2 ttl=116 time=75.8 ms
  64 bytes from del11s08-in-x0e.1e100.net (2404:6800:4002:813::200e): icmp_seq=3 ttl=116 time=92.4 ms

  --- google.com ping statistics ---
  3 packets transmitted, 3 received, 0% packet loss, time 2002ms
  rtt min/avg/max/mdev = 66.380/78.165/92.365/10.744 ms
  ~#
  ```

> [!NOTE]
> The lower the packet loss the better

5. use `reflector` to choose the fastest mirrors

  ```
  ~# reflector -c India --sort rate --save /etc/pacman.d/mirrorlist --verbose
  ```

> [!NOTE]
> Replace `India` with your country name

6. Install `archlinux-keyring` which is a crucial package in Arch Linux that provides the PGP keys used by pacman to verify the authenticity and integrity of packages.

  ```
  ~# pacman -Syy archlinux-keyring
  ~# archlinux-keyring-wkd-sync
  ```

> [!NOTE]
> This command takes some serious time so be patient

7. Use `parted` to create partitions

  **Partition Layout**: https://wiki.archlinux.org/title/Installation_guide#Example_layouts

  **Partition Type Wiki**: https://en.wikipedia.org/wiki/GUID_Partition_Table#Partition_type_GUIDs

> [!NOTE]
> For me the drive I will be installing in is `/dev/sda` ([How to find drive](#Find-Drive))

  ```
  ~# parted /dev/sda
  ...
  (parted) mktable gpt 
  (parted) mkpart "EFI System Partition" fat32 1MiB 513MiB
  (parted) set 1 esp on
  (parted) mkpart "Root Partition" ext4 513MiB -8GiB
  (parted) type 2 4F68BCE3-E8CD-4DB1-96E7-FBCAF984B709
  (parted) mkpart "Swap Partition" linux-swap -8GiB 100%
  (parted) type 3 0657FD6D-A4AB-43C4-84E5-0933C84B4F4F 
  (parted) quit
  ```

8. Format the partitions

  ```
  ~# mkfs.fat -F32 /dev/sda1 
  ~# mkfs.ext4 /dev/sda2
  ~# mkswap /dev/sda3
  ```

9. Mount the file systems

  ```
  ~# mount /dev/sda2 /mnt
  ~# mount --mkdir /dev/sda1 /mnt/boot
  ```

10. Enable Swap

  ```
  ~# swapon /dev/sda3
  ```

11. Install essential packages

  ```
  ~# pacstrap -K /mnt base linux linux-firmware
  ```

12. Install More Packages. You can do this later via `pacman` after using `arch-chroot` but I prefer this way

> [!NOTE]
> Its recommended to check and install optional dependencies according to your need. For example:-

  ```
  ~# pacman -Si pipewire
  ...
  Optional Deps   : gst-plugin-pipewire: GStreamer plugin         <---
                    pipewire-alsa: ALSA configuration             <---
                    pipewire-audio: Audio support
                    pipewire-docs: Documentation
                    pipewire-ffado: FireWire support
                    pipewire-jack-client: PipeWire as JACK client
                    pipewire-jack: JACK replacement               <---
                    pipewire-libcamera: Libcamera support
                    pipewire-pulse: PulseAudio replacement        <---
                    ...
  ```

> [!NOTE]
> Most of the packages I installed here are taken from [archinstall](https://wiki.archlinux.org/title/Archinstall)

  ```
  ~# pacstrap -K /mnt base-devel
  ~# pacstrap -K /mnt zram-generator networkmanager
  ~# pacstrap -K /mnt pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse
  ~# pacstrap -K /mnt kitty tmux vim htop
  ~# pacstrap -K /mnt openssh wget iwd wireless-tools wpa-supplicant smartmontools xdg-utils
  ~# pacstrap -K /mnt sway brightnessctl foot grim i3status libpulse mako polkit swaybg sway-contrib swayidle swaylock waybar wmenu xorg-xwayland xdg-desktop-portal-gtk
  ~# pacstrap -K /mnt xorg-server xorg-xinit mesa libva-intel-driver intel-media-driver vulkan-intel intel-ucode
  ~# pacstrap -K /mnt ly
  ...
  ```

> [!NOTE]
> Here is the whole list of all installed packages in my system [explicitly](./Packages-Installed-Explicitly.md) and as [dependency](./Dependency-Packages.md)

13. To get file systems mounted on startup, we have to generate an fstab file

  ```
  ~# genfstab -U /mnt >> /mnt/etc/fstab
  ```

14. To directly interact with the new system's environment as if you were booted into it, change root into the new system

  ```
  ~# arch-chroot /mnt
  ```

> [!NOTE]
> From this point on all the commands will be executed inside the chroot environment provided by `arch-chroot`

15. Set timezone

  ```
  ~# ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
  ~# hwclock --systohc
  ```

16. To use the correct region and language specific formatting (like dates, currency, decimal separators) uncomment `en_US.UTF-8 UTF-8` in file `/etc/locale.gen` with your preferred text editor like `vim` or `nano` then run

  ```
  ~# locale-gen
  ```

17. Create the `/etc/locale.conf` file, and set the LANG variable accordingly in it like this

  ```
  LANG=en_US.UTF-8
  ```

18. To assign a name to your system, create the `/etc/hostname` file and write a hostname you want like this

  ```
  archlab
  ```

19. Create new initramfs

  ```
  ~# mkinitcpio -P
  ```

20. set root password

> [!NOTE]
> You will not be able to see anything while you are typing password but its detecting everything, that's how the password input works usually in Linux CLI

  ```
  ~# passwd
  ```

21. Add a user. My name is Sidhartha so I will use `sid` as my username

  ```
  ~# useradd -m -G wheel sid
  ~# passwd sid
  ```

22. Setup superuser privileges by installing `sudo` then running

  ```
  ~# pacman -S sudo
  ```

  And then uncommenting `%wheel ALL=(ALL:ALL) ALL` in `/etc/sudoers` file

23. Enable essential services

  ```
  ~# systemctl enable fstrim.timer
  ~# systemctl enable NetworkManager.service
  ~# systemctl enable ly
  ~# systemctl enable systemd-timesyncd
  ~# systemctl enable tlp.service
  ```

24. Install boot loader, I will be using `systemd-boot` as my boot loader

  ```
  ~# bootctl install
  ```

> [!NOTE]
> This command will put the essentials in place but it will not add a boot
> entry in UEFI Boot Manager configuration from a chroot environment.
> See: [Bug](https://github.com/systemd/systemd/issues/36174)
> although we will be able to boot by selecting the current drive and then
> running the command again will fix it.
> See: [Boot Loader Fix](#Boot-Loader-Fix)

25. create boot loader config file [loader.conf](./../root/boot/loader/loader.conf) in `/boot/loader/`

26. Create boot loader entries by creating [arch.conf](./../root//boot/loader/entries/arch.conf) and [arch-fallback.conf](./../root/boot/loader/entries/arch-fallback.conf) file in `/boot/loader/entries/`

  Example format:-
  ```
  title    Arch Linux
  linux    /vmlinuz-linux
  initrd   /initramfs-linux.img
  options  root=UUID=XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX  rw
  ```

> [!NOTE]
> Here UUID of your root partion can be obtained from `lsblk -f </dev/root-partition>` in this case `/dev/sda2`

27. Now we exit out of chroot with `exit` command, then we unmount the mounted partitions switch off our computer/laptop properly

  ```
  ~# umount -R /mnt
  ~# poweroff
  ```

28. Switch on the computer/laptop and go to `One Time Boot Mode` and _select the drive in which you installed Arch Linux_ to boot. Alternatively, you can use the `F2` key to boot into BIOS settings and alter the boot sequence.

  Then login as User in Shell to Fix Boot Entry in UEFI
  <a name="Boot-Loader-Fix"/>

  ```
  ~$ sudo bootctl install
  ```

29. Create [zram-generator.conf](./../root//etc/systemd/zram-generator.conf) in `/etc/systemd/` then enable zram by running

  ```
  ~$ sudo systemctl daemon-reload
  ~$ sudo systemctl start /dev/zram0
  ```

## Configuration

Configure your environment with appropriate config files, I have stored my config in a tree structure style so that it's easy to understand which location they belong to.

  ```
  root
  ├── boot
  │   ├── loader
  │   │   ├── entries
  │   │   │   ├── arch.conf
  │   │   │   └── ...
  │   │   └── loader.conf
  │   └── README.md
  ├── etc
  │   ├── ly
  │   │   └── config.ini
  │   ├── README.md
  │   └── ...
  └── home
      └── sid
          ├── .bash_profile
          ├── .bashrc
          ├── .config
          │   ├── kitty
          │   └── ...
          ├── ...
          └── README.md
  ```

> [!WARNING]
> Don't copy paste config without checking it atleast once because some configs like [tlp.conf](./../root/etc/tlp.conf) will mess up your system's performance so modifying config before use is recommended.

  [Must have Firefox Plugins](./Firefox-PLugins.md)

After this Your Arch Linux will be ready for use :D  
And you will be able to say `I use Arch btw` ;)
