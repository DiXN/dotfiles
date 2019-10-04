#r "nuget: SSH.NET, 2016.1.0"
#r "nuget: Microsoft.PowerShell.SDK, 6.2.3"

using System;
using System.IO;
using System.Security;
using System.Runtime.InteropServices;
using System.Management.Automation;
using Renci.SshNet;
using Renci.SshNet.Sftp;
using Renci.SshNet.Common;

public static void WaitForDebugger()
{
    Console.WriteLine("Attach Debugger (VS Code)");
    while (!System.Diagnostics.Debugger.IsAttached);
}

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

var credentials = Args.Contains("--debugger") ? new FileInfo("credential.txt") : new FileInfo($"{Path.GetTempPath()}\\dotfiles\\credential.txt");

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
                if (config.Exists)
                    config.Delete();

                using (var fstream = config.OpenWrite())
                {
                    Console.WriteLine("[Downloading \"rclone.conf\" ...]");
                    client.DownloadFile("/share/backup/rclone/rclone.conf", fstream);
                }

                client.Disconnect();
            }
            catch (Exception ex)
            {
                Console.ForegroundColor = ConsoleColor.Red;
                Console.WriteLine("[Could not download \"rclone.conf\" ...]");
                Console.WriteLine(ex.Message);
                Console.ResetColor();

                credentials.Delete();

                return -1;
            }
        }
    }

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
