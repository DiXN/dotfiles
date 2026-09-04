import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    pluginId: "yubikeyOath"

    ToggleSetting {
        settingKey: "copyDigitsOnly"
        label: "Copy digits only"
        description: "Copy 501604 instead of 501 604 to the clipboard"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showUsernames"
        label: "Show usernames"
        description: "Second line under the account name"
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "codeGrouping"
        label: "Code grouping"
        description: "How the code is displayed"
        options: [
            { label: "Split (501 604)", value: "half" },
            { label: "No spaces (501604)", value: "none" }
        ]
        defaultValue: "half"
    }
}
