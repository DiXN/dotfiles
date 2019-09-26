using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

class ChocoDependency : TaskBase
{
    private ConcurrentQueue<ChocoDependencyTuple> _chocoDependencyQueue;

    public ChocoDependency(string file)
    {
        CmdType = CMD_TYPE.CHOCO_DEPENDENCY;
        FileName = file;

        var deserialize = Serial.Deserialize<ChocoDependencyWrapper, ChocoDependencyTuple>(file);

        deserialize.IfPresent(val =>
        {
            _chocoDependencyQueue = new ConcurrentQueue<ChocoDependencyTuple>(val.Commands);
            Tasks = val.Commands.Count;
        });
    }
    public override Task<int>[] Exec() => new[] { ExecTask() };

    protected override Task<int> ExecTask()
    {
        return Task.Run(async () =>
        {
            int returnCode = 0;
            foreach (var task in _chocoDependencyQueue.Select(cmd => ExecCommand($"choco install {cmd.app} -y && {string.Join(" && ", cmd.Cmd ?? (new[] { "" }))}", cmd.Desc, cmd.Path)))
            {
                (int code, string output) res = await task;

                returnCode = res.code;

                if (res.code != 0)
                    Console.ForegroundColor = ConsoleColor.Red;
                else
                    Console.ForegroundColor = ConsoleColor.Green;

                Console.WriteLine($"Choco with dependency {++_status} of {Tasks} (\"{res.output}\") finished" + (res.code != 0 ? " with an error." : ".") + Environment.NewLine);
                Console.ResetColor();
            }

            return returnCode;
        });
    }

    internal class ChocoDependencyTuple
    {
        [YamlMember(Alias = "app")]
        public string app { get; set; }
        [YamlMember(Alias = "cmd")]
        public string[] Cmd { get; set; }
        [YamlMember(Alias = "path")]
        public string Path { get; set; }
        [YamlMember(Alias = "desc")]
        public string Desc { get; set; }
    }

    internal class ChocoDependencyWrapper : ICommandable<ChocoDependencyTuple>
    {
        [YamlMember(Alias = "choco_dependency")]
        public List<ChocoDependencyTuple> Commands { get; set; }
    }
}
