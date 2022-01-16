#load "ICommandable.cs"

using System;
using System.IO;
using YamlDotNet.Serialization;
using YamlDotNet.Core;

static class Serial
{
    public static Optional<T> Deserialize<T, K>(string file) where T : ICommandable<K>
    {
        using (StringReader reader = new StringReader(File.ReadAllText(file)))
        {
            Deserializer deserializer = new Deserializer();

            try
            {
                var deserialize = deserializer.Deserialize<T>(reader);

                if (deserialize?.Commands != null)
                    return Optional.Of(deserialize);
                else
                    return Optional.Empty<T>();
            }
            catch (YamlException ex)
            {
                Console.WriteLine(ex.Message);
                return Optional.Empty<T>();
            }
        }
    }
}
