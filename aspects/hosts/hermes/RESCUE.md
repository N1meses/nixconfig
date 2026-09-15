# Hermes — portable rescue stick

Hermes is a full NixOS install on a USB stick (LUKS-encrypted `/persist`,
impermanence, GRUB installed `efiInstallAsRemovable`). Because it boots on
arbitrary UEFI hardware and carries a checkout of this flake at
`/home/hermes/nixconfig` (persisted), it doubles as the fleet's recovery
environment: boot it on a dead host, mount that host's disks, chroot in, and
rebuild its config.

## When you need it

A host is unbootable or locked out and there's no working login. Typical case:
`users.mutableUsers = false` with a missing/cleared password — every generation
re-locks the account on boot (so booting an older generation does **not** help),
and `root` is locked too (no rescue/single-user shell). The only way back in is
an external root shell to activate a generation whose config sets the password.

## Prerequisites

- Same CPU arch as the target (this stick is x86_64).
- `nixos-enter` (from `nixos-install-tools`) and `cryptsetup` in `PATH`. If they
  aren't present on the running stick, pull them on demand (needs network):

  ```
  nix-shell -p nixos-install-tools cryptsetup gptfdisk
  ```

## Steps

1. Boot the stick (firmware boot menu → the USB device). Unlock its own
   `/persist` when prompted.
2. **Identify the target's partitions.** This is the step people get wrong — do
   not memorise or copy UUIDs; read them off the machine in front of you:

   ```
   lsblk -f
   ```

   On the host's *internal* disk you need exactly two partitions:

   - **NixOS root** — `ext4` (or `btrfs`), usually the largest partition. If it
     shows as `crypto_LUKS` it's encrypted — unlock it first (LUKS recipe below).
   - **ESP / boot** — a small (~512 MB–1 GB) `vfat` partition, on the *same disk*
     as the root.

   Leave everything else alone: Windows is `ntfs` (often with its own small
   `vfat` ESP), games/data is `ntfs`/`exfat`.

   Mount with the **device node** from the `NAME` column (e.g. `/dev/nvme1n1p2`),
   not a UUID. Example — a layout like prometheus (two disks; NixOS on the
   second, Windows untouched on the first):

   ```
   NAME        FSTYPE LABEL   UUID                  MOUNTPOINTS
   nvme0n1                                          # <- Windows disk, leave it
   ├─nvme0n1p1 vfat           XXXX-XXXX             #    (Windows ESP)
   └─nvme0n1p2 ntfs   Windows ...                   #    (Windows)
   nvme1n1                                          # <- NixOS disk
   ├─nvme1n1p1 vfat   FAT32   99C8-389D             #    ESP   -> mount at /mnt/boot
   ├─nvme1n1p2 ext4           61edc440-5d0c-4777... #    root  -> mount at /mnt
   └─nvme1n1p3 ntfs   Games   220903B921B32465      #    games, leave it
   ```

   Your device names *will* differ — read your own `lsblk`. Here you'd use
   `/dev/nvme1n1p2` (root) and `/dev/nvme1n1p1` (ESP). The UUIDs above are
   prometheus's actual ones; if you'd rather mount by UUID,
   `mount /dev/disk/by-uuid/<uuid> /mnt` works too — but note a `crypto_LUKS`
   partition's *inner* filesystem UUID does not exist until you unlock it.

3. Mount the target at `/mnt` using the recipe matching its disk layout
   (see below).
4. Rebuild into a fresh boot generation:

   ```
   nixos-enter --root /mnt -c "nixos-rebuild boot --flake /flake#<host>"
   ```

   For a **fleet host**, first expose this stick's flake inside the chroot:

   ```
   mkdir -p /mnt/flake && mount --bind /home/hermes/nixconfig /mnt/flake
   ```

   For a **foreign host**, skip the bind-mount and use that machine's own
   config instead (`--flake /etc/nixos#<host>`, or plain `nixos-rebuild boot`
   for a channels-based system).
5. Clean up and reboot the target:

   ```
   umount -R /mnt
   cryptsetup close rescue-root rescue-persist 2>/dev/null || true
   reboot
   ```

## Mount recipes

`<root>`, `<esp>`, `<nix>`, `<persist>` are the **device nodes** you identified
in step 2 (e.g. `/dev/nvme1n1p2`), not UUIDs.

### Plain single root (e.g. prometheus)

```
mount <root> /mnt        # the ext4 NixOS partition,  e.g. /dev/nvme1n1p2
mount <esp>  /mnt/boot   # the small vfat ESP on it,  e.g. /dev/nvme1n1p1
```

### LUKS single root (e.g. nimeses, the common encrypted case)

```
cryptsetup open <root> rescue-root      # prompts for passphrase
mount /dev/mapper/rescue-root /mnt
mount <esp> /mnt/boot
```

### Impermanence: tmpfs root + separate /nix + LUKS /persist (hermes-style)

```
mount -t tmpfs -o size=50%,mode=755 none /mnt
mkdir -p /mnt/{boot,nix,persist}
mount <nix> /mnt/nix
cryptsetup open <persist> rescue-persist
mount /dev/mapper/rescue-persist /mnt/persist
mount <esp> /mnt/boot
```

The system profile lives in `/nix/var/nix/profiles/system`, so `nixos-enter`
and `nixos-rebuild boot` work even though the runtime root is ephemeral.

## Provision a host from scratch (disko + install)

The stick is also a full installer — use it to set up a fleet host on blank/new
hardware, or to reinstall one whose disk you intend to wipe. **This destroys the
target disk**, the opposite of the rescue flow above; only do it when there is
nothing on that disk to keep. (For prometheus you would *not* do this — it has no
disko config and shares a disk with the games partition; rescue it instead.)

Unlike the rescue flow, `nixos-install` runs from the stick itself (not inside a
chroot), so point `--flake` at the real path `/home/hermes/nixconfig`, not the
`/flake` bind-mount.

For a host **with** a disko config (hermes, nimeses, …):

```
# 1. partition + format + mount per the host's disko config — DESTRUCTIVE.
#    opens LUKS / builds tmpfs roots as declared, all under /mnt.
disko --mode destroy,format,mount --flake /home/hermes/nixconfig#<host>
#    add --yes-wipe-all-disks to skip the safety prompt (automation).

# 2. install the system + bootloader onto the freshly formatted disk
nixos-install --flake /home/hermes/nixconfig#<host> --no-root-passwd

# 3. reboot into the installed system
umount -R /mnt
reboot
```

`modules/hosts/hermes/install-hermes.sh` is a worked example of this flow.

Two handy variants:

- **Just mount a disko host** (for the rescue flow, no wiping):
  `disko --mode mount --flake /home/hermes/nixconfig#<host>` reads the layout
  from config and mounts everything under `/mnt` (opening LUKS, `/nix`,
  `/persist`, ESP) so you don't hand-mount.
- **Host without a disko config** (e.g. prometheus, plain `fileSystems`):
  partition by hand (`parted`/`gptfdisk`), `mkfs` the filesystems, mount them
  under `/mnt` matching the host's `fileSystems` mountpoints, then
  `nixos-install --flake /home/hermes/nixconfig#<host>`.

## Caveats

- Use `nixos-rebuild **boot**`, not `switch`, inside a chroot.
- **Bootloader install targets the host's configured loader.** systemd-boot
  hosts write to the mounted ESP — make sure you mounted the *right* one. GRUB
  hosts write to `boot.loader.grub.device`; only rescue a GRUB/removable host
  when that device resolves correctly in the rescue environment.
- Under `mutableUsers = false`, a manual `passwd` does **not** survive a reboot
  (activation re-locks on the next boot). You must rebuild a generation whose
  config actually sets the password.
- `nixos-rebuild`/`nixos-enter` never touch other partitions — Windows, games,
  etc. are safe. The only thing that wipes disks is `nixos-install` with a
  disko/format step; don't run that for a repair.
