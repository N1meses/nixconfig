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
2. Identify the target's partitions:

   ```
   lsblk -f          # match by fstype/label/uuid
   ```

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

`<esp>`, `<root>`, etc. are the partition device nodes from `lsblk -f`.

### Plain single root (e.g. prometheus)

```
mount <root> /mnt
mount <esp>  /mnt/boot
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
