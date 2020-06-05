{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : FrmOpenDocs

 Info    : This Unit contains the class TFormOpenDocs.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit FrmOpenDocs;

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
    procedure ListViewOpenFilesChange(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListViewOpenFilesDblClick(Sender: TObject);
  private
  class var
    FIsShowing: Boolean;
  var
    FClosing: Boolean;
    procedure RefreshLabels;
  public
    class property IsShowing: Boolean read FIsShowing;
  end;

var
  Form1: TFormOpenDocs;

implementation

{$R *.dfm}

uses
  IdePlugin, ToolsApi, ViewManager;

{-------------------------------------------------------------------------------
 Name   : FormClose
 Info   :
 Input  : Sender =
          Action =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TFormOpenDocs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClosing := True;
  if ModalResult = mrOk then
  begin
    if ListViewOpenFiles.ItemIndex > 0 then
    begin
      Plugin.ViewManager.ShowSourceView(ListViewOpenFiles.ItemIndex);
    end;
  end;
  Action := caFree;
  FIsShowing := False;

  // enable keyboard hook
  Plugin.ActivateKeyboardHook;
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
  i: Integer;
begin
  FIsShowing := True;
  for i := 0 to Plugin.ViewManager.ViewCount -1 do
  begin
    ListViewOpenFiles.AddItem(ExtractFileName(Plugin.ViewManager.GetViewAt(i)), nil);
  end;
  if ListViewOpenFiles.Items.Count > 0 then
  begin
    ListViewOpenFiles.ItemIndex := 0;
  //  RefreshLabels;
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
  if not FClosing then
    Close;
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
   // RefreshLabels;
  end

  else if Key = VK_ESCAPE then
  begin
    ListViewOpenFiles.ItemIndex := 0; // no action
    ModalResult := mrCancel;
    Close;
  end;
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
    FileName := Plugin.ViewManager.GetViewAt(ListViewOpenFiles.ItemIndex);
    Label_FullPath.Caption := FileName;
    Label_SelectedFile.Caption := ExtractFileName(FileName);
  end
  else
  begin
    Label_FullPath.Caption := '--';
    Label_SelectedFile.Caption := '--';
  end;
end;

end.
