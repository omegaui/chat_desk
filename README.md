
<div align="center" style="margin: 20px;">
    <a href="https://codeclimate.com/github/omegaui/chat_desk/maintainability"><img src="https://api.codeclimate.com/v1/badges/22ee0cd01d57542e4f45/maintainability" /></a>
    <a href="https://github.com/omegaui/chat_desk/actions"><img src="https://github.com/omegaui/chat_desk/actions/workflows/build-for-desktop.yml/badge.svg" /></a>
    <img src="https://img.shields.io/github/downloads/omegaui/chat_desk/total?style=social" />
    <img src="https://img.shields.io/github/v/release/omegaui/chat_desk" />
    <img src="https://img.shields.io/github/license/omegaui/chat_desk" />
</div>

[alpha-preview.webm](https://user-images.githubusercontent.com/73544069/222953852-a379b891-a3f8-4cb9-bb55-848041664768.webm)

# ![](app-icon/app_icon_32.png) chat_desk (in the making)
A self-hosted chat application for desktop written in Flutter!

## ![](https://img.icons8.com/external-basicons-color-danil-polshin/32/null/external-space-space-basicons-color-danil-polshin-13.png) Features
- 🚀 Self-Host your own Chat Rooms
- 🔐 Set a Server Code or leave empty for an open connection server
- 💙 Complete Private Chatting
- ❌ No Data Collection
- 🪨 Unbreakable Core
- 🎉 Truly Opensource

## ![](https://img.icons8.com/color-glass/32/null/lab-items.png) Features to be implemented
- [ ] 😼 Blocking Users   
- [ ] 💕 An optional white list of users to only allow connection from specified users
- [ ] 🎽 Multi-Theming 

## ![](https://img.icons8.com/external-itim2101-flat-itim2101/32/null/external-test-online-education-itim2101-flat-itim2101.png) Testing (requires dart installed)
**Finely Tested on Windows and Linux!**

**I don't own a mac, So, Mac Testers are needed! Any help would be very grateful 💕**

### ![](https://img.icons8.com/color/32/null/linux--v1.png) Linux, ![](https://img.icons8.com/fluency/32/null/windows-10.png) Windows and ![](https://img.icons8.com/color/32/null/mac-logo.png) MacOS
Head over to **Releases**

### Linux One Line Install

```shell
curl "https://raw.githubusercontent.com/omegaui/chat_desk_linux_install_script/main/script/install-linux.sh" | sh
```

### Windows and Mac
Apart from setup, you are required to download `chat_desk_core` & `pubspec.yml` at the installation root directory,

Run the following to download it,
```shell
wget https://raw.githubusercontent.com/omegaui/chat_desk_core/main/bin/<platform>/chat_desk_core.exe
wget https://raw.githubusercontent.com/omegaui/chat_desk_core/main/pubspec.yml
```

where, platform is either **windows** or **mac**. 

#### ![](https://img.icons8.com/color/24/null/mac-logo.png) mac is now 🎉 supported (experimental).


##  Build From Source

**It's easy**

- **Clone the repo**
```shell
git clone https://github.com/omegaui/chat_desk
cd chat_desk
```

- Getting Dependencies
```shell
flutter pub get
wget https://raw.githubusercontent.com/omegaui/chat_desk_core/main/bin/<platform>/chat_desk_core.exe
# for linux
# sudo chmod 777 chat_desk_core.exe
```

- Launching
```shell
flutter run 
```

## ⚡ Contributing

Hey this is for you, if you want to help in building the project,

Since, the core of the program is separated and independent of the UI,
There seems a hassle of building both the core and the UI for testing changes/features,

**⚡ But this is not the case with chat_desk ⚡**

For debugging purpose, you can replace the spawner command in `server_handler.dart`,
to enable embedded core,

All you need to do is to replace,

Only this line
```dart
    _serverProcess = await Process.start(
"${Platform.isLinux ? "./" : ""}chat_desk_core.exe", []);
```

With this line
```dart
    _serverProcess = await Process.start(
"dart", ["lib/core/server/server.dart"]);
```

_And thats all, your embedded server is ready for testing!!_


<div align="center">
    <img src="images/preview.png">
    <h4 style="font-style: italic;">Dark Mode Banner</h4>
    <br>
    <br>
    <img src="images/github-banner.png">
    <h4 style="font-style: italic;">Light Mode Banner</h4>
    <br>
    <br>
    <img src="images/preview-windows.png">
    <h4 style="font-style: italic;">Windows 11 Preview</h4>
</div>