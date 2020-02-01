unit HTMLp.HTMLParser;

interface

uses
  HTMLp.DomCore, HTMLp.HTMLReader, HTMLp.HTMLTags;

type
  THTMLParser = class
  private
    FHTMLDocument: TDocument;
    FHTMLReader: THTMLReader;
    FCurrentNode: TNode;
    FCurrentTag: THTMLTag;
    function FindDefParent: TElement;
    function FindParent: TElement;
    function FindParentElement(tagList: THTMLTagSet): TElement;
    function FindTableParent: TElement;
    function FindThisElement: TElement;
    function GetMainElement(const tagName: WideString): TElement;
    procedure ProcessAttributeEnd(Sender: TObject);
    procedure ProcessAttributeStart(Sender: TObject);
    procedure ProcessCDataSection(Sender: TObject);
    procedure ProcessComment(Sender: TObject);
    procedure ProcessDocType(Sender: TObject);
    procedure ProcessElementEnd(Sender: TObject);
    procedure ProcessElementStart(Sender: TObject);
    procedure ProcessEndElement(Sender: TObject);
    procedure ProcessEntityReference(Sender: TObject);
    procedure ProcessScript(Sender: TObject);
    procedure ProcessTextNode(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;

    function ParseString(const htmlStr: WideString): TDocument;
    property HTMLDocument: TDocument read FHTMLDocument;
  end;

implementation

const
  htmlTagName = 'html';
  headTagName = 'head';
  bodyTagName = 'body';

constructor THTMLParser.Create;
begin
  inherited Create;

  FHTMLReader := THTMLReader.Create;
  with FHTMLReader do
  begin
    OnAttributeEnd := ProcessAttributeEnd;
    OnAttributeStart := ProcessAttributeStart;
    OnCDataSection := ProcessCDataSection;
    OnComment := ProcessComment;
    OnDocType := ProcessDocType;
    OnElementEnd := ProcessElementEnd;
    OnElementStart := ProcessElementStart;
    OnEndElement := ProcessEndElement;
    OnEntityReference := ProcessEntityReference;
    OnScript := ProcessScript;
    //OnNotation := ProcessNotation;
    //OnProcessingInstruction := ProcessProcessingInstruction;
    OnTextNode := ProcessTextNode;
  end
end;

destructor THTMLParser.Destroy;
begin
  FHTMLReader.Free;

  inherited Destroy;
end;

function THTMLParser.FindDefParent: TElement;
begin
  if FCurrentTag.Number in [HEAD_TAG, BODY_TAG] then Result := FHTMLDocument.AppendChild(FHTMLDocument.CreateElement(htmlTagName)) as TElement
  else if FCurrentTag.Number in HeadTags then Result := GetMainElement(headTagName)
  else Result := GetMainElement(bodyTagName);
end;

function THTMLParser.FindParent: TElement;
begin
  if (FCurrentTag.Number = P_TAG) or (FCurrentTag.Number in BlockTags) then Result := FindParentElement(BlockParentTags)
  else if FCurrentTag.Number in [LI_TAG] then Result := FindParentElement(ListItemParentTags)
  else if FCurrentTag.Number in [DD_TAG, DT_TAG] then Result := FindParentElement(DefItemParentTags)
  else if FCurrentTag.Number in [TD_TAG, TH_TAG] then Result := FindParentElement(CellParentTags)
  else if FCurrentTag.Number in [TR_TAG] then Result := FindParentElement(RowParentTags)
  else if FCurrentTag.Number in [COL_TAG] then Result := FindParentElement(ColParentTags)
  else if FCurrentTag.Number in [COLGROUP_TAG, THEAD_TAG, TFOOT_TAG, TBODY_TAG] then Result := FindParentElement(TableSectionParentTags)
  else if FCurrentTag.Number in [TABLE_TAG] then Result := FindTableParent
  else if FCurrentTag.Number in [OPTION_TAG] then Result := FindParentElement(OptionParentTags)
  else if FCurrentTag.Number in [HEAD_TAG, BODY_TAG] then Result := FHTMLDocument.DocumentElement as TElement
  else Result := nil;

  if Result = nil then Result := FindDefParent;
end;

function THTMLParser.FindParentElement(tagList: THTMLTagSet): TElement;
var
  Node: TNode;      
  HTMLTag: THTMLTag;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    HTMLTag := HTMLTagList.GetTagByName(Node.Name);

    if HTMLTag.Number in tagList then
    begin
      Result := Node as TElement;
      Exit;
    end;

    Node := Node.ParentNode;
  end;

  Result := nil;
end;

function THTMLParser.FindTableParent: TElement;
var
  Node: TNode;
  HTMLTag: THTMLTag;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    HTMLTag := HTMLTagList.GetTagByName(Node.Name);

    if (HTMLTag.Number = TD_TAG) or (HTMLTag.Number in BlockTags) then
    begin
      Result := (Node as TElement);
      Exit;
    end;

    Node := Node.ParentNode;
  end;

  Result := GetMainElement(bodyTagName);
end;

function THTMLParser.FindThisElement: TElement;
var
  Node: TNode;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    Result := (Node as TElement);
    if Result.TagName = FHTMLReader.Name then Exit;

    Node := Node.ParentNode;
  end;

  Result := nil;
end;

function THTMLParser.GetMainElement(const tagName: WideString): TElement;
var
  child: TNode;
  I: Integer;
begin
  if (FHTMLDocument.DocumentElement = nil) then FHTMLDocument.AppendChild(FHTMLDocument.CreateElement(htmlTagName));

  for I := 0 to FHTMLDocument.DocumentElement.ChildNodes.Count - 1 do
  begin
    child := FHTMLDocument.DocumentElement.ChildNodes.Items[I];

    if (child.NodeType = ELEMENT_NODE) and (child.Name = tagName) then
    begin
      Result := (child as TElement);

      Exit
    end
  end;

  Result := FHTMLDocument.CreateElement(tagName);
  FHTMLDocument.DocumentElement.AppendChild(Result);
end;

procedure THTMLParser.ProcessAttributeEnd(Sender: TObject);
begin
  FCurrentNode := (FCurrentNode as TAttr).OwnerElement;
end;

procedure THTMLParser.ProcessAttributeStart(Sender: TObject);
var
  newAttrName: string;
  Attr: TAttr;
begin
  newAttrName := (Sender as THTMLReader).Name;
  Attr := (FCurrentNode as TElement).GetAttributeNode(newAttrName);

  if not (Assigned(Attr)) then
  begin
    Attr := FHTMLDocument.CreateAttribute(newAttrName);
    (FCurrentNode as TElement).SetAttributeNode(Attr);
  end;

  FCurrentNode := Attr;
end;

procedure THTMLParser.ProcessCDataSection(Sender: TObject);
var
  CDataSection: TCDataSection;
begin
  CDataSection := FHTMLDocument.CreateCDATASection(FHTMLReader.NodeValue);
  FCurrentNode.AppendChild(CDataSection)
end;

procedure THTMLParser.ProcessComment(Sender: TObject);
var
  Comment: TComment;
begin
  Comment := FHTMLDocument.CreateComment(FHTMLReader.NodeValue);
  FCurrentNode.AppendChild(Comment);
end;

procedure THTMLParser.ProcessDocType(Sender: TObject);
begin
  with FHTMLReader do FHTMLDocument.Doctype := DomImplementation.CreateDocumentType(Name, PublicID, SystemID);
end;

procedure THTMLParser.ProcessElementEnd(Sender: TObject);
begin
  if FHTMLReader.isEmptyElement
    or (FCurrentTag.Number in EmptyTags) then FCurrentNode := FCurrentNode.ParentNode;

  FCurrentTag := nil;
end;

procedure THTMLParser.ProcessElementStart(Sender: TObject);
var
  Element: TElement;
  Parent: TNode;
begin
  FCurrentTag := HTMLTagList.GetTagByName(FHTMLReader.Name);
  if FCurrentTag.Number in (NeedFindParentTags + BlockTags) then
  begin
    Parent := FindParent;
    if not Assigned(Parent) then raise DomException.Create(HIERARCHY_REQUEST_ERR);
    FCurrentNode := Parent;
  end;

  Element := FHTMLDocument.CreateElement(FHTMLReader.Name);
  FCurrentNode.AppendChild(Element);
  FCurrentNode := Element;
end;

procedure THTMLParser.ProcessEndElement(Sender: TObject);
var
  Element: TElement;
begin
  Element := FindThisElement;
  if Assigned(Element) then FCurrentNode := Element.ParentNode
  // else if IsBlockTagName(FHtmlReader.nodeName) then raise DomException.Create(HIERARCHY_REQUEST_ERR);
end;

procedure THTMLParser.ProcessEntityReference(Sender: TObject);
var
  EntityReference: TEntityReference;
begin
  EntityReference := FHTMLDocument.CreateEntityReference(FHTMLReader.Name);
  FCurrentNode.AppendChild(EntityReference);
end;

procedure THtmlParser.ProcessScript(Sender: TObject);
var
  Script: TScript;
begin
  Script := FHTMLDocument.CreateScript(FHTMLReader.NodeValue);
  FCurrentNode.AppendChild(Script);
end;

procedure THtmlParser.ProcessTextNode(Sender: TObject);
var
  TextNode: TTextNode;
begin
  TextNode := FHTMLDocument.CreateTextNode(FHTMLReader.NodeValue);
  FCurrentNode.AppendChild(TextNode);
end;

function THTMLParser.ParseString(const htmlStr: WideString): TDocument;
begin
  FHTMLReader.HTMLStr := htmlStr;
  FHTMLDocument := DomImplementation.CreateEmptyDocument(nil);
  FCurrentNode := FHTMLDocument;
  try
    while FHTMLReader.Read do;
  except
    // TODO: Add event ?
  end;

  Result := FHTMLDocument;
end;

end.
