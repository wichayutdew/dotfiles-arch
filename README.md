# System

| Type | Name |
| --- | --- |
| OS | Arch Linux |
| Bootloader | Limine |
| Display Manager (DM) | LY |
| Compositor | Hyprland |

# Pre-Requisutes

## Create free partition on hardware disk (If dual boot is needed)

- Disable Windows' BitLocker encryption - using command prompt as administrator

```bash
    manage-bde -status                # To check the status
    manage-bde -off <DriveLetter>:    # To disable the feature
```

- Shrinken the Windows drive to make space for Arch

## Bootable Arch linux USB drive (using Rufus)

- Download [Arch Linux ISO](https://archlinux.org/download)
- Use Rufus to burn the ISO file to USB drive

> check the device's mainboard/hard disk for `Partition Scheme` and `Target System`
> Usually newer hardware are on `GPT` and `UEFI`
> Leave File System as `FAT32`

# Installing Arch

- Enter BIOS mode -- disable `secure boot` and select Bootable USB drive as a primary
- Select 1st Arch installation method `Arch Linux install medium (x86_64, UEFI)` and wait for the drive preparation
- Start the installation process on terminal shell (if the font is too small run `setfont ter-132n`)
- Connect to wifi using `iwctl` command

```bash
    device list # will usually rounded `wlan0`
    station wlan0 get-networks
    station wlan0 connect <WIFI-SSID>
    ## type wifi password
    exit

    ## try ping google.com to see if network is established
 ```

- update system to latest version `pacman -Syu`

## Partitioning Drive

> `lsblk` to list all the virtual drives (the hard disk is usually called `nvme0n1`)
> `fdisk -l` for more verbose drives info

- `cfdisk /dev/nvme0n1` to create 4 partitions `boot`, `swap`, `root`, `home`

> `boot` is to boot the OS (EFI system ~1G)
> `root` is to stored all the OS related files (Linux filesystem ~75G)
> `swap` is to support RAM usage when it runs out (Linux swap ~4G)
> `home` is the main drive for daily usage (Linux filesystem the rest of the spaces)
> each partition of the drive will be named `/dev/nvme0n1p{partitionId}`

- Formatting each drives (can update to other format if wanted)

```bash
    mkfs.fat -F 32 /dev/nvme0n1p{..} ## boot
    mkfs.ext4 /dev/nvme0n1p{..}      ## root
    mkswap /dev/nvme0n1p{..}         ## swap
    mkfs.ext4 /dev/nvme0n1p{..}      ## home
```

- Mounting the partition

```bash
    mount /dev/nvme0n1p{..} /mnt      ## root
    mkdir /mnt/home
    mkdir /mnt/boot
    mount /dev/nvme0n1p{..} /mnt/home ## home
    mount /dev/nvme0n1p{..} /mnt/boot ## boot
    swapon /dev/nvme0n1p{..}          ## swap
    lsblk                             ## to check the result
```

## Update mirrorlist

```bash
    pacman -S reflector ## if needed
    reflector --latest --country {TH} --protocol http,https --sort rate --save /etc/pacman.d/mirrorlist
```

## Adding crucial packages and Preparing to enter Arch system

```bash
    pacstrak -K /mnt base linux linux-firmware base-devel networkmanager vim vi git reflector {intel-ucode/amd-ucode}
    genfstab -U /mnt >> /mnt/etc/fstab
    arch-chroot /mnt
    ## now you are in Arch system not USB drive
```

## Basic Configuration

```bash
    ## Setting Locale
    ln -sf /usr/share/zoneinfo/{Asia/Bangkok} /etc/localtime
    hwclock --systohc
    vim /etc/locale.gen ## uncomment desired locale e.g. all the en_US
    locale-gen
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    ## Adding Users
    echo {root_username} > /etc/hostname
    passwd ## add in your root user password
    useradd -m -G wheel,users {username-1}
    passwd {username-1} ## add password for your 1st user
    visudo ## open vim to uncomment wheel command to allow user to ack as sudo

    ## Enable Network
    systemctl enable NetworkManager
```

# Using Limine Bootloader

- Setting up Bootloader system

```bash
    pacman -S limine efibootmgr ## installing the bootloader

    mkdir -p /boot/EFI/limine
    cp /usr/share/limine/BOOTX64.EFI /boot/EFI/limine/

    efibootmgr --create --disk /dev/nvme0n1 --part {the partition of EFI System} \ ## check the drive name and partition
      --label "Arch Linux Limine Bootloader" \
      --loader '\EFI\limine\BOOTX64.EFI' \
      --unicode
```

- `vim /boot/EFI/limine/limine.conf` and Paste below config

> `blkid or cat /mnt/etc/fstab` to identify drive's partition UUID
> This one, I've patched the issue where laptop is not sleeping/booting correctly with lid close/open action. Check first if needed
> `iommu=pt nvme_core.default_ps_max_latency_us=0`

```
timeout: 5

/Arch Linux
 protocol: linux
 path: boot():/vmlinuz-linux
 cmdline: root=UUID={device-UUID} rw quiet iommu=pt nvme_core.default_ps_max_latency_us=0
 module_path: boot():/initramfs-linux.img

/Arch Linux (Fallback)
 protocol: linux
 path: boot():/vmlinuz-linux
 cmdline: root=UUID={device-UUID} rw iommu=pt nvme_core.default_ps_max_latency_us=0
 module_path: boot():/initramfs-linux-fallback.img
```

## Reboot for setting to reflect

```bash
    exit
    umount -R /mnt
    reboot
```

# Install LY Display Manager

```bash
    pacman -S ly
    systemctl enable ly.service
    systemctl start ly.service
```

# Install Hyprland

```bash
    sudo pacman -S hyprland-git xdg-desktop-portal-hyprland kitty ## kitty can be removed later
    reboot
```

## Install yay

```bash
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
```

## Adding crucial packages

```bash
## Fonts
yay -S noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono
## Wifi
yay -S nmgui-bin
## Bluetooth
yay -S bluez bluez-utils blueman
## Media/Audio
yay -S pipewire pipewire-alsa pipewire-pulse pipewire-audio pipewire-jack wireplumber
yay -S playerctl mpv
yay -S pavucontrol  
yay -S easyeffects gst-plugin-pipewire calf lsp-plugins zam-plugins-lv2 mda.lv2 yelp
yay -S brightnessctl
## Screenshot
yay -S grim slurp satty
## GUI Apps
yay -S ghostty onlyoffice-bin spotify swaync zennotes firefox
## Hyprland related
yay -S hypridle hyprlock hyprpaper waybar wlogout
## Terminal Essentials
yay -S yazi 7zip unzip fish eza fish fzf imv jq lazygit neovim ripgrep starship tmux zoxide
## AI
yay -S pi-coding-agent
## Coding Language Version manaer
asdf-vm
## etc.
yay -S power-profiles-daemon tree-sitter-cli matugen-bin

```

# Reference

- [Rufus Drive ISO burner](https://rufus.ie)
- [Dualbooting Windows/Arch](https://youtu.be/9DO0MI2VtsE?si=_PuN-55sfGSMMFSu)
- [Manually installing Arch without `archinstall`](https://youtu.be/TS1ghG3c3xI?si=EmsyB7bO_77lltoz)
- [Installing Limine Bootloader}](https://gist.github.com/yovko/512326b904d120f3280c163abfbcb787)
