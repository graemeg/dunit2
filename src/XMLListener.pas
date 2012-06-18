{$ifdef selftest}
  {$define ShowClass}
{$endif}

{$I DUnit.inc}

unit XMLListener;

interface

uses
  Contnrs
  ,TestFrameworkProxyIfaces
  {$IFDEF XDOM}
  ,xdom   // Chosen because it does not drag in any other units e.g. TComponent
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  // The following is from "http://www.philo.de/xml/" - Both the 'adom' and 'utils' files are required.
  // Need "\externals\adom" to be added to the project search path
  {$IFDEF DELPHIXE2_UP}
  ,Xml.Internal.AdomCore_4_3
  {$ELSE}
  ,dkAdomCore_4_3
  {$ENDIF DELPHIXE2_UP}
  {$ENDIF DKADOMCORE}
  ;

type

  IXMLStack = interface
  ['{CC96971E-E712-475D-A8AB-1BE7EB96092D}']
    function  Pop: TDomElement;
    procedure Push(const ANode: TDomElement);
    function  Empty: boolean;
    function  Top: TDomElement;
  end;


  TXMLListener = class(TInterfacedObject, ITestListener, ITestListenerX)
  private
    FAppPath: string;
    FAppName: string;
    FDocName: string;
    FStack:   IXMLStack;
    FXMLDoc: TdomDocument;
    procedure AppendComment(const AComment: string);
    procedure AppendElement(const AnElement: string);
    function  CurrentElement: TDomElement;
    procedure MakeElementCurrent(const AnElement: TDomElement);
    function  PreviousElement: TDomElement;
    procedure AddResult(const ATitle, AValue: string);
    procedure AppendLF;
    procedure AddNamedValue(const AnAttrib: TDomElement; const AName: string; AValue: string);
    procedure AddNamedText(const ANode: TDomElement; const AName: string; const AMessage: string);
    procedure AddFault(const AnError: TTestFailure; const AFault: string);
  protected
    function  UnEscapeUnknownText(const UnKnownText: string): string; virtual;
    procedure AddSuccess(Test: ITestProxy); virtual;
    procedure AddError(AnError: TTestFailure); virtual;
    procedure AddFailure(AnError: TTestFailure); virtual;
    procedure AddWarning(AnError: TTestFailure); virtual;
    procedure TestingStarts; virtual;
    procedure StartSuite(Suite: ITestProxy); virtual;
    procedure StartTest(Test: ITestProxy); virtual;
    procedure EndTest(Test: ITestProxy); virtual;
    procedure EndSuite(Suite: ITestProxy); virtual;
    procedure TestingEnds(TestResult: TTestResult); virtual;
    function  ShouldRunTest(const ATest :ITestProxy):Boolean; virtual;
    procedure Status(const ATest: ITestProxy; AMessage: string); virtual;
  public
    constructor Create(const ExePathFileName: string); overload;
    constructor Create(const ExePathFileName: string; const PIContent: string); overload;
    destructor Destroy; override;
  end;


implementation
uses
  TestFrameworkIfaces,
  Classes,
  SysUtils;

const
  milliSecsToDays       = 1/86400000;
  cxmlExt               = '.xml';
  cxmlStylesheet        = 'xml-stylesheet';
  cElapsedTime          = 'ElapsedTime';
  cNumberOfErrors       = 'NumberOfErrors';
  cNumberOfFailures     = 'NumberOfFailures';
  cNumberOfRunTests     = 'NumberOfRunTests';
  cNumberOfWarnings     = 'NumberOfWarnings';
  cNumberOfExcludedTests = 'NumberOfExcludedTests';
  cNumberOfChecksCalled = 'NumberOfChecksCalled';
  cTotalElapsedTime     = 'TotalElapsedTime';
  cDateTimeRan          = 'DateTimeRan';
  cyyyymmddhhmmss       = 'yyyy-mm-dd hh:mm:ss';
  chhnnsszz             = 'hh:nn:ss.zzz';
  cTestResults          = 'TestResults';
  cTestListing          = 'TestListing';
  cName                 = 'Name';
  cExceptionClass       = 'ExceptionClass';
  cExceptionMessage     = 'ExceptionMessage';
  cMessage              = 'Message';
  cTest                 = 'Test';
  cResult               = 'Result';
  cError                = 'Error';
  cFailed               = 'Failed';
  cWarning              = 'Warning';
  cOK                   = 'OK';
  cTitle                = 'Title';
  cTitleText            = 'Dunit2 XML test report';
  cGeneratedBy          = 'Generated using DUnit2 on ';
  cEncoding             = 'UTF-8';
  cTestSuite            = 'TestSuite';
  cTestCase             = {$ifdef ShowClass} 'TestCase' {$else} cTestSuite {$endif};
  cTestDecorator        = {$ifdef ShowClass} 'TestDecorator' {$else} cTestSuite {$endif};
  cTestProject          = {$ifdef ShowClass} 'TestProject' {$else} cTestSuite {$endif};

//Converts the test time (in millisecs) to 24 hours for formatting
function PrecisionTimeToDateTimeStr(const SubSecs: Cardinal): string;
begin
  Result := FormatDateTime(chhnnsszz, SubSecs * milliSecsToDays)
end;

{ TXMLStack }

type
  TXMLStack = class(TInterfacedObject, IXMLStack)
  private
    FStack: TObjectList;
  protected
    function  Pop: TDomElement;
    procedure Push(const ANode: TDomElement);
    function  Empty: boolean;
    function  Top: TDomElement;
  public
    constructor Create;
    destructor Destroy; override;
  end;

constructor TXMLStack.Create;
begin
  inherited Create;
  FStack := TObjectList.Create(False);
end;

destructor TXMLStack.Destroy;
begin
  FStack.Destroy;
  inherited Destroy;
end;

function TXMLStack.Empty: boolean;
begin
  Result := FStack.Count = 0;
end;

function TXMLStack.Pop: TDomElement;
var
  idx: integer;
begin
  if Empty then
    Result := nil
  else
  begin
    idx := FStack.Count-1;
    Result := FStack.Items[idx] as TDomElement;
    FStack.Delete(idx);
  end;
end;

procedure TXMLStack.Push(const ANode: TDomElement);
begin
  FStack.Add(ANode);
end;

function TXMLStack.Top: TDomElement;
begin
  if Empty then
    Result := nil
  else
    Result := FStack.Items[FStack.Count-1] as TDomElement;
end;


{ TXMLListener }

constructor TXMLListener.Create(const ExePathFileName: string);
begin
  Create(ExePathFileName, '');
end;

constructor TXMLListener.Create(const ExePathFileName: string; const PIContent: string);
var
  LDomElement: TDomElement;
  LDomProcessingInstruction : TDomProcessingInstruction;
begin
  inherited Create;
  FStack := TXMLStack.Create;
  FAppPath := ExtractFilePath(ExePathFileName);
  FAppName := ExtractFileName(ExePathFileName);
  FDocName := ChangeFileExt(FAppName, cxmlExt);
  FXMLDoc := TDOMDocument.create(nil);
  {$IFDEF XDOM}
  FXMLDoc.Encoding := cEncoding;
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  FXMLDoc.InputEncoding := cEncoding;
  FXMLDoc.XmlEncoding   := cEncoding;
  {$ENDIF}
  if PIContent <> '' then
  begin
    {$IFDEF XDOM}
    LDomProcessingInstruction := FXMLDoc.createProcessingInstruction(cxmlStylesheet, PIContent);
    {$ENDIF}
    {$IFDEF DKADOMCORE}
    LDomProcessingInstruction := TDomProcessingInstruction.Create(FXMLDoc, cxmlStylesheet);
    LDomProcessingInstruction.Data := PIContent;
    {$ENDIF}
    FXMLDoc.appendChild(LDomProcessingInstruction);
  end;
  {$IFDEF XDOM}
  LDomElement := FXMLDoc.createElement(cTestResults);
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LDomElement := TDomElement.Create(FXMLDoc, cTestResults);
  {$ENDIF}
  FXMLDoc.appendChild(LDomElement);
  MakeElementCurrent(LDomElement);
  AppendLF;
  AppendComment(cGeneratedBy + FormatDateTime(cyyyymmddhhmmss, Now));
end;

destructor TXMLListener.Destroy;
var
  Stream: TFileStream;
  S: string;
  {$IFDEF DKADOMCORE}
  DomToXmlParser    : TDomToXmlParser;
  DomImplementation : TDomImplementation;
  {$ENDIF}
begin
  {$IFDEF XDOM}
  S := FXMLDoc.code;
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  DomImplementation := TDomImplementation.Create(nil);
  try
    DomToXmlParser := TDomToXmlParser.Create(nil);
    try
      DomToXmlParser.DOMImpl := DomImplementation;
      DomToXmlParser.WriteToString(FXMLDoc, cEncoding{FXMLDoc.XmlEncoding}, S);
    finally
      DomToXmlParser.Free;
    end;
  finally
    DomImplementation.Free;
  end;
  {$ENDIF}
  Stream := TFileStream.Create(FAppPath + FDocName, fmCreate or fmOpenWrite);
  try
    Stream.Write(Pointer(S)^, Length(S) * SizeOf(Char));  // RINGN: Unicode fix
  finally
    FreeAndNil(Stream);
  end;
  FStack := nil;
  FreeAndNil(FXMLDoc);
  inherited Destroy;
end;

{------------------- Functions that operate on the stack ----------------------}

function TXMLListener.CurrentElement: TDomElement;
begin
  Result := FStack.Top;
end;

procedure TXMLListener.MakeElementCurrent(const AnElement: TDomElement);
begin
  FStack.Push(AnElement);
end;

function TXMLListener.PreviousElement: TDomElement;
begin
  Result := FStack.Pop;
end;

{------------------- Functions that collect associated actions ----------------}

procedure TXMLListener.AppendLF;
var
  LDomText : TDomText;
begin
  {$IFDEF XDOM}
  LDomText := FXMLDoc.createTextNode(#10);
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LDomText := TDomText.Create(FXMLDoc);
  LDomText.Data := #10;
  {$ENDIF}
  CurrentElement.appendChild(LDomText);
end;

procedure TXMLListener.AppendElement(const AnElement: string);
var
  LDomElement: TDomElement;
begin
  {$IFDEF XDOM}
  LDomElement := FXMLDoc.createElement(AnElement);
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LDomElement := TDomElement.Create(FXMLDoc, AnElement);
  {$ENDIF}
  CurrentElement.appendChild(LDomElement);
  AppendLF;
  MakeElementCurrent(LDomElement);
end;

procedure TXMLListener.AppendComment(const AComment: string);
var
  LDomComment : TDomComment;
begin
  {$IFDEF XDOM}
  LDomComment := FXMLDoc.CreateComment(AComment);
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LDomComment := TDomComment.Create(FXMLDoc);
  LDomComment.Data := AComment;
  {$ENDIF}
  CurrentElement.appendChild(LDomComment);
  AppendLF;
end;

procedure TXMLListener.AddResult(const ATitle: string; const AValue: string);
var
  LElement: TDomElement;
  LDomText : TDomText;
  E: Exception;
begin
  {$IFDEF XDOM}
  LElement := FXMLDoc.createElement(ATitle);
  LDomText := FXMLDoc.createTextNode(UnEscapeUnknownText(AValue));
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LElement := TDomElement.Create(FXMLDoc, ATitle);
  LDomText := TDomText.Create(FXMLDoc);
  LDomText.Data := UnEscapeUnknownText(AValue);
  {$ENDIF}

  LElement.appendChild(LDomText);
  if (CurrentElement <> nil) then
  begin
    CurrentElement.appendChild(LElement);
    AppendLF;
  end
  else
  begin
    E := Exception.Create('XMLListener: No corresponding opening tag for ' +
      ATitle + '  Final value = ' + AValue);
    raise E;
  end;
end;

procedure TXMLListener.AddNamedValue(const AnAttrib: TDomElement; const AName: string; AValue: string);
var
  LAttrib: TdomAttr;
begin
  {$IFDEF XDOM}
  LAttrib := FXMLDoc.createAttribute(AName);
  LAttrib.value := AValue;
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LAttrib := TdomAttr.Create(FXMLDoc, AName, True);
  LAttrib.NodeValue := AValue;
  {$ENDIF}
  AnAttrib.setAttributeNode(LAttrib);
end;

procedure TXMLListener.AddNamedText(const ANode: TDomElement; const AName: string; const AMessage: string);
var
  LDomElement: TDomElement;
  LTDomText : TDomText;
begin
  {$IFDEF XDOM}
  LDomElement := FXMLDoc.createElement(AName);
  LTDomText := FXMLDoc.createTextNode(UnEscapeUnknownText(AMessage));
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LDomElement := TDomElement.Create(FXMLDoc, AName);
  LTDomText := TDomText.Create(FXMLDoc);
  LTDomText.Data := UnEscapeUnknownText(AMessage);
  {$ENDIF}
  LDomElement.appendChild(LTDomText);
  ANode.appendChild(LDomElement);
  AppendLF;
end;

{--------------------- These are ITestListener functions ----------------------}

function TXMLListener.ShouldRunTest(const ATest: ITestProxy): Boolean;
begin
  Result := True;
end;

procedure TXMLListener.StartSuite(Suite: ITestProxy);
begin
// Nothing required here but the procedure must be includes to match the interface.
end;

procedure TXMLListener.Status(const ATest: ITestProxy; AMessage: string);
begin
// Nothing required here but the procedure must be includes to match the interface.
end;

procedure TXMLListener.EndSuite(Suite: ITestProxy);
begin
// Nothing required here but the procedure must be includes to match the interface.
end;

{--------------------- Active ITestListener functions -------------------------}

procedure TXMLListener.TestingStarts;
begin
  AppendElement(cTestListing);
end;

function TXMLListener.UnEscapeUnknownText(const UnKnownText: string): string;
begin
  Result := UnKnownText;
end;

procedure TXMLListener.StartTest(Test: ITestProxy);
var
  LTestElement: TDomElement;

  procedure AddClassName(const AClassName: string);
  begin
    {$IFDEF XDOM}
    LTestElement := FXMLDoc.createElement(AClassName);
    {$ENDIF}
    {$IFDEF DKADOMCORE}
    LTestElement := TDomElement.Create(FXMLDoc, AClassName);
    {$ENDIF}
    AddNamedValue(LTestElement, cName, UnEscapeUnknownText(Test.Name));
    CurrentElement.appendChild(LTestElement);
    MakeElementCurrent(LTestElement);
    AppendLF;
  end;


begin  {TXMLListener.StartTest(Test: ITestProxy);}
  if not Assigned(Test) or (CurrentElement = nil) then
    Exit;

  if not Test.IsTestMethod then
  begin
    case Test.SupportedIfaceType of
      _isTestCase:      AddClassName(cTestCase);
      _isTestSuite:     AddClassName(cTestSuite);
      _isTestDecorator: AddClassName(cTestDecorator);
      _isTestProject:   AddClassName(cTestProject);
    end;
  end;
end;

procedure TXMLListener.EndTest(Test: ITestProxy);
begin
  if not Assigned(Test) then
    Exit;

  if Ord(Test.ExecutionStatus) > Ord(_Running)  then
  begin
    if (CurrentElement = nil) then
      Exit;

    case Test.SupportedIfaceType of
      _isTestCase,
      _isTestSuite,
     _isTestProject,
     _isTestDecorator:
      begin
        AddNamedValue(CurrentElement, cElapsedTime, PrecisionTimeToDateTimeStr(Test.ElapsedTestTime));
        if Test.Updated then
        begin
          AddNamedValue(CurrentElement, cNumberOfErrors,   IntToStr(Test.Errors));
          AddNamedValue(CurrentElement, cNumberOfFailures, IntToStr(Test.Failures));
          AddNamedValue(CurrentElement, cNumberOfWarnings, IntToStr(Test.Warnings));
          AddNamedValue(CurrentElement, cNumberOfRunTests, IntToStr(Test.TestsExecuted));
         end;
        PreviousElement;
      end;
    end;  {case}
  end;
end;

procedure TXMLListener.TestingEnds(TestResult: TTestResult);
begin
  if not Assigned(TestResult) or (CurrentElement = nil) then
    Exit;

  AddNamedValue(CurrentElement, cElapsedTime,       PrecisionTimeToDateTimeStr(TestResult.TotalTime));
  AddNamedValue(CurrentElement, cNumberOfErrors,    IntToStr(TestResult.ErrorCount));
  AddNamedValue(CurrentElement, cNumberOfFailures,  IntToStr(TestResult.FailureCount));
  AddNamedValue(CurrentElement, cNumberOfRunTests,  IntToStr(TestResult.RunCount));
  AddNamedValue(CurrentElement, cNumberOfWarnings,  IntToStr(TestResult.WarningCount));
  AddNamedValue(CurrentElement, cNumberOfChecksCalled, IntToStr(TestResult.ChecksCalledCount));

  while (CurrentElement <> nil) and (CurrentElement.tagName <> cTestResults) do
    PreviousElement;

  AddResult(cTitle, cTitleText);
  AddResult(cNumberOfRunTests, IntToStr(TestResult.RunCount));
  AddResult(cNumberOfErrors,   IntToStr(TestResult.ErrorCount));
  AddResult(cNumberOfFailures, IntToStr(TestResult.FailureCount));
  AddResult(cNumberOfWarnings, IntToStr(TestResult.WarningCount));
  AddResult(cNumberOfExcludedTests, IntToStr(TestResult.ExcludedCount));
  AddResult(cNumberOfChecksCalled, IntToStr(TestResult.ChecksCalledCount));
  AddResult(cTotalElapsedTime, PrecisionTimeToDateTimeStr(TestResult.TotalTime));
  AddResult(cDateTimeRan,      FormatDateTime(cyyyymmddhhmmss, Now));
end;

procedure TXMLListener.AddSuccess(Test: ITestProxy);
var
  LOKTest: TDomElement;
begin
  if not Assigned(Test) or (CurrentElement = nil) then
    Exit;

  if Test.IsTestMethod then
  begin
    {$IFDEF XDOM}
    LOKTest := FXMLDoc.createElement(cTest);
    {$ENDIF}
    {$IFDEF DKADOMCORE}
    LOKTest := TDomElement.Create(FXMLDoc, cTest);
    {$ENDIF}
    AddNamedValue(LOKTest, cName, UnEscapeUnknownText(Test.Name));
    AddNamedValue(LOKTest, cResult, cOK);
    AddNamedValue(LOKTest, cElapsedTime, PrecisionTimeToDateTimeStr(Test.ElapsedTestTime));
    CurrentElement.appendChild(LOKTest);
    AppendLF;
  end;
end;

procedure TXMLListener.AddFault(const AnError: TTestFailure;
                                const AFault: string);
var
  LBadTest: TDomElement;
begin
  if not Assigned(AnError) or (CurrentElement = nil) then
    Exit;
  {$IFDEF XDOM}
  LBadTest := FXMLDoc.createElement(cTest);
  {$ENDIF}
  {$IFDEF DKADOMCORE}
  LBadTest := TDomElement.Create(FXMLDoc, cTest);
  {$ENDIF}
  AddNamedValue(LBadTest, cName, UnEscapeUnknownText(AnError.FailedTest.Name));
  AddNamedValue(LBadTest, cResult, AFault);
  AddNamedValue(LBadTest, cElapsedTime, PrecisionTimeToDateTimeStr(AnError.FailedTest.ElapsedTestTime));
  AppendLF;

  AddNamedText(LBadTest, cMessage, AnError.FailedTest.ParentPath + '.' +
    AnError.FailedTest.Name + ': ' + AnError.ThrownExceptionMessage);
  AddNamedText(LBadTest, cExceptionClass, AnError.ThrownExceptionName);
  AddNamedText(LBadTest, cExceptionMessage, AnError.ThrownExceptionMessage);
  CurrentElement.appendChild(LBadTest);
  AppendLF;
end;

procedure TXMLListener.AddWarning(AnError: TTestFailure);
begin
  AddFault(AnError, cWarning);
end;

procedure TXMLListener.AddError(AnError: TTestFailure);
begin
  AddFault(AnError, cError);
end;

procedure TXMLListener.AddFailure(AnError: TTestFailure);
begin
  AddFault(AnError, cFailed);
end;

end.

