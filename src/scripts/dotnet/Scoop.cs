using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class Scoop : TaskBase
{
    private ConcurrentQueue<string> _scoopQueue;

    public Scoop(string file)
    {
        CmdType = CMD_TYPE.SCOOP;
        FileName = file;

        var deserialize = Serial.Deserialize<ChocoWrapper, string>(file);

        deserialize.IfPresent(val =>
        {
            _scoopQueue = new ConcurrentQueue<string>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }

    public override void Exec() => ExecTask();

    protected override void ExecTask()
    {
        Task.Run(async () =>
        {
            foreach (var task in _scoopQueue.Select(cmd => ExecCommand($"scoop install {cmd}", cmd)))
            {
                Console.WriteLine(await task);
                Console.WriteLine($"Scoop task {++_status} of {Tasks} finished. {Environment.NewLine}");
            }
        });
    }

    internal class ChocoWrapper : ICommandable<string>
    {
        [YamlMember(Alias = "scoop")]
        public List<string> Commands { get; set; }
    }
}
