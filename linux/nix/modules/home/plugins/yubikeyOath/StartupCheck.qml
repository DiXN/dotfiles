import QtQuick
import qs.Common

QtObject {
    function check(done) {
        Proc.runCommand("yubikeyOath.depCheck", ["sh", "-c", "command -v ykman"], (stdout, exitCode) => {
            if (exitCode === 0) {
                done(null);
                return;
            }
            done({
                "title": I18n.tr("ykman is required"),
                "details": I18n.tr("Install 'yubikey-manager' (ykman) and re-enable this plugin.")
            });
        });
    }
}
