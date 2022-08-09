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

## Running with git ssh keys
To run ssh with the same private key as the host, mount or copy the keys in the `.ssh` directory into the container.
```bash
docker run -it --rm -v ~/.ssh/id_ed25519:/root/.ssh/id_ed25519 cpp:dev bash
```
