# Oh My Zsh Dotfiles

A dotfiles repository for configuring a terminal environment with Oh My Zsh, Powerlevel10k, and productivity plugins. Designed for use with VS Code devcontainers.

![Zsh](https://img.shields.io/badge/shell-zsh-green)
![Oh My Zsh](https://img.shields.io/badge/framework-oh--my--zsh-blue)
![Powerlevel10k](https://img.shields.io/badge/theme-powerlevel10k-purple)
## Features

- **Oh My Zsh** - Zsh configuration framework
- **Powerlevel10k** - Fast, customizable prompt theme
- **zsh-autosuggestions** - Fish-like command autosuggestions
- **zsh-syntax-highlighting** - Command syntax highlighting
- **Tmux** - Terminal multiplexer with session management
- **Tmux Plugin Manager (TPM)** - Plugin management for tmux
- **Dracula Theme** - Beautiful dark theme for tmux
- **Session persistence** - Automatically save and restore tmux sessions
- **Automatic zsh launch** - Seamless integration with bash-default containers

## Setup

### Option 1: VS Code Dotfiles (Recommended)

1. Fork this repository to your GitHub account

2. Add to your VS Code settings (`settings.json`):

```json
{
  "dotfiles.repository": "YOUR_USERNAME/oh-my-zsh-dev-env",
  "dotfiles.targetPath": "~/dotfiles",
  "dotfiles.installCommand": "install.sh"
}
```

3. New devcontainers will automatically configure your shell environment.

### Option 2: Manual Installation

```bash
git clone https://github.com/YOUR_USERNAME/oh-my-zsh-dev-env.git ~/dotfiles
cd ~/dotfiles && ./install.sh
```

### Option 3: Via devcontainer.json

Add to `.devcontainer/devcontainer.json`:

```json
{
  "postCreateCommand": "git clone https://github.com/raulstechtips/oh-my-zsh-dev-env.git ~/dotfiles && ~/dotfiles/install.sh"
}
```

## Repository Structure

```
oh-my-zsh-dev-env/
├── install.sh     # Installation script
├── .zshrc         # Zsh configuration
├── .p10k.zsh      # Powerlevel10k theme config
├── .tmux.conf     # Tmux configuration with plugins
└── README.md
```

## Font Configuration

Powerlevel10k requires a Nerd Font for proper icon display.

**Recommended font:** MesloLGS NF

Download from: https://github.com/romkatv/powerlevel10k#fonts

Configure VS Code terminal font:

```json
{
  "terminal.integrated.fontFamily": "MesloLGS NF"
}
```

## Included Plugins

The `.zshrc` includes several Oh My Zsh plugins. These are bundled with Oh My Zsh and provide command completion and aliases for common tools:

| Plugin | Purpose |
|--------|---------|
| `git` | Git aliases and completion |
| `docker` | Docker command completion |
| `kubectl` | Kubernetes CLI completion |
| `tmux` | Tmux aliases and session management |
| `npm` | npm/yarn completion |
| `node` | Node.js version display |
| `python` | Python aliases |
| `pip` | pip completion |
| `virtualenv` | Virtualenv indicator |
| `zsh-autosuggestions` | Command suggestions (custom) |
| `zsh-syntax-highlighting` | Syntax highlighting (custom) |

Plugins only activate if the corresponding tool is installed. Unused plugins have no effect.

## Tmux Setup

This configuration includes tmux with the following plugins (managed by TPM):

| Plugin | Purpose |
|--------|---------|
| `tmux-sensible` | Basic tmux settings everyone can agree on |
| `dracula/tmux` | Beautiful Dracula dark theme |
| `tmux-resurrect` | Save and restore tmux sessions |
| `tmux-continuum` | Automatic session save/restore |

**Key Features:**
- **Vi key bindings** - Navigate tmux using vim-style keys
- **Mouse support** - Click to switch panes and windows
- **Session persistence** - Sessions automatically save and restore after system restart
- **Dracula theme** - Clean, professional appearance with system stats
- **Smart pane navigation** - Alt+Arrow keys to switch panes without prefix

## Included Aliases

### Git

| Alias | Command |
|-------|---------|
| `gs` | `git status` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gcm` | `git commit -m` |
| `gp` | `git push` |
| `gl` | `git pull` |
| `gd` | `git diff` |
| `gco` | `git checkout` |
| `gcob` | `git checkout -b` |
| `gb` | `git branch` |
| `glog` | `git log --oneline --graph --decorate` |

### Docker

| Alias | Command |
|-------|---------|
| `dps` | `docker ps` |
| `dpsa` | `docker ps -a` |
| `dimg` | `docker images` |
| `dexec` | `docker exec -it` |

### Kubernetes

| Alias | Command |
|-------|---------|
| `k` | `kubectl` |
| `kgp` | `kubectl get pods` |
| `kgs` | `kubectl get services` |
| `kgd` | `kubectl get deployments` |
| `kaf` | `kubectl apply -f` |
| `kdf` | `kubectl delete -f` |

### Tmux

| Alias | Command | Description |
|-------|---------|-------------|
| `ta` | `tmux attach -t` | Attach to existing session |
| `tl` | `tmux list-sessions` | List all sessions |
| `ts` | `tmux new-session -s` | Create new named session |
| `tksv` | `tmux kill-server` | Kill tmux server |
| `tkss` | `tmux kill-session -t` | Kill specific session |

**Tmux Keybindings:**
- `Alt + Arrow Keys` - Switch between panes
- `Prefix + Shift + Arrow` - Swap window positions
- `Prefix + r` - Reload tmux config
- `Prefix + c` - New window (opens in current directory)
- `Prefix + "` - Split pane horizontally
- `Prefix + %` - Split pane vertically

## Customization

### Reconfigure Powerlevel10k

```bash
p10k configure
```

### Add Custom Aliases

Edit `.zshrc` and add aliases to the appropriate section.

### Modify Plugins

Edit the `plugins` array in `.zshrc`. Built-in plugins are listed at:
https://github.com/ohmyzsh/ohmyzsh/wiki/Plugins

## How It Works

The `install.sh` script performs the following:

1. Installs system dependencies (zsh, git, curl, tmux)
2. Installs Oh My Zsh framework
3. Installs Powerlevel10k theme
4. Installs custom plugins (autosuggestions, syntax-highlighting)
5. Installs Tmux Plugin Manager (TPM)
6. Creates symlinks from `~/.zshrc`, `~/.p10k.zsh`, and `~/.tmux.conf` to this repository
7. Installs tmux plugins (Dracula theme, resurrect, continuum)
8. Configures `.bashrc` to automatically launch zsh
9. Configures tmux to use zsh as default shell

The bash-to-zsh auto-launch ensures zsh is used even when containers default to bash. Tmux is configured to always use zsh, and sessions are automatically saved/restored.

## Troubleshooting

**Icons not displaying correctly**
- Install a Nerd Font and configure your terminal to use it

**Zsh not launching**
- Verify zsh is installed: `which zsh`
- Check bashrc: `grep -A2 "oh-my-zsh-dotfiles" ~/.bashrc`

**Slow prompt**
- Run `p10k configure` and enable instant prompt

**Tmux plugins not working**
- Enter tmux and press `Prefix + I` (capital i) to install plugins
- Prefix is `Ctrl+b` by default
- Or run: `~/.tmux/plugins/tpm/bin/install_plugins`

**Tmux not using zsh**
- Verify zsh is installed: `which zsh`
- Check tmux config: `tmux show-options -g default-shell`
- Should show `/bin/zsh`
