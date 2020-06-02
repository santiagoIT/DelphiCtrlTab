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
  OnClick = FormClick
  OnClose = FormClose
  OnCreate = FormCreate
  OnDeactivate = FormDeactivate
  OnKeyUp = FormKeyUp
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBoxOpenUnits: TGroupBox
    Left = 0
    Top = 0
    Width = 688
    Height = 371
    Align = alClient
    Caption = 'Open Files'
    TabOrder = 0
    object Label_SelectedFile: TLabel
      Left = 2
      Top = 15
      Width = 684
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
      Top = 356
      Width = 684
      Height = 13
      Align = alBottom
      Caption = 'Label_FullPath'
      ExplicitWidth = 69
    end
    object ListViewOpenFiles: TListView
      AlignWithMargins = True
      Left = 5
      Top = 37
      Width = 678
      Height = 316
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
