# In this repo
Dockerfiles used for development.
The Docker files consist of multiple stages that can be used for different stages of development (e.g., testing, development, etc.).

# Building images
To build images, run
```bash
docker build . -f cpp.Dockerfile --target dev
```
where `.` can be replaced with the context (i.e., where the container is built from), `cpp.Dockerfile` can be replaced with the appropriate file, and `dev` can be replaced with the target from the Dockerfile (i.e., what comes after `AS`).

# Running containers
To run a container, build it using the commands above and then run
```bash
docker run -it --rm cpp:dev bash
```
where `--rm` removes the container once it exits (i.e., it makes it a temporary container).

## List of useful flags and mounts
| Mount                                         | Description                                                   |
|-----------------------------------------------|---------------------------------------------------------------|
| `~/.ssh/id_ed25519:/home/cpp/.ssh/id_ed25519` | SSH private key. Allows using SSH within the container        |
| `~/.zsh_history:/home/cpp/.zsh_history`       | ZSH command history                                           |
| `-e DISPLAY=$DISPLAY`                         | Set display                                                   |
| `/tmp/.X11-unix:/tmp/.X11-unix`               | Forward X11 port                                              |
| `--hostname hostname`                         | Set container host-name                                       |
| `--network host`                              | Set network to host (useful when developing web applications) |


