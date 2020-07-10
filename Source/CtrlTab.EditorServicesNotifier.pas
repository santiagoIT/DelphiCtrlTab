{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : CtrlTab.EditorServicesNotifier

 Info    : This Unit contains the class TCtrlTabEditorServicesNotifier.
           DockFormUpdated is called whenever a Tab is activated.
           This is the only way I have to know when special modules such
           as the Welcome Page are activated.

  Copyright (c) 2020 - Santiago Burbano
===============================================================================}
unit CtrlTab.EditorServicesNotifier;

interface

uses
  ToolsApi, System.Classes, DockForm;

type
  TCtrlTabEditorServicesNotifier = Class(TNotifierObject, INTAEditServicesNotifier)
  public
    // INTAEditorServicesNotifier
    procedure DockFormRefresh(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormUpdated(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure DockFormVisibleChanged(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
    procedure EditorViewActivated(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
    procedure EditorViewModified(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
    procedure WindowActivated(Const EditWindow: INTAEditWindow);
    procedure WindowCommand(Const EditWindow: INTAEditWindow; Command: Integer; Param: Integer; Var Handled: Boolean);
    procedure WindowNotification(Const EditWindow: INTAEditWindow; Operation: TOperation);
    procedure WindowShow(Const EditWindow: INTAEditWindow; Show: Boolean; LoadedFromDesktop: Boolean);
  end;

implementation

uses
  IdePlugin, System.SysUtils, CtrlTab.Consts;

procedure TCtrlTabEditorServicesNotifier.DockFormRefresh(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin
end;

{-------------------------------------------------------------------------------
 Name   : DockFormUpdated
 Info   : This method is called whenever a tab is activated.
          It is the only way I have found to be able to detect that the Welcome Page
          has been activated.
 Input  : EditWindow =
          DockForm =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TCtrlTabEditorServicesNotifier.DockFormUpdated(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
var
  Caption: string;
begin
  if Assigned(EditWindow.Form) then
  begin
    Caption := EditWindow.Form.Caption;
    // only interested in special pages such as Welcome Page
    if Caption.StartsWith(c_BdsSpecialPrefix) then
    begin
      // register view without bds prefix
      Plugin.ViewManager.ViewActivated(Caption.Substring(5));
    end;
  end;
end;

procedure TCtrlTabEditorServicesNotifier.DockFormVisibleChanged(Const EditWindow: INTAEditWindow; DockForm: TDockableForm);
begin
end;

procedure TCtrlTabEditorServicesNotifier.EditorViewActivated(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
begin
end;

procedure TCtrlTabEditorServicesNotifier.EditorViewModified(Const EditWindow: INTAEditWindow; Const EditView: IOTAEditView);
begin
end;

procedure TCtrlTabEditorServicesNotifier.WindowActivated(Const EditWindow: INTAEditWindow);
begin
end;

procedure TCtrlTabEditorServicesNotifier.WindowCommand(Const EditWindow: INTAEditWindow; Command: Integer; Param: Integer; Var Handled: Boolean);
begin
end;

procedure TCtrlTabEditorServicesNotifier.WindowNotification(Const EditWindow: INTAEditWindow; Operation: TOperation);
begin
end;

procedure TCtrlTabEditorServicesNotifier.WindowShow(Const EditWindow: INTAEditWindow; Show: Boolean; LoadedFromDesktop: Boolean);
begin
end;

end.