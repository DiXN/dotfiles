﻿using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using YamlDotNet.Serialization;

namespace DotfilesWrapper
{
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
        public override void Exec() => ExecTask();

        protected override void ExecTask()
        {
            Task.Run(async () =>
            {
                foreach (var task in _chocoDependencyQueue.Select(cmd => ExecCommand($"choco install {cmd.app} -y && {string.Join(" && ", cmd.Cmd ?? (new[] { "" }))}", cmd.Desc, cmd.Path)))
                {
                    Console.WriteLine(await task);
                    Console.WriteLine($"Choco with dependency task {++_status} of {Tasks} finished. {Environment.NewLine}");
                }
            });
        }

        internal class ChocoDependencyTuple
        {
            [YamlMember(Alias = "cmd")]
            public string[] Cmd { get; set; }
            [YamlMember(Alias = "path")]
            public string Path { get; set; }
            [YamlMember(Alias = "desc")]
            public string Desc { get; set; }
            [YamlMember(Alias = "app")]
            public string app { get; set; }
        }

        internal class ChocoDependencyWrapper : ICommandable<ChocoDependencyTuple>
        {
            [YamlMember(Alias = "choco_dependency")]
            public List<ChocoDependencyTuple> Commands { get; set; }
        }
    }
}
