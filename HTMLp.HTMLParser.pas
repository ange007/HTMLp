unit HTMLp.HtmlParser;

interface

uses
  HTMLp.DomCore, HTMLp.HtmlReader, HTMLp.HtmlTags;

type
  THtmlParser = class
  private
    FHtmlDocument: TDocument;
    FHtmlReader: THtmlReader;
    FCurrentNode: TNode;
    FCurrentTag: THtmlTag;
    function FindDefParent: TElement;
    function FindParent: TElement;
    function FindParentElement(tagList: THtmlTagSet): TElement;
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
    property HTMLDocument: TDocument read FHtmlDocument;
  end;

implementation

const
  htmlTagName = 'html';
  headTagName = 'head';
  bodyTagName = 'body';

constructor THtmlParser.Create;
begin
  inherited Create;

  FHtmlReader := THtmlReader.Create;
  with FHtmlReader do
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

destructor THtmlParser.Destroy;
begin
  FHtmlReader.Free;

  inherited Destroy
end;

function THtmlParser.FindDefParent: TElement;
begin
  if FCurrentTag.Number in [HEAD_TAG, BODY_TAG] then Result := FHtmlDocument.AppendChild(FHtmlDocument.CreateElement(htmlTagName)) as TElement
  else if FCurrentTag.Number in HeadTags then Result := GetMainElement(headTagName)
  else Result := GetMainElement(bodyTagName)
end;

function THtmlParser.FindParent: TElement;
begin
  if (FCurrentTag.Number = P_TAG) or (FCurrentTag.Number in BlockTags) then Result := FindParentElement(BlockParentTags)
  else if FCurrentTag.Number = LI_TAG then Result := FindParentElement(ListItemParentTags)
  else if FCurrentTag.Number in [DD_TAG, DT_TAG] then Result := FindParentElement(DefItemParentTags)
  else if FCurrentTag.Number in [TD_TAG, TH_TAG] then Result := FindParentElement(CellParentTags)
  else if FCurrentTag.Number = TR_TAG then Result := FindParentElement(RowParentTags)
  else if FCurrentTag.Number = COL_TAG then Result := FindParentElement(ColParentTags)
  else if FCurrentTag.Number in [COLGROUP_TAG, THEAD_TAG, TFOOT_TAG, TBODY_TAG] then Result := FindParentElement(TableSectionParentTags)
  else if FCurrentTag.Number = TABLE_TAG then Result := FindTableParent
  else if FCurrentTag.Number = OPTION_TAG then Result := FindParentElement(OptionParentTags)
  else if FCurrentTag.Number in [HEAD_TAG, BODY_TAG] then Result := FHtmlDocument.DocumentElement as TElement
  else Result := nil;

  if Result = nil then Result := FindDefParent
end;

function THtmlParser.FindParentElement(tagList: THtmlTagSet): TElement;
var
  Node: TNode;      
  HtmlTag: THtmlTag;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    HtmlTag := HtmlTagList.GetTagByName(Node.Name);

    if HtmlTag.Number in tagList then
    begin
      Result := Node as TElement;
      Exit
    end;

    Node := Node.ParentNode
  end;

  Result := nil
end;

function THtmlParser.FindTableParent: TElement;
var
  Node: TNode;
  HtmlTag: THtmlTag;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    HtmlTag := HtmlTagList.GetTagByName(Node.Name);

    if (HtmlTag.Number = TD_TAG) or (HtmlTag.Number in BlockTags) then
    begin
      Result := (Node as TElement);
      Exit
    end;

    Node := Node.ParentNode
  end;

  Result := GetMainElement(bodyTagName)
end;

function THtmlParser.FindThisElement: TElement;
var
  Node: TNode;
begin
  Node := FCurrentNode;

  while Node.NodeType = ELEMENT_NODE do
  begin
    Result := (Node as TElement);
    if Result.TagName = FHtmlReader.Name then Exit;

    Node := Node.ParentNode
  end;

  Result := nil
end;

function THtmlParser.GetMainElement(const tagName: WideString): TElement;
var
  child: TNode;
  I: Integer;
begin
  if FHtmlDocument.DocumentElement = nil then FHtmlDocument.AppendChild(FHtmlDocument.CreateElement(htmlTagName));

  for I := 0 to FHtmlDocument.DocumentElement.ChildNodes.Count - 1 do
  begin
    child := FHtmlDocument.DocumentElement.ChildNodes.Items[I];

    if (child.NodeType = ELEMENT_NODE) and (child.Name = tagName) then
    begin
      Result := (child as TElement);

      Exit
    end
  end;

  Result := FHtmlDocument.CreateElement(tagName);
  FHtmlDocument.DocumentElement.AppendChild(Result)
end;

procedure THtmlParser.ProcessAttributeEnd(Sender: TObject);
begin
  FCurrentNode := (FCurrentNode as TAttr).OwnerElement
end;

procedure THtmlParser.ProcessAttributeStart(Sender: TObject);
var
  Attr: TAttr;
begin
  Attr := FHtmlDocument.CreateAttribute((Sender as THtmlReader).Name);
  (FCurrentNode as TElement).SetAttributeNode(Attr);
  FCurrentNode := Attr;
end;

procedure THtmlParser.ProcessCDataSection(Sender: TObject);
var
  CDataSection: TCDataSection;
begin
  CDataSection := FHtmlDocument.CreateCDATASection(FHtmlReader.NodeValue);
  FCurrentNode.AppendChild(CDataSection)
end;

procedure THtmlParser.ProcessComment(Sender: TObject);
var
  Comment: TComment;
begin
  Comment := FHtmlDocument.CreateComment(FHtmlReader.NodeValue);
  FCurrentNode.AppendChild(Comment)
end;

procedure THtmlParser.ProcessDocType(Sender: TObject);
begin
  with FHtmlReader do FHtmlDocument.Doctype := DomImplementation.CreateDocumentType(Name, PublicID, SystemID);
end;

procedure THtmlParser.ProcessElementEnd(Sender: TObject);
begin
  if FHtmlReader.isEmptyElement or (FCurrentTag.Number in EmptyTags) then FCurrentNode := FCurrentNode.ParentNode;
  FCurrentTag := nil
end;

procedure THtmlParser.ProcessElementStart(Sender: TObject);
var
  Element: TElement;
  Parent: TNode;
begin
  FCurrentTag := HtmlTagList.GetTagByName(FHtmlReader.Name);
  if FCurrentTag.Number in NeedFindParentTags + BlockTags then
  begin
    Parent := FindParent;
    if not Assigned(Parent) then raise DomException.Create(HIERARCHY_REQUEST_ERR);
    FCurrentNode := Parent
  end;

  Element := FHtmlDocument.CreateElement(FHtmlReader.Name);
  FCurrentNode.AppendChild(Element);
  FCurrentNode := Element
end;

procedure THtmlParser.ProcessEndElement(Sender: TObject);
var
  Element: TElement;
begin
  Element := FindThisElement;
  if Assigned(Element) then
    FCurrentNode := Element.ParentNode
{  else
  if IsBlockTagName(FHtmlReader.nodeName) then
    raise DomException.Create(HIERARCHY_REQUEST_ERR)}
end;

procedure THtmlParser.ProcessEntityReference(Sender: TObject);
var
  EntityReference: TEntityReference;
begin
  EntityReference := FHtmlDocument.CreateEntityReference(FHtmlReader.Name);
  FCurrentNode.AppendChild(EntityReference)
end;

procedure THtmlParser.ProcessScript(Sender: TObject);
var
  Script: TScript;
begin
  Script := FHtmlDocument.CreateScript(FHtmlReader.NodeValue);
  FCurrentNode.AppendChild(Script);
end;

procedure THtmlParser.ProcessTextNode(Sender: TObject);
var
  TextNode: TTextNode;
begin
  TextNode := FHtmlDocument.CreateTextNode(FHtmlReader.NodeValue);
  FCurrentNode.AppendChild(TextNode)
end;

function THtmlParser.ParseString(const htmlStr: WideString): TDocument;
begin
  FHtmlReader.HTMLStr := htmlStr;
  FHtmlDocument := DomImplementation.CreateEmptyDocument(nil);
  FCurrentNode := FHtmlDocument;
  try
    while FHtmlReader.Read do;
  except
    // TODO: Add event ?
  end;

  Result := FHtmlDocument
end;

end.
