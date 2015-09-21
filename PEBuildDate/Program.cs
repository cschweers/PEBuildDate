using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Schweers;

namespace PEBuildDate
{
    class Program
    {
        static void Main(string[] args)
        {
            Schweers.PEBuildDate date = new Schweers.PEBuildDate();
            Console.WriteLine("Assembly build on {0} (\"local\")", date.ToString());
            Console.WriteLine("Assembly build on {0} (\"ISO8601\")", date.ToString("--ISO8601"));
            Console.WriteLine("Assembly build on {0} (\"UTC\")", date.GetDateTime().ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"));
            return;
        }
    }
}
