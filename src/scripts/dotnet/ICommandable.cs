using System.Collections.Generic;

interface ICommandable<T>
{
    List<T> Commands { get; set; }
}
