{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : FileLogger

 Info    : This Unit contains the class TFileLogger.
           This class is used for debugging purposes only.
           It writes output to:
           <User>\Appdata\Roaming\ControlTab\log.txt

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit FileLogger;

interface

uses
  IdePluginInterfaces;

type
  TFileLogger = class(TInterfacedObject, ILogger)
    procedure ClearLog;
    procedure LogMessage(aMessage: string);
  private
    FLogFile: string;
    procedure OpenLogLocation;
  public
    constructor Create;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, IdePlugin, ShellApi, Winapi.Windows;

{-------------------------------------------------------------------------------
 Name   : Create
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
constructor TFileLogger.Create;
var
  LogDirectory: string;
begin
  inherited;
  LogDirectory := System.SysUtils.GetHomePath;
  LogDirectory := TPath.Combine(LogDirectory, 'ControlTab');
  FLogFile  := TPath.Combine(LogDirectory, 'log.txt');

  Plugin.PrintMessage(Format('Log file: %s', [FLogFile]));

  // ensure directory exists
  if not TDirectory.Exists(LogDirectory) then
    TDirectory.CreateDirectory(LogDirectory);
end;

{-------------------------------------------------------------------------------
 Name   : ClearLog
 Info   : Deletes the log file, if it exists
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFileLogger.ClearLog;
begin
  if TFile.Exists(FLogFile) then
    TFile.Delete(FLogFile);
end;

{-------------------------------------------------------------------------------
 Name   : LogMessage
 Info   : Appends a message to the log file
 Input  : aMessage =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFileLogger.LogMessage(aMessage: string);
begin
  TFile.AppendAllText(FLogFile, aMessage + sLineBreak, TEncoding.UTF8);
end;

{-------------------------------------------------------------------------------
 Name   : OpenLogLocation
 Info   : Spwans the windows explorer to open the log file directory
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFileLogger.OpenLogLocation;
begin
  ShellExecute(0,'open', PChar(ExtractFilePath(FLogFile)), nil, nil, SW_SHOWNORMAL) ;
end;

end.

