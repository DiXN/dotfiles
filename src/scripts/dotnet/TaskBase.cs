#load "Optional.cs"

using System;
using System.Collections.Concurrent;
using System.Diagnostics;
using System.Linq;
using System.Text;
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
                FileName = "cmd.exe",
                Arguments = $"/C{cmd}",
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                WorkingDirectory = path,
            };

            StringBuilder builder = new StringBuilder();
            string error = string.Empty, output = string.Empty;

            try
            {
                process.Start();
                Console.WriteLine($"Started task: \"{(!string.IsNullOrEmpty(desc) ? desc : cmd)}\"");

                output = await process.StandardOutput.ReadToEndAsync();
                error = await process.StandardError.ReadToEndAsync();
            }
            catch (Exception ex)
            {
                error = ex.Message;
            }

            FormatStd(cmd, error, desc, STD_TYPE.ERROR).IfPresent(err => builder.Append(err));

            FormatStd(cmd, output, desc, STD_TYPE.OUTPUT).IfPresentOrElse(outp =>
                builder.Append(outp), () => builder.AppendLine($"no output for \"{cmd}\""));

            return (code: String.IsNullOrEmpty(error) ? 0 : -1, output: builder.ToString());
        }
    }

    protected abstract Task<int> ExecTask();
    public abstract Task<int>[] Exec();
}