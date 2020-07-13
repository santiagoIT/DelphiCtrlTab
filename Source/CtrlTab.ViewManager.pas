{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : CtrlTab.ViewManager

 Info    : This Unit contains the class TViewManager.

 Copyright (c) 2020 - Santiago Burbano
===============================================================================}
unit CtrlTab.ViewManager;

interface

uses
  CtrlTab.Interfaces, System.Classes, ToolsApi;

type
  TViewManager = class(TInterfacedObject, IViewManager)
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

constructor TViewManager.Create;
begin
  inherited;
  FUnits := TStringList.Create;
end;

destructor TViewManager.Destroy;
begin
  inherited;
  FreeAndNil(FUnits);
end;

function TViewManager.GetViewAt(aIndex: Integer): string;
begin
  Result := FUnits[aIndex];
end;

function TViewManager.GetViewCount: Integer;
begin
  Result := FUnits.Count;
end;

procedure TViewManager.ShowSourceView(aIndex: Integer);
var
  FileToShow: string;
  i: Integer;
  j: Integer;
  ModuleEditor: IOTAEditor;
  ModuleServices: IOTAModuleServices;
  OpenModule: IOTAModule;
  SpecialModule: IOTAModule;
begin
  FileToShow := FUnits[aIndex];
  SpecialModule := nil;

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
        Exit;
      end;
    end;

    // Could be a special module (Welcome Page)
    if OpenModule.FileName = FileToShow then
    begin
      SpecialModule := OpenModule;
    end;
  end;

  // Could be a special module (Welcome Page)
  if Assigned(SpecialModule) then
    SpecialModule.Show;
end;

procedure TViewManager.ShutDown;
begin
  FUnits.Clear;
end;


procedure TViewManager.ViewActivated(const aFileName: string);
var
  Index: Integer;
begin
  Index := FUnits.IndexOf(aFileName);
  if Index = 0 then Exit;
  // remove if already in list
  if Index >= 0 then
    FUnits.Delete(Index);
  // add to top
  FUnits.Insert(0, aFileName);
end;

procedure TViewManager.ViewClosed(const aViewName: string);
var
  Index: Integer;
begin
  Index := FUnits.IndexOf(aViewName);
  if Index >= 0 then
    FUnits.Delete(Index);
end;

end.
