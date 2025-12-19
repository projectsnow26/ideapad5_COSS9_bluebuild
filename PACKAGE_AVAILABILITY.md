# CentOS Stream 9 BlueBuild - Package Availability Analysis

## Build Failure Root Cause

The original build failed with:
```
error: Packages not found: arc-theme, blueman, budgie-backgrounds, budgie-control-center, 
budgie-desktop, budgie-desktop-view, budgie-extras, budgie-screensaver
```

## Package Availability Research (December 2025)

### ❌ Budgie Desktop - NOT AVAILABLE for CentOS Stream 9

| Package | Status | Details |
|---------|--------|---------|
| `budgie-desktop` | ❌ NOT AVAILABLE | stenstorp/budgie COPR only builds for Fedora + **EL8 only** |
| `budgie-desktop-view` | ❌ NOT AVAILABLE | Same - no EL9/EPEL9 chroot in COPR |
| `budgie-backgrounds` | ❌ NOT AVAILABLE | Same |
| `budgie-control-center` | ❌ NOT AVAILABLE | Same |
| `budgie-screensaver` | ❌ NOT AVAILABLE | Same |
| `budgie-extras` | ❌ NOT AVAILABLE | Same |

**Source:** https://copr.fedorainfracloud.org/coprs/stenstorp/budgie/
> "The Budgie desktop environment for Fedora and **EL8**"

The stenstorp/budgie COPR explicitly states EL8 support only. EL8 is limited to Budgie version 10.5 (the last version supporting Mutter 3.28).

### ❌ Themes Not in EPEL 9

| Package | Status | Details |
|---------|--------|---------|
| `arc-theme` | ❌ NOT AVAILABLE | Only in EPEL 7, dropped from EPEL 8+ |
| `greybird-*` themes | ❌ NOT AVAILABLE | Fedora only, never packaged for EPEL |

### ❌ Bluetooth Manager

| Package | Status | Details |
|---------|--------|---------|
| `blueman` | ❌ NOT AVAILABLE | Fedora only, never packaged for EPEL |

**Alternative:** Use `gnome-bluetooth` (with GNOME) or `bluedevil` (with KDE Plasma)

### ✅ Available Packages (EPEL 9)

| Package | Status | Repository |
|---------|--------|------------|
| `papirus-icon-theme` | ✅ AVAILABLE | EPEL 9 |
| `lightdm` | ✅ AVAILABLE | EPEL 9 |
| `lightdm-gtk` | ✅ AVAILABLE | EPEL 9 |
| XFCE (full desktop) | ✅ AVAILABLE | EPEL 9 |
| KDE Plasma (full desktop) | ✅ AVAILABLE | EPEL 9 |

### ✅ Available Packages (CentOS Base Repos)

| Package | Status | Repository |
|---------|--------|------------|
| GNOME (full desktop) | ✅ AVAILABLE | AppStream |
| `adwaita-*` themes | ✅ AVAILABLE | BaseOS/AppStream |
| `gnome-themes-extra` | ✅ AVAILABLE | AppStream |

---

## Available Desktop Environments for CentOS Stream 9

| Desktop | Source | Recommendation |
|---------|--------|----------------|
| **GNOME 40** | CentOS Base | ✅ **RECOMMENDED** - Best support, native |
| **XFCE** | EPEL 9 | ✅ Good - Lightweight option |
| **KDE Plasma 5.27** | EPEL 9 | ✅ Good - Full-featured |
| Budgie | ~~stenstorp COPR~~ | ❌ **NOT SUPPORTED** on EL9 |
| Cinnamon | ~~stenstorp COPR~~ | ❌ NOT SUPPORTED on EL9 |
| MATE | ~~stenstorp COPR~~ | ❌ NOT SUPPORTED on EL9 |

---

## Fixed Recipes

The following fixed recipes have been created:

| File | Description |
|------|-------------|
| `recipe-fixed.yml` | Main recipe using GNOME instead of Budgie |
| `desktop-gnome-fixed.yml` | GNOME desktop (verified packages only) |
| `desktop-xfce-fixed.yml` | XFCE desktop (verified packages only) |
| `base-repos-fixed.yml` | Repository config (removed unavailable COPRs) |
| `files/scripts/enable-repos-fixed.sh` | Script without Budgie COPR |

### To Build with GNOME (Recommended)

```bash
bluebuild build ./recipes/recipe-fixed.yml
```

### To Build with XFCE

Edit `recipe-fixed.yml` and change:
```yaml
- from-file: desktop-gnome-fixed.yml
```
to:
```yaml
- from-file: desktop-xfce-fixed.yml
```

### To Build with KDE Plasma

The original `desktop-plasma.yml` should work, but verify all package names are correct for EPEL 9.

---

## If You Really Need Budgie on EL9

You have the following options:

1. **Request EL9 support** from the COPR maintainer (stenstorp)
   - Open an issue on their COPR project requesting `epel-9-x86_64` chroot

2. **Build the packages yourself**
   - Fork the COPR
   - Add EL9 as a build target
   - Handle any dependency issues

3. **Use a Fedora base image** instead of CentOS Stream 9
   - Budgie is natively available in Fedora repos
   - Change base-image: `quay.io/fedora/fedora-bootc:41`

4. **Use AlmaLinux 8 or Rocky Linux 8**
   - stenstorp/budgie does support EL8
   - Downside: EL8 EOL is sooner than EL9

---

## Additional Notes

### lightdm-gtk vs lightdm-gtk-greeter

In EPEL 9, the package is `lightdm-gtk` not `lightdm-gtk-greeter`. Verify the exact package name:
```bash
dnf search lightdm
```

### Verifying Package Availability

Before adding packages to your recipe, verify they exist:
```bash
# Enable repos first
dnf config-manager --set-enabled crb
dnf install epel-release epel-next-release

# Search for a package
dnf search <package-name>
dnf info <package-name>
```

### Package Sources Reference

- **CentOS BaseOS/AppStream:** https://mirror.stream.centos.org/9-stream/
- **EPEL 9:** https://dl.fedoraproject.org/pub/epel/9/
- **COPR repos:** https://copr.fedorainfracloud.org/

---

## Summary

**Your build failed because Budgie Desktop is not available for CentOS Stream 9.**

The stenstorp/budgie COPR only supports EL8 (not EL9). Additionally, several theming packages (arc-theme, greybird, blueman) are not available in EPEL 9.

**Solution:** This project now uses **KDE Plasma 5.27 LTS** from EPEL 9.

### Build Command

```bash
bluebuild build ./recipes/recipe.yml
```

### What Was Changed

1. `recipe.yml` - Now uses `desktop-plasma-fixed.yml`
2. `enable-repos.sh` - Removed unavailable Budgie COPR repos
3. `desktop-plasma-fixed.yml` - Verified KDE Plasma packages for EPEL 9

### Alternative Desktops

To use a different desktop, edit `recipe.yml` and change the `from-file:` line:

```yaml
# For GNOME (from base repos):
- from-file: desktop-gnome-fixed.yml

# For XFCE (from EPEL 9):
- from-file: desktop-xfce-fixed.yml
```
