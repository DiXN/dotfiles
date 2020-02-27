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

    protected override string CommandName => "Scoop";

    public override Task<int>[] Exec() => new[] { ExecTask() };

    protected override Task<int> ExecTask()
    {
        return Task.Run(async () =>
        {
            int returnCode = 0;
            foreach (var scoop in _scoopQueue)
            {
                for (int i = 0; i < 3; i++)
                {
                    (int code, string output) res = await ExecCommand($"scoop install {scoop}", scoop);

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
                        await ExecCommand($"scoop uninstall {scoop}", scoop);
                    }
                }
            }

            return returnCode;
        });
    }

    internal class ChocoWrapper : ICommandable<string>
    {
        [YamlMember(Alias = "scoop")]
        public List<string> Commands { get; set; }
    }
}
