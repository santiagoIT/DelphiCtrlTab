{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : SourceEditorNotifier

 Info    : This Unit contains the class TSourceEditorNotifier.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit SourceEditorNotifier;

interface

uses
  Classes, SysUtils, ToolsAPI, IdePluginInterfaces, EditorNotifierBase;

type
  TSourceEditorNotifier = class(TEditorNotifierBase, IOTANotifier, IOTAEditorNotifier, IEditorNotifier)
  private
    procedure ViewActivated(const View: IOTAEditView);
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
  protected
  public
    constructor Create(AEditor: IOTAEditor); reintroduce;
  end;

implementation

uses
  IdePlugin;

{-------------------------------------------------------------------------------
 Name   : Create
 Info   : Constructor. Register myself as a notifier for AEditor
 Input  : AEditor = source editor
 Output :
 Result : None
-------------------------------------------------------------------------------}
constructor TSourceEditorNotifier.Create(AEditor: IOTAEditor);
begin
  inherited;
  FIndex := FEditor.AddNotifier(Self);
end;


{-------------------------------------------------------------------------------
 Name   : ViewActivated
 Info   : This is called when the associated view is activated in the editor.
 Input  : View = view which was activated.
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TSourceEditorNotifier.ViewActivated(const View: IOTAEditView);
begin
  // notify view manager that a view was activated.
  Plugin.ViewManager.ViewActivated(View.Buffer.FileName);
end;

{-------------------------------------------------------------------------------
 Name   : ViewNotification
 Info   : Called when a new edit view is created(opInsert) or destroyed(opRemove)
 Input  : View =
          Operation = remove of insert
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TSourceEditorNotifier.ViewNotification(const View: IOTAEditView; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    // notify unit manager that a view has been closed.
    Plugin.FileClosing(View.Buffer.FileName);
  end
  else if Operation = opInsert then
  begin
    // register open file
    Plugin.ViewManager.ViewActivated(View.Buffer.FileName);
  end;
end;

end.

