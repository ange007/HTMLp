unit HTMLp.HtmlReader;

interface

uses
  Classes,

  HTMLp.DomCore;

type
  TDelimiters = set of Byte;
  TReaderState = (rsInitial, rsBeforeAttr, rsBeforeValue, rsInValue, rsInQuotedValue);

  THtmlReader = class
  private
    FHtmlStr: string;
    FPosition: Integer;
    FNodeType: Integer;
    FPrefix: string;
    FLocalName: string;
    FNodeValue: string;
    FPublicID: string;
    FSystemID: string;
    FIsEmptyElement: Boolean;
    FState: TReaderState;
    FQuotation: Word;
    FOnAttributeEnd: TNotifyEvent;
    FOnAttributeStart: TNotifyEvent;
    FOnCDataSection: TNotifyEvent;
    FOnComment: TNotifyEvent;
    FOnDocType: TNotifyEvent;
    FOnElementEnd: TNotifyEvent;
    FOnElementStart: TNotifyEvent;
    FOnEndElement: TNotifyEvent;
    FOnEntityReference: TNotifyEvent;
    FOnNotation: TNotifyEvent;
    FOnProcessingInstruction: TNotifyEvent;
    FOnScript: TNotifyEvent;
    FOnTextNode: TNotifyEvent;
    function GetNodeName: string;
    function GetToken(Delimiters: TDelimiters): string;
    function IsAttrTextChar: Boolean;
    function IsDigit(HexBase: Boolean): Boolean;
    function IsEndEntityChar: Boolean;
    function IsEntityChar: Boolean;
    function IsEqualChar: Boolean;
    function IsHexEntityChar: Boolean;
    function IsNumericEntity: Boolean;
    function IsQuotation: Boolean;
    function IsSlashChar: Boolean;
    function IsSpecialTagChar: Boolean;
    function IsStartCharacterData: Boolean;
    function IsStartComment: Boolean;
    function IsStartDocumentType: Boolean;
    function IsStartEntityChar: Boolean;
    function IsStartMarkupChar: Boolean;
    function IsStartScript: Boolean;
    function IsStartTagChar: Boolean;
    function Match(const Signature: string; IgnoreCase: Boolean): Boolean;
    function ReadAttrNode: Boolean;
    function ReadAttrTextNode: Boolean;
    function ReadCharacterData: Boolean;
    function ReadComment: Boolean;
    function ReadDocumentType: Boolean;
    function ReadElementNode: Boolean;
    function ReadEndElementNode: Boolean;
    function ReadEntityNode: Boolean;
    function ReadNamedEntityNode: Boolean;
    function ReadNumericEntityNode: Boolean;
    function ReadQuotedValue(var Value: string): Boolean;
    function ReadScript: Boolean;
    function ReadSpecialNode: Boolean;
    function ReadTagNode: Boolean;
    function ReadValueNode: Boolean;
    function SkipTo(const Signature: string): Boolean;
    procedure FireEvent(Event: TNotifyEvent);
    procedure ReadElementTail;
    procedure ReadTextNode;
    procedure SetHtmlStr(const Value: string);
    procedure SetNodeName(Value: string);
    procedure SkipWhiteSpaces;
  public
    constructor Create;
    function Read: Boolean;

    property HTMLStr: string read FHtmlStr write SetHtmlStr;
    property isEmptyElement: Boolean read FIsEmptyElement;
    property LocalName: string read FLocalName;
    property Name: string read GetNodeName;
    property NodeType: Integer read FNodeType;
    property Position: Integer read FPosition;
    property Prefix: string read FPrefix;
    property PublicID: string read FPublicID;
    property State: TReaderState read FState;
    property SystemID: string read FSystemID;
    property NodeValue: string read FNodeValue;
    property OnAttributeEnd: TNotifyEvent read FOnAttributeEnd write FOnAttributeEnd;
    property OnAttributeStart: TNotifyEvent read FOnAttributeStart write FOnAttributeStart;
    property OnCDataSection: TNotifyEvent read FOnCDataSection write FOnCDataSection;
    property OnComment: TNotifyEvent read FOnComment write FOnComment;
    property OnDocType: TNotifyEvent read FOnDocType write FOnDocType;
    property OnElementEnd: TNotifyEvent read FOnElementEnd write FOnElementEnd;
    property OnElementStart: TNotifyEvent read FOnElementStart write FOnElementStart;
    property OnEndElement: TNotifyEvent read FOnEndElement write FOnEndElement;
    property OnEntityReference: TNotifyEvent read FOnEntityReference write FOnEntityReference;
    property OnNotation: TNotifyEvent read FOnNotation write FOnNotation;
    property OnProcessingInstruction: TNotifyEvent read FOnProcessingInstruction write FOnProcessingInstruction;
    property OnScript: TNotifyEvent read FOnScript write FOnScript;
    property OnTextNode: TNotifyEvent read FOnTextNode write FOnTextNode;
  end;

implementation

uses
  SysUtils;

const
  startTagChar = Ord('<');
  endTagChar = Ord('>');
  specialTagChar = Ord('!');
  slashChar = Ord('/');
  equalChar = Ord('=');
  quotation = [Ord(''''), Ord('"')];
  tagDelimiter = [slashChar, endTagChar];
  tagNameDelimiter = whiteSpace + tagDelimiter;
  attrNameDelimiter = tagNameDelimiter + [equalChar];
  startEntity = Ord('&');
  startMarkup = [startTagChar, startEntity];
  endEntity = Ord(';');
  notEntity = [endEntity] + startMarkup + whiteSpace;
  notAttrText = whiteSpace + quotation + tagDelimiter;
  numericEntity = Ord('#');
  hexEntity = [Ord('x'), Ord('X')];
  decDigit = [Ord('0')..Ord('9')];
  hexDigit = [Ord('a')..Ord('f'), Ord('A')..Ord('F')];

  DocTypeStartStr = 'DOCTYPE';
  DocTypeEndStr = '>';
  CDataStartStr = '[CDATA[';
  CDataEndStr = ']]>';
  CommentStartStr = '--';
  CommentEndStr = '-->';
  ScriptStartStr = 'script';
  ScriptEndStr = '</script>';

function DecValue(const Digit: WideChar): Word;
begin
  Result := Ord(Digit) - Ord('0')
end;

function HexValue(const HexChar: WideChar): Word;
var
  C: Char;
begin
  if Ord(HexChar) in decDigit then Result := Ord(HexChar) - Ord('0')
  else
  begin
    C := UpCase(Chr(Ord(HexChar)));
    Result := Ord(C) - Ord('A');
  end
end;

constructor THtmlReader.Create;
begin
  inherited Create;
  FHtmlStr := HTMLStr;
  FPosition := 1
end;

function THtmlReader.GetNodeName: string;
begin
  if FPrefix <> '' then
    Result := FPrefix + ':' + FLocalName
  else
    Result := FLocalName
end;

function THtmlReader.GetToken(Delimiters: TDelimiters): string;
var
  Start: Integer;
begin
  Start := FPosition;
  while (FPosition <= Length(FHtmlStr)) and not (Ord(FHtmlStr[FPosition]) in Delimiters) do
    Inc(FPosition);
  Result := Copy(FHtmlStr, Start, FPosition - Start)
end;

function THtmlReader.IsAttrTextChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  if FState = rsInQuotedValue then
    Result := (Ord(WC) <> FQuotation) and (Ord(WC) <> startEntity)
  else
    Result := not (Ord(WC) in notAttrText)
end;

function THtmlReader.IsDigit(HexBase: Boolean): Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) in decDigit;
  if not Result and HexBase then
    Result := Ord(WC) in hexDigit
end;

function THtmlReader.IsEndEntityChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = endEntity
end;

function THtmlReader.IsEntityChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := not (Ord(WC) in notEntity)
end;

function THtmlReader.IsEqualChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = equalChar
end;

function THtmlReader.IsHexEntityChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) in hexEntity
end;

function THtmlReader.IsNumericEntity: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = numericEntity
end;

function THtmlReader.IsQuotation: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  if FQuotation = 0 then
    Result := Ord(WC) in quotation
  else
    Result := Ord(WC) = FQuotation
end;

function THtmlReader.IsSlashChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = slashChar
end;

function THtmlReader.IsSpecialTagChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = specialTagChar
end;

function THtmlReader.IsStartCharacterData: Boolean;
begin    
  Result := Match(CDataStartStr, false)
end;

function THtmlReader.IsStartComment: Boolean;
begin
  Result := Match(CommentStartStr, false)
end;

function THtmlReader.IsStartDocumentType: Boolean;
begin
  Result := Match(DocTypeStartStr, true)
end;

function THtmlReader.IsStartEntityChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = startEntity
end;

function THtmlReader.IsStartMarkupChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) in startMarkup
end;

function THtmlReader.IsStartScript: Boolean;
begin
  Result := Match(ScriptStartStr, true);
end;

function THtmlReader.IsStartTagChar: Boolean;
var
  WC: WideChar;
begin
  WC := FHtmlStr[FPosition];
  Result := Ord(WC) = startTagChar
end;

function THtmlReader.Match(const Signature: string; IgnoreCase: Boolean): Boolean;
var
  I, J: Integer;
  W1, W2: WideChar;
begin
  Result := False;

  for I := 1 to Length(Signature) do
  begin
    J := FPosition + I - 1;
    if (J < 1) or (J > Length(FHtmlStr)) then Exit;
    W1 := Signature[I];
    W2 := FHtmlStr[J];
    if (W1 <> W2) and (not IgnoreCase or (UpperCase(W1) <> UpperCase(W2))) then Exit
  end;

  Result := True;
end;

function THtmlReader.ReadAttrNode: Boolean;
var
  AttrName: string;
begin
  Result := False;
  SkipWhiteSpaces;
  AttrName := LowerCase(GetToken(attrNameDelimiter));
  if AttrName = '' then Exit;

  SetNodeName(AttrName);
  FireEvent(FOnAttributeStart);

  FState := rsBeforeValue;
  FQuotation := 0;

  Result := True;
end;

function THtmlReader.ReadAttrTextNode: Boolean;
var
  Start: Integer;
begin
  Result := False;
  Start := FPosition;

  while (FPosition <= Length(FHtmlStr)) and (IsAttrTextChar) do Inc(FPosition);
  if FPosition = Start then Exit;

  FNodeType := TEXT_NODE;
  FNodeValue:= Copy(FHtmlStr, Start, FPosition - Start);
  FireEvent(FOnTextNode);

  Result := True;
end;

function THtmlReader.ReadCharacterData: Boolean;
var
  StartPos: Integer;
begin
  Inc(FPosition, Length(CDataStartStr));
  StartPos := FPosition;
  Result := SkipTo(CDataEndStr);
  if Result then
  begin
    FNodeType := CDATA_SECTION_NODE;
    FNodeValue := Copy(FHtmlStr, StartPos, FPosition - StartPos - Length(CDataEndStr));
    FireEvent(FOnCDataSection)
  end
end;

function THtmlReader.ReadComment: Boolean;
var
  StartPos: Integer;
begin
  Inc(FPosition, Length(CommentStartStr));
  StartPos := FPosition;
  Result := SkipTo(CommentEndStr);
  if Result then
  begin
    FNodeType := COMMENT_NODE;
    FNodeValue := Copy(FHtmlStr, StartPos, FPosition - StartPos - Length(CommentEndStr));
    FireEvent(FOnComment)
  end
end;

function THtmlReader.ReadDocumentType: Boolean;
var
  Name: string;
begin
  Result := False;

  Inc(FPosition, Length(DocTypeStartStr));
  SkipWhiteSpaces;
  Name := GetToken(tagNameDelimiter);
  if Name = '' then Exit;

  SetNodeName(Name);
  SkipWhiteSpaces;
  GetToken(tagNameDelimiter);
  SkipWhiteSpaces;
  if ((FHtmlStr[FPosition] = '"') or (FHtmlStr[FPosition] = '''')) and not (ReadQuotedValue(FPublicID)) then Exit;

  SkipWhiteSpaces;
  if FHtmlStr[FPosition] = '"' then
  begin
    if not ReadQuotedValue(FSystemID) then Exit
  end;

  Result := SkipTo(DocTypeEndStr)
end;

function THtmlReader.ReadElementNode: Boolean;
var
  TagName: string;
begin
  Result := False;

  if FPosition < Length(FHtmlStr) then
  begin
    TagName := LowerCase(GetToken(tagNameDelimiter));
    if TagName = '' then Exit;

    FNodeType := ELEMENT_NODE;
    SetNodeName(TagName);

    FState := rsBeforeAttr;
    FireEvent(FOnElementStart);
    Result := True;
  end
end;

function THtmlReader.ReadEndElementNode: Boolean;
var
  TagName: string;
begin
  Result := False;
  Inc(FPosition);
  if FPosition > Length(FHtmlStr) then Exit;

  TagName := LowerCase(GetToken(tagNameDelimiter));
  if TagName = '' then Exit;

  Result := SkipTo(WideChar(endTagChar));
  if Result then
  begin
    FNodeType := END_ELEMENT_NODE;  
    SetNodeName(TagName);
    FireEvent(FOnEndElement);
    Result := True;
  end
end;

function THtmlReader.ReadEntityNode: Boolean;
var
  CurrPos: Integer;
begin
  Result := False;
  CurrPos := FPosition;
  Inc(FPosition);
  if FPosition > Length(FHtmlStr) then Exit;

  if IsNumericEntity then
  begin
    Inc(FPosition);
    Result := ReadNumericEntityNode
  end
  else Result := ReadNamedEntityNode;

  if Result then
  begin
    FNodeType := ENTITY_REFERENCE_NODE;
    // FireEvent(FOnEntityReference);  VVV - remove, entity node is added in ReadXXXEntityNode
  end
  else FPosition := CurrPos
end;

function THtmlReader.ReadNamedEntityNode: Boolean;
var
  Start: Integer;
begin    
  Result := False;
  if FPosition > Length(FHtmlStr) then Exit;

  Start := FPosition;
  while (FPosition <= Length(FHtmlStr)) and IsEntityChar do Inc(FPosition);
  if (FPosition > Length(FHtmlStr)) or not IsEndEntityChar then Exit;

  FNodeType := ENTITY_REFERENCE_NODE;
  SetNodeName(Copy(FHtmlStr, Start, FPosition - Start));
  Inc(FPosition);

  FireEvent(FOnEntityReference);
  Result := True;
end;

function THtmlReader.ReadNumericEntityNode: Boolean;
var
  Value: Word;
  HexBase: Boolean;
begin
  Result := False;
  if FPosition > Length(FHtmlStr) then Exit;

  HexBase := IsHexEntityChar;
  if HexBase then Inc(FPosition);

  Value := 0;
  while (FPosition <= Length(FHtmlStr)) and IsDigit(HexBase) do
  begin
    try
      if HexBase then Value := Value * 16 + HexValue(FHtmlStr[FPosition])
      else Value := Value * 10 + DecValue(FHtmlStr[FPosition])
    except
      Exit
    end;

    Inc(FPosition);
  end;

  if (FPosition > Length(FHtmlStr)) or not IsEndEntityChar then Exit;
  Inc(FPosition);
  FNodeType := TEXT_NODE;
  FNodeValue := WideChar(Value);
  FireEvent(FOnTextNode);
  Result := True;
end;

function THtmlReader.ReadQuotedValue(var Value: string): Boolean;
var
  QuotedChar: WideChar;
  Start: Integer;
begin
  QuotedChar := FHtmlStr[FPosition];
  Inc(FPosition);
  Start := FPosition;
  Result := SkipTo(QuotedChar);
  if Result then Value := Copy(FHtmlStr, Start, FPosition - Start);
end;

function THtmlReader.ReadScript: Boolean;
var
  StartPos: Integer;
begin
  Inc(FPosition, Length(ScriptStartStr));
  StartPos := FPosition;
  Result := SkipTo(ScriptEndStr);
  if Result then
  begin
    FNodeType := SCRIPT_NODE;
    FNodeValue := Copy(FHtmlStr, StartPos, FPosition - StartPos - Length(ScriptEndStr));
    FireEvent(FOnScript)
  end
end;

function THtmlReader.ReadSpecialNode: Boolean;
begin
  Result := False;

  Inc(FPosition);
  if FPosition > Length(FHtmlStr) then Exit;

  if IsStartDocumentType then Result := ReadDocumentType
  else if IsStartCharacterData then Result := ReadCharacterData
  else if IsStartComment then Result := ReadComment;
end;

function THtmlReader.ReadTagNode: Boolean;
var
  CurrPos: Integer;
begin
  Result := False;

  CurrPos := FPosition;
  Inc(FPosition);
  if FPosition > Length(FHtmlStr) then Exit;

  if IsSlashChar then Result := ReadEndElementNode
  else if IsSpecialTagChar then Result := ReadSpecialNode
  else if IsStartScript then Result := ReadScript
  else Result := ReadElementNode;

  if not Result then FPosition := CurrPos;
end;

function THtmlReader.SkipTo(const Signature: string): Boolean;
begin
  while FPosition <= Length(FHtmlStr) do
  begin
    if Match(Signature, False) then
    begin
      Inc(FPosition, Length(Signature));
      Result := True;
      Exit
    end;

    Inc(FPosition)
  end;

  Result := False;
end;

procedure THtmlReader.FireEvent(Event: TNotifyEvent);
begin
  if Assigned(Event) then Event(Self);
end;

function THtmlReader.Read: Boolean;
begin
  FNodeType := NONE;
  FPrefix := '';
  FLocalName := '';
  FNodeValue := '';
  FPublicID := '';
  FSystemID := '';
  FIsEmptyElement := False;
  Result := False;

  if FPosition > Length(FHtmlStr) then Exit;
  Result := True;

  if FState in [rsBeforeValue, rsInValue, rsInQuotedValue] then
  begin
    if ReadValueNode then Exit;
    if FState = rsInQuotedValue then Inc(FPosition);
    FNodeType := ATTRIBUTE_NODE;
    FireEvent(FOnAttributeEnd);
    FState := rsBeforeAttr
  end
  else if FState = rsBeforeAttr then
  begin
    if ReadAttrNode then Exit;
    ReadElementTail;
    FState := rsInitial;
  end
  else if IsStartTagChar then
  begin
    if ReadTagNode then Exit;
    Inc(FPosition);
    FNodeType := ENTITY_REFERENCE_NODE;
    SetNodeName('lt');
    FireEvent(FOnEntityReference);
  end
  else if IsStartEntityChar then
  begin
    if ReadEntityNode then Exit;
    Inc(FPosition);
    FNodeType := ENTITY_REFERENCE_NODE;
    SetNodeName('amp');
    FireEvent(FOnEntityReference)
  end
  else ReadTextNode;
end;

procedure THtmlReader.ReadTextNode;
var
  Start: Integer;
begin
  Start := FPosition;
  repeat
    Inc(FPosition)
  until (FPosition > Length(FHtmlStr)) or IsStartMarkupChar;
  FNodeType := TEXT_NODE;
  FNodeValue:= Copy(FHtmlStr, Start, FPosition - Start);
  FireEvent(FOnTextNode)
end;

function THtmlReader.ReadValueNode: Boolean;
begin
  Result := False;
  if FState = rsBeforeValue then
  begin
    SkipWhiteSpaces;
    if FPosition > Length(FHtmlStr) then Exit;
    if not IsEqualChar then Exit;

    Inc(FPosition);
    SkipWhiteSpaces;
    if FPosition > Length(FHtmlStr) then Exit;

    if IsQuotation then
    begin
      FQuotation := Ord(FHtmlStr[FPosition]);
      Inc(FPosition);
      FState := rsInQuotedValue
    end
    else FState := rsInValue
  end;

  if FPosition > Length(FHtmlStr) then Exit;

  if IsStartEntityChar then
  begin
    Result := True;
    if ReadEntityNode then Exit;

    Inc(FPosition);
    FNodeType := ENTITY_REFERENCE_NODE;

    SetNodeName('amp');
    FireEvent(FOnEntityReference)
  end
  else Result := ReadAttrTextNode
end;

procedure THtmlReader.ReadElementTail;
begin
  SkipWhiteSpaces;
  if (FPosition <= Length(FHtmlStr)) and (IsSlashChar) then
  begin
    FIsEmptyElement := True;
    Inc(FPosition)
  end;

  SkipTo(WideChar(endTagChar));
  FNodeType := ELEMENT_NODE;
  FireEvent(FOnElementEnd)
end;
                                 
procedure THtmlReader.SetHtmlStr(const Value: string);
begin
  FHtmlStr := Value;
  FPosition := 1;
end;

procedure THtmlReader.SetNodeName(Value: string);
var
  I: Integer;
begin
  I := Pos(':', Value);

  if I > 0 then
  begin
    FPrefix := Copy(Value, 1, I - 1);
    FLocalName := Copy(Value, I + 1, Length(Value) - I);
  end
  else
  begin
    FPrefix := '';
    FLocalName := Value;
  end
end;

procedure THtmlReader.SkipWhiteSpaces;
begin
  while (FPosition <= Length(FHtmlStr))
    and (Ord(FHtmlStr[FPosition]) in whiteSpace) do Inc(FPosition);
end;

end.
