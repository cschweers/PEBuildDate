Option Explicit On
Option Strict On

Imports System.IO

''' <summary>
''' PEBuilDate Konsolenanwendung
''' </summary>
Module PEBuilDate
  ''' <summary>
  ''' Einstiegspunkt der Anwendung.
  ''' </summary>
  ''' <param name="args">
  ''' Pfad zu einer gültigen PE-Datei (EXE/DLL)</param>
  ''' <remarks>
  ''' Gibt die eigene Version, sowie Erstellungsdatum auf der Konsole
  ''' aus. Wird als Argument der Pfad einer gültigen PE-Datei
  ''' (EXE/DLL) angegeben, wird
  ''' deren Erstellungsdatum ebenfalls angezeigt.
  ''' </remarks>
  Sub Main(ByVal args() As String)
    Dim lVersion As Version = _
System.Reflection.Assembly.GetExecutingAssembly.GetName().Version

    Console.WriteLine("PE BuildDate " & lVersion.ToString(4))
    Console.WriteLine("Erstellt am: " & _
              BuildInfo.PEBuildDate().ToString & ControlChars.NewLine)

    If args.Length > 0 Then
      Dim lAppName As String = Path.GetFileName(args(0))
      Console.WriteLine(lAppName)

      Try
        Console.WriteLine("wurde erstellt am: " & _
                          BuildInfo.PEBuildDate(args(0)).ToString)
      Catch ex As Exception
        Console.WriteLine(ex.Message)
      End Try

      Exit Sub
    End If

    Console.WriteLine("Anwendung:{0}{0}   pebuildate Dateiname", _
                      ControlChars.NewLine)
  End Sub
End Module

''' <summary>
''' Stellt Informationen zu einer PE Datei zur Verfügung.
''' </summary>
Friend Class BuildInfo

  ''' <summary>
  ''' Gibt das Erstellungsdatum des aktuell ausgeführten Assembly
  ''' zurück.
  ''' </summary>
  Public Shared Function PEBuildDate() As DateTime
    Return PEBuildDate( _
            System.Reflection.Assembly.GetExecutingAssembly)
  End Function

  ''' <summary>
  ''' Gibt das Erstellungsdatum eines Assembly zurück.
  ''' </summary>
  ''' <param name="assembly">Das Assembly dessen Erstellungsdatum _
  ''' ermittelt werden soll.</param>
  Public Shared Function PEBuildDate( _
	ByVal [assembly] As System.Reflection.Assembly _
			) As DateTime
    Return PEBuildDate([assembly].Location)
  End Function

  ''' <summary>
  ''' Gibt das Erstellungsdatum einer PE-Datei zurück.
  ''' </summary>
  ''' <param name="filename">
  ''' Dateiname der PE-Datei, deren Erstellungsdatum ermittelt werden
  ''' soll.</param>
  ''' <returns>Ein DateTime mit dem Datum der Erstellung der
  ''' angegebenen PE-Datei.</returns>
  ''' <exception cref="FileNotFoundException">
  ''' Der angegebene Pfad konnte nicht gefunden werden.</exception>
  ''' <exception cref="InvalidPEFileException">
  ''' Die angegebene Datei ist keine gültige Portable Executable (PE)
  ''' Datei.</exception>
  Public Shared Function PEBuildDate( _
			             ByVal filename As String _
					   ) As DateTime
    Dim lPEOffset As Integer
    Dim lPE() As Char
    Dim lTimeStamp As Integer
    Dim lDate As New DateTime(1970, 1, 1)

    Const PE_OFFSET As Integer = &H3C
    Const PE_TIMESTAMP As Integer = 8
    Const PE_SIGNATURE As String = "PE" & ControlChars.NullChar & _
                                          ControlChars.NullChar

    If Not System.IO.File.Exists(filename) Then
      Throw New FileNotFoundException
    End If

    Dim lStream As Stream = File.Open(filename, _
                                      FileMode.Open, _
                                      FileAccess.Read, _
                                      FileShare.Read)
    Dim lReader As New BinaryReader(lStream)

    lReader.BaseStream.Seek(PE_OFFSET, SeekOrigin.Begin)
    lPEOffset = lReader.ReadInt32()
    lReader.BaseStream.Seek(lPEOffset, SeekOrigin.Begin)
    lPE = lReader.ReadChars(PE_SIGNATURE.Length)

    If Not String.Equals(lPE, PE_SIGNATURE) Then
      lReader.Close()
      Throw New InvalidPEFileException
    End If

    lReader.BaseStream.Seek(lPEOffset + PE_TIMESTAMP, _
                            SeekOrigin.Begin)
    lTimeStamp = lReader.ReadInt32()
    lReader.Close()

    Return lDate.AddSeconds(lTimeStamp).ToLocalTime
  End Function
End Class

''' <summary>
''' Ausnahme, die geworfen wird, wenn die angegebene Datei keine _
''' PE-Datei repräsentiert.
''' </summary>
Friend Class InvalidPEFileException
  Inherits System.Exception

  ''' <summary>
  ''' Erstellt eine neue Instanz der InvalidPEFileException Klasse.
  ''' </summary>
  Public Sub New()
    MyBase.New("Die angegebene Datei ist keine gültige PE-Datei.")
  End Sub
End Class
