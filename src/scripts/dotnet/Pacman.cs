using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class Pacman : TaskBase
{
    private ConcurrentQueue<PacmanTuple> _pacmanQueue;

    public Pacman(string file)
    {
        CmdType = CMD_TYPE.PACMAN;
        FileName = file;

        var deserialize = Serial.Deserialize<PacmanWrapper, PacmanTuple>(file);

        deserialize.IfPresent(val =>
        {
            _pacmanQueue = new ConcurrentQueue<PacmanTuple>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }

    protected override string CommandName => "Pacman";

    public override Task<int>[] Exec() => new[] { ExecTask() };

    protected override Task<int> ExecTask()
    {
        return Task.Run(async () =>
        {
            int returnCode = 0;
            foreach (var pacman in _pacmanQueue)
            {
                bool.TryParse(Environment.GetEnvironmentVariable("CI"), out var ci);
                if (pacman.Ci && ci)
                {
                    Console.WriteLine($"[Pacman]: Skipping (\"{pacman.App}\") because of running on CI.");
                    Console.WriteLine($"Pacman task {++_status} of {Tasks} (\"{pacman.App}\") finished" + Environment.NewLine);
                } else
                {
                    for (int i = 0; i < 3; i++)
                    {
                        (int code, string output) res = await ExecCommand($"yay -S --noconfirm {pacman.Args} {pacman.App}", pacman.App);

                        returnCode = res.code;

                        if (res.code != 0)
                            Console.ForegroundColor = ConsoleColor.Red;
                        else
                            Console.ForegroundColor = ConsoleColor.Green;

                        Console.WriteLine($"Pacman task {(i == 0 ? ++_status : _status)} of {Tasks} (\"{res.output}\") finished" + (res.code != 0 ? " with an error." : ".") + Environment.NewLine);
                        Console.ResetColor();

                        if (res.code == 0)
                            break;
                        else
                        {
                            Console.WriteLine($"Retrying Pacman task \"{pacman}\"" + Environment.NewLine);
                            await ExecCommand($"pacman uninstall {pacman}", pacman.App);
                        }
                    }
                }
            }

            return returnCode;
        });
    }

    internal class PacmanTuple
    {
        [YamlMember(Alias = "app")]
        public string App { get; set; }
        [YamlMember(Alias = "args")]
        public string Args { get; set; }
        [YamlMember(Alias = "ci")]
        public bool Ci { get; set; }
    }

    internal class PacmanWrapper : ICommandable<PacmanTuple>
    {
        [YamlMember(Alias = "pacman")]
        public List<PacmanTuple> Commands { get; set; }
    }
}
