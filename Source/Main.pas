{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : Main

 Info    : This Unit contains the Register function. It is the entry point for
           this plugin.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit Main;

interface

procedure Register;

implementation

uses
  IdePlugin, ToolsAPI;

{-------------------------------------------------------------------------------
 Name   : Register
 Info   : Entry point for design time component
 Input  :
 Output :
 Result :
-------------------------------------------------------------------------------}
procedure Register;
begin
  Plugin.BootUp;
end;

initialization

finalization
  Plugin.ShutDown;
end.

