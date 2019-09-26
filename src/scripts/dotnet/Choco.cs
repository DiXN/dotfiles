using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class Choco : TaskBase
{
    private ConcurrentQueue<string> _chocoQueue;

    public Choco(string file)
    {
        CmdType = CMD_TYPE.CHOCO;
        FileName = file;

        var deserialize = Serial.Deserialize<ChocoWrapper, string>(file);

        deserialize.IfPresent(val =>
        {
            _chocoQueue = new ConcurrentQueue<string>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }
    public override Task[] Exec() => new[] { ExecTask() };

    protected override Task ExecTask()
    {
        return Task.Run(async () =>
        {
            foreach (var task in _chocoQueue.Select(cmd => ExecCommand($"choco install {cmd} -y", cmd)))
            {
                Console.WriteLine(await task);
                Console.WriteLine($"Choco task {++_status} of {Tasks} finished. {Environment.NewLine}");
            }
        });
    }

    internal class ChocoWrapper : ICommandable<string>
    {
        [YamlMember(Alias = "choco")]
        public List<string> Commands { get; set; }
    }
}
