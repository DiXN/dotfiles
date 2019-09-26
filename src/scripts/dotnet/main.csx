#r "nuget: YamlDotNet, 6.1.2"
#load "TaskBase.cs"
#load "Command.cs"
#load "Scoop.cs"
#load "Choco.cs"
#load "ChocoDependency.cs"

using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;
using System.Threading.Tasks;

Console.WriteLine($"Available Threads: {Environment.ProcessorCount}");

var _taskList = new Queue<TaskBase>();
var _allTasks = new List<Task[]>();

foreach (var arg in Args.Distinct())
{
    Console.WriteLine(arg);
    if (File.Exists(arg) && Regex.IsMatch(Path.GetExtension(arg.ToLower()), "^.ya?ml$"))
    {
        Console.WriteLine($"{arg} exists");
        switch (Path.GetFileNameWithoutExtension(arg))
        {
            case "commands":
                ExecTask(new Command(arg));
                break;
            case "scoop":
                ExecTask(new Scoop(arg));
                break;
            case "choco":
                _taskList.Enqueue(new Choco(arg));
                break;
            case "choco_dependency":
                _taskList.Enqueue(new ChocoDependency(arg));
                break;
        }
    }
}

if (_taskList.Count > 0)
    ExecTask(_taskList.Dequeue());

void ExecTask(TaskBase task)
{
    if (task.Tasks > 0)
    {
        _allTasks.Add(task.Exec());
    }
    else
    {
        Console.WriteLine($"\"{task.FileName}\" has no value to process.");
        Console.WriteLine($"Check if the commands in \"{task.FileName}\" are valid!");
    }
}

TaskBase.OnTasksFinished += (sender, type) =>
{
  if (_taskList.Count > 0)
  {
    var task = _taskList.Dequeue();

    if (task != null)
      ExecTask(task);
  }
};

var allTasksFlattened = _allTasks.SelectMany(x => x).ToArray();

Task.WaitAll(allTasksFlattened);

Console.WriteLine($"Processed {allTasksFlattened.Length} tasks in total.");