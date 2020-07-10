{===============================================================================
 Project : DelphiCtrlTab_D27

 Name    : IdePlugin

 Info    : This Unit contains the class TIdePlugin.
           This class manages all relevant services for this plugin.
           It is a singleton.
           It is also responsible to hooking/unhooking the keyboard.

 Copyright (c) 2020 Santiago Burbano
===============================================================================}
unit IdePlugin;

interface

uses
  IdePluginInterfaces;

function Plugin: IIdePlugin;

implementation

uses
  System.Generics.Defaults, Classes, SysUtils, ToolsAPI, FormEditorNotifier,
  ViewManager, SourceEditorNotifier, IdeNotifier, DesignIntf,
  DesignNotification, Vcl.Forms, windows, messages, FrmOpenDocs, System.IOUtils, FileLogger, SettingsManager,
  CtrlTab.EditorServicesNotifier;

type
  TIdePlugin = class(TSingletonImplementation, IIdePlugin)
    procedure ActivateKeyboardHook;
    procedure BootUp;
    procedure ClearSourceEditorNotifiers;
    procedure DesignerClosed(aFormFile: string);
    procedure DisableKeyBoardHook;
    procedure EditorNotifierAboutToBeDestroyed(aNotifier: IEditorNotifier);
    procedure FileClosing(aUnitFile: string);
    function GetLogger: ILogger;
    function GetSettings: ISettings;
    function GetViewManager: IViewManager;
    procedure InstallSourceEditorNotifiers(Module: IOTAModule);
    procedure PrintMessage(const aMsg: string);
    procedure RemoveIDENotifier;
    procedure ShutDown;
  private
    FDesignNotification: IDesignNotification;
    FEditorNotifierId: Integer;
    FEditorNotifiers: IInterfaceList;
    FIDENotifierIndex: Integer;
    FLogger: ILogger;
    FViewManager: IViewManager;
    FSettingsManager: ISettingsManager;
    class function KeyboardHookProc(Code: Integer; WordParam: Word; LongParam: LongInt): LongInt; static; stdcall;
  public
  class var
    KBHook: HHook;
    constructor Create;
    property Logger: ILogger read GetLogger;
  end;

// the singleton instance
var
  PluginSingleton : TIdePlugin;

{-------------------------------------------------------------------------------
 Name   : Create
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
constructor TIdePlugin.Create;
begin
  inherited;
  FEditorNotifiers := TInterfaceList.Create;
  FViewManager := TViewManager.Create;
  FDesignNotification := TDesignNotification.Create;
  FSettingsManager := TSettingsManager.Create;
  FIDENotifierIndex := -1;
  KBHook := 0;
end;

{-------------------------------------------------------------------------------
 Name   : ActivateKeyboardHook
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.ActivateKeyboardHook;
begin
  // test if already active
  if KBHook <> 0 then Exit;

  // set hook
  KBHook :=SetWindowsHookEx(WH_KEYBOARD,
            {callback >} @KeyboardHookProc,
                           HInstance,
                           GetCurrentThreadId()) ;
end;

{-------------------------------------------------------------------------------
 Name   : BootUp
 Info   : Initializes the plugin.
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.BootUp;
var
  Services: IOTAServices;
  ModuleServices: IOTAModuleServices;
  i: Integer;
  OpenModule: IOTAModule;
begin
  {$IFDEF DEBUG}
  // clear logs
  // Logger.ClearLog;
  // Logger.OpenLogLocation;
  {$ENDIF}

  // install IDE notifier so that we can install editor notifiers for any newly opened module
  Services := BorlandIDEServices as IOTAServices;
  FIDENotifierIndex := Services.AddNotifier(TIDENotifier.Create);

  // install editor notifiers for all currently open modules
  ModuleServices := BorlandIDEServices as IOTAModuleServices;
  for i := 0 to ModuleServices.ModuleCount - 1 do
  begin
    OpenModule := ModuleServices.Modules[i];
    InstallSourceEditorNotifiers(OpenModule);
  end;

  // install editor services notifier. This is the only way to know when special windows have
  // been activated
  FEditorNotifierId := (BorlandIDEServices As IOTAEditorServices).AddNotifier(TCtrlTabEditorServicesNotifier.Create);

  RegisterDesignNotification(FDesignNotification);

  ActivateKeyboardHook;

  FSettingsManager.BootUp;
end;

{-------------------------------------------------------------------------------
 Name   : ClearSourceEditorNotifiers
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.ClearSourceEditorNotifiers;
var
  I: Integer;
  Notifier: IEditorNotifier;
begin
  if Assigned(FEditorNotifiers) then
  begin
    for I := FEditorNotifiers.Count - 1 downto 0 do
    begin
      // Destroyed calls RemoveNotifier which in turn releases the instance
      if Supports(FEditorNotifiers[i], IEditorNotifier, Notifier) then
        Notifier.CleanUp;
    end;
    FEditorNotifiers.Clear;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : DesignerClosed
 Info   :
 Input  : aFormFile =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.DesignerClosed(aFormFile: string);
var
  EditorNotifier: IEditorNotifier;
  FormNotifier: IOTAFormNotifier;
  i: Integer;
begin
  FViewManager.ViewClosed(aFormFile);

  for i := 0 to FEditorNotifiers.Count -1 do
  begin
    if Supports(FEditorNotifiers[i], IOTAFormNotifier, FormNotifier) then
    begin
      if Supports(FEditorNotifiers[i], IEditorNotifier, EditorNotifier) and (EditorNotifier.FileName = aFormFile) then
      begin

        FEditorNotifiers.Delete(i);
        EditorNotifier.CleanUp;
        break;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : DisableKeyBoardHook
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.DisableKeyBoardHook;
begin
  {unhook the keyboard interception}
  if KBHook <> 0 then
  begin
    UnHookWindowsHookEx(KBHook);
    KBHook := 0;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : EditorNotifierAboutToBeDestroyed
 Info   :
 Input  : aNotifier =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.EditorNotifierAboutToBeDestroyed(aNotifier: IEditorNotifier);
var
  Index: Integer;
begin
  Index := FEditorNotifiers.IndexOf(aNotifier as IInterface);
  if Index >= 0 then
    FEditorNotifiers.Delete(Index);
end;

{-------------------------------------------------------------------------------
 Name   : FileClosing
 Info   :
 Input  : aUnitFile =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.FileClosing(aUnitFile: string);
var
  EditorNotifier: IEditorNotifier;
  FormNotifier: IOTAEditorNotifier;
  i: Integer;
begin
  FViewManager.ViewClosed(aUnitFile);

  for i := 0 to FEditorNotifiers.Count -1 do
  begin
    if Supports(FEditorNotifiers[i], IOTAEditorNotifier, FormNotifier) then
    begin
      if Supports(FEditorNotifiers[i], IEditorNotifier, EditorNotifier) and (EditorNotifier.FileName = aUnitFile) then
      begin
        FEditorNotifiers.Delete(i);
        EditorNotifier.CleanUp;
        break;
      end;
    end;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : GetLogger
 Info   :
 Input  :
 Output :
 Result : ILogger
-------------------------------------------------------------------------------}
function TIdePlugin.GetLogger: ILogger;
begin
  if not Assigned(FLogger) then
    FLogger := TFileLogger.Create;
  Result := FLogger;
end;

{-------------------------------------------------------------------------------
 Name   : GetSettings
 Info   :
 Input  :
 Output :
 Result : ISettings
-------------------------------------------------------------------------------}
function TIdePlugin.GetSettings: ISettings;
begin
  Result := FSettingsManager.Settings;
end;

{-------------------------------------------------------------------------------
 Name   : GetViewManager
 Info   :
 Input  :
 Output :
 Result : IViewManager
-------------------------------------------------------------------------------}
function TIdePlugin.GetViewManager: IViewManager;
begin
  Result := FViewManager;
end;

{-------------------------------------------------------------------------------
 Name   : InstallSourceEditorNotifiers
 Info   :
 Input  : Module =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.InstallSourceEditorNotifiers(Module: IOTAModule);
var
  FormEditor: IOTAFormEditor;
  i: Integer;
  ModuleEditor: IOTAEditor;
  OtaServices: IOTAServices;
  SourceEditor: IOTASourceEditor;
begin
  OtaServices := BorlandIDEServices as IOTAServices;

  // if module has no module files, it is a special module such as the welcome page.
  if Module.ModuleFileCount = 0 then
  begin
    // exclude .groupproj
    // register open file
    if not OtaServices.IsProjectGroup(Module.FileName) then
      Plugin.ViewManager.ViewActivated(Module.FileName);
    Exit;
  end;

  // attach a notifier
  for i := 0 to Module.ModuleFileCount - 1 do
  begin
    ModuleEditor := Module.ModuleFileEditors[i];

    if Supports(ModuleEditor, IOTASourceEditor, SourceEditor) then
    begin
      // add notifier
      // view manager will be notified only once a view is inserted.
      // otherwise we would end up with several entries for open modules
      // that do not have a file tab associated with them (dpk, dpr files).
      FEditorNotifiers.Add(TSourceEditorNotifier.Create(SourceEditor) as IInterface);
    end
    else if Supports(ModuleEditor, IOTAFormEditor, FormEditor) then
    begin
      // add notifier
      FEditorNotifiers.Add(TFormEditorNotifier.Create(FormEditor) as IInterface);
      // register open file
      Plugin.ViewManager.ViewActivated(ModuleEditor.FileName);
    end;
  end;
end;

{-------------------------------------------------------------------------------
 Name   : KeyboardHookProc
 Info   : Keyboard hook callback. This method is called whenever a key is pressed in the IDE.
 Input  : Code =
          WordParam =
          LongParam =

 Output :
 Result : LongInt
-------------------------------------------------------------------------------}
class function TIdePlugin.KeyboardHookProc(Code: Integer; WordParam: Word; LongParam: LongInt): LongInt;
var
  Form: TFormOpenDocs;
begin
  // Code = HC_ACTION -> The wParam and lParam parameters contain information about a keystroke message.
  if (Code = HC_ACTION) then
  begin
    case WordParam of
      VK_TAB:
        begin
          if GetKeyState(VK_CONTROL) < 0 then
          begin
            // make sure only one instance can be displayed
            if not TFormOpenDocs.IsShowing and (Plugin.ViewManager.ViewCount > 1) then
            begin
              // create form
              Application.CreateForm(TFormOpenDocs, Form);
              Form.Show;

              // If the hook procedure processed the message, it may return a nonzero value to prevent the system from
              // passing the message to the rest of the hook chain or the target window procedure.
              Result := 1;

              // disable keyboard hook
              Plugin.DisableKeyBoardHook;
              Exit;
            end;
          end;
        end;
    end;
  end;

  // be a good citizen, if procedure did not process the message, it is highly recommended
  // that you call CallNextHookEx and return the value it returns
  Result := CallNextHookEx(KBHook, Code, WordParam, LongParam);;
end;

{-------------------------------------------------------------------------------
 Name   : PrintMessage
 Info   : Prints a message to the Messages View.
 Input  : aMsg =

 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.PrintMessage(const aMsg: string);
begin
  (BorlandIDEServices as IOTAMessageServices).AddTitleMessage(aMsg);
end;

{-------------------------------------------------------------------------------
 Name   : RemoveIDENotifier
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.RemoveIDENotifier;
var
  Services: IOTAServices;
begin
  Services := BorlandIDEServices as IOTAServices;
  if Assigned(Services) then
    Services.RemoveNotifier(FIDENotifierIndex);
end;

{-------------------------------------------------------------------------------
 Name   : ShutDown
 Info   :
 Input  :
 Output :
 Result : None
-------------------------------------------------------------------------------}
procedure TIdePlugin.ShutDown;
begin
  DisableKeyBoardHook;

  FSettingsManager.ShutDown;
  FViewManager.ShutDown;
  ClearSourceEditorNotifiers;
  RemoveIDENotifier;

  // remove editor services notifier
  if FEditorNotifierId > -1 then
    (BorlandIDEServices As IOTAEditorServices).RemoveNotifier(FEditorNotifierId);

  UnRegisterDesignNotification(FDesignNotification);

  FreeAndNil(PluginSingleton);
end;

{-------------------------------------------------------------------------------
 Name   : Plugin
 Info   :
 Input  :
 Output :
 Result : IIdePlugin
-------------------------------------------------------------------------------}
function Plugin: IIdePlugin;
begin
  Result := PluginSingleton;
end;

initialization
  PluginSingleton := TIdePlugin.Create;
end.

