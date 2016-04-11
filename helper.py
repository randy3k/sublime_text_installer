import sublime
import sys
import subprocess
import os


def plugin_loaded():

    pc_settings = sublime.load_settings("Package Control.sublime-settings")

    def kill_subl(restart=False):
        if sublime.platform() == "osx":
            if sublime.version() > "3000":
                cmd = "sleep 1; killall 'Sublime Text'; sleep 3; "
                if restart:
                    cmd = cmd + "osascript -e 'tell application \"Sublime Text\" to activate'"
            else:
                cmd = "sleep 1; killall 'Sublime Text 2'; sleep 3; "
                if restart:
                    cmd = cmd + "osascript -e 'tell application \"Sublime Text 2\" to activate'"
        elif sublime.platform() == "linux":
            cmd = "sleep 1; killall 'sublime_text'; sleep 3; "
            if restart:
                cmd = cmd + "subl"
        elif sublime.platform() == "windows":
            cmd = "sleep 1 & taskkill /F /im sublime_text.exe & sleep 3 "
            if restart:
                cmd = cmd + "& \"C:\\st\\sublime_text.exe\""

        subprocess.Popen(cmd, shell=True)

    def check_bootstrap():
        if pc_settings.get("bootstrapped", False):
            kill_subl(True)
        else:
            sublime.set_timeout(check_bootstrap, 20)

    def check_dependencies():
        if sublime.version() > "3000" and 'Package Control' in sys.modules:
            manager = sys.modules[
                        'Package Control'].package_control.package_manager.PackageManager()
        elif sublime.version() < "3000" and 'package_control' in sys.modules:
            manager = sys.modules['package_control'].package_manager.PackageManager()
        else:
            sublime.set_timeout(check_dependencies, 20)
            return

        required_dependencies = set(manager.find_required_dependencies())

        def _check_dependencies():
            installed_dependencies = set(manager.list_dependencies())
            missing_dependencies = required_dependencies - installed_dependencies
            if len(missing_dependencies) == 0:
                success = os.path.join(
                    sublime.packages_path(),
                    "0_install_package_control_helper",
                    "success")
                open(success, 'a').close()
                kill_subl()
            else:
                sublime.set_timeout(_check_dependencies, 20)

        _check_dependencies()

    if not pc_settings.get("bootstrapped", False):
        check_bootstrap()
    else:
        check_dependencies()

if sublime.version() < '3000':
    plugin_loaded()
