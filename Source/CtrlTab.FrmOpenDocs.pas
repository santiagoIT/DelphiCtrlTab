{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : CtrlTab.FrmOpenDocs

 Info    : This Unit contains the class TFormOpenDocs.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit CtrlTab.FrmOpenDocs;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFormOpenDocs = class(TForm)
    GroupBoxOpenUnits: TGroupBox;
    Label_SelectedFile: TLabel;
    Label_FullPath: TLabel;
    ListViewOpenFiles: TListView;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetDisplayNameFor(const aModuleFileName: string): string;
    procedure ListViewOpenFilesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListViewOpenFilesDblClick(Sender: TObject);
  private
  class var
    FIsShowing: Boolean;
  var
    FClosing: Boolean;
    // keep track of whether KeyUp was detected to the Tab-Key
    FTabKeyUpCalled: Boolean;
    procedure RefreshLabels;
  public
    class property IsShowing: Boolean read FIsShowing;
  end;

var
  Form1: TFormOpenDocs;

implementation

{$R *.dfm}

uses
  CtrlTab.IdePlugin, ToolsApi, CtrlTab.ViewManager, CtrlTab.Consts;

{-------------------------------------------------------------------------------
 Name   : FormClose
 Info   :
 Input  : Sender =
          Action =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.FormClose(Sender: TObject; var Action: TCloseAction);
var
  FileToActivateIndex: Integer;
begin
  FClosing := True;
  if ModalResult = mrOk then
  begin
    // if Ctrl+Tab was pressed and released very quickly, then no KeyUp event for the Tab is registered
    // in this case we will set the item index to 1.
    if not FTabKeyUpCalled then
    begin
      if Plugin.ViewManager.ViewCount > 1 then
        FileToActivateIndex := 1
      else
        FileToActivateIndex := 0;
    end
    else
      FileToActivateIndex := ListViewOpenFiles.ItemIndex;

    if FileToActivateIndex > 0 then
      Plugin.ViewManager.ShowSourceView(FileToActivateIndex);
  end;
  Action := caFree;
  FIsShowing := False;

  // enable keyboard hook
  Plugin.ActivateKeyboardHook;

  // store size
  Plugin.Settings.DialogWidth := Self.Width;
  Plugin.Settings.DialogHeight := Self.Height;
end;

{-------------------------------------------------------------------------------
 Name   : FormCreate
 Info   :
 Input  : Sender =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.FormCreate(Sender: TObject);
var
  FileDisplayName: string;
  i: Integer;
begin
  AlphaBlend := True;
  AlphaBlendValue := 0;
  FIsShowing := True;
  FTabKeyUpCalled := False;

   // apply size
  if Plugin.Settings.DialogWidth > 0 then
    Width := Plugin.Settings.DialogWidth;
  if Plugin.Settings.DialogHeight > 0 then
    Height := Plugin.Settings.DialogHeight;

  for i := 0 to Plugin.ViewManager.ViewCount -1 do
  begin
    FileDisplayName := GetDisplayNameFor(Plugin.ViewManager.GetViewAt(i));
    ListViewOpenFiles.AddItem(ExtractFileName(FileDisplayName), nil);
  end;
  if ListViewOpenFiles.Items.Count > 0 then
  begin
    ListViewOpenFiles.ItemIndex := 0;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : FormDeactivate
 Info   :
 Input  : Sender =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.FormDeactivate(Sender: TObject);
begin
  if not FClosing then Close;
end;

{-------------------------------------------------------------------------------
 Name   : FormKeyUp
 Info   :
 Input  : Sender =
          Key =
          Shift =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  Index: Integer;
begin
  if Key = VK_CONTROL then
  begin
    ModalResult := mrOk;
    Close;
  end
  else if (Key = VK_TAB) or (Key = VK_SPACE) then
  begin
    AlphaBlendValue := 255;
    FTabKeyUpCalled := True;

    // if shift is pressed move the opposite direction
    if GetKeyState(VK_SHIFT) < 0 then
    begin
      Index := ListViewOpenFiles.ItemIndex - 1;
      if Index< 0 then
        Index := ListViewOpenFiles.Items.Count - 1;
    end
    else
    begin
      Index := ListViewOpenFiles.ItemIndex + 1;
      if Index >= ListViewOpenFiles.Items.Count then
        Index := 0;
    end;
    ListViewOpenFiles.ItemIndex := Index;
  end

  else if Key = VK_ESCAPE then
  begin
    ListViewOpenFiles.ItemIndex := 0; // no action
    ModalResult := mrCancel;
    Close;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : GetDisplayNameFor
 Info   : Returns proper display name for BDS special pages such as the welcome page.
 Input  : aFileName = Module File Name
 Output :
 Result : string
-------------------------------------------------------------------------------}
function TFormOpenDocs.GetDisplayNameFor(const aModuleFileName: string): string;
begin
  if aModuleFileName = c_WelcomePage then
    Result := c_WelcomePageDisplayName
  else
    Result := aModuleFileName;
end;

{-------------------------------------------------------------------------------
 Name   : ListViewOpenFilesChange
 Info   :
 Input  : Sender =
          Item =
          Change =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.ListViewOpenFilesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
begin
  RefreshLabels;
end;

{-------------------------------------------------------------------------------
 Name   : ListViewOpenFilesDblClick
 Info   :
 Input  : Sender =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.ListViewOpenFilesDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

{-------------------------------------------------------------------------------
 Name   : RefreshLabels
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.RefreshLabels;
var
  FileName: string;
begin
  if ListViewOpenFiles.ItemIndex >= 0 then
  begin
    FileName := GetDisplayNameFor(Plugin.ViewManager.GetViewAt(ListViewOpenFiles.ItemIndex));
    Label_FullPath.Caption := FileName;
    Label_SelectedFile.Caption := ExtractFileName(FileName);
  end
  else
  begin
    Label_FullPath.Caption := '--';
    Label_SelectedFile.Caption := '--';
  end;

  // make sure selected item is always visible
  if Assigned(ListViewOpenFiles.Selected) then
    ListViewOpenFiles.Selected.MakeVisible(False);
end;

end.
