unit FileLogger;

interface

uses
  IdePluginInterfaces;

type
  TFileLogger = class(TInterfacedObject, ILogger)
    procedure ClearLog;
    procedure LogMesage(aMessage: string);
  private
    FLogFile: string;
  public
    constructor Create;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, IdePlugin;

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

procedure TFileLogger.ClearLog;
begin
  if TFile.Exists(FLogFile) then
    TFile.Delete(FLogFile);
end;

procedure TFileLogger.LogMesage(aMessage: string);
begin
  TFile.AppendAllText(FLogFile, aMessage + sLineBreak, TEncoding.UTF8);
end;

end.

