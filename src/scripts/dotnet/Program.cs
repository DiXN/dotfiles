using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using System.Linq;

namespace DotfilesWrapper
{
    class Program
    {
        static void Main(string[] args)
        {
            var _taskList = new Queue<TaskBase>();

            foreach (var arg in args.Distinct())
            {
                if (File.Exists(arg) && Regex.IsMatch(Path.GetExtension(arg.ToLower()) , "^.ya?ml$"))
                {
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

            void ExecTask(TaskBase task)
            {
                if (task.Tasks > 0)
                {
                    task.Exec();
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

            if (_taskList.Count > 0)
                ExecTask(_taskList.Dequeue());

            Console.ReadLine();
        }
    }
}
