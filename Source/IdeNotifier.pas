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
  IdePlugin, SysUtils;

//----------------------------------------------------------------------------------------------------------------------

{ TIDENotifier private: IOTAIDENotifier }

//----------------------------------------------------------------------------------------------------------------------

procedure TIDENotifier.AfterCompile(Succeeded: Boolean);
begin
  // do nothing
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TIDENotifier.BeforeCompile(const Project: IOTAProject; var Cancel: Boolean);
begin
  // do nothing
end;

//----------------------------------------------------------------------------------------------------------------------

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
          Plugin.InstallSourceEditorNotifiers(Module, False);
      end;

    ofnFileClosing:
    begin
      Plugin.FileClosing(FileName);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

end.

