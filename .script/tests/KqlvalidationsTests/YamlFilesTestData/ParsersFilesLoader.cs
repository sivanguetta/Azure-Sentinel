using Kqlvalidations.Tests.FunctionSchemasLoaders;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Kqlvalidations.Tests
{
    public class ParsersFilesLoader
    {
        protected const int TestFolderDepth = 6;
        protected List<string> GetDirectoryPaths()
        {
            var basePath = Utils.GetTestDirectory(TestFolderDepth);
            var parsersDirs = Directory.GetDirectories(Path.Combine(basePath, "Parsers"), "*", SearchOption.TopDirectoryOnly);
            var solutionDirs = Directory.GetDirectories(Path.Combine(basePath, "Solutions"), "*", SearchOption.TopDirectoryOnly).Select(dir => Path.Combine(basePath, dir));
            return parsersDirs.Concat(solutionDirs).ToList();
        }

        public List<string> GetFilesNames()
        {
            var directoryPaths = GetDirectoryPaths();

            return directoryPaths.Aggregate(new List<string>(), (accumulator, directoryPath) =>
            {
                var txtfiles = Directory.GetFiles(directoryPath, "*.txt", SearchOption.AllDirectories).ToList();
                var kqlfiles = Directory.GetFiles(directoryPath, "*.kql", SearchOption.AllDirectories).ToList();
                return accumulator.Concat(txtfiles).Concat(kqlfiles).ToList();
            });
        }
    }
}