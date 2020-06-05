{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : FormEditorNotifier

 Info    : This Unit contains the class TFormEditorNotifier.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit FormEditorNotifier;

interface

uses
  Classes, SysUtils, ToolsAPI, IdePluginInterfaces, EditorNotifierBase;

type
  TFormEditorNotifier = class(TEditorNotifierBase, IOTANotifier, IOTAFormNotifier, IEditorNotifier)
  private
    { Called when a component on this form was renamed }
    procedure ComponentRenamed(ComponentHandle: TOTAHandle; const OldName, NewName: string);
    { IOTAEditorNotifier }
    procedure FormActivated;
    { This is called immediately prior to the form being streamed out.  This
      may be called without first getting a BeforeSave as in the case of
      the project being compiled. }
    procedure FormSaving;
  protected
  public
    constructor Create(aEditor: IOTAFormEditor);
  end;

implementation

uses
  IdePlugin;

{-------------------------------------------------------------------------------
 Name   : Create
 Info   : Constructor. Register myself as a notifier for AEditor
 Input  : aEditor = form editor
 Output :
 Result : None
-------------------------------------------------------------------------------}
constructor TFormEditorNotifier.Create(aEditor: IOTAFormEditor);
begin
  inherited Create(aEditor);
  FIndex := FEditor.AddNotifier(Self);
end;

{-------------------------------------------------------------------------------
 Name   : ComponentRenamed
 Info   :
 Input  : ComponentHandle =
          OldName =
          NewName =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormEditorNotifier.ComponentRenamed(ComponentHandle: TOTAHandle; const OldName, NewName: string);
begin
end;

{-------------------------------------------------------------------------------
 Name   : FormActivated
 Info   : This method is called when a form is activated.
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormEditorNotifier.FormActivated;
begin
  // notify view manager
  Plugin.ViewManager.ViewActivated(FFileName);
end;

{-------------------------------------------------------------------------------
 Name   : FormSaving
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormEditorNotifier.FormSaving;
begin
end;

end.

