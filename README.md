# ⚡ Arch Auto-Update Installer

**Author:** Verge (Yohan)  
**License:** MIT  
**Version:** 1.2  

---

## 🛠 Development

- Fully integrated Arch Linux auto-update installer  
- Timeshift snapshot safety before updates  
- Gmail notifications for update status  
- Supports top-bar widgets in HyDE, KaJoo, Waybar  
- Toggle commands: `autoupdate-on` / `autoupdate-off`  
- Secure permissions: scripts executable only by owner  
- Logs located at `~/.local/log/aur-auto-update.log`  

---

## 🚀 Installation

1. Clone this repository:

```bash
git clone git@github.com:VergeRepos/Arch-AutoUpdate.git
cd Arch-AutoUpdate
Make the installer executable:

bash
Copy code
chmod +x install.sh
Run the installer:

bash
Copy code
./install.sh
You will be prompted for your Gmail username & app password (for notifications).

Timeshift snapshots will be created automatically.

The installer will detect your desktop bar (HyDE/KaJoo/Waybar) and configure the auto-update widget automatically.

⚠️ Disclaimer
This software is provided as-is. Use at your own risk.

The author is not liable for any data loss, system damage, or hardware issues caused by using this software.

Always ensure backups are available before enabling auto-updates.

📬 Contact
GitHub: https://github.com/VergeRepos/Arch-AutoUpdate

Email: nybentulan@gmail.com
