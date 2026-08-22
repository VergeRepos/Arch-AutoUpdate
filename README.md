# Arch Auto-Update Installer
### Hyprland Environment

![GitHub Repo Size](https://img.shields.io/github/repo-size/VergeRepos/Arch-AutoUpdate?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/VergeRepos/Arch-AutoUpdate?style=flat-square)

**Author:** Verge (Yohan)  
**Version:** 1.2  

---

## System Overview

This utility provides automated update management for Arch Linux systems running Hyprland. It focuses on system stability and administrative control through pre-update snapshots and real-time status monitoring.

### Technical Functionality
*   **Snapshot Verification:** Automatic system restoration point creation via Timeshift prior to update execution.
*   **Status Communication:** Integration with Gmail API to dispatch automated update reports and status notifications.
*   **Interface Integration:** Native support for desktop status bars including HyDE, KaJoo, and Waybar.
*   **System Controls:** Toggled management via dedicated commands (`autoupdate-on` / `autoupdate-off`).
*   **Security Configuration:** Strict file permission schema limiting script execution privileges to the resource owner.
*   **Operational Logging:** Persistent system logs written directly to `~/.local/log/aur-auto-update.log`.

---

## Core Technologies

*   **Operating System:** Arch Linux
*   **Scripting Engine:** Bash, Python, Luau
*   **Application Stack:** Java, JavaScript, TypeScript, React, HTML5, CSS3
*   **Version Control:** Git

---

## Installation and Deployment

### 1. Repository Retrieval
```bash
git clone git@github.com:VergeRepos/Arch-AutoUpdate.git
cd Arch-AutoUpdate
```

### 2. Permissions Initialization
```bash
chmod +x install.sh
```

### 3. Execution
```bash
./install.sh
```

---

## Configuration and Integration

### Notification Services
The installation routine requires authentication details to establish communication with the Gmail SMTP relay server:

```text
Username: xiannicohjaden@gmail.com
App Password: [Secure Application Password]
```

### Automation Details
*   **Backup Mechanics:** Timeshift state capture initializes automatically prior to package synchronization.
*   **Interface Detection:** The installer scans for active HyDE, KaJoo, or Waybar environments to inject the update monitoring widget.

---

## Disclaimer

This software is distributed without warranties of any kind. The user assumes all operational risks associated with automated package management. The author maintains no liability for data modification, system instability, or hardware irregularities arising from the application of these tools. Regular validation of system backups remains the responsibility of the system administrator.

---

## Contact

*   **Repository:** VergeRepos/Arch-AutoUpdate
*   **Support:** xiannicohjaden@gmail.com
