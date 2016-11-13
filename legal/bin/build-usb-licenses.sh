#!/bin/bash

BASEDIR="$(cd "$(dirname "$0")/.." ; pwd -P)"
LICENSES="${BASEDIR}/usb/LICENSES.txt"

cat "${BASEDIR}/licenses/trademarks.txt" > "${LICENSES}"

for dir in "${BASEDIR}"/licenses/*; do
	if [[ -d "${dir}" ]]; then
		dirname=$(basename "${dir}")
		echo -e "\n\n${dirname}\n==============================\n" >> "${LICENSES}"

		for file in "${dir}"/*; do
			cat "${file}" >> "${LICENSES}"
			echo >> "${LICENSES}"
		done
	fi
done
