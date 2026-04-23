# Terminal Setup

One-command setup for a modern developer terminal environment. Installs:

| Tool            | What it does                                               |
| --------------- | ---------------------------------------------------------- |
| **Homebrew**    | Package manager — used to install the other tools          |
| **Ghostty**     | Fast, modern terminal app                                  |
| **Starship**    | Smart shell prompt that shows git branch, status, and more |
| **Claude Code** | AI coding assistant you run from the terminal              |

The script is safe to run more than once. Anything already installed is skipped, and any missing configuration is automatically completed.

---

## macOS

Open **Terminal** (press `Cmd + Space`, type `Terminal`, press Enter) and paste this:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mrpbennett/scripts/refs/heads/main/pp-cc-setup/terminal-setup.sh)"
```

**What to expect:**

- You will be asked for your Mac login password once (for Homebrew). Type it and press Enter — nothing will appear on screen while you type, that is normal.
- The full install takes 3–10 minutes depending on your internet speed.
- When it finishes, run `source ~/.zshrc` or close and reopen your terminal.

**After setup:**

- Open **Ghostty** from your Applications folder for your new terminal
- Your prompt will look different — that is Starship showing git info
- Type `claude` to start Claude Code

---

## Windows

You need **Git Bash** installed. If you do not have it:

1. Download Git from [git-scm.com/download/win](https://git-scm.com/download/win)
2. Run the installer with default settings
3. Open **Git Bash** from the Start Menu

Then paste this into Git Bash:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mrpbennett/scripts/refs/heads/main/pp-cc-setup/terminal-setup.sh)"
```

**What to expect:**

- Windows Package Manager (`winget`) is used to install apps. If the script says it is not found, see the troubleshooting section below.
- If Node.js is installed for the first time, the script will ask you to close and reopen Git Bash, then run it again. This is normal — it only happens once.
- The full install takes 3–10 minutes.

**After setup:**

- Open **Ghostty** from the Start Menu for your new terminal
- Your prompt will look different — that is Starship
- Type `claude` to start Claude Code

> **Note:** Run this script in **Git Bash**, not in PowerShell or Command Prompt.

---

## Linux

Open your terminal and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mrpbennett/scripts/refs/heads/main/pp-cc-setup/terminal-setup.sh)"
```

**What to expect:**

- You may be asked for your password once (for Homebrew). This is normal.
- Ghostty cannot be installed automatically on Linux — the script will print a link to [ghostty.org/download](https://ghostty.org/download) where you can install it manually. Everything else installs fine.
- When it finishes, run `source ~/.bashrc` or close and reopen your terminal.

---

## WSL (Windows Subsystem for Linux)

If you are running Linux inside WSL on a Windows machine:

- Run the script inside WSL the same way as Linux above — Homebrew, Starship, and Claude Code will all install normally.
- **Ghostty** is a Windows app and should be installed on the Windows side. Open Git Bash (not WSL) and run the Windows setup above.

---

## Troubleshooting

### "winget not found" (Windows)

winget comes with the **App Installer** package.

1. Open the **Microsoft Store**
2. Search for **App Installer**
3. Click **Install** or **Update**
4. Close Git Bash and reopen it, then run the script again

### "command not found: brew" after install (macOS / Linux)

Run the following and try again:

```bash
# Apple Silicon Mac
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"

# Linux
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

Or simply close and reopen your terminal — the PATH is written to your shell config automatically.

### "command not found: claude" after install

Close and reopen your terminal, then try again. If it still does not work, run:

```bash
source ~/.zshrc    # macOS
source ~/.bashrc   # Linux / WSL / Windows Git Bash
```

### Something else went wrong

The script is safe to run again — it will skip anything already installed and retry what failed. Just paste the command again.

---

## What the script changes

The script only writes to your shell configuration file. It never modifies system files or installs anything globally without telling you.

| OS                 | File modified |
| ------------------ | ------------- |
| macOS              | `~/.zshrc`    |
| Windows (Git Bash) | `~/.bashrc`   |
| Linux / WSL        | `~/.bashrc`   |

Lines added are idempotent — running the script multiple times will not add duplicates.
