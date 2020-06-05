{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : FileLogger

 Info    : This Unit contains the class TFileLogger.

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
 Info   :
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
 Info   :
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
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFileLogger.OpenLogLocation;
begin
  ShellExecute(0,'open', PChar(ExtractFilePath(FLogFile)), nil, nil, SW_SHOWNORMAL) ;
end;

end.

