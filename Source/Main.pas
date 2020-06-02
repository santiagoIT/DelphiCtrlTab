unit Main;

interface

procedure Register;

implementation

uses
  IdePlugin, ToolsAPI;

procedure Register;
begin
  Plugin.BootUp;
end;

initialization

finalization
  Plugin.ShutDown;
end.

