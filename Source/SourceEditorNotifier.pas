unit SourceEditorNotifier;

interface

uses
  Classes, SysUtils, ToolsAPI, IdePluginInterfaces;

type
  TSourceEditorNotifier = class(TNotifierObject, IOTANotifier, IOTAEditorNotifier, IEditorNotifier)
  private
    [Weak]
    FEditor: IOTASourceEditor;
    FIndex: Integer;
    procedure AfterSave;
    { IOTANotifier }
    procedure Destroyed;
    function GetFileName: string;
    { IOTAEditorNotifier }
    procedure ViewActivated(const View: IOTAEditView);
    procedure ViewNotification(const View: IOTAEditView; Operation: TOperation);
  public
    constructor Create(AEditor: IOTASourceEditor); overload;
    destructor Destroy; override;
    procedure CleanUp;
  end;

implementation

uses
  IdePlugin;

constructor TSourceEditorNotifier.Create(AEditor: IOTASourceEditor);

begin
  inherited Create;
  FEditor := AEditor;
  FIndex := FEditor.AddNotifier(Self);
 // Plugin.PrintMessage(Format('Added notifier for: %s', [FEditor.FileName]));
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TSourceEditorNotifier.Destroy;
begin
  Plugin.SourceEditorNotifierDestroyed(Self);
  Cleanup;
  FEditor := nil;
  inherited Destroy;
end;

procedure TSourceEditorNotifier.AfterSave;
begin
end;

// calls private destroyed method
procedure TSourceEditorNotifier.CleanUp;
begin
//  Plugin.PrintMessage(Format('TSourceEditorNotifier.CleanUp: %d', [FIndex]));
  if FIndex >= 0 then
  begin
    if Assigned(FEditor) then
      FEditor.RemoveNotifier(FIndex);
   // Plugin.PrintMessage(Format('Removed notifier for: %s', [FEditor.FileName]));
    FIndex := -1;
  end;
end;

procedure TSourceEditorNotifier.Destroyed;
begin
 // Plugin.PrintMessage(Format('TSourceEditorNotifier.Destroyed: %s', [FEditor.FileName]));
  CleanUp;
end;

function TSourceEditorNotifier.GetFileName: string;
begin
  if not Assigned(FEditor) then Exit(string.Empty);
  Result := FEditor.FileName;
end;

procedure TSourceEditorNotifier.ViewActivated(const View: IOTAEditView);
begin
 // Plugin.PrintMessage(Format('View activated: %s', [FEditor.FileName]));
  Plugin.UnitManager.ViewActivated(FEditor.FileName);
end;

procedure TSourceEditorNotifier.ViewNotification(const View: IOTAEditView; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
    Plugin.FileClosing(View.Buffer.FileName);
  end;
end;

end.

