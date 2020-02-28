#r "nuget: SSH.NET, 2016.1.0"
#r "nuget: Microsoft.PowerShell.SDK, 6.2.3"

#load "JunctionPoints.cs"

using System;
using System.IO;
using System.Security;
using System.Runtime.InteropServices;
using System.Management.Automation;
using System.Diagnostics;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using Renci.SshNet.Common;

private bool IsDebug => Args.Contains("--debugger");

public static void WaitForDebugger()
{
    Console.WriteLine("Attach Debugger (VS Code)");
    while (!System.Diagnostics.Debugger.IsAttached);
}

if (Args.Contains("--ci"))
    return 0;

if (Args.Contains("--debugger"))
    WaitForDebugger();

static string ToBasicString(this SecureString value)
{
    IntPtr valuePtr = IntPtr.Zero;

    try
    {
        valuePtr = Marshal.SecureStringToGlobalAllocUnicode(value);
        return Marshal.PtrToStringUni(valuePtr);
    }
    finally
    {
        Marshal.ZeroFreeGlobalAllocUnicode(valuePtr);
    }
}

static bool ProcessBuilder(string process, string args)
{
    using (var p = new Process())
    {
        var psi = new ProcessStartInfo(process, args)
        {
            CreateNoWindow = true,
            UseShellExecute = false,
            RedirectStandardOutput = true,
            RedirectStandardError = true
        };

        p.StartInfo = psi;
        p.Start();

        var title = "Sync files";

        Task.Run(async () =>
        {
            string line = string.Empty;
            while ((line = await p.StandardOutput.ReadLineAsync()) != null)
            {
                Console.WriteLine($"[{title}]: {line}");
            }
        });

        Task.Run(async () =>
        {
            string line = string.Empty;
            while ((line = await p.StandardError.ReadLineAsync()) != null)
            {
                Console.Error.WriteLine($"[{title}]: {line}");
            }
        });

        p.WaitForExit();

        return p.ExitCode == 0;
    }

    return false;
}

var credentials = IsDebug ? new FileInfo("credential.txt") : new FileInfo($"{Path.GetTempPath()}\\dotfiles\\credential.txt");

if (credentials.Exists)
{
    using (var ps = PowerShell.Create())
    {
        //Get SecureString form credentials file.
        ps.AddScript("Get-Content \"credential.txt\" | ConvertTo-SecureString");
        var password = ps.Invoke()[0].BaseObject as SecureString;

        using (var client = new SftpClient("10.0.0.5", "admin", password.ToBasicString()))
        {
            try
            {
                Console.WriteLine("[Connecting to server for \"rclone.conf\" ...]");
                client.Connect();

                //Create rclone directory if it does not exist.
                var folderPath = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".config", "rclone");
                Directory.CreateDirectory(folderPath);

                var path = Path.Combine(folderPath, "rclone.conf");
                var config = new FileInfo(path);

                //Delete previous config to prevent appending of config.
                if (!IsDebug && config.Exists)
                    config.Delete();

                using (var fstream = config.OpenWrite())
                {
                    Console.WriteLine("[Downloading \"rclone.conf\" ...]");

                    if (!IsDebug)
                        client.DownloadFile("/share/backup/rclone/rclone.conf", fstream);
                }

                client.Disconnect();

                //Wait for rclone to be available.
                while (!ProcessBuilder("where", "rclone"))
                {
                    System.Threading.Thread.Sleep(250);
                }

                //Sync all files.
                ProcessBuilder("rclone", $@"sync -v db:/ {(IsDebug ? "F" : "C")}:\sync");

                //Wait for git and aws to be available.
                while (!ProcessBuilder("where", "git") && !ProcessBuilder("where", "aws"))
                {
                    System.Threading.Thread.Sleep(250);
                }

                //Create symlink for ".gitconfig".
                var gitconfigLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.gitconfig";
                var gitconfigInfo = new FileInfo(gitconfigLink);

                if (!IsDebug && gitconfigInfo.Exists)
                    gitconfigInfo.Delete();

                var resConfig = ProcessBuilder("cmd.exe", $@" /C mklink {gitconfigLink} {(IsDebug ? "F" : "C")}:\sync\config\.gitconfig");
                Console.WriteLine($"[{(resConfig ? "Successfully" : "Failed")} creating symlink for \".gitconfig\" ...]");

                //Create symlink for Microsoft.PowerShell_profile.ps1.
                var powershellConfigDir = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\Documents\WindowsPowerShell";
                var powershellConfig = $@"{powershellConfigDir}\Microsoft.PowerShell_profile.ps1";
                var powershellConfigInfo = new FileInfo(powershellConfig);

                if(!IsDebug && !Directory.Exists(powershellConfigDir))
                    Directory.CreateDirectory(powershellConfigDir)

                if (!IsDebug && powershellConfigInfo.Exists)
                    powershellConfigInfo.Delete();

                var resPowerConfig = ProcessBuilder("cmd.exe", $@" /C mklink {powershellConfig} {(IsDebug ? "F" : "C")}:\sync\config\Microsoft.PowerShell_profile.ps1");
                Console.WriteLine($"[{(resPowerConfig ? "Successfully" : "Failed")} creating symlink for \"Microsoft.PowerShell_profile.ps1\" ...]");

                //Create symlink for VS Code config.
                var vscodeConfig =  $@"{Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData)}\Documents\Code\User\settings.json";
                var vscodeConfigInfo = new FileInfo(vscodeConfig);

                if (!IsDebug && vscodeConfigInfo.Exists)
                    vscodeConfigInfo.Delete();

                var resVsConfig = ProcessBuilder("cmd.exe", $@" /C mklink {vscodeConfig} {(IsDebug ? "F" : "C")}:\sync\config\settings.json");
                Console.WriteLine($"[{(resVsConfig ? "Successfully" : "Failed")} creating symlink for \"Microsoft.PowerShell_profile.ps1\" ...]");

                //Create junction for ".aws".
                try
                {
                    var awsLink = $@"{Environment.GetFolderPath(Environment.SpecialFolder.UserProfile)}\.aws";
                    JunctionPoint.Create(awsLink, $@"{(IsDebug ? "F" : "C")}:\sync\config\.aws", true);
                    Console.WriteLine("[Successfully creating symlink for \".aws\" ...]");
                }
                catch (IOException)
                {
                    Console.Error.WriteLine("[Failed creating symlink for \".aws\" ...]");
                }
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("[Could not download \"rclone.conf\" ...]");
                Console.WriteLine(ex.Message);
                Console.ResetColor();

                if (!IsDebug)
                    credentials.Delete();

                return -1;
            }
        }
    }

    if (!IsDebug)
        credentials.Delete();
}
else
{
    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine("[Could not find credentials ...]");
    Console.ResetColor();
    return -1;
}

return 0;
