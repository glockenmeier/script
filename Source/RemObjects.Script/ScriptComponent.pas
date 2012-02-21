﻿{
  Copyright (c) 2009-2011 RemObjects Software. See LICENSE.txt for more details.
}

namespace RemObjects.Script;

interface

uses
  System.Collections,
  System.Collections.Generic,
  System.Collections.ObjectModel,
  System.ComponentModel,
  System.Linq,
  System.Reflection,
  System.Text,
  RemObjects.Script.EcmaScript;

type
  ScriptDebugEventArgs = public class(EventArgs)
  public
    constructor(aName: string; aSpan: PositionPair);
    constructor(aName: string; aSpan: PositionPair; ex: Exception);
    property Name: String; readonly;
    property Exception: Exception; readonly;
    property SourceFileName: String read SourceSpan.File;
    property SourceSpan: PositionPair; readonly;
  end;


  ScriptComponentException = public class(Exception);


  ScriptStatus = public enum(
    Stopped,
    StepInto, 
    StepOver,
    StepOut,
    Running,
    Stopping,
    Paused,
    Pausing);


  ScriptStackFrame = public class
  private
    fThis: Object;
    fMethod: string;
    fFrame: EnvironmentRecord;
  assembly
    constructor(aMethod: String; aThis: Object; aFrame: EnvironmentRecord);
  public
    property Frame: EnvironmentRecord read fFrame;
    property This: Object read fThis;
    property &Method: string read fMethod;
  end;


  ScriptComponent = public abstract class({$IFNDEF SILVERLIGHT} Component, {$ENDIF}IDebugSink, IDisposable)
  private
    fWorkThread: System.Threading.Thread;
    fRunResult: Object;
    fRunInThread: Boolean;
    fDebug: Boolean;
    //fSetup: ScriptRuntimeSetup;
    fTracing: boolean; volatile;
    fStatus: ScriptStatus;
    fStackItems: System.Collections.ObjectModel.ReadOnlyCollection<ScriptStackFrame>;
    fDebugLastPos: PositionPair;
    fWaitEvent: System.Threading.ManualResetEvent := new System.Threading.ManualResetEvent(true);
    method DebugLine(aFilename: string; aStartRow, aStartCol, aEndRow, aEndCol: Integer); 
    method EnterScope(aName: string; athis: Object; aContext: ExecutionContext); // enter method
    method ExitScope(aName: string; aContext: ExecutionContext); // exit method
    method CaughtException(e: Exception); // triggers on a CATCH before the js code itself
    method UncaughtException(e: Exception); // triggers when an exception escapes the main method
    method Debugger; 
    method Idle;
    method set_Status(value: ScriptStatus);
    method set_RunInThread(value: Boolean);
    method CheckShouldPause;
  protected
    fLastFrame: Integer;
    fExceptionResult: Exception;
    fStackList: List<ScriptStackFrame> := new List<ScriptStackFrame>;
    fGlobals: ScriptScope;
    fEntryStatus: ScriptStatus := ScriptStatus.Running;
    method IntRun: Object; abstract;
    method SetDebug(b: Boolean); virtual;
  public
    constructor;
    [Category('Script')]
    property Debug: Boolean read fDebug write SetDebug;
    [Category('Script')]
    property SourceFileName: String;
    [Category('Script')]
    property Source: String;
    [Category('Script')]
    property RunInThread: Boolean read fRunInThread write set_RunInThread;    

    [Browsable(false)]
    property CallStack: ReadOnlyCollection<ScriptStackFrame> read fStackItems;
    [Browsable(false)]
    property Globals: ScriptScope read; abstract;
    {$IFDEF SILVERLIGHT}
    method Dispose;
    {$ELSE}
    method Dispose(disposing: Boolean); override;
    {$ENDIF}

    method ExposeType(&type: &Type;  name: String := nil); abstract;

    //method UseNamespace(ns: String); virtual;
    /// <summary>Clears all assemblies and exposed variables</summary>
    method Clear(aGlobals: Boolean := false); abstract;

    /// <summary>starts the script,
    ///   this should be ran from another thread
    ///   if you want to use the debugger</summary>
    method Run; 
    property RunResult: Object read fRunResult;
    property RunException: Exception read fExceptionResult;
    property DebugLastPos: PositionPair read fDebugLastPos;

    /// <summary>Returns if there is a function by that name. After calling Run the global object
    ///   will contain a list of all functions, these can be called
    ///   by name. Note this only works after calling Run first.</summary>
    method HasFunction(aName: String): Boolean; abstract;
    /// <summary>Executes the given function by name. After calling Run the global object
    ///   will contain a list of all functions, these can be called
    ///   by name. Note this only works after calling Run first.</summary>
    method RunFunction(aName: String; params args: Array of object): Object; 
    method RunFunction(aInitialStatus: ScriptStatus; aName: String; params args: Array of object): Object; abstract;

    property Status: ScriptStatus read fStatus protected write set_Status;
    method StepInto;
    method StepOver;
    method StepOut;
    method Pause;
    method &Stop;

    event DebugFrameEnter: EventHandler<ScriptDebugEventArgs>;
    event DebugFrameExit: EventHandler<ScriptDebugEventArgs>;
    event DebugThreadExit: EventHandler<ScriptDebugEventArgs>;
    event DebugTracePoint: EventHandler<ScriptDebugEventArgs>;
    event DebugDebugger: EventHandler<ScriptDebugEventArgs>;
    event DebugException: EventHandler<ScriptDebugEventArgs>;
    event DebugExceptionUnwind: EventHandler<ScriptDebugEventArgs>;
    event StatusChanged: EventHandler;
    event NonThreadedIdle: EventHandler;
  end;


  ScriptAbortException = public class (Exception)
  end;


  {$REGION Designtime Attributes}
  {$IFDEF DESIGN}
  [System.Drawing.ToolboxBitmap(typeof(RemObjects.Script.EcmaScriptComponent), 'Glyphs.EcmaScriptComponent.png')]
  {$ENDIF}
  {$ENDREGION}
  EcmaScriptComponent = public class(ScriptComponent)
  private
  protected
    var fCompiler: EcmaScriptCompiler;
    var fScope: ScriptScope;
    var fRoot: ExecutionContext;
    var fGlobalObject: RemObjects.Script.EcmaScript.GlobalObject;
    fJustFunctions: Boolean;

    method set_JustFunctions(value: Boolean);
    method SetDebug(b: Boolean); override;
    method IntRun: Object; override;
  public
    property RootContext: ExecutionContext; 
    property JustFunctions: Boolean read fJustFunctions write set_JustFunctions;
    method Clear(aGlobals: Boolean := false); override;
    property Globals: ScriptScope read fScope; override;
    property GlobalObject: RemObjects.Script.EcmaScript.GlobalObject read fGlobalObject;
    method ExposeType(&type: &Type;  name: String); override;
    method HasFunction(aName: String): Boolean; override;
    method RunFunction(aInitialStatus: ScriptStatus; aName: String; params args: Array of object): Object; override;
  end;


  SyntaxErrorException = public class(Exception)
  public
    constructor(aSource: string; aMessage: String; aSpan: PositionPair; anErrorCode: Int32); 
    property Message: string; readonly; reintroduce;
    property Source: string; readonly; reintroduce;
    property SourceFilename: string; readonly; reintroduce;
    property Span: PositionPair; readonly;
    property ErrorCode: Int32; readonly;

    method ToString: String; override;
  end;


implementation

constructor ScriptDebugEventArgs(aName: string; aSpan: PositionPair);
begin
  Name := aName;
  SourceSpan := aSpan;
end;

constructor ScriptDebugEventArgs(aName: string; aSpan: PositionPair; ex: Exception);
begin
  constructor(aname, aSpan);
  Exception := ex;
end;

constructor ScriptComponent;
begin
  inherited constructor;
  fStackItems := new ReadOnlyCollection<ScriptStackFrame>(fStackList);
  Clear;
end;

method ScriptComponent.SetDebug(b: Boolean);
begin
  if fDebug = b then exit;
  fDebug := b;
end;


method ScriptComponent.StepInto;
begin
  locking self do begin
    if STatus = ScriptStatus.Stopped then begin
      fEntryStatus := ScriptStatus.StepInto;
      fLastFrame := fStackList.Count;
      Run;
      exit;
    end;

    if Status in [ScriptStatus.Paused, ScriptStatus.Pausing, ScriptStatus.Running] then begin
      if Status = ScriptStatus.Paused then begin
        Status := ScriptStatus.StepInto;
        fWaitEvent.Set();
      end else 
        Status := ScriptStatus.StepInto;
      fLastFrame := fStackList.Count;
    end;
  end;
end;

method ScriptComponent.StepOver;
begin
  locking self do begin
    if STatus = ScriptStatus.Stopped then begin
      fEntryStatus := ScriptStatus.StepInto;
      fLastFrame := fStackList.Count;
      Run;
      exit;
    end;
    if Status in [ScriptStatus.Paused, ScriptStatus.Pausing, ScriptStatus.Running] then begin
      if Status = ScriptStatus.Paused then begin
        Status := ScriptStatus.StepOver;
        fWaitEvent.Set();
      end else 
      Status := ScriptStatus.StepOver;
      fLastFrame := fStackList.Count;
    end;
  end;
end;

method ScriptComponent.StepOut;
begin
  locking self do begin
    if STatus = ScriptStatus.Stopped then begin
      fEntryStatus := ScriptStatus.StepInto;
      fLastFrame := fStackList.Count;
      Run;
      exit;
    end;
    if Status in [ScriptStatus.Paused, ScriptStatus.Pausing, ScriptStatus.Running] then begin
      if Status = ScriptStatus.Paused then begin
        Status := ScriptStatus.StepOut;
        fWaitEvent.Set();
      end else 
        Status := ScriptStatus.StepOut;
      fLastFrame := fStackList.Count;
    end;
  end;
end;

method ScriptComponent.Stop;
begin
  locking self do begin
    case Status of
      ScriptStatus.Paused: begin Status := ScriptStatus.Stopping; fWaitEvent.Set(); end;
      ScriptStatus.Stopping,
      ScriptStatus.Pausing, 
      ScriptStatus.Running, 
      ScriptStatus.StepInto,
      ScriptStatus.StepOut, 
      ScriptStatus.StepOver:  Status := ScriptStatus.Stopping;
      ScriptStatus.Stopped: ;
    end; // case
  end;
end;

method ScriptComponent.set_RunInThread(value: Boolean);
begin
  if Status = ScriptStatus.Stopped then 
    fRunInThread := value 
  else
    raise new ScriptComponentException(Properties.Resources.eRunInThreadCannotBeModifiedWhenScriptIsRunning);
end;

method ScriptComponent.set_Status(value: ScriptStatus);
begin
  fStatus := value;
  if assigned(StatusChanged) then StatusChanged(self, EventArgs.Empty);
end;



method ScriptComponent.Run;
begin
  if fRunInThread then begin
    locking self do begin
      if Status in [ScriptStatus.StepInto, ScriptStatus.StepOut, ScriptStatus.StepOver] then begin
        Status := ScriptStatus.Running;
        exit;
      end else if Status = ScriptStatus.Paused  then begin
        Status := ScriptStatus.Running;
        fWaitEvent.Set();
        exit;
      end else if Status <> ScriptStatus.Stopped then raise new ScriptComponentException(RemObjects.Script.Properties.Resources.eAlreadyRunning);
      Status := ScriptStatus.Running;
    end;
      fExceptionResult := nil;
      fWorkThread := new System.Threading.Thread(method begin
        try
          fRunResult := IntRun;
        except
          on e: Exception do
            fExceptionResult := e;
        end;
      end);
      try
        fWorkThread.Start;
      except
        Status := ScriptStatus.Stopped;
        raise;
      end;
  end else begin
    if Status = ScriptStatus.Paused then begin Status := ScriptStatus.Running; exit; end;
    if Status <> ScriptStatus.Stopped then raise new ScriptComponentException(RemObjects.Script.Properties.Resources.eAlreadyRunning);
    fRunResult := IntRun;
  end;

end;

method ScriptComponent.Pause;
begin
  locking self do begin
    if Status = ScriptStatus.Running then begin
      Status := ScriptStatus.Pausing;
    end;
  end;
end;

method ScriptComponent.Idle;
begin
  if Status = ScriptStatus.Pausing then
    Status := ScriptStatus.Paused;
  while Status = ScriptStatus.Paused do begin
    if NonThreadedIdle <> nil then NonThreadedIdle(self, EventArgs.Empty) else
      System.Threading.Thread.Sleep(10);
  end;
end;


method ScriptComponent.DebugLine(aFilename: string; aStartRow, aStartCol, aEndRow, aEndCol: Integer);
begin
  fDebugLastPos := new PositionPair(0, aStartRow, aStartCol, 0, aEndRow, aendCol, aFilename);
  if Status = ScriptStatus.Stopping then raise new ScriptAbortException();
  if  fTracing then exit;
  fTracing := true;
  try
    if DebugTracePoint <> nil then DebugTracePoint(self, new ScriptDebugEventArgs(fStackList[fStackItems.Count-1].Method, new PositionPair(0, aSTartRow, aStartCol, 0, aEndRow, aEndCol, aFilename)));
    if (Status = ScriptStatus.StepInto) or 
          ((Status = ScriptStatus.StepOver) and (fLastFrame = fStackList.Count)) then Status := ScriptStatus.Pausing;
    CheckShouldPause;
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.EnterScope(aName: string; athis: Object; aContext: ExecutionContext);
begin
  fStackList.Add(new ScriptStackFrame(aName, aThis, aContext.LexicalScope));
  if Status = ScriptStatus.Stopping then raise new ScriptAbortException();
  if  fTracing then exit;
  fTracing := true;
  try
    if Status = ScriptStatus.StepInto then Status := ScriptStatus.Pausing;
    CheckShouldPause;
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.ExitScope(aName: string; aContext: ExecutionContext);
begin
  fStackList.RemoveAt(fStackList.Count-1);
  if  fTracing then exit;
  fTracing := true;
  try
    if (status = ScriptStatus.StepOut) and (fLastFrame < fStackList.Count) then Status := ScriptStatus.Pausing;
    CheckShouldPause;
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.CaughtException(e: Exception);
begin
  if  fTracing then exit;
  fTracing := true;
  try
    if DebugException <> nil then DebugException(self, new ScriptDebugEventArgs(fStackList[fStackList.Count-1].Method, fDebugLastPos));
    CheckShouldPause;
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.UncaughtException(e: Exception);
begin
  if  fTracing then exit;
  fTracing := true;
  try
    if DebugExceptionUnwind <> nil then DebugExceptionUnwind(self, new ScriptDebugEventArgs(nil, fDebugLastPos));
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.Debugger;
begin
  if  fTracing then exit;
  fTracing := true;
  try
    if DebugDebugger <> nil then DebugDebugger(self, new ScriptDebugEventArgs(fStackList[fStackList.Count-1].Method, fDebugLastPos));
    CheckShouldPause;
  finally
    fTracing := false;
  end;
end;

method ScriptComponent.CheckShouldPause;
begin
  if Status in [ScriptStatus.Paused, ScriptStatus.Pausing] then begin
    if fRunInThread then begin
      Status := ScriptStatus.Paused;
      fWaitEvent.Reset();
      fWaitEvent.WaitOne();
    end else Idle;
  end;
end;

{$IFDEF SILVERLIGHT} 
method ScriptComponent.Dispose;
{$ELSE}
method ScriptComponent.Dispose(disposing: Boolean);
{$ENDIF}
begin
  {$IFNDEF SILVERLIGHT} if disposing then {$ENDIF}
  fWaitEvent.Close;

end;

method ScriptComponent.RunFunction(aName: String; params args: Array of object): Object;
begin
  exit RunFunction(ScriptStatus.Running, aName, args);
end;

method EcmaScriptComponent.HasFunction(aName: String): Boolean;
begin
  exit fGlobalObject.Get(aName) is RemObjects.Script.EcmaScript.EcmaScriptBaseFunctionObject;
end;

method EcmaScriptComponent.RunFunction(aInitialStatus: ScriptStatus; aName: String; params args: Array of object): Object;
begin
  try
    var lItem := fGlobalObject.Get(aName) as RemObjects.Script.EcmaScript.EcmaScriptBaseFunctionObject;
    if lItem = nil then raise new ScriptComponentException(String.Format(RemObjects.Script.Properties.Resources.eNoSuchFunction, aName));
    if args = nil then Args := [];
    if aInitialStatus = ScriptStatus.StepInto then begin
      Status := aInitialStatus;
      fLastFrame := fStackList.Count;
    end else
      Status := ScriptStatus.Running;
    exit lItem.Call(fRoot, Args.Select(a->EcmaScriptScope.DoTryWrap(fGlobalObject, a)).ToArray());
  finally
    Status := ScriptStatus.Stopped;
  end;
end;

method EcmaScriptComponent.IntRun: Object;
begin
  Status := fEntryStatus; 
  fEntryStatus := ScriptStatus.Running;
  try
    if String.IsNullOrEmpty(SourceFileName) then SourceFileName := 'main.js';
    if Source = nil then Source := '';
    fGlobalObject.FrameCount := 0;
    var lCallback := fCompiler.Parse(SourceFileName, Source);
    result := lCallback(fRoot, fGlobalObject, []);
  except
    on e: ScriptRuntimeException where EcmaScriptObjectWrapper(e.Original):Value is Exception do 
      fExceptionResult := Exception(EcmaScriptObjectWrapper(e.Original).Value);
    on e: ScriptAbortException do
      exit Undefined.Instance;
  finally
    Status := ScriptStatus.Stopped;
  end;
end;


method EcmaScriptComponent.ExposeType(&type: &Type;  name: String);
begin
  if  (String.IsNullOrEmpty(name))  then
    name := &type.Name;

  self.fGlobalObject.AddValue(name, new EcmaScriptObjectWrapper(nil, &type, self.fGlobalObject));
end;


method EcmaScriptComponent.SetDebug(b: Boolean);
begin
  if b <> inherited Debug then begin
    inherited SetDebug(b);
    Clear;
  end;
end;

method EcmaScriptComponent.Clear(aGlobals: Boolean := false);
begin
  fGlobalObject := new GlobalObject();
  if aGlobals or (fScope = nil) then
    fScope := new EcmaScriptScope(nil, fGlobalObject)
  else
    fScope.Global := fGlobalObject;
  if Debug then
    fGlobalObject.Debug := self;
  var lRoot := new ObjectEnvironmentRecord(fScope, fGlobalObject, false);

  froot := new ExecutionContext(lRoot, false);
  fGlobalObject.ExecutionContext := fRoot;
  fCompiler := new EcmaScriptCompiler(new EcmaScriptCompilerOptions(EmitDebugCalls := Debug, GlobalObject := fGlobalObject, Context := fRoot.LexicalScope, JustFunctions := fJustFunctions));
  fGlobalObject.Parser := fCompiler;
end;

method EcmaScriptComponent.set_JustFunctions(value: Boolean);
begin
  if value <> fJustFunctions then begin
    fJustFunctions := value;
    fCompiler.JustFunctions := value;
  end;

end;

constructor ScriptStackFrame(aMethod: String; aThis: Object; aFrame: EnvironmentRecord);
begin
  fMethod := aMethod;
  fFrame := aFrame;
  fthis := aThis;
end;

constructor SyntaxErrorException(aSource: string; aMessage: String; aSpan: PositionPair; anErrorCode: Int32);
begin
  inherited constructor(String.Format('{0}({1}, {2}): {4} {3}',
    aSource, aSpan.StartRow, aSpan.StartCol, aMessage,
    'error'));
  Source := aSource;
  Span := aSpan;
  ErrorCode := anErrorCode;
  Message := aMessage;
end;

method SyntaxErrorException.ToString: String;
begin
  exit inherited Message;
end;


end.

