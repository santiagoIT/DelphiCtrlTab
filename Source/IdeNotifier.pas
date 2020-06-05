{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : IdeNotifier

 Info    : This Unit contains the class TIDENotifier.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit IdeNotifier;

interface

uses
  ToolsAPI;

type
  TIDENotifier = class(TNotifierObject, IOTANotifier, IOTAIDENotifier)
  private
    { IOTAIDENotifier }
    procedure FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
    procedure BeforeCompile(const Project: IOTAProject; var Cancel: Boolean); overload;
    procedure AfterCompile(Succeeded: Boolean); overload;
  end;

implementation

uses
  IdePlugin, SysUtils, System.Rtti;


{-------------------------------------------------------------------------------
 Name   : AfterCompile
 Info   :
 Input  : Succeeded =
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  // do nothing
end;


{-------------------------------------------------------------------------------
 Name   : BeforeCompile
 Info   :
 Input  : Project =
          Cancel =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  // do nothing
end;


{-------------------------------------------------------------------------------
 Name   : FileNotification
 Info   :
 Input  : NotifyCode =
          FileName =
          Cancel =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIDENotifier.FileNotification(NotifyCode: TOTAFileNotification; const FileName: string; var Cancel: Boolean);
var
  ModuleServices: IOTAModuleServices;
  Module: IOTAModule;
begin
  case NotifyCode of
    ofnFileOpened:
      begin
        ModuleServices := BorlandIDEServices as IOTAModuleServices;
        Module := ModuleServices.FindModule(FileName);
        if Assigned(Module) then
          Plugin.InstallSourceEditorNotifiers(Module);
      end;

    ofnFileClosing:
    begin
      Plugin.FileClosing(FileName);
    end;
  end;
end;

end.

