unit FormEditorNotifier;

interface

uses
  Classes, SysUtils, ToolsAPI, IdePluginInterfaces;

type
  TFormEditorNotifier = class(TNotifierObject, IOTANotifier, IOTAFormNotifier, IEditorNotifier)
  private
    [Weak]
    FFormEditor: IOTAFormEditor;
    FIndex: Integer;
    procedure AfterSave;
    { Called when a component on this form was renamed }
    procedure ComponentRenamed(ComponentHandle: TOTAHandle; const OldName, NewName: string);
    { IOTANotifier }
    procedure Destroyed;
    { IOTAEditorNotifier }
    procedure FormActivated;
    { This is called immediately prior to the form being streamed out.  This
      may be called without first getting a BeforeSave as in the case of
      the project being compiled. }
    procedure FormSaving;
    function GetFileName: string;
  public
    constructor Create(aFormEdiitor: IOTAFormEditor);
    destructor Destroy; override;
    procedure CleanUp;
  end;

implementation

uses
  IdePlugin;

constructor TFormEditorNotifier.Create(aFormEdiitor: IOTAFormEditor);
begin
  inherited Create;
  FFormEditor := aFormEdiitor;
  FIndex := FFormEditor.AddNotifier(Self);
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TFormEditorNotifier.Destroy;

begin
  Plugin.SourceEditorNotifierDestroyed(Self);
  CleanUp;
  FFormEditor := nil;
  inherited Destroy;
end;

procedure TFormEditorNotifier.AfterSave;
begin
end;

// calls private destroyed method
procedure TFormEditorNotifier.CleanUp;
begin
  if FIndex >= 0 then
  begin
    if Assigned(FFormEditor) then
    begin
      Plugin.PrintMessage(Format('TFormEditorNotifier.CleanUp: %d. %s', [FIndex, FFormEditor.FileName]));
      FFormEditor.RemoveNotifier(FIndex);
    end;
    FIndex := -1;
  end;
end;

procedure TFormEditorNotifier.ComponentRenamed(ComponentHandle: TOTAHandle; const OldName, NewName: string);
begin

end;

procedure TFormEditorNotifier.Destroyed;
begin
 // Plugin.PrintMessage(Format('TFormEditorNotifier.Destroyed: %d. %s', [FIndex, FFormEditor.FileName]));

  CleanUp;
end;

procedure TFormEditorNotifier.FormActivated;
begin
 // Plugin.PrintMessage(Format('Form activated: %s', [FFormEditor.FileName]));
  Plugin.UnitManager.ViewActivated(FFormEditor.FileName);
end;

procedure TFormEditorNotifier.FormSaving;
begin

end;

function TFormEditorNotifier.GetFileName: string;
begin
  if not Assigned(FFormEditor) then Exit(string.Empty);
  Result := FFormEditor.FileName;
end;

end.

