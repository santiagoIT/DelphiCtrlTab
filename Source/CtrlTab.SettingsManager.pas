{===============================================================================
 Project : DelphiCtrlTab

 Name    : CtrlTab.SettingsManager

 Info    : This Unit contains the class TSettingsManager. Handles storage of
           plugin settings.

 Copyright (c) 2020 - Santiago Burbano
===============================================================================}
unit CtrlTab.SettingsManager;

interface

uses
  CtrlTab.Interfaces, System.Classes, ToolsApi;

type
  TSettingsManager = class(TInterfacedObject, ISettingsManager)
  private
    FSettings: ISettings;
    procedure BootUp;
    function GetSettings: ISettings;
    procedure LoadSettings;
    procedure PersistSettings;
    procedure ShutDown;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, CtrlTab.Settings, System.Win.Registry, WinApi.Windows, CtrlTab.IdePlugin;

const
  c_CtrlTabRegistryKey = 'Software\CtrlTab';
  c_Value_Height = 'height';
  c_Value_Width = 'width';

constructor TSettingsManager.Create;
begin
  inherited;
  FSettings := TPluginSettings.Create;
end;

destructor TSettingsManager.Destroy;
begin
  inherited;
end;

{-------------------------------------------------------------------------------
 Name   : BootUp
 Info   : Called when Plugin is loading
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TSettingsManager.BootUp;
begin
  LoadSettings;
end;

function TSettingsManager.GetSettings: ISettings;
begin
  Result := FSettings;
end;

{-------------------------------------------------------------------------------
 Name   : ShutDown
 Info   : Called when Ide is shutting down
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TSettingsManager.ShutDown;
begin
  PersistSettings;
end;

{-------------------------------------------------------------------------------
 Name   : LoadSettings
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TSettingsManager.LoadSettings;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_READ);
  try
    try
      Registry.RootKey := HKEY_CURRENT_USER;

      // do not want to create it if it doesn't exist
      if not Registry.OpenKey(c_CtrlTabRegistryKey, False) then Exit;

      if Registry.ValueExists(c_Value_Height) then
        FSettings.DialogHeight := Registry.ReadInteger(c_Value_Height);

      if Registry.ValueExists(c_Value_Height) then
        FSettings.DialogWidth := Registry.ReadInteger(c_Value_Width);
    finally
      Registry.Free;
    end;
  except
    on E:Exception do
      Plugin.PrintMessage(Format('Failed to restore settings: %s', [E.Message]));
  end;
end;


procedure TSettingsManager.PersistSettings;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create(KEY_WRITE);
  try
    try
      Registry.RootKey := HKEY_CURRENT_USER;

      // create it if it doesn't exist
      if not Registry.OpenKey(c_CtrlTabRegistryKey, True) then
      begin
        Plugin.PrintMessage('Failed to persist settings.');
        Exit;
      end;

      Registry.WriteInteger(c_Value_Height, FSettings.DialogHeight);
      Registry.WriteInteger(c_Value_Width, FSettings.DialogWidth);
    finally
      Registry.Free;
    end;
  except
    on E:Exception do
      Plugin.PrintMessage(Format('Failed to persist settings: %s', [E.Message]));
  end;
end;


end.
