unit IdePlugin;

interface

uses
  IdePluginInterfaces;

function Plugin: IIdePlugin;

implementation

uses
  System.Generics.Defaults, Classes, SysUtils, ToolsAPI, FormEditorNotifier,
  UnitManager, SourceEditorNotifier, IdeNotifier, DesignIntf,
  DesignNotification, Vcl.Forms, windows, messages, FrmOpenDocs, System.IOUtils;

type
  TIdePlugin = class(TSingletonImplementation, IIdePlugin)
    procedure ActivateKeyboardHook;
    procedure BootUp;
    procedure ClearSourceEditorNotifiers;
    procedure DesignerClosed(aFormFile: string);
    procedure DisableKeyBoardHook;
    procedure FileClosing(aUnitFile: string);
    function GetUnitManager: IUnitManager;
    procedure InstallSourceEditorNotifiers(Module: IOTAModule);
    procedure PrintMessage(const aMsg: string);
    procedure RemoveIDENotifier;
    procedure ShutDown;
    procedure SourceEditorNotifierDestroyed(aNotifier: IEditorNotifier);
  private
    FDesignNotification: IDesignNotification;
    FEditorNotifiers: IInterfaceList;
    FIDENotifierIndex: Integer;
    FUnitManager: IUnitManager;
    class function KeyboardHookProc(Code: Integer; WordParam: Word; LongParam: LongInt): LongInt; static; stdcall;
  public
  class var
    KBHook: HHook;
    constructor Create;
    destructor Destroy; override;
  end;

// the singleton instance
var
  PluginSingleton : TIdePlugin;


constructor TIdePlugin.Create;
begin
  inherited;
  FEditorNotifiers := TInterfaceList.Create;
  FUnitManager := TUnitManager.Create;
  FDesignNotification := TDesignNotification.Create;
  FIDENotifierIndex := -1;
  KBHook := 0;
end;

destructor TIdePlugin.Destroy;
begin
  inherited;
end;

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

procedure TIdePlugin.BootUp;
var
  Services: IOTAServices;
  ModuleServices: IOTAModuleServices;
  i: Integer;
  OpenModule: IOTAModule;
begin
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

  RegisterDesignNotification(FDesignNotification);

  ActivateKeyboardHook;
end;

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
      begin
        Notifier.CleanUp;
      end;
    end;
    FEditorNotifiers.Clear;
  end;
end;

procedure TIdePlugin.DesignerClosed(aFormFile: string);
var
  EditorNotifier: IEditorNotifier;
  FormNotifier: IOTAFormNotifier;
  i: Integer;
begin
  FUnitManager.ViewClosed(aFormFile);

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

procedure TIdePlugin.DisableKeyBoardHook;
begin
  {unhook the keyboard interception}
  if KBHook <> 0 then
  begin
    UnHookWindowsHookEx(KBHook);
    KBHook := 0;
  end;
end;

procedure TIdePlugin.FileClosing(aUnitFile: string);
var
  EditorNotifier: IEditorNotifier;
  FormNotifier: IOTAEditorNotifier;
  i: Integer;
begin
  FUnitManager.ViewClosed(aUnitFile);

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

function TIdePlugin.GetUnitManager: IUnitManager;
begin
  Result := FUnitManager;
end;

procedure TIdePlugin.InstallSourceEditorNotifiers(Module: IOTAModule);
var
  FileExt: string;
  FormEditor: IOTAFormEditor;
  i: Integer;
  ModuleEditor: IOTAEditor;
  OtaServices: IOTAServices;
  SourceEditor: IOTASourceEditor;
begin
  OtaServices := BorlandIDEServices as IOTAServices;
  // attach a notifier
  for i := 0 to Module.ModuleFileCount - 1 do
  begin
    ModuleEditor := Module.ModuleFileEditors[i];

    if Supports(ModuleEditor, IOTASourceEditor, SourceEditor) then
    begin
      // make sure that at least one edit view exists. This prevents all loaded .dpk and .dpr files
      // from appearing in the loaded modules list.
      if (SourceEditor.EditViewCount < 1) then
      begin
        // for now ignore dproj and groupproj file.
        // the problem is that these modules are listed as opened modules when the IDE startsup.
        // Have not found a way to distinguish between opened modules and opened modules that have a tab view.
        FileExt := TPath.GetExtension(Module.FileName).ToLower();
        if Supports(Module, IOTAProject) or OtaServices.IsProjectGroup(Module.FileName) then Exit;
      end;

      // add notifier
      FEditorNotifiers.Add(TSourceEditorNotifier.Create(SourceEditor) as IInterface);
    end
    else if Supports(ModuleEditor, IOTAFormEditor, FormEditor) then
    begin
      // add notifier
      FEditorNotifiers.Add(TFormEditorNotifier.Create(FormEditor) as IInterface);
    end;

    // register open file
    Plugin.UnitManager.ViewActivated(ModuleEditor.FileName);
  end;
end;

class function TIdePlugin.KeyboardHookProc(Code: Integer; WordParam: Word; LongParam: LongInt): LongInt;
var
  Form: TFormOpenDocs;
begin
  // If code is less than zero, the hook procedure must pass the message to the CallNextHookEx function without
  // further processing and should return the value returned by CallNextHookEx.
  if Code < 0 then
  begin
    Result := CallNextHookEx(TIdePlugin.KBHook, Code, WordParam, LongParam);
    Exit;
  end;

  case WordParam of
    VK_TAB:
      begin
        if GetKeyState(VK_CONTROL) < 0 then
        begin
          // make sure only one instance can be displayed
          if not TFormOpenDocs.IsShowing and (Plugin.UnitManager.ViewCount > 1) then
          begin
            // create form
            Application.CreateForm(TFormOpenDocs, Form);
            Form.Show;
            Result := 1;

            // disable keyboard hook
            Plugin.DisableKeyBoardHook;
            Exit;
          end;
        end;
      end;
  end;

  Result := 0;//CallNextHookEx(KBHook, Code, WordParam, LongParam);;
end;


procedure TIdePlugin.PrintMessage(const aMsg: string);
begin
  (BorlandIDEServices as IOTAMessageServices).AddTitleMessage(aMsg);
end;

procedure TIdePlugin.RemoveIDENotifier;
var
  Services: IOTAServices;
begin
  Services := BorlandIDEServices as IOTAServices;
  if Assigned(Services) then
    Services.RemoveNotifier(FIDENotifierIndex);
end;

procedure TIdePlugin.ShutDown;
begin
  DisableKeyBoardHook;

  FUnitManager.ShutDown;
  ClearSourceEditorNotifiers;
  RemoveIDENotifier;

  UnRegisterDesignNotification(FDesignNotification);

  FreeAndNil(PluginSingleton);
end;

procedure TIdePlugin.SourceEditorNotifierDestroyed(aNotifier: IEditorNotifier);
var
  Index: Integer;
begin
  Index := FEditorNotifiers.IndexOf(aNotifier as IInterface);
  if Index >= 0 then
    FEditorNotifiers.Delete(Index);
end;

function Plugin: IIdePlugin;
begin
  Result := PluginSingleton;
end;

initialization
  PluginSingleton := TIdePlugin.Create;
end.

