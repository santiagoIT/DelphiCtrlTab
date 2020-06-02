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
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure ListViewOpenFilesChange(Sender: TObject; Item: TListItem; Change:
        TItemChange);
    procedure ListViewOpenFilesDblClick(Sender: TObject);
  private
  class var
    FIsShowing: Boolean;
  var
    FClosing: Boolean;
    procedure RefreshLabels;
    { Private declarations }
  public
    class property IsShowing: Boolean read FIsShowing;
    { Public declarations }
  end;

var
  Form1: TFormOpenDocs;

implementation

{$R *.dfm}

uses
  IdePlugin, ToolsApi;

procedure TFormOpenDocs.FormClick(Sender: TObject);
begin
  Plugin.PrintMessage('TFormOpenDocs.FormClick');
end;

procedure TFormOpenDocs.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FClosing := True;
  if ModalResult = mrOk then
  begin
    if ListViewOpenFiles.ItemIndex > 0 then
    begin
      Plugin.UnitManager.ShowSourceView(ListViewOpenFiles.ItemIndex);
    end;
  end;
  Action := caFree;
  FIsShowing := False;

  // enable keyboard hook
  Plugin.ActivateKeyboardHook;
end;

procedure TFormOpenDocs.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  FIsShowing := True;
  for i := 0 to Plugin.UnitManager.ViewCount -1 do
  begin
    ListViewOpenFiles.AddItem(ExtractFileName(Plugin.UnitManager.GetViewAt(i)), nil);
  end;
  if ListViewOpenFiles.Items.Count > 0 then
  begin
    ListViewOpenFiles.ItemIndex := 0;
  //  RefreshLabels;
  end;
end;

procedure TFormOpenDocs.FormDeactivate(Sender: TObject);
begin
  if not FClosing then
    Close;
end;

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

procedure TFormOpenDocs.ListViewOpenFilesChange(Sender: TObject; Item:
    TListItem; Change: TItemChange);
begin
  RefreshLabels;
end;

procedure TFormOpenDocs.ListViewOpenFilesDblClick(Sender: TObject);
begin
  ModalResult := mrOk;
  Close;
end;

procedure TFormOpenDocs.RefreshLabels;
var
  FileName: string;
begin
  if ListViewOpenFiles.ItemIndex >= 0 then
  begin
    FileName := Plugin.UnitManager.GetViewAt(ListViewOpenFiles.ItemIndex);
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
