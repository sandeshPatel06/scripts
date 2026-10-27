#!/bin/bash
# =============================================================================
# ZSH SETUP SCRIPT - REAK Workstation
# Installs ZSH, Oh My Zsh, plugins, themes, full config with REAK logo
# =============================================================================
set -e

echo "========================================="
echo "  ZSH SETUP - REAK Workstation"
echo "========================================="

# ---- 1. Check/Install ZSH ----
echo "[1/6] Checking ZSH installation..."
if ! command -v zsh &> /dev/null; then
    echo "ZSH not found. Installing..."
    sudo apt update
    sudo apt install -y zsh
else
    echo "✓ ZSH already installed: $(zsh --version)"
fi

# ---- 2. Install Oh My Zsh ----
echo "[2/6] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo "✓ Oh My Zsh installed"
else
    echo "✓ Oh My Zsh already installed"
fi

# ---- 3. Install ZSH Plugins ----
echo "[3/6] Installing ZSH plugins..."
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

plugins=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions:https://github.com/zsh-users/zsh-completions"
    "zsh-history-substring-search:https://github.com/zsh-users/zsh-history-substring-search"
    "you-should-use:https://github.com/MichaelAquilina/zsh-you-should-use"
)

for plugin in "${plugins[@]}"; do
    IFS=':' read -r name url <<< "$plugin"
    if [ ! -d "${ZSH_CUSTOM}/plugins/${name}" ]; then
        echo "  Installing ${name}..."
        git clone --depth=1 "$url" "${ZSH_CUSTOM}/plugins/${name}" 2>/dev/null || true
    else
        echo "  ✓ ${name} already installed"
    fi
done

# ---- 4. Install Powerlevel10k Theme ----
echo "[4/6] Installing Powerlevel10k theme..."
if [ ! -d "${ZSH_CUSTOM}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM}/themes/powerlevel10k
    echo "✓ Powerlevel10k installed"
else
    echo "✓ Powerlevel10k already installed"
fi

# ---- 5. Create Full .zshrc with REAK Logo & Dashboard ----
echo "[5/6] Creating .zshrc with REAK logo and welcome dashboard..."

cat > ~/.zshrc << 'ZSHRC_EOF'
# -----------------------------------------------------------------------------
# Oh My Zsh
# -----------------------------------------------------------------------------

export ZSH="$HOME/.oh-my-zsh"

REPORTTIME=10
ZSH_THEME="robbyrussell"
DISABLE_UNTRACKED_FILES_DIRTY="true"
HIST_STAMPS="yyyy-mm-dd"

plugins=(
  git
  docker
  z
  history
  colored-man-pages
  extract
  copypath
  copyfile
  web-search
  jsontools
  common-aliases
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  zsh-history-substring-search
  you-should-use
)

source "$ZSH/oh-my-zsh.sh"

# -----------------------------------------------------------------------------
# Zsh Options & History Tuning
# -----------------------------------------------------------------------------

HISTSIZE=50000
SAVEHIST=50000
HISTFILE="$HOME/.zsh_history"

setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS

# -----------------------------------------------------------------------------
# Environment Variables & SDK Paths
# -----------------------------------------------------------------------------

export EDITOR="nvim"

# Java
export JAVA_HOME="$HOME/java/jdk-21"

# Android
export ANDROID_HOME="$HOME/android-sdk"

# Go
export GOPATH="$HOME/go"
export GOROOT="/usr/local/go"

# -----------------------------------------------------------------------------
# PATH Construction (Deduplicated)
# -----------------------------------------------------------------------------

typeset -U path
path=(
  /usr/local/go/bin
  $GOPATH/bin
  $JAVA_HOME/bin
  $ANDROID_HOME/platform-tools
  $HOME/bin
  $HOME/.local/bin
  $HOME/.local/ollama/bin
  $HOME/.bun/bin
  $path
)
export PATH

# -----------------------------------------------------------------------------
# NVM (Lazy Loaded for Instant Shell Startup)
# -----------------------------------------------------------------------------

export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  _load_nvm() {
    unset -f nvm node npm npx yarn pnpm _load_nvm
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  }
  nvm() { _load_nvm; nvm "$@"; }
  node() { _load_nvm; node "$@"; }
  npm() { _load_nvm; npm "$@"; }
  npx() { _load_nvm; npx "$@"; }
  yarn() { _load_nvm; yarn "$@"; }
  pnpm() { _load_nvm; pnpm "$@"; }
fi

# -----------------------------------------------------------------------------
# Load External Environment Configuration
# -----------------------------------------------------------------------------

if [[ -f "$HOME/.env" ]]; then
  set -a
  source "$HOME/.env" 2>/dev/null
  set +a
fi

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------

# General & Navigation
alias cls="clear"
alias ll="ls -lh --color=auto"
alias la="ls -lah --color=auto"
alias l="ls -CF --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias -- -="cd -"

# Git
alias gs="git status"
alias ga="git add ."
alias gc="git commit -m"
alias gcm="git commit"
alias gp="git push origin"
alias gpl="git pull"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gl="git log --oneline -n 20"

# Docker
alias d="docker"
alias dc="docker compose"
alias dps="docker ps -a --size"
alias dlogs="docker logs -f"
alias dstop="docker stop \$(docker ps -q 2>/dev/null)"
alias dprune="docker system prune -af --volumes"

# Kubernetes
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get svc"
alias kgn="kubectl get nodes"
alias kdp="kubectl describe pod"
alias kl="kubectl logs -f"

# Go
alias gor="go run"
alias gob="go build"
alias got="go test ./..."
alias gom="go mod tidy"

# Tod / OneDev CLI
alias todc="tod config"

# -----------------------------------------------------------------------------
# Utility Functions
# -----------------------------------------------------------------------------

# Create directory and enter it immediately
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Falling Green Matrix Digital Rain Simulator
matrix() {
  local cols=$(tput cols)
  local rows=$(tput lines)
  trap "tput cnorm; clear; return" INT TERM
  tput civis
  clear
  local -A s
  local -A d
  for i in {1..$cols}; do
    s[$i]=$((RANDOM % rows + 1))
    d[$i]=$((RANDOM % 5 + 1))
  done
  while true; do
    for i in {1..$cols}; do
      local r=${s[$i]}
      tput cup $((r-1)) $((i-1))
      echo -n " "
      if [ $r -ge $rows ]; then
        s[$i]=1
        d[$i]=$((RANDOM % 5 + 1))
      else
        s[$i]=$((r + d[$i]))
      fi
      local next_r=${s[$i]}
      tput cup $((next_r-1)) $((i-1))
      echo -ne "\e[32m$(printf \\$(printf '%03o' $((RANDOM%93+33))))\e[0m"
    done
    sleep 0.05
  done
}

# Simulated Hacker Decryption Script
hack() {
  echo -ne "\e[1;31m[!] WARNING: INITIALIZING DECRYPTION PROTOCOL ON SECURE PORT\e[0m\n"
  sleep 0.5
  echo -ne "Connecting to target firewall..."
  sleep 0.5
  echo -ne " [ \e[32mOK\e[0m ]\n"
  sleep 0.3
  echo -ne "Bypassing biometric authorization..."
  sleep 0.6
  echo -ne " [ \e[32mOK\e[0m ]\n"
  sleep 0.3
  echo -ne "Extracting secret database tables..."
  sleep 0.5
  echo -ne " [ \e[31mACCESS DENIED\e[0m ]\n"
  sleep 0.4
  echo -ne "Rerouting proxy chains via IP: 10.105.87.190..."
  sleep 0.7
  echo -ne " [ \e[32mOK\e[0m ]\n"
  sleep 0.3
  echo -ne "Decrypting payload data: "
  for i in {1..20}; do
    echo -ne "\e[32m$((RANDOM%9))\e[0m"
    sleep 0.05
  done
  echo -ne " [ \e[32mSUCCESS\e[0m ]\n"
  sleep 0.5
  echo -e "\n\e[1;32m[+] Host fully compromised. Root access achieved.\e[0m"
}

# Display IP addresses
myip() {
  echo "Internal IPs: $(hostname -I)"
  echo "External IP:  $(curl -s https://ifconfig.me || echo 'N/A')"
}
alias IP="myip"

# Display active open network ports
ports() {
  ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || lsof -i -P -n 2>/dev/null
}

# Extract common archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"    ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"      ;;
      *.Z)         uncompress "$1" ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# -----------------------------------------------------------------------------
# History Substring Search Keybindings
# -----------------------------------------------------------------------------

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# -----------------------------------------------------------------------------
# REAK Welcome Dashboard
# -----------------------------------------------------------------------------
_update_runtime_cache() {
  local cache_file="$HOME/.cache/term_runtimes.cache"
  mkdir -p "$HOME/.cache"
  (
    setopt localoptions no_notify no_monitor
    local _go=$(go version 2>/dev/null | awk '{print $3}' | sed 's/go//')
    local _node=$(node -v 2>/dev/null || cat ~/.nvm/alias/default 2>/dev/null)
    local _py=$(python3 -V 2>/dev/null | awk '{print $2}')
    local _docker=$(docker --version 2>/dev/null | awk '{print $3}' | tr -d ',')
    local _wails=$(wails version 2>/dev/null | grep 'v[0-9]' | head -1 | awk '{print $1}')
    local _kubectl=$(kubectl version --client 2>/dev/null | grep -o 'v[0-9.]*' | head -1)
    local _git=$(git --version 2>/dev/null | awk '{print $3}')

    cat <<EOF > "$cache_file"
SYS_GO="${_go:-1.25.1}"
SYS_NODE="${_node:-v20.19.5}"
SYS_PY="${_py:-3.12.3}"
SYS_DOCKER="${_docker:-29.6.2}"
SYS_WAILS="${_wails:-v2.12.0}"
SYS_KUBECTL="${_kubectl:-v1.34.2}"
SYS_GIT="${_git:-2.43.0}"
EOF
  ) >/dev/null 2>&1 &!
}

_show_tab_info() {
  [[ -o interactive ]] || return

  local C_RESET="\033[0m"
  local C_BOLD="\033[1m"
  local C_CYAN="\033[36m"
  local C_GREEN="\033[32m"
  local C_YELLOW="\033[33m"
  local C_BLUE="\033[34m"
  local C_MAGENTA="\033[35m"
  local C_DIM="\033[2m"

  _update_runtime_cache

  local cache_file="$HOME/.cache/term_runtimes.cache"
  [ -f "$cache_file" ] && source "$cache_file"

  local user_host="$(whoami)@$(hostname)"
  local os_info="$(uname -s -r)"
  local uptime_str="$(uptime -p 2>/dev/null | sed 's/up //')"
  
  local cpu_model=$(awk -F: '/model name/ {print $2; exit}' /proc/cpuinfo 2>/dev/null | sed 's/^ //' | awk '{print $1" "$2" "$3" "$4}')
  local load_info=$(awk '{print $1" "$2" "$3}' /proc/loadavg 2>/dev/null)
  local proc_cnt=$(awk '{print $4}' /proc/loadavg 2>/dev/null | cut -d'/' -f2)

  local mem_total_kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null)
  local mem_avail_kb=$(awk '/MemAvailable/ {print $2}' /proc/meminfo 2>/dev/null)
  local mem_used_mb=$(( (mem_total_kb - mem_avail_kb) / 1024 ))
  local mem_total_mb=$(( mem_total_kb / 1024 ))
  local mem_pct=$(( (mem_used_mb * 100) / mem_total_mb ))

  local disk_info=$(df -h "$HOME" 2>/dev/null | tail -1 | awk '{print $3" / "$2" ("$5")"}')
  local local_ip=$(hostname -I 2>/dev/null | awk '{print $1}')
  local k8s_ctx=$(grep 'current-context' ~/.kube/config 2>/dev/null | awk '{print $2}')

  echo -e "${C_BOLD}${C_GREEN}"
  cat <<'EOF'
    ██████╗ ███████╗ █████╗ ██╗  ██╗
    ██╔══██╗██╔════╝██╔══██╗██║ ██╔╝
    ██████╔╝█████╗  ███████║█████═╝ 
    ██╔══██╗██╔══╝  ██╔══██║██╔═██╗ 
    ██║  ██║███████╗██║  ██║██║  ██╗
    ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
EOF
  echo -e "${C_RESET}"

  echo "${C_BOLD}${C_CYAN}  ┌───────────────────────────────────────────────────────────────┐${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}${C_MAGENTA}🚀 Welcome back, ${C_YELLOW}${user_host}${C_RESET}!"
  echo "${C_BOLD}${C_CYAN}  ├───────────────────────────────────────────────────────────────┤${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}OS:${C_RESET}     ${C_GREEN}${os_info}${C_RESET}  ${C_DIM}│${C_RESET} ${C_BOLD}Uptime:${C_RESET} ${C_GREEN}${uptime_str}${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}CPU:${C_RESET}    ${C_GREEN}${cpu_model:-x86_64}${C_RESET}  ${C_DIM}│${C_RESET} ${C_BOLD}Load:${C_RESET}   ${C_YELLOW}${load_info}${C_RESET} ${C_DIM}(${proc_cnt:-0} procs)${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}RAM:${C_RESET}    ${C_YELLOW}${mem_used_mb}MB / ${mem_total_mb}MB (${mem_pct}%)${C_RESET}  ${C_DIM}│${C_RESET} ${C_BOLD}Disk (~):${C_RESET} ${C_YELLOW}${disk_info}${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}IP:${C_RESET}     ${C_BLUE}${local_ip:-N/A}${C_RESET}  ${C_DIM}│${C_RESET} ${C_BOLD}Docker:${C_RESET} ${C_CYAN}${SYS_DOCKER:-N/A}${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  ├───────────────────────────────────────────────────────────────┤${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}🛠️  Runtimes & Tooling:${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET}   • ${C_BOLD}Go:${C_RESET} ${C_CYAN}${SYS_GO:-N/A}${C_RESET}      • ${C_BOLD}Node:${C_RESET} ${C_CYAN}${SYS_NODE:-N/A}${C_RESET}    • ${C_BOLD}Python:${C_RESET} ${C_CYAN}${SYS_PY:-N/A}${C_RESET}"
  echo "${C_BOLD}${C_CYAN}  │${C_RESET}   • ${C_BOLD}Wails:${C_RESET} ${C_CYAN}${SYS_WAILS:-N/A}${C_RESET}   • ${C_BOLD}Kubectl:${C_RESET} ${C_CYAN}${SYS_KUBECTL:-N/A}${C_RESET} • ${C_BOLD}Git:${C_RESET} ${C_CYAN}${SYS_GIT:-N/A}${C_RESET}"

  if [ -n "$k8s_ctx" ]; then
    echo "${C_BOLD}${C_CYAN}  ├───────────────────────────────────────────────────────────────┤${C_RESET}"
    echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}☸️  K8s Context:${C_RESET} ${MAGENTA}${k8s_ctx}${C_RESET}"
  fi

  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local repo_name=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)")
    local branch_name=$(git branch --show-current 2>/dev/null || echo "HEAD")
    local git_dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    local status_label="${C_GREEN}clean${C_RESET}"
    if [ "$git_dirty" -gt 0 ]; then
      status_label="${C_YELLOW}${git_dirty} modified files${C_RESET}"
    fi
    echo "${C_BOLD}${C_CYAN}  ├───────────────────────────────────────────────────────────────┤${C_RESET}"
    echo "${C_BOLD}${C_CYAN}  │${C_RESET} ${C_BOLD}📂 Git Repo:${C_RESET} ${MAGENTA}${repo_name}${C_RESET} (${C_CYAN}${branch_name}${C_RESET}) - ${status_label}"
  fi

  echo "${C_BOLD}${C_CYAN}  └───────────────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
}

_first_precmd() {
  add-zsh-hook -d precmd _first_precmd
  _show_tab_info
}
autoload -U add-zsh-hook
add-zsh-hook precmd _first_precmd

# -----------------------------------------------------------------------------
# Additional PATH entries
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
ZSHRC_EOF

echo "✓ .zshrc created with REAK logo and welcome dashboard"

# Restore ZSH history
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.zsh_history" ]; then
    cp "$SCRIPT_DIR/.zsh_history" ~/.zsh_history
    echo "✓ ZSH history restored"
elif [ -f "$HOME/Downloads/.zsh_history" ]; then
    cp "$HOME/Downloads/.zsh_history" ~/.zsh_history
    echo "✓ ZSH history restored from Downloads"
fi

# Restore p10k config if available
if [ -d "$SCRIPT_DIR/zsh" ] && [ -f "$SCRIPT_DIR/zsh/.p10k.zsh" ]; then
    cp "$SCRIPT_DIR/zsh/.p10k.zsh" ~/.p10k.zsh
    echo "✓ Powerlevel10k config restored"
fi

# ---- 6. Set ZSH as Default Shell ----
echo "[6/6] Setting ZSH as default shell..."
ZSH_PATH=$(which zsh)
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)

if [ "$CURRENT_SHELL" != "$ZSH_PATH" ]; then
    echo "Changing default shell from $CURRENT_SHELL to $ZSH_PATH"
    chsh -s "$ZSH_PATH"
    echo "✓ ZSH set as default shell"
    echo ""
    echo "NOTE: Log out and log back in, or run: exec zsh"
else
    echo "✓ ZSH is already your default shell"
fi

echo ""
echo "========================================="
echo "  ZSH SETUP COMPLETE!"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Run: exec zsh  (or logout and login)"
echo "  2. Run: p10k configure  (to setup Powerlevel10k theme)"
echo ""
echo "Features:"
echo "  ✓ REAK ASCII logo on every new terminal"
echo "  ✓ System info dashboard (CPU, RAM, Disk, IP)"
echo "  ✓ Runtime versions (Go, Node, Python, Docker, etc.)"
echo "  ✓ Git repo status display"
echo "  ✓ Matrix rain effect (run: matrix)"
echo "  ✓ Hack simulation (run: hack)"
echo "  ✓ All aliases (gs, ga, gc, d, dc, k, etc.)"
echo ""
