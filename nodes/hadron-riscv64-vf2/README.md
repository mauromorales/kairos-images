# Hadron for the StarFive VisionFive 2 (riscv64) with k0s

A Hadron-based Kairos image for the VisionFive 2, with k0s. It is an experiment: it
has not been booted on the board.

Hadron publishes no riscv64 image. Its releases are amd64 and arm64 only; riscv64 is
built in its own pull-request CI. So the base is built by hand.

## What is in it

| Part | Version |
|---|---|
| Hadron | `main` at d50ff6d (6 commits after v0.7.0, built with `HADRON_VERSION=v0.7.0`), kernel 7.3.6-hadron, GRUB |
| Kairos layer | from Hadron's `make build-kairos` (kairos-init), core image |
| provider-kairos | Kairos v4.4.0 riscv64 release. The core image does not have it. It reads `k0s:` and `k0s-worker:` from the cloud-config |
| k0s | v1.36.4+k0s.0, the unofficial riscv64 build in release `k0s-riscv64-v1.36.4-k0s.0` of this repository (sha256 is checked in the Dockerfile) |

Hadron's kernel has the JH7110 drivers but not the HDMI patches of
`../kairos-riscv64-vf2`. Use serial or SSH. The image has no `/boot/dtb`: on the
board, U-Boot 2025.10 passes its own device tree through EFI.

## Build

The base takes about 12 hours on 16 cores under QEMU. Run it at low priority.

```sh
git clone https://github.com/kairos-io/hadron && git clone https://github.com/mauromorales/kairos-images
cd hadron
git checkout d50ff6d86461f0bf4958620266955bf56922f6e4
make build-hadron ARCH=riscv64 HADRON_VERSION=v0.7.0 JOBS=16   # makes hadron:local
make build-kairos ARCH=riscv64 VERSION=v0.7.0 BOOTLOADER=grub  # makes hadron-init:latest
docker build --platform linux/riscv64 -t <registry>/kairos-riscv64:<tag> ../kairos-images/nodes/hadron-riscv64-vf2
```

## Tag

`hadron-<hadron version>-standard-riscv64-visionfive2-<image version>-k0sv<k0s version>`

The first image is
`quay.io/mauromorales/kairos-riscv64:hadron-v0.7.0-standard-riscv64-visionfive2-0.1.0-k0sv1.36.4`.
A tag is never moved or reused.

## ISO

The workflow `build-hadron-riscv64-vf2-iso.yaml` takes a pushed image tag and makes
the live ISO with AuroraBoot, as the Ubuntu VF2 release job does. It makes a draft
release; nothing is public until you publish it.

Install: use steps 1 to 3 of `../kairos-riscv64-vf2/README.md` (update U-Boot to 2025.10,
boot the ISO, run `kairos-agent manual-install`). Skip its HDMI GRUB entry: this kernel has
no display patches and the image has no `/boot/dtb`. Its example cloud-config is for k3s;
write a `k0s:` or `k0s-worker:` stanza instead.

The image version (`0.1.0`) is in the tag and the release, not in `os-release`: the Kairos
layer was built with `VERSION=v0.7.0`.
