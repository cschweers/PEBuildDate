using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
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
            Console.WriteLine("Assembly \"{1}\" build on {0,-25} (\"local\")", date.ToString(), Path.GetFileName( date.AssemblyName));
            Console.WriteLine("Assembly \"{1}\" build on {0,-25} (\"ISO8601\")", date.ToString("--ISO8601"), Path.GetFileName(date.AssemblyName));
            Console.WriteLine("Assembly \"{1}\" build on {0,-25} (\"UTC\")", date.GetDateTime().ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ"), Path.GetFileName(date.AssemblyName));
            if(Debugger.IsAttached)
            {
                Console.WriteLine("Press any key to exit...");
                Console.ReadLine();
            }
            return;
        }
    }
}
