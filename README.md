# dregsy-skopeo
Dregsy and Skopeo, built from source to an [OCI image](https://github.com/tkcp-k8s/dregsy-skopeo/pkgs/container/dregsy-skopeo)

## Usage

```bash
# pull
docker pull ghcr.io/tkcp-k8s/dregsy-skopeo:latest

# run skopeo... 
docker run -it ghcr.io/tkcp-k8s/dregsy-skopeo:latest skopeo --version

# run dregsy...
docker run -it ghcr.io/tkcp-k8s/dregsy-skopeo:latest dregsy ...
```
