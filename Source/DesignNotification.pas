unit DesignNotification;

interface

uses
  Classes, SysUtils, ToolsAPI, IdePluginInterfaces, DesignIntf;

type
  TDesignNotification = class(TInterfacedObject, IDesignNotification)
    procedure DesignerClosed(const ADesigner: IDesigner; AGoingDormant: Boolean);
    procedure DesignerOpened(const ADesigner: IDesigner; AResurrecting: Boolean);
     procedure ItemDeleted(const ADesigner: IDesigner; AItem: TPersistent);
    procedure ItemInserted(const ADesigner: IDesigner; AItem: TPersistent);
    procedure ItemsModified(const ADesigner: IDesigner);
    procedure SelectionChanged(const ADesigner: IDesigner; const ASelection:
        IDesignerSelections);
  end;

implementation

uses
  IdePlugin;

procedure TDesignNotification.DesignerClosed(const ADesigner: IDesigner; AGoingDormant: Boolean);
var
  FormFileName: string;
  ImplFileName: string;
  IntfFileName: string;
begin
  // this is a workaround, because IOTAFormNotifier are not notified when forms are closed...
  ADesigner.ModuleFileNames(ImplFileName, IntfFileName, FormFileName);
  Plugin.DesignerClosed(FormFileName);
end;

procedure TDesignNotification.DesignerOpened(const ADesigner: IDesigner;
    AResurrecting: Boolean);
begin
end;

procedure TDesignNotification.ItemDeleted(const ADesigner: IDesigner; AItem:
    TPersistent);
begin

end;

procedure TDesignNotification.ItemInserted(const ADesigner: IDesigner; AItem:
    TPersistent);
begin

end;

procedure TDesignNotification.ItemsModified(const ADesigner: IDesigner);
begin

end;

procedure TDesignNotification.SelectionChanged(const ADesigner: IDesigner;
    const ASelection: IDesignerSelections);
begin
end;

end.

