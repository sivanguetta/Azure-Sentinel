using System.IO;

namespace Kqlvalidations.Tests
{
    public class ParsersFilesTestData : TheoryData<string, string>
    {
        public ParsersFilesTestData()
        {
            var parsersFilesLoader = new ParsersFilesLoader();
            var files = parsersFilesLoader.GetFilesNames();
            files.ForEach(filePath =>
            {
                var fileName = Path.GetFileName(filePath);
                Add(fileName, Utils.EncodeToBase64(filePath));
            });
        }
    }
}
