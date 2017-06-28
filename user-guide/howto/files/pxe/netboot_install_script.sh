#!/usr/bin/bash
#
# The logic is simple:
#  1. Download and extract USB image into /tmp/usbkey
#  2. Run prompt-config.sh, which will create /usbkey on the zones pool
#  3. Copy contents of /tmp/usbkey into /usbkey
#####

# Adjust this: download URL of the compute node USB image
USB_URL="http://10.10.0.33/esdc-ce-cn-latest.img"
###########################################################

export PATH="/usr/sbin:/sbin:/usr/bin:/bin"

# Active network interface
NIC_UP="$1"
# /usbkey
USB_PATH="/$(svcprop -p "joyentfs/usb_copy_path" svc:/system/filesystem/smartdc:default)"
# /mnt/usbkey
USBMOUNT="/mnt/$(svcprop -p "joyentfs/usb_mountpoint" svc:/system/filesystem/smartdc:default)"
# Download USB image into /tmp
USBIMAGE="/tmp/usbkey.iso"
# Danube Cloud prompt-config.sh
PROMPT_CONFIG="${USBMOUNT}/scripts/prompt-config.sh"

echo "=> Running netboot_install_script"

if [[ -f "${USB_PATH}/.joyliveusb" ]]; then
	echo "${USB_PATH} is already in place" >&2
	exit 0
fi

echo "=> Preparing ${USBMOUNT}"
mkdir -p "${USBMOUNT}"

echo "=> Downloading compute node USB image into ${USBIMAGE}"
if ! curl -m 30 -f -k -L --progress-bar -o "${USBIMAGE}" "${USB_URL}"; then
	echo "ERROR: Failed to download \"${USB_URL}\"" >&2
	exit 1
fi

echo "=> Mounting USB image"
LOFIDEV=$(lofiadm -a "${USBIMAGE}")
mount -F pcfs -o noclamptime,noatime "${LOFIDEV}:c" "${USBMOUNT}"

if [[ ! -f "${USBMOUNT}/scripts/prompt-config.sh" ]]; then
	echo "ERROR: \"${USBMOUNT}/scripts/prompt-config.sh\" does not exist" >&2
	exit 2
fi

echo "=> Shutting down network (${NIC_UP})"
[[ -n "${NIC_UP}" ]] && /sbin/ifconfig "${NIC_UP}" inet down unplumb

echo "=> Running prompt-config.sh"
/smartdc/lib/sdc-on-tty -d /dev/console "${PROMPT_CONFIG}" "${USBMOUNT}"

echo "=> Copying files from USB image onto disk storage"
echo "=> Please wait..."
rsync -a --exclude private --exclude os "${USBMOUNT}/" "${USB_PATH}/"

echo "=> The system will now reboot"
reboot 2> /dev/null
