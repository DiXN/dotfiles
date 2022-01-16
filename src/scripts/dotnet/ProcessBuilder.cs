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
}
