unit HTMLp.Helper;

interface

uses System.Classes, System.SysUtils, System.StrUtils, System.Math, System.Variants, System.Types,
      System.Generics.Collections,

      HTMLp.DomCore, HTMLp.Formatter,
      HTMLp.HtmlParser;

type
  TNode = HTMLp.DomCore.TNode;
  TNodeList = HTMLp.DomCore.TNodeList;
  TElement = HTMLp.DomCore.TElement;

  IHTMLParser = interface
  ['{A2496DE9-17B0-40FC-A804-D19363A14154}']
    function Find(const selector: string): IHTMLParser;
    function Map(callback: TProc<Integer, TElement>): IHTMLParser;
    {}
    function GetRootNode: TElement;
    function GetFirstNode: TElement;
    function GetLastNode: TElement;
    function GetNodeCount: Integer;
    function GetNodeList: TNodeList;
    function Clear: IHTMLParser;
    {}
    property RootNode: TElement read GetRootNode;
    property NodeList: TNodeList read GetNodeList;
    property NodeCount: Integer read GetNodeCount;
  end;

  THTMLParserHelper = class(TInterfacedObject, IHTMLParser)
  private
    FDocument: TDocument;
    FCurrentNodeList: TNodeList;
    FCurrentElement: TElement;
    FNodeList: TList<TNodeList>;
  public
    constructor Create(const HTML: string); overload;
    destructor Destroy; override;

    function Find(const selector: string): IHTMLParser;
    function SelectNode(const nodeIndex: Integer): IHTMLParser;
    function Map(callback: TProc<Integer, TElement>): IHTMLParser;

    function GetRootNode: TElement;
    function GetFirstNode: TElement;
    function GetLastNode: TElement;
    function GetNodeCount: Integer;
    function GetNodeList: TNodeList;
    function Clear: IHTMLParser;

    property RootNode: TElement read GetRootNode;
    property NodeList: TNodeList read GetNodeList;
    property NodeCount: Integer read GetNodeCount;
  end;

function ParseHTML(const HTML: string): IHTMLParser;

implementation

function ParseHTML(const HTML: string): IHTMLParser;
begin
  Result := THTMLParserHelper.Create(HTML);
end;

constructor THTMLParserHelper.Create(const HTML: string);
begin
  inherited Create;

  {}
  with THTMLParser.Create do
  begin
    FDocument := parseString(HTML);
    FCurrentElement := GetRootNode;

    Free;
  end;

  {}
  FNodeList := TList<TNodeList>.Create;
end;

destructor THTMLParserHelper.Destroy;
begin
  Clear;

  FreeAndNil(FNodeList);
  FreeAndNil(FDocument);

  inherited;
end;

function THTMLParserHelper.Find(const selector: string): IHTMLParser;
begin
  Result := Self;

  if Pos('/', selector) = 1 then FCurrentNodeList := FCurrentElement.GetElementsByXPath(selector)
  else FCurrentNodeList := FCurrentElement.GetElementsByCSSSelector(selector);

  FNodeList.Add(FCurrentNodeList);
end;

function THTMLParserHelper.SelectNode(const nodeIndex: Integer): IHTMLParser;
begin
  Result := Self;
  if nodeIndex >= FCurrentNodeList.Count then Exit;

  FCurrentElement := (FCurrentNodeList[nodeIndex] as TElement);
end;

function THTMLParserHelper.Map(callback: TProc<Integer, TElement>): IHTMLParser;
var
  i: Integer;
begin
  Result := Self;
  if not (Assigned(FCurrentNodeList)) then Exit;

  for i := 0 to FCurrentNodeList.Count - 1 do callback(i, (FCurrentNodeList[i] as TElement));
end;

function THTMLParserHelper.GetRootNode: TElement;
begin
  Result := FDocument.DocumentElement;
end;

function THTMLParserHelper.GetFirstNode: TElement;
var
  node: TNode;
begin
  Result := nil;

  node := FCurrentNodeList.GetFirst;
  if Assigned(node) then Result := (node as TElement);
end;

function THTMLParserHelper.GetLastNode: TElement;
var
  node: TNode;
begin
  Result := nil;

  node := FCurrentNodeList.GetLast;
  if Assigned(node) then Result := (node as TElement);
end;

function THTMLParserHelper.GetNodeCount: Integer;
begin
  Result := FCurrentNodeList.Count;
end;

function THTMLParserHelper.GetNodeList: TNodeList;
begin
  Result := FCurrentNodeList;
end;

function THTMLParserHelper.Clear: IHTMLParser;
var
  i: Integer;
begin
  for i := 0 to FNodeList.Count - 1 do FNodeList[i].Destroy;
  FNodeList.Clear;

  Result := Self;
end;

end.

