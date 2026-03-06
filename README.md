# Chris Titus Tech's Windows Utility : Altered

Please see [here](https://github.com/ChrisTitusTech/winutil) for information on the upstream version.

Changes here include:
- Removals
   - Remove powershell profile

- Changes
   - Change winutildir to local res
   - Switch autorun call order to installs, tweaks, features

- Additions
   - Add option to install local programs with additional arguments.
   - Load `C:\Users\Default\NTUSER.DAT` to `"HKLM\DefaultUser` as a registry hive.
   - Add "Disable Bing Search" tweak, based on the `WPFToggleBingSearch` toggle.
   - Add "Install Clean User Profiles" tweak.
   - Add "Run Clean User Profiles" button to tweaks.
   - Add "Add Printer Search to Desktop" tweak.
   - Add "App defaults" tweak.
   - Add "Lid stays on while closed" tweak.
   - Add "Restart Printer Spooler" button to tweaks.
   - Add "Power Options" tweak.
   - Add "Add arbitrary files" tweak.
