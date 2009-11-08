unit Unit1;

interface
uses
  Classes;

type
  TTestedClassA = class(Tobject)
  private
    FLast: Boolean;
  public
    function ReturnsTrue: Boolean;
    function RetunesFalse: Boolean;
    function ReturnsTrueFalseAlternately: Boolean;
  end;


  TTestedClassB = class(Tobject)
  private
    FLast: Boolean;
  public
    function ReturnsNotTrue: Boolean;
    function RetunesNotFalse: Boolean;
    function ReturnsFalseTrueAlternately: Boolean;
  end;

implementation

{ TTestedClass }

function TTestedClassA.RetunesFalse: Boolean;
begin
  Result := False;
end;

function TTestedClassA.ReturnsTrue: Boolean;
begin
  Result := True;
end;

function TTestedClassA.ReturnsTrueFalseAlternately: Boolean;
begin
  FLast := not FLast;
  Result := FLast;
end;

{ TTestedClassB }

function TTestedClassB.RetunesNotFalse: Boolean;
begin
  Result := True;
end;

function TTestedClassB.ReturnsFalseTrueAlternately: Boolean;
begin
  FLast := not FLast;
  Result := FLast;
end;

function TTestedClassB.ReturnsNotTrue: Boolean;
begin
  Result := False;
end;

end.
