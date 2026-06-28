# RL-Based RISC-V Verification

This repository provides an environment for experimenting with reinforcement learning techniques for RISC-V processor verification.

The project uses:

* lowRISC Ibex RISC-V processor
* Verilator for RTL simulation
* Cocotb for Python-based verification
* PyTorch
* Stable-Baselines3
* RISC-V ISA analysis tools
* Docker for a reproducible development environment

## Repository structure

A typical project structure is:

```text
RL_RISC-V_VERIFICATION/
├── Dockerfile
├── requirements.txt
├── README.md
├── rtl/
├── tests/
├── scripts/
└── results/
```

The exact structure may change as the project develops.

## Prerequisites

Install Docker before building the project.

Verify that Docker is available:

```bash
docker --version
```

## Clone the repository

```bash
git clone https://github.com/HosseinRostami/RL_RISC-V_VERIFICATION.git
cd RL_RISC-V_VERIFICATION
```


## Build the Docker image

Run the following command from the repository root, where the `Dockerfile` and `requirements.txt` are located:

```bash
docker build --progress=plain -t rl-verif-env .
```

Explanation:

* `docker build` builds the Docker image.
* `--progress=plain` displays detailed build output.
* `-t rl-verif-env` names the image `rl-verif-env`.
* `.` uses the current directory as the Docker build context.

The first build may take a long time because large Python packages, including PyTorch, must be downloaded.

After a successful build, verify the image:

```bash
docker images
```

You should see an image named:

```text
rl-verif-env
```

## Run the Docker container

Run the container and mount the current repository into `/workspace/my_code`:

```bash
docker run --rm -it \
  -v "$(pwd):/workspace/my_code" \
  -w /workspace/my_code \
  rl-verif-env
```

Explanation:

* `--rm` removes the stopped container automatically.
* `-it` opens an interactive terminal.
* `-v "$(pwd):/workspace/my_code"` mounts the current host directory inside the container.
* `-w /workspace/my_code` sets the mounted project directory as the working directory.
* `rl-verif-env` is the Docker image name.

Files created or modified under `/workspace/my_code` inside the container are also changed in the host repository.

For Windows PowerShell, use:

```powershell
docker run --rm -it `
  -v "${PWD}:/workspace/my_code" `
  -w /workspace/my_code `
  rl-verif-env
```

## Verify the environment

After entering the container, verify the main tools:

```bash
verilator --version
python3 --version
gcc --version
g++ --version
cmake --version
```

Check the installed Python packages:

```bash
python3 -c "import cocotb; print('Cocotb:', cocotb.__version__)"
python3 -c "import torch; print('PyTorch:', torch.__version__)"
python3 -c "import stable_baselines3; print('Stable-Baselines3:', stable_baselines3.__version__)"
```

Check that the Ibex source exists:

```bash
ls /workspace/ibex
```

## Exit the container

To leave the container:

```bash
exit
```

Because the container is started with `--rm`, it is deleted after exiting. The project files remain available on the host because they are stored in the mounted repository directory.

## Rebuild after changing dependencies

After modifying `requirements.txt` or the `Dockerfile`, rebuild the image:

```bash
docker build --progress=plain -t rl-verif-env .
```

Docker will reuse unchanged cached layers when possible.

To force a completely clean build:

```bash
docker build --no-cache --progress=plain -t rl-verif-env .
```

Use `--no-cache` only when necessary, because it forces all packages to be downloaded and installed again.

## Troubleshooting

### Slow Python package downloads

The first build can be slow because PyTorch and its dependencies are large. The Dockerfile uses a pip cache and extended timeout settings to reduce failures caused by slow connections.

Run the normal build command again after a temporary network failure:

```bash
docker build --progress=plain -t rl-verif-env .
```

### Permission problems in mounted files

On Linux, run the container using your host user and group IDs:

```bash
docker run --rm -it \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd):/workspace/my_code" \
  -w /workspace/my_code \
  rl-verif-env
```

## Export and Compress the Docker Image

After building the Docker image, you can export and compress it so it can be stored, backed up, or transferred to another machine.

### Save and compress with gzip

```bash
docker save rl-verif-env:latest | gzip > rl-verif-env.tar.gz
```

This creates:

```text
rl-verif-env.tar.gz
```

Check the compressed file size:

```bash
ls -lh rl-verif-env.tar.gz
```

To load the image again:

```bash
gunzip -c rl-verif-env.tar.gz | docker load
```

### Save with stronger xz compression

For a smaller archive, use:

```bash
docker save rl-verif-env:latest | xz -T0 -9 > rl-verif-env.tar.xz
```

Explanation:

* `docker save` exports the Docker image.
* `xz` compresses the exported image.
* `-T0` uses all available CPU cores.
* `-9` uses maximum compression.

Check the archive:

```bash
ls -lh rl-verif-env.tar.xz
```

To restore the image:

```bash
xz -dc rl-verif-env.tar.xz | docker load
```

`xz` usually produces a smaller file than `gzip`, but compression takes longer.


## Author

Hossein Rostami
