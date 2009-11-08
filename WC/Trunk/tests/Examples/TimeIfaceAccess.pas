unit TimeIfaceAccess;
interface
uses
  Classes,
  RefTestFramework;

type
  IMyTestit = interface
  ['{46EAC687-8067-4973-A542-EF9E342D14BA}']

  function  getit: Cardinal;
  procedure setit(const Value: Cardinal);
  property  It: Cardinal read getit write setit;
  end;

  TMyTestit = class(TInterfacedObject, IMyTestit)
  private
    FIt: Cardinal;
    function  getit: Cardinal;
    procedure setit(const Value: Cardinal);
  published
    property  It: Cardinal read getit write setit;
  end;

  THammerIt3Ways = class(TTestCase)
  private
    FMyTestIt: IMyTestIt;
    FMyTestedIt: IMyTestIt;
    FCount: Cardinal;
    FMult: Cardinal;
    FLoops: Cardinal;
    function ItAsParam(const Value: IMyTestIt): Cardinal;
    function ItAsFieldVar(const Value: IMyTestIt): Cardinal;
    function ItAsLocalVar(const Value: IMyTestIt): Cardinal;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure HammerItAsParam;
    procedure HammerItAsFieldVar;
    procedure HammerItAsLocalVar;
  end;

  THammerSingleCall = class(THammerIt3Ways)
  protected
    procedure SetUp; override;

  end;

  THammerMultiCalls = class(THammerIt3Ways)
  protected
    procedure SetUp; override;

  end;

implementation
uses
  SysUtils;

{ TMyTestit }

function TMyTestit.getit: Cardinal;
begin
  Result := FIt;
end;

procedure TMyTestit.setit(const Value: Cardinal);
begin
  FIt := Value;
end;

{ THammerIt3Ways }


procedure THammerIt3Ways.SetUp;
begin
  FMyTestIt := TMyTestIt.Create;
  FMyTestedIt := nil;
end;

procedure THammerIt3Ways.TearDown;
begin
  FMyTestIt := nil;
  FMyTestedIt := nil;
end;

procedure THammerIt3Ways.HammerItAsFieldVar;
var
  LCount: Cardinal;
  I : Integer;
begin
  for I := 0 to FMult - 1 do
  begin
    FMyTestIt.It := 0;
    LCount := ItAsFieldVar(FMyTestIt);
  end;
  Check(LCount = FCount,
    'ItAsFieldVar returned value should be ' + IntToStr(FCount) +
      ' but was ' + IntToStr(LCount));
end;

procedure THammerIt3Ways.HammerItAsLocalVar;
var
  LCount: Cardinal;
  I : Cardinal;
begin
  for I := 0 to FMult - 1 do
  begin
    FMyTestIt.It := 0;
    LCount := ItAsLocalVar(FMyTestIt);
  end;
  Check(LCount = FCount,
    'ItAsLocalVar returned value should be ' + IntToStr(FCount) +
      ' but was ' + IntToStr(LCount));
end;

procedure THammerIt3Ways.HammerItAsParam;
var
  LCount: Cardinal;
  I : Cardinal;
begin
  for I := 0 to FMult - 1 do
  begin
    FMyTestIt.It := 0;
    LCount := ItAsParam(FMyTestIt);
  end;
  Check(LCount = FCount,
  'ItAsParam returned value should be ' + IntToStr(FCount) +
    ' but was ' + IntToStr(LCount));
end;

function THammerIt3Ways.ItAsFieldVar(const Value: IMyTestIt): Cardinal;
var
  I: Cardinal;
begin
  FMyTestIt := Value;
  for I := 0 to FLoops -1 do
    FMyTestIt.It := FMyTestIt.It + 1;
  Result := FMyTestIt.It;
end;

function THammerIt3Ways.ItAsLocalVar(const Value: IMyTestIt): Cardinal;
var
  I: Cardinal;
  LMyTestIt: IMyTestIt;
begin
  LMyTestIt := Value;
  for I := 0 to FLoops -1 do
    LMyTestIt.It := LMyTestIt.It + 1;
  Result := LMyTestIt.It;
end;

function THammerIt3Ways.ItAsParam(const Value: IMyTestIt): Cardinal;
var
  I: Cardinal;
begin
  for I := 0 to FLoops -1 do
    Value.It := Value.It + 1;
  Result := Value.It;
end;

{ THammerSingleCall }

procedure THammerSingleCall.SetUp;
begin
  inherited;
  FMult := 1;
  FLoops := $FFFFFFF;
  FCount := FLoops;
end;

{ THammerMultiCalls }

procedure THammerMultiCalls.SetUp;
begin
  inherited;
  FMult := $FFFFFFF;
  FLoops := $1;
  FCount := FLoops;
end;

initialization
  RefTestFrameWork.RegisterTests([THammerSingleCall.Suite, THammerMultiCalls.Suite]);
end.

