# ⚡ Arch Auto-Update Installer

![GitHub Repo Size](https://img.shields.io/github/repo-size/VergeRepos/Arch-AutoUpdate?style=flat-square)
![License](https://img.shields.io/github/license/VergeRepos/Arch-AutoUpdate?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/VergeRepos/Arch-AutoUpdate?style=flat-square)

**Author:** Verge (Yohan)  
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

## 🖥 Technologies / Languages

- ![Arch Linux](https://img.shields.io/badge/OS-Arch%20Linux-blue?style=flat-square) Arch Linux  
- ![Bash](https://img.shields.io/badge/Shell-Bash-yellow?style=flat-square) Bash  
- ![Python](https://img.shields.io/badge/Language-Python-3776AB?style=flat-square&logo=python&logoColor=white) Python  
- ![Java](https://img.shields.io/badge/Language-Java-007396?style=flat-square&logo=java&logoColor=white) Java  
- ![JavaScript](https://img.shields.io/badge/Language-JavaScript-F7DF1E?style=flat-square&logo=javascript&logoColor=black) JavaScript  
- ![TypeScript](https://img.shields.io/badge/Language-TypeScript-3178C6?style=flat-square&logo=typescript&logoColor=white) TypeScript  
- ![React](https://img.shields.io/badge/Library-React-61DAFB?style=flat-square&logo=react&logoColor=black) React  
- ![Luau](https://img.shields.io/badge/Language-Luau-004080?style=flat-square&logo=data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg'/%3E) Luau  
- ![HTML5](https://img.shields.io/badge/Language-HTML5-E34F26?style=flat-square&logo=html5&logoColor=white) HTML  
- ![CSS3](https://img.shields.io/badge/Language-CSS3-1572B6?style=flat-square&logo=css3&logoColor=white) CSS  
- ![Git](https://img.shields.io/badge/Version%20Control-Git-F05032?style=flat-square&logo=git&logoColor=white) Git  

---

## 🚀 Setup & Installation

### 1️⃣ Clone the repository

```bash
git clone git@github.com:VergeRepos/Arch-AutoUpdate.git
cd Arch-AutoUpdate
2️⃣ Make the installer executable
bash
Copy code
chmod +x install.sh
3️⃣ Run the installer
bash
Copy code
./install.sh
You will be prompted for your Gmail credentials for notifications:

Username: xiannicohjaden@gmail.com

App password: (your Gmail app password)

Timeshift snapshots will be created automatically.

The installer will detect your desktop bar (HyDE/KaJoo/Waybar) and configure the auto-update widget automatically.

