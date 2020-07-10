{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : CtrlTab.IdeNotifier

 Info    : This Unit contains the class TIDENotifier.
           This class receives notifications whenever a file is opened/closed.
           When a file is opened we attach a editor notifier to it. The editor
           notifier is removed once the file is closed.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit CtrlTab.IdeNotifier;

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
  CtrlTab.IdePlugin, SysUtils, System.Rtti;


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

