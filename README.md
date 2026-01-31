# Node.js TypeScript Dev Container for Docker Desktop

This is a Node.js TypeScript dev container intended to provide a secure "sandbox" for running Claude Code and Codex CLI on [Docker Desktop](https://docs.docker.com/desktop/).

Docker Desktop (macOS, Windows, Linux) runs its containers in its own lightweight Linux VM, which provides secure isolation between the Linux VM running the containers and the host. 

DO NOT ASSUME AND RELY ON SECURE ISOLATION BETWEEN CONTAINERS. Docker containers do not provide adequate isolation between themselves because they share the same Linux kernel. In addition, the devcontainer runs in privileged mode in order to run Docker in Docker.

The dev container provides:
* Node 24 on Debian Linux Trixie
* pnpm 10
* bash, fish shells
* Claude Code, Codex CLI
* Forwarding of port 3000 of the devcontainer to the host
* ssh agent forwarding
* Persistent home directory
* Persistent inner docker images/volumes

## Usage

Copy the `.devcontainer/` directory to any TypeScript project directory and open that project with an IDE or editor that supports dev containers.

### VSCode

[VSCode]((https://code.visualstudio.com/docs/devcontainers/containers)) has full support for running/building dev containers.

### Zed

[Zed]((https://zed.dev/docs/dev-containers)) has partial support for running/building dev containers.

### devcontainer CLI

You can also run/build devcontainers via the [devcontainer CLI](https://github.com/devcontainers/cli)

Install CLI:

```sh
npm i -g @devcontainers/cli
```

Build and start devcontainer from directory containing `.devcontainer/`:

```sh
devcontainer up --workspace-folder PATH_TO_PROJECT_DIRECTORY
```

Open bash shell to devcontainer from the directory containing `.devcontainer/`:

```sh
devcontainer exec --workspace-folder PATH_TO_PROJECT_DIRECTORY bash
```

Stop devcontainer (not yet implemented in the devcontainer CLI):

```sh
docker ps -a \
  --filter "label=devcontainer.local_folder=$(pwd -P)" \
  --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
  
docker stop <container_id>
```

## Using 1Password SSH Agent on macOS

### Setup `SSH_AUTH_SOCK`

Make sure `SSH_AUTH_SOCK` points to 1Password ssh agent on Mac

```sh
launchctl setenv SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

launchctl getenv SSH_AUTH_SOCK
```

To persist `SSH_AUTH_SOCK` across reboots

```sh
bash -lc 'mkdir -p "$HOME/Library/LaunchAgents" && cat > "$HOME/Library/LaunchAgents/com.op.ssh-auth-sock.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.op.ssh-auth-sock</string>

    <key>LimitLoadToSessionType</key>
    <array>
      <string>Aqua</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>ProgramArguments</key>
    <array>
      <string>/bin/launchctl</string>
      <string>setenv</string>
      <string>SSH_AUTH_SOCK</string>
      <string>$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock</string>
    </array>
  </dict>
</plist>
EOF'

bash -lc 'launchctl unload "$HOME/Library/LaunchAgents/com.op.ssh-auth-sock.plist" 2>/dev/null || true; launchctl load "$HOME/Library/LaunchAgents/com.op.ssh-auth-sock.plist"'
```

### Open Docker Desktop via command line

You must start Docker Desktop via the terminal instead of opening the Docker Desktop app via the Finder. If Docker Desktop was already started, quit it and reopen it via terminal.

```sh
open -a Docker
```

### Checking if Docker Desktop is using 1Password SSH Agent

This should list the ssh Identiies in 1Password:

```sh
docker run --rm -it \
    --mount type=bind,src=/run/host-services/ssh-auth.sock,target=/run/host-services/ssh-auth.sock \
    -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock \
    alpine:3.19 sh -lc 'apk add --no-cache openssh-client >/dev/null; ssh-add -l || true'
```
