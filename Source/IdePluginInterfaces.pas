unit IdePluginInterfaces;

interface

uses
  ToolsApi;

type
  IEditorNotifier = interface;

  IUnitManager = interface
  ['{53A0592B-86F9-42AF-9ABF-00A1B47E3081}']
    function GetViewAt(aIndex: Integer): string;
    function GetViewCount: Integer;
    procedure ShowSourceView(aIndex: Integer);
    procedure ShutDown;
    procedure ViewActivated(const aFileName: string);
    procedure ViewClosed(const aViewName: string);
    property ViewCount: Integer read GetViewCount;
  end;

  IIdePlugin = interface
  ['{1DFF971B-BE77-48D2-90E8-5F507ADA128C}']
    procedure ActivateKeyboardHook;
    procedure BootUp;
    procedure DesignerClosed(aFormFile: string);
    procedure DisableKeyBoardHook;
    procedure FileClosing(aFormFile: string);
    function GetUnitManager: IUnitManager;
    procedure InstallSourceEditorNotifiers(Module: IOTAModule; aUseEditViewCount: Boolean);
    procedure PrintMessage(const aMsg: string);
    procedure ShutDown;
    procedure SourceEditorNotifierDestroyed(aNotifier: IEditorNotifier);
    property UnitManager: IUnitManager read GetUnitManager;
  end;

  IEditorNotifier = interface
  ['{3F5EBCA8-162C-467F-A21D-4EB5800F450B}']
    procedure CleanUp;
    function GetFileName: string;
    property FileName: string read GetFileName;
  end;

implementation

end.

