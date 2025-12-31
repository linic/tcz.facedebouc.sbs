#!/bin/sh
unsquashfs -lc $1 | sed 's|^squashfs-root||' > $1.list
