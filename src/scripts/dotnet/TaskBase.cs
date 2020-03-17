#load "Optional.cs"

using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

abstract class TaskBase
{
    protected int _currentProcesses = 0, _status = 0;

    public delegate void TaskFinishedEventArgs(object sender, CMD_TYPE cmdType);
    public static event TaskFinishedEventArgs OnTasksFinished;

    private enum STD_TYPE
    {
        OUTPUT,
        ERROR
    }

    public enum CMD_TYPE
    {
        COMMAND,
        CHOCO,
        CHOCO_DEPENDENCY,
        SCOOP
    }

    public CMD_TYPE CmdType { get; set; }

    public string FileName { get; set; }

    protected abstract string CommandName {get; }

    protected TaskBase()
    {
        Task.Run(async () =>
        {
            while (Tasks == 0 || _status < Tasks)
                await Task.Delay(50);

            OnTasksFinished?.Invoke(this, CmdType);
        });
    }

    public int Tasks { get; set; }

    protected bool Check<T>(int i, ConcurrentQueue<T> queue) =>
        i < Environment.ProcessorCount && (queue != null ? !queue.IsEmpty : false);

    private Optional<string> FormatStd(string cmd, string std, string desc, STD_TYPE type)
    {
        if (std != string.Empty)
        {
            StringBuilder builder = new StringBuilder();

            void FillBuilder(string prefix, string head, string body)
            {
                string actualHead = $"{prefix} \"{(string.IsNullOrEmpty(desc) ? head : desc)}\"";
                builder.AppendLine(actualHead);
                builder.AppendLine(string.Concat(Enumerable.Repeat("=", actualHead.Length)));
                builder.AppendLine(std);
            }

            switch (type)
            {
                case STD_TYPE.OUTPUT:
                    FillBuilder("Output for", cmd, std);
                    break;
                case STD_TYPE.ERROR:
                    FillBuilder("Error for", cmd, std);
                    break;
                default:
                    break;
            }

            return Optional.Of(builder.ToString());
        }
        else
        {
            return Optional.Empty<string>();
        }
    }

    protected async Task<(int, string)> ExecCommand(string cmd, string desc = "", string path = "")
    {
        using (Process process = new Process())
        {
            process.StartInfo  = new ProcessStartInfo()
            {
                WindowStyle = ProcessWindowStyle.Hidden,
                FileName = "pwsh.exe",
                Arguments = $"-Command {cmd}",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                WorkingDirectory = path,
            };

            int code = -1;
            int pTimer = 0;
            var title = !string.IsNullOrEmpty(desc) ? desc : cmd;

            try
            {
                process.Start();
                Console.WriteLine($"Started \"{CommandName}\" task: \"{(!string.IsNullOrEmpty(desc) ? desc : cmd)}\"");

                Task.Run(async () =>
                {
                    string line = string.Empty;
                    while ((line = await process.StandardOutput.ReadLineAsync()) != null)
                    {
                        Console.WriteLine($"[{title}]: {line}");
                        Interlocked.Exchange(ref pTimer, 0);
                    }
                });

                Task.Run(async () =>
                {
                    string line = string.Empty;
                    while ((line = await process.StandardError.ReadLineAsync()) != null)
                    {
                        Console.WriteLine($"[{title}]: {line}");
                        Interlocked.Exchange(ref pTimer, 0);
                    }
                });

                while (!process.HasExited)
                {
                    if (pTimer >= 1_800_000)
                    {
                        process.Kill();
                        break;
                    }

                    if (pTimer > 0 && pTimer % 60000 == 0)
                        Console.WriteLine($"[{title}]: has not responded for {pTimer / 60000} minutes.");

                    await Task.Delay(100);
                    Interlocked.Add(ref pTimer, 100);
                }

                code = process.ExitCode;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[{title}]: {ex.Message}");
            }

            return (code: code, output: title);
        }
    }

    protected abstract Task<int> ExecTask();
    public abstract Task<int>[] Exec();
}