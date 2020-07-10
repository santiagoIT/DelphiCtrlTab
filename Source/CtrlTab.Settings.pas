{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : CtrlTab.Settings

 Info    : This Unit contains the class TViewManager.

 Copyright (c) 2020 - Santiago Burbano
===============================================================================}
unit CtrlTab.Settings;

interface

uses
  CtrlTab.Interfaces, System.Classes;

type
  TPluginSettings = class(TInterfacedObject, ISettings)
  private
    FDialogHeight: Integer;
    FDialogWidth: Integer;
    function GetDialogHeight: Integer;
    function GetDialogWidth: Integer;
    procedure SetDialogHeight(const Value: Integer);
    procedure SetDialogWidth(const Value: Integer);
  public
    constructor Create;
  end;

implementation

uses
  System.SysUtils;

constructor TPluginSettings.Create;
begin
  inherited;
  FDialogHeight := 0;
  FDialogWidth := 0;
end;

function TPluginSettings.GetDialogHeight: Integer;
begin
  Result := FDialogHeight;
end;

function TPluginSettings.GetDialogWidth: Integer;
begin
  Result := FDialogWidth;
end;

procedure TPluginSettings.SetDialogHeight(const Value: Integer);
begin
  FDialogHeight := Value;
end;

procedure TPluginSettings.SetDialogWidth(const Value: Integer);
begin
  FDialogWidth := Value;
end;


end.
