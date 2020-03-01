
#load "Symlink.cs"

public static void WaitForDebugger()
{
    Console.WriteLine("Attach Debugger (VS Code)");
    while (!System.Diagnostics.Debugger.IsAttached);
}

if (Args.Contains("--ci"))
    return 0;

if (Args.Contains("--wait"))
    WaitForDebugger();

var syncRoot = Environment.GetEnvironmentVariable("SYNC_ROOT");
var syncActive = Environment.GetEnvironmentVariable("SYNC_Active");

SetSymlinks(Args.Contains("--debug"), syncRoot, syncActive);
