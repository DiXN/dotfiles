using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class Scoop : TaskBase
{
    private ConcurrentQueue<ScoopTuple> _scoopQueue;

    public Scoop(string file)
    {
        CmdType = CMD_TYPE.SCOOP;
        FileName = file;

        var deserialize = Serial.Deserialize<ScoopWrapper, ScoopTuple>(file);

        deserialize.IfPresent(val =>
        {
            _scoopQueue = new ConcurrentQueue<ScoopTuple>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }

    protected override string CommandName => "Scoop";

    public override Task<int>[] Exec() => new[] { ExecTask() };

    protected override Task<int> ExecTask()
    {
        return Task.Run(async () =>
        {
            int returnCode = 0;
            foreach (var scoop in _scoopQueue)
            {
                bool.TryParse(Environment.GetEnvironmentVariable("CI"), out var ci);
                if (scoop.Ci && ci)
                {
                    Console.WriteLine($"[Scoop]: Skipping (\"{scoop.App}\") because of running on CI.");
                    Console.WriteLine($"Scoop task {++_status} of {Tasks} (\"{scoop.App}\") finished" + Environment.NewLine);
                } else
                {
                    for (int i = 0; i < 3; i++)
                    {
                        (int code, string output) res = await ExecCommand($"scoop {scoop.Args} install {scoop.App}", scoop.App);

                        returnCode = res.code;

                        if (res.code != 0)
                            Console.ForegroundColor = ConsoleColor.Red;
                        else
                            Console.ForegroundColor = ConsoleColor.Green;

                        Console.WriteLine($"Scoop task {(i == 0 ? ++_status : _status)} of {Tasks} (\"{res.output}\") finished" + (res.code != 0 ? " with an error." : ".") + Environment.NewLine);
                        Console.ResetColor();

                        if (res.code == 0)
                            break;
                        else
                        {
                            Console.WriteLine($"Retrying Scoop task \"{scoop}\"" + Environment.NewLine);
                            await ExecCommand($"scoop uninstall {scoop}", scoop.App);
                        }
                    }
                }
            }

            return returnCode;
        });
    }

    internal class ScoopTuple
    {
        [YamlMember(Alias = "app")]
        public string App { get; set; }
        [YamlMember(Alias = "args")]
        public string Args { get; set; }
        [YamlMember(Alias = "ci")]
        public bool Ci { get; set; }
    }

    internal class ScoopWrapper : ICommandable<ScoopTuple>
    {
        [YamlMember(Alias = "scoop")]
        public List<ScoopTuple> Commands { get; set; }
    }
}
