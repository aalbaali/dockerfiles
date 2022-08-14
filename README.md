# In this repo
Dockerfiles used for development.
The Docker files consist of multiple stages that can be used for different stages of development (e.g., testing, development, etc.).

# Building images
To build images, run
```bash
docker build . -f cpp.Dockerfile --target dev cpp:target
```
where `.` can be replaced with the context (i.e., where the container is built from),
`cpp.Dockerfile` can be replaced with the appropriate file, and `dev` can be replaced with the
target from the Dockerfile (i.e., what comes after `AS`).
The `cpp:target` are shown when displaying the image (i.e., `docker image ls`) under `REPOSITORY`
and `TARGET`, respectively. 

To use a specific username in the build, use `--build-arg USERNAME=username`, which replaces the
`USERNAME` argument in the Dockerfile.

# Running containers
To run a container, build it using the commands above and then run
```bash
docker run -it --rm cpp:dev bash
```
where `--rm` removes the container once it exits (i.e., it makes it a temporary container).

## List of useful flags and mounts
The following commands are useful when running `docker run`

| Mount                                         | Description                                                   |
|-----------------------------------------------|---------------------------------------------------------------|
| `~/.ssh:/home/cpp/.ssh/`                      | SSH keys. Allows using SSH within the container               |
| `~/.zsh_history:/home/cpp/.zsh_history`       | ZSH command history                                           |
| `-e DISPLAY=$DISPLAY`                         | Set display                                                   |
| `/tmp/.X11-unix:/tmp/.X11-unix`               | Forward X11 port                                              |
| `--hostname hostname`                         | Set container host-name                                       |
| `--network host`                              | Set network to host (useful when developing web applications) |

# Common issues
## Ctrl+P not working properly
The `<C-P>` is used by Docker to detach keys.
To change the key, update the `"detachKeys"` in `~/.docker/config.json`.
For example
```bash
    "detachKeys": "ctrl-z,z"
```
Check [this answer](https://stackoverflow.com/questions/20828657/docker-change-ctrlp-to-something-else) for more details.
