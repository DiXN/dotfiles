#r "nuget: YamlDotNet, 9.1.0"
#load "TaskBase.cs"
#load "Command.cs"
#load "Scoop.cs"
#load "Choco.cs"
#load "Pacman.cs"
#load "ChocoDependency.cs"

using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;
using System.Threading.Tasks;

public static void WaitForDebugger()
{
    Console.WriteLine("Attach Debugger (VS Code)");
    while (!System.Diagnostics.Debugger.IsAttached);
}

if (Args.Contains("--debugger"))
    WaitForDebugger();

Console.WriteLine($"Available Threads: {Environment.ProcessorCount}");

var _taskList = new Queue<TaskBase>();
var _allTasks = new List<Task<int>[]>();

foreach (var arg in Args.Distinct())
{
    if (File.Exists(arg) && Regex.IsMatch(Path.GetExtension(arg.ToLower()), "^.ya?ml$"))
    {
        switch (Path.GetFileNameWithoutExtension(arg))
        {
            case "commands":
                ExecTask(new Command(arg));
                break;
            case "scoop":
                ExecTask(new Scoop(arg));
                break;
            case string s when s.StartsWith("pacman"):
                ExecTask(new Pacman(arg));
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

if (allTasksFlattened.Any(t => t.Result != 0))
{
    Console.Error.WriteLine($"Not all tasks have finished successfully. There were {allTasksFlattened.Count(x => x.Result != 0)} tasks with errors.");
    return -1;
}
else
    return 0;
