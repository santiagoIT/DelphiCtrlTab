unit UnitManager;

interface

uses
  IdePluginInterfaces, System.Classes, ToolsApi;

type
  TUnitManager = class(TInterfacedObject, IUnitManager)
    function GetViewAt(aIndex: Integer): string;
    function GetViewCount: Integer;
    procedure ShutDown;
    procedure ViewActivated(const aFileName: string);
    procedure ViewClosed(const aViewName: string);
  private
    FUnits: TStringList;
    procedure ShowSourceView(aIndex: Integer);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils;

constructor TUnitManager.Create;
begin
  inherited;
  FUnits := TStringList.Create;
end;

destructor TUnitManager.Destroy;
begin
  inherited;
  FreeAndNil(FUnits);
end;

function TUnitManager.GetViewAt(aIndex: Integer): string;
begin
  Result := FUnits[aIndex];
end;

function TUnitManager.GetViewCount: Integer;
begin
  Result := FUnits.Count;
end;

procedure TUnitManager.ShowSourceView(aIndex: Integer);
var
  FileToShow: string;
  i: Integer;
  j: Integer;
  ModuleEditor: IOTAEditor;
  ModuleServices: IOTAModuleServices;
  OpenModule: IOTAModule;
begin
  FileToShow := FUnits[aIndex];

  // find open module and show it
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  for i := 0 to ModuleServices.ModuleCount - 1 do
  begin
    OpenModule := ModuleServices.Modules[i];

    // loop editors
    for j := 0 to OpenModule.ModuleFileCount - 1 do
    begin
      ModuleEditor := OpenModule.ModuleFileEditors[j];
      if ModuleEditor.FileName = FileToShow then
      begin
        ModuleEditor.Show;
        break;
      end;
    end;
  end;
end;

procedure TUnitManager.ShutDown;
begin
  FUnits.Clear;
end;


procedure TUnitManager.ViewActivated(const aFileName: string);
var
  Index: Integer;
begin
  Index := FUnits.IndexOf(aFileName);
  // remove if already in list
  if Index >= 0 then
    FUnits.Delete(Index);
  // add to top
  FUnits.Insert(0, aFileName);
end;

procedure TUnitManager.ViewClosed(const aViewName: string);
var
  Index: Integer;
begin
  Index := FUnits.IndexOf(aViewName);
  if Index >= 0 then
    FUnits.Delete(Index);
end;

end.
