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
    public override Task<int>[] Exec() => new[] { ExecTask() };

    protected override Task<int> ExecTask()
    {
        return Task.Run(async () =>
        {
            int returnCode = 0;
            foreach (var task in _chocoQueue.Select(cmd => ExecCommand($"choco install {cmd} -y", cmd)))
            {
                (int code, string output) res = await task;

                returnCode = res.code;

                if (res.code != 0)
                    Console.ForegroundColor = ConsoleColor.Red;
                else
                    Console.ForegroundColor = ConsoleColor.Green;

                Console.WriteLine(res.output);
                Console.WriteLine($"Choco task {++_status} of {Tasks} finished. {Environment.NewLine}");
            }

            return returnCode;
        });
    }

    internal class ChocoWrapper : ICommandable<string>
    {
        [YamlMember(Alias = "choco")]
        public List<string> Commands { get; set; }
    }
}
