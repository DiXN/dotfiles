#load "ProcessBuilder.cs"

public static void SetSymlinks(bool isDebug, string syncRoot, string syncActive)
{
    //Wait for git and aws to be available.
    while (!ProcessBuilder("where", "git") && !ProcessBuilder("where", "aws"))
    {
        System.Threading.Thread.Sleep(250);
    }

    //Create symlink for ".gitconfig".
    var gitconfigLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.gitconfig";
    var gitconfigInfo = new FileInfo(gitconfigLink);

    if (!isDebug && gitconfigInfo.Exists)
        gitconfigInfo.Delete();

    var resConfig = ProcessBuilder("cmd.exe", $@" /C mklink {gitconfigLink} {syncRoot}\config\.gitconfig");
    Console.WriteLine($"[{(resConfig ? "Successfully" : "Failed")} creating symlink for \".gitconfig\" ...]");

    //Create symlink for Microsoft.PowerShell_profile.ps1.
    var powershellConfigDir = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\Documents\WindowsPowerShell";
    var powershellConfig = $@"{powershellConfigDir}\Microsoft.PowerShell_profile.ps1";
    var powershellConfigInfo = new FileInfo(powershellConfig);

    if (!isDebug && !Directory.Exists(powershellConfigDir))
        Directory.CreateDirectory(powershellConfigDir);

    if (!isDebug && powershellConfigInfo.Exists)
        powershellConfigInfo.Delete();

    var resPowerConfig = ProcessBuilder("cmd.exe", $@" /C mklink {powershellConfig} {syncRoot}\config\Microsoft.PowerShell_profile.ps1");
    Console.WriteLine($"[{(resPowerConfig ? "Successfully" : "Failed")} creating symlink for \"Microsoft.PowerShell_profile.ps1\" ...]");

    //Create symlink for VS Code config.
    var vscodeConfig = $@"{Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}\Code\User\settings.json";
    var vscodeConfigInfo = new FileInfo(vscodeConfig);

    if (!isDebug && vscodeConfigInfo.Exists)
        vscodeConfigInfo.Delete();

    var resVsConfig = ProcessBuilder("cmd.exe", $@" /C mklink {vscodeConfig} {syncRoot}\config\settings.json");
    Console.WriteLine($"[{(resVsConfig ? "Successfully" : "Failed")} creating symlink for \"settings.json\" ...]");

    //Create symlink for AWS.
    var awsLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.aws";

    if (!isDebug && Directory.Exists(awsLink))
        Directory.Delete(awsLink, true);

    var resAwsConfig = ProcessBuilder("cmd.exe", $@" /C mklink /D {awsLink} {syncRoot}\config\.aws");
    Console.WriteLine($"[{(resAwsConfig ? "Successfully" : "Failed")} creating symlink for \".aws\" ...]");

    //Create symlink for SSH.
    var sshLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.ssh";

    if (!isDebug && Directory.Exists(sshLink))
        Directory.Delete(sshLink, true);

    var resSshLink = ProcessBuilder("cmd.exe", $@" /C mklink /D {sshLink} {syncRoot}\config\.ssh");
    Console.WriteLine($"[{(resSshLink ? "Successfully" : "Failed")} creating symlink for \".ssh\" ...]");

    var emConfig = ProcessBuilder("MailClient.exe", $@" /importsettings {syncRoot}\config\em_client\settings.xml -s");
    Console.WriteLine($"[{(emConfig ? "Successfully" : "Failed")} importing settings for \"eM Client\" ...]");
}
