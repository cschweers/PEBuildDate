using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace Schweers
{
    /// <summary>
    /// http://microsoft.public.de.german.entwickler.dotnet.vb.narkive.com/dD3ket9l/kompilierungszeitpunkt-der-assembly-abfragen#post5
	/// https://groups.google.com/forum/#!msg/microsoft.public.de.german.entwickler.dotnet.vb/Fc2ql8IY_Ro/aanyvalzIGkJ
    /// </summary>
	public class PEBuildDate
	{
		private string _assemblyName;

		public PEBuildDate() : this( System.Reflection.Assembly.GetExecutingAssembly())
		{
		}

		public PEBuildDate(System.Reflection.Assembly MyAssembly) : this( MyAssembly.Location)
		{
		}

		public PEBuildDate(string Filename)
		{
			_assemblyName = Filename;
		}

		public DateTime GetDateTime()
		{
			int lPEOffset;
			char[] lPE;
			int lTimeStamp;
			DateTime lDate = new DateTime(1970, 1, 1);
			const int PE_OFFSET = 0x3C;
			const int PE_TIMESTAMP = 8;
			const string PE_SIGNATURE = "PE\0\0";

			if (!System.IO.File.Exists(_assemblyName))
			{
				throw new FileNotFoundException();
			}

			Stream lStream = File.Open(_assemblyName, FileMode.Open, FileAccess.Read, FileShare.Read);
			BinaryReader lReader = new BinaryReader( lStream);

			lReader.BaseStream.Seek( PE_OFFSET, SeekOrigin.Begin);
			lPEOffset = lReader.ReadInt32();
			lReader.BaseStream.Seek( lPEOffset, SeekOrigin.Begin);
			lPE = lReader.ReadChars( PE_SIGNATURE.Length);
			string lPEstr = new string( lPE);

			if (0 != PE_SIGNATURE.CompareTo(lPEstr))
			{
				lReader.Close();
				throw new InvalidPEFileException();
			}

			lReader.BaseStream.Seek(lPEOffset + PE_TIMESTAMP, SeekOrigin.Begin);
			lTimeStamp = lReader.ReadInt32();
			lReader.Close();
			return lDate.AddSeconds(lTimeStamp).ToLocalTime();
		}
		
		public override string ToString()
		{
			return this.GetDateTime().ToString();
		}
		
		/// <summary>
		/// get DateTime as a string in a specific format
		/// </summary>
		/// <param name="format">"--ISO8601", else local time</param>
		/// <returns></returns>
		public string ToString(string format)
		{
			string sRet;
			switch (format) {
				case "--ISO8601":
					sRet = this.GetDateTime().ToString("yyyy-MM-ddTHH:mm:sszzz");
					break;
				default:
					sRet = this.ToString();
					break;
			}
			return sRet;
		}
	}

	public class InvalidPEFileException : Exception
	{
		public InvalidPEFileException()
			: base("Die Datei ist keine gültige PE-Datei.")
		{
		}
		public InvalidPEFileException(string message)
			: base(message)
		{
		}
		public InvalidPEFileException(string message, Exception inner)
			: base(message, inner)
		{
		}
	}
}
