#!/usr/bin/env bash
# Enable CRB and EPEL for CentOS Stream 9
# Removed Budgie COPR - stenstorp/budgie only supports EL8, NOT EL9/CS9
set -euo pipefail

echo "==> Enabling CRB repository..."
dnf config-manager --set-enabled crb || true

echo "==> Installing EPEL release packages..."
dnf -y install \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    https://dl.fedoraproject.org/pub/epel/epel-next-release-latest-9.noarch.rpm \
    || true

# NOTE: Budgie COPR repos removed - they do NOT support CentOS Stream 9
# stenstorp/budgie only builds for Fedora + EL8 (not EL9)
# Using KDE Plasma from EPEL 9 instead

# Verify enabled repos
echo "==> Enabled repositories:"
dnf repolist enabled

echo "==> Repos configured successfully."
