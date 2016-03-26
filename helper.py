import sublime
import sys
import subprocess
import os


def plugin_loaded():

    pc_settings = sublime.load_settings("Package Control.sublime-settings")
    checker_settings = sublime.load_settings("Package Control Installer.sublime-settings")
    preferences = sublime.load_settings("Preferences.sublime-settings")

    def check_bootstrap():
        if pc_settings.get("bootstrapped", False):

            checker_settings.set("bootstrapped", True)
            sublime.save_settings("Package Control Installer.sublime-settings")

            if sublime.platform() == "osx":
                if sublime.version() > "3000":
                    subprocess.Popen(
                        "sleep 1; "
                        "killall 'Sublime Text'; "
                        "sleep 1; "
                        "osascript -e 'tell application \"Sublime Text\" to activate'",
                        shell=True)
                else:
                    subprocess.Popen(
                        "sleep 1; "
                        "killall 'Sublime Text 2'; "
                        "sleep 1; "
                        "osascript -e 'tell application \"Sublime Text 2\" to activate'",
                        shell=True)
            elif sublime.platform() == "linux":
                subprocess.Popen("sleep 1; killall 'sublime_text'; subl", shell=True)
            elif sublime.platform() == "windows":
                subprocess.Popen(
                    "sleep 1 & taskkill /im sublime_text.exe & sleep 1 & \"%s\""
                    % sublime.executable_path(),
                    shell=True)

        else:
            sublime.set_timeout(check_bootstrap, 50)

    def check_dependencies():
        if sublime.version() > "3000" and 'Package Control' in sys.modules:
            manager = sys.modules['Package Control'].package_control.package_manager.PackageManager()
        elif sublime.version() < "3000" and 'package_control' in sys.modules:
            manager = sys.modules['package_control'].package_manager.PackageManager()
        else:
            sublime.set_timeout(check_dependencies, 50)
            return

        installed_dependencies = set(manager.list_dependencies())
        required_dependencies = set(manager.find_required_dependencies())
        missing_dependencies = required_dependencies - installed_dependencies

        if len(missing_dependencies) == 0 and pc_settings.get("bootstrapped", False):

            checker_settings.set("installed_dependencies", True)
            sublime.save_settings("Package Control Installer.sublime-settings")
            ignored_packages = preferences.get("ignored_packages", [])
            ignored_packages.append("0_package_control_helper")
            preferences.set("ignored_packages", ignored_packages)
            sublime.save_settings("Preferences.sublime-settings")

            os.unlink(os.path.join(
                sublime.packages_path(),
                "User",
                "Package Control Installer.sublime-settings"))

            if sublime.platform() == "osx":
                if sublime.version() > "3000":
                    subprocess.Popen(
                        "sleep 1; "
                        "killall 'Sublime Text'",
                        shell=True)
                else:
                    subprocess.Popen(
                        "sleep 1; "
                        "killall 'Sublime Text 2'",
                        shell=True)
            elif sublime.platform() == "linux":
                subprocess.Popen("sleep 1; killall 'sublime_text'", shell=True)
            elif sublime.platform() == "windows":
                subprocess.Popen(
                    "sleep 1 & taskkill /im sublime_text.exe & sleep 1",
                    shell=True)

        else:
            sublime.set_timeout(check_dependencies, 50)

    if not checker_settings.get("bootstrapped", False):
        check_bootstrap()
    elif not checker_settings.get("installed_dependencies", False):
        check_dependencies()

if sublime.version() < '3000':
    plugin_loaded()
