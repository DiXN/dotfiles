#load "ProcessBuilder.cs"

private static void RunProcessBuilder(string app, string arg, string name)
{
    var res = ProcessBuilder(app, arg);
    Console.WriteLine($"[{(res ? "Successfully" : "Failed")} creating symlink for \"{name}\" ...]");
}

public static void SetSymlinks(bool isDebug, string syncRoot, string syncActive)
{
    //Create symlink for ".gitconfig".
    var gitconfigLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.gitconfig";
    var gitconfigInfo = new FileInfo(gitconfigLink);

    if (!isDebug && gitconfigInfo.Exists)
        gitconfigInfo.Delete();

    RunProcessBuilder("cmd.exe", $@" /C mklink {gitconfigLink} {syncRoot}\config\.gitconfig", ".gitconfig");

    //Create symlink for Microsoft.PowerShell_profile.ps1.
    var powershellConfigDir = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\Documents\WindowsPowerShell";
    var powershellConfig = $@"{powershellConfigDir}\Microsoft.PowerShell_profile.ps1";
    var powershellConfigInfo = new FileInfo(powershellConfig);

    if (!isDebug && !Directory.Exists(powershellConfigDir))
        Directory.CreateDirectory(powershellConfigDir);

    if (!isDebug && powershellConfigInfo.Exists)
        powershellConfigInfo.Delete();

    RunProcessBuilder("cmd.exe", $@" /C mklink {powershellConfig} {syncRoot}\config\Microsoft.PowerShell_profile.ps1", "Microsoft.PowerShell_profile.ps1");

    //Create symlink for VS Code config.
    var vscodeConfig = $@"{Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}\Code\User\settings.json";
    var vscodeConfigInfo = new FileInfo(vscodeConfig);

    if (!isDebug && vscodeConfigInfo.Exists)
        vscodeConfigInfo.Delete();

    RunProcessBuilder("cmd.exe", $@" /C mklink {vscodeConfig} {syncRoot}\config\settings.json", "settings.json");

    //Create symlink for AWS.
    var awsLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.aws";

    if (!isDebug && Directory.Exists(awsLink))
        Directory.Delete(awsLink, true);

    RunProcessBuilder("cmd.exe", $@" /C mklink /D {awsLink} {syncRoot}\config\.aws", ".aws");

    //Create symlink for SSH.
    var sshLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.ssh";

    if (!isDebug && Directory.Exists(sshLink))
        Directory.Delete(sshLink, true);

    RunProcessBuilder("cmd.exe", $@" /C mklink /D {sshLink} {syncRoot}\config\.ssh", ".ssh");

    //Import settings for eMClient.
    RunProcessBuilder("MailClient.exe", $@" /importsettings {syncRoot}\config\em_client\settings.xml -s", "eM Client");
}
