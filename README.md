# TypeScript Dev Container for Docker Desktop on macOS

This is a dev container for TypeScript development intended to provide a secure "sandbox" for running Claude Code and other AI agents. 

Docker Desktop for macOS runs its containers in a lightweight Linux VM, which does provide secure isolation between the Linux VM runing the containers and the macOS host. 

But Docker containers do not provide secure isolation between themselves because they share the same Linux kernel. In addition, the devcontainer runs in privileged mode in order to run Docker in Docker. DO NOT ASSUME AND RELY ON SECURE ISOLATION BETWEEN CONTAINERS.

The dev container provides:
* Node 24 in Debian Linux Trixie
* pnpm 10
* bash, fish shells
* Claude Code, Codex CLI
* ssh agent forwarding
* persistent home directory
* persistent inner docker images/volumes
* Forwarding of port 3000 of the devcontainer to the macOS host

SSH agent forwarding from your Mac is supported, allowing ssh-based git to work.

Note: Since the devcontainer is run within a Linux VM, `node_modules/` will be Linux-based if installed within the devcontainer. Probably best to use a separate clone of the git repo from what's used for dev on locally on the Mac.

## To Use:

Copy the `.devcontainer` directory to any TypeScript project directory and open that project with an IDE or editor that supports dev containers.

### VSCode

VSCode has native support for running/building devcontainers:
 
[https://code.visualstudio.com/docs/devcontainers/containers](https://code.visualstudio.com/docs/devcontainers/containers)

### devcontainer CLI

You can also run/build devcontainers via the devcontainer CLI

#### Install CLI:

```sh
npm i -g @devcontainers/cli
```

#### Build and start devcontainer:

In the directory containing `.devcontainer/`

```sh
devcontainer up --workspace-folder PATH_TO_PROJECT_DIRECTORY
```

#### Open bash shell in devcontainer:

In the directory containing .devcontainer/

```sh
devcontainer exec --workspace-folder PATH_TO_PROJECT_DIRECTORY bash
```

#### Stop devcontainer:

It's planned but not implemented in the devcontainer CLI yet.

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
