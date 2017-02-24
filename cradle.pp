program cradle;
const TAB = ^I;
var Look : char;
procedure GetChar;
begin
	Read(Look);
end;
procedure Error (s : string);
begin
	WriteLn;
	WriteLn (^G, 'Error:[', s, '.');
end;
procedure Abort (s : string);
begin
	Error(s);
	Halt;
end;
procedure Expected (s : string);
begin
	Abort(s +  'Expected');
end;

procedure Match ( x : char );
begin
	if Look = x then GetChar
	else Expected (' " ' + x + ' " ');
end;
function IsAlpha(c : char) : boolean;
begin
	IsAlpha := UpCase(c) in ['A'..'Z'];
end;
function IsDigit(c : char) : boolean;
begin
	IsDigit := c in ['0'..'9'];
end;
function GetName : char;
begin
	if not IsAlpha(Look) then Expected ('Name');
	GetName := UpCase(Look);
	GetChar;
end;
function GetNum : char;
begin
	if not IsDigit(Look) then Expected ('Integer');
	GetNum := Look;
	GetChar;
end;
procedure Emit (s : string);
begin
	Write(TAB,s);
end;
procedure EmitLn (s : string);
begin
	Emit(s);
	WriteLn;
end;
procedure Init;
begin
	GetChar;
end;
procedure Factor;
begin
	EmitLn('MOVE_#' + GetNum + ',D0')
end;
procedure Multiply;
begin
	Match('*');
	Factor;
	EmitLn('MUL_(SP)+, D0');
end;
procedure Divide;
begin
	Match('/');
	Factor;
	EmitLn('MOVE_(SP)+,D1');
	EmitLn('DIVS_D1,D0');
end;
procedure Term;
begin
	Factor;
	while Look in ['*','/'] do begin
		EmitLn('MOVE_D0,-(SP)');
		case Look of
			'*': Multiply;
			'/': Divide;
		end;
	end;
end;
procedure Add;
begin
	Match('+');
	Term;
	EmitLn('ADD_(SP)+,D0');
end;		
procedure Subtract;

begin
	Match('-');
	Term;
	EmitLn('SUB_(SP)+,D0');
	EmitLn('NEG_D0')
end;
function IsAddop(c: char): boolean;
begin
	IsAddop := c in ['+','-'];
end;
procedure Expression;
begin
	if IsAddop(Look)
		EmitLn("CLR_D0")
	else
		Term;
	while Look in ['+','-'] do begin
		EmitLn('MOVE_D0, -(SP)');
		case Look of
			'+' : Add;
			'-'	: Subtract;
		end;
	end;
end;

procedure Expression; Forward;
procedure Factor;
begin
	if Look  = '(' then begin
		Match('(');
		Expression;
		Match(')');
	        end
        else if IsAlpha(Look)
           Ident
	else
		EmitLn('MOVE_' + GetNum + ',D0');
end;

procedure Ident;
begin
var Name := char
Name := GetName
if Look = '('  then begin
   Match('(');
   Match(')');
   EmitLn('BSR_' + Name)
   end
else
    EmitLn('MOVE_' + Name + '(PC), D0');

end;

begin
	
	Init;
	Expression;
end.
