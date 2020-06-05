{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : EditorNotifierBase

 Info    : This Unit contains the class TEditorBase.
           This class contains the base functionallity for Source and Form
           EditorNotifiers.

  Copyright (c) 2020 - Santiago Burbano
===============================================================================}
unit EditorNotifierBase;

interface

uses
  ToolsAPI, IdePluginInterfaces;

type
  TEditorNotifierBase = class(TNotifierObject, IOTANotifier, IEditorNotifier)
  private
    function GetFileName: string;
  protected
    FEditor: IOTAEditor;
    FIndex: Integer;
    FFileName: string;
    procedure CleanUp;
    procedure Destroyed;
  public
    constructor Create(aEditor: IOTAEditor); reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  IdePlugin, System.SysUtils;

{-------------------------------------------------------------------------------
 Name   : Create
 Info   : Constructor
 Input  : aEditor = Editor

 Output :
 Result : None
-------------------------------------------------------------------------------}
constructor TEditorNotifierBase.Create(aEditor: IOTAEditor);
begin
  inherited Create;
  FEditor := aEditor;
  FFileName := FEditor.FileName;
end;

{-------------------------------------------------------------------------------
 Name   : Destroy
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
destructor TEditorNotifierBase.Destroy;
begin
  Plugin.EditorNotifierAboutToBeDestroyed(Self);
  Cleanup;
  inherited;
end;

{-------------------------------------------------------------------------------
 Name   : CleanUp
 Info   : Performs clean up once the notifier is about to be released.
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TEditorNotifierBase.CleanUp;
begin
  if FIndex >= 0 then
  begin
    if Assigned(FEditor) then
    begin
      Plugin.Logger.LogMessage(Format('TEditorNotifierBase. notifier removed. [%s]', [FFileName]));
      FEditor.RemoveNotifier(FIndex);
    end;
    FIndex := -1;
  end;
  FEditor := nil;
end;

{-------------------------------------------------------------------------------
 Name   : Destroyed
 Info   : The associated item is being destroyed so all references should be dropped.
          Exceptions are ignored.
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TEditorNotifierBase.Destroyed;
begin
  Plugin.Logger.LogMessage(Format('TEditorNotifierBase.Destroyed. [%s]', [FFileName]));
  CleanUp;
end;


{-------------------------------------------------------------------------------
 Name   : GetFileName
 Info   :
 Input  :
 Output :
 Result : string
-------------------------------------------------------------------------------}
function TEditorNotifierBase.GetFileName: string;
begin
  Result := FFileName;
end;


end.

