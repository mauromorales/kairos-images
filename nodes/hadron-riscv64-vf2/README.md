# Hadron for the StarFive VisionFive 2 (riscv64) with k0s

A Hadron-based Kairos image for the VisionFive 2, with k0s. It is an experiment: it
has not been booted on the board.

Hadron publishes no riscv64 image. Its releases are amd64 and arm64 only; riscv64 is
built in its own pull-request CI. So the base is built by hand.

## What is in it

| Part | Version |
|---|---|
| Hadron | v0.7.0 (`main` at d50ff6d), kernel 7.3.6-hadron, GRUB |
| Kairos layer | from Hadron's `make build-kairos` (kairos-init), core image |
| provider-kairos | Kairos v4.4.0 riscv64 release. The core image does not have it. It reads `k0s:` and `k0s-worker:` from the cloud-config |
| k0s | v1.36.4+k0s.0, the unofficial riscv64 build in release `k0s-riscv64-v1.36.4-k0s.0` of this repository (sha256 is checked in the Dockerfile) |

Hadron's kernel has the JH7110 drivers but not the HDMI patches of
`../kairos-riscv64-vf2`. Use serial or SSH. The image has no `/boot/dtb`: on the
board, U-Boot 2025.10 passes its own device tree through EFI.

## Build

The base takes about 12 hours on 16 cores under QEMU. Run it at low priority.

```sh
git clone https://github.com/kairos-io/hadron && cd hadron
git checkout d50ff6d86461f0bf4958620266955bf56922f6e4
make build-hadron ARCH=riscv64 HADRON_VERSION=v0.7.0 JOBS=16   # makes hadron:local
make build-kairos ARCH=riscv64 VERSION=v0.7.0 BOOTLOADER=grub  # makes hadron-init:latest
docker build --platform linux/riscv64 -t <registry>/kairos-riscv64:<tag> nodes/hadron-riscv64-vf2
```

## Tag

`hadron-<hadron version>-standard-riscv64-visionfive2-<image version>-k0sv<k0s version>`

The first image is
`quay.io/mauromorales/kairos-riscv64:hadron-v0.7.0-standard-riscv64-visionfive2-0.1.0-k0sv1.36.4`.
A tag is never moved or reused.

## ISO

The workflow `build-hadron-riscv64-vf2-iso.yaml` takes a pushed image tag and makes
the live ISO with AuroraBoot, as the Ubuntu VF2 release job does. It makes a draft
release; nothing is public until you publish it. Install steps and the U-Boot update
are the same as in `../kairos-riscv64-vf2/README.md`.
