#load "Serial.cs"

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class Command : TaskBase
{
    private ConcurrentQueue<CommandTuple> _commandQueue;
    private List<Task> _tasks = new List<Task>();

    public Command(string file)
    {
        CmdType = CMD_TYPE.COMMAND;
        FileName = file;

        var deserialize = Serial.Deserialize<CommandWrapper, CommandTuple>(file);

        deserialize.IfPresent(val =>
        {
            _commandQueue = new ConcurrentQueue<CommandTuple>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }

    public override void Exec()
    {
        for (var i = 0; Check(i, _commandQueue); i++)
            ExecTask();

        Task.WaitAll(_tasks.ToArray());
    }

    protected override void ExecTask()
    {
        if (Check(_currentProcesses, _commandQueue))
        {
            _commandQueue.TryDequeue(out var cmd);
            _tasks.Add(Task.Run(async () =>
            {
                Interlocked.Increment(ref _currentProcesses);
                Console.WriteLine(await ExecCommand(string.Join(" && ", cmd.Cmd ?? (new[] { "" })), cmd.Desc, cmd.Path));
                Interlocked.Increment(ref _status);
                Console.WriteLine($"Command task {_status} of {Tasks} finished. {Environment.NewLine}");
            }).ContinueWith(x =>
            {
                Interlocked.Decrement(ref _currentProcesses);
                ExecTask();
            }));
        }
    }
    internal class CommandTuple
    {
        [YamlMember(Alias = "cmd")]
        public string[] Cmd { get; set; }
        [YamlMember(Alias = "path")]
        public string Path { get; set; }
        [YamlMember(Alias = "desc")]
        public string Desc { get; set; }
    }

    internal class CommandWrapper : ICommandable<CommandTuple>
    {
        [YamlMember(Alias = "commands")]
        public List<CommandTuple> Commands { get; set; }
    }
}