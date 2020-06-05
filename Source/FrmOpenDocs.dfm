object FormOpenDocs: TFormOpenDocs
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Go to...'
  ClientHeight = 371
  ClientWidth = 688
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poMainFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxOpenUnits: TGroupBox
    AlignWithMargins = True
    Left = 5
    Top = 3
    Width = 678
    Height = 363
    Margins.Left = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alClient
    Caption = 'Open Files'
    TabOrder = 0
    object Label_SelectedFile: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 18
      Width = 668
      Height = 19
      Align = alTop
      Caption = 'Label_SelectedFile'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      ExplicitWidth = 153
    end
    object Label_FullPath: TLabel
      Left = 2
      Top = 348
      Width = 674
      Height = 13
      Align = alBottom
      Caption = 'Label_FullPath'
      ExplicitWidth = 69
    end
    object ListViewOpenFiles: TListView
      AlignWithMargins = True
      Left = 5
      Top = 43
      Width = 668
      Height = 302
      Align = alClient
      Columns = <
        item
          AutoSize = True
        end>
      ColumnClick = False
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      TabOrder = 0
      ViewStyle = vsReport
      OnChange = ListViewOpenFilesChange
      OnDblClick = ListViewOpenFilesDblClick
    end
  end
end
