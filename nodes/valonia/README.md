# valonia

The ARM64 worker of the `belgica` cluster: a Raspberry Pi 4 (8 GB). The image is Kairos
Hadron for the Pi 4 with k0s. It is built by `.github/workflows/build-valonia.yaml` with the
Kairos factory action, from the Hadron base that Kairos publishes (`ghcr.io/kairos-io/hadron`).
There is no custom base image and no Dockerfile.

Upstream publishes Hadron for the Pi 4 only with k3s or with no Kubernetes at all, so this
node builds its own with k0s.

Output: a raw disk image (`-img` tag on `quay.io/mauromorales/valonia`). Write it to the SD card
or disk. The node config goes on the `COS_OEM` partition as `90_custom.yaml`. See
`nodes/belgica/README.md` in `mauromorales/homelab`.

Not checked yet: that Hadron boots on a real Pi 4 with this image.
