I agree. A `ctf-setup` script starts to hide too much state. For a dotfiles repository, explicit documentation is often better:

* You know **what** is being installed.
* You know **when** to build the Podman image.
* You don't accidentally build a large image on every fresh machine.
* The repo remains a collection of reproducible instructions, not a magic installer.

I would keep the README focused around **three independent tasks**:

1. Enable the CTF devShell.
2. Build the pwn container (only when needed).
3. Use the pwn container.

Something like this:

````markdown
# CTF Environment

Nix devShell + Podman FHS environment for CTF work.

## Requirements

- NixOS
- direnv
- Podman

---

# 1. Enable CTF DevShell

Clone dotfiles:

```bash
git clone <dotfiles-repo> ~/nixos-dotfiles
````

Create CTF workspace:

```bash
mkdir -p ~/ctf
cd ~/ctf
```

Create `.envrc`:

```bash
echo "use flake ~/nixos-dotfiles/ctf-config#ctf" > .envrc
```

Allow direnv:

```bash
direnv allow
```

Verify:

```bash
which ghidra
which burpsuite
```

---

# 2. Build Pwn Container (Optional)

Only required for pwn challenges that need an FHS environment.

From inside the CTF devShell:

```bash
pwn-build
```

Verify:

```bash
podman images
```

Expected:

```
REPOSITORY     TAG
local/pwn      latest
```

---

# 3. Pwn Challenge Workflow

Create or enter challenge directory:

```bash
mkdir -p ~/ctf/pwn/<challenge>
cd ~/ctf/pwn/<challenge>
```

Example:

```
challenge/
├── vuln
├── libc.so.6
└── exploit.py
```

---

## Static Analysis (Host)

Use Nix tools:

```bash
ghidra vuln
```

or:

```bash
r2 vuln
```

---

## Enter FHS Environment

From the challenge directory:

```bash
pwn-env
```

Inside container:

```bash
checksec vuln
```

Debug:

```bash
gdb vuln
```

Run exploit:

```bash
python3 exploit.py
```

Exit:

```bash
exit
```

---

# 4. Rebuild Container

After modifying:

```
pwn-container/Containerfile
```

Run:

```bash
pwn-build
```

---

# Directory Layout

```
~/nixos-dotfiles/
└── ctf-config/
    ├── flake.nix
    └── pwn-container/
        ├── Containerfile
        ├── build.sh
        └── enter-pwn-env.sh


~/ctf/
└── pwn/
    └── challenge/
        ├── vuln
        ├── libc.so.6
        └── exploit.py
```

```

This also leaves room for future additions. For example, if later you add a kernel exploitation container or a Windows reversing VM, they can get their own documented section without turning the repo into a one-shot installer.

I would keep `build.sh` and `enter-pwn-env.sh` exactly as helper scripts, but let the README be the source of truth for **when** they are used.
```

