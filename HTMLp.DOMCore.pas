unit HTMLp.DomCore;

interface

uses
  Classes, SysUtils, StrUtils, RegularExpressions, Math;

const
  TAB = 9;
  LF = 10;
  CR = 13;
  SP = 32;

  WhiteSpace = [TAB, LF, CR, SP];

  NONE                           = 0;  // extension
  ELEMENT_NODE                   = 1;
  ATTRIBUTE_NODE                 = 2;
  TEXT_NODE                      = 3;
  CDATA_SECTION_NODE             = 4;
  ENTITY_REFERENCE_NODE          = 5;
  ENTITY_NODE                    = 6;
  PROCESSING_INSTRUCTION_NODE    = 7;
  COMMENT_NODE                   = 8;
  DOCUMENT_NODE                  = 9;
  DOCUMENT_TYPE_NODE             = 10;
  DOCUMENT_FRAGMENT_NODE         = 11;
  NOTATION_NODE                  = 12;
  SCRIPT_NODE                    = 13;

  END_ELEMENT_NODE               = 255; // extension

  INDEX_SIZE_ERR                 = 1;
  DOMSTRING_SIZE_ERR             = 2;
  HIERARCHY_REQUEST_ERR          = 3;
  WRONG_DOCUMENT_ERR             = 4;
  INVALID_CHARACTER_ERR          = 5;
  NO_DATA_ALLOWED_ERR            = 6;
  NO_MODIFICATION_ALLOWED_ERR    = 7;
  NOT_FOUND_ERR                  = 8;
  NOT_SUPPORTED_ERR              = 9;
  INUSE_ATTRIBUTE_ERR            = 10;
  INVALID_STATE_ERR              = 11;
  SYNTAX_ERR                     = 12;
  INVALID_MODIFICATION_ERR       = 13;
  NAMESPACE_ERR                  = 14;
  INVALID_ACCESS_ERR             = 15;

  {HTML DTDs}
  DTD_HTML_STRICT    = 1;
  DTD_HTML_LOOSE     = 2;
  DTD_HTML_FRAMESET  = 3;
  DTD_XHTML_STRICT   = 4;
  DTD_XHTML_LOOSE    = 5;
  DTD_XHTML_FRAMESET = 6;
  
type
  DomException = class(Exception)
  private
    FCode: Integer;
  public
    constructor Create(code: Integer);
    
    property Code: Integer read FCode;
  end;

  TNamespaceURIList = class
  private
    FList: TStrings;
    function GetItem(I: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    
    function Add(const NamespaceURI: string): Integer;
    procedure Clear;
        
    property Item[I: Integer]: string read GetItem; default;
  end;

  TDocument = class;
  TNodeList = class;
  TNamedNodeMap = class;
  TElement = class;

  TNode = class
  private
    FOwnerDocument: TDocument;
    FParentNode: TNode;
    FNamespaceURI: Integer;
    FPrefix: string;
    FNodeName: string;
    FNodeValue: string;
    FAttributes: TNamedNodeMap;
    
    function GetFirstChild: TNode;
    function GetLastChild: TNode;
    function GetPreviousSibling: TNode;
    function GetNextSibling: TNode;
    function GetLocalName: string;
    function GetNamespaceURI: string;
    function InsertSingleNode(newChild, refChild: TNode): TNode; virtual;
  protected                    
    FChildNodes: TNodeList;
    
    function GetNodeValue: string; virtual;
    function GetNodeType: Integer; virtual; abstract;
    function GetParentNode: TNode; virtual;
    function GetChildNodes: TNodeList; virtual;
    function CanInsert(Node: TNode): Boolean; virtual;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; virtual;
    function GetNodeName: string; virtual;
    procedure SetNodeValue(const value: string); virtual;
    procedure SetNamespaceURI(const value: string);
    procedure SetPrefix(const value: string);
    procedure SetLocalName(const value: string);
    procedure CloneChildNodesFrom(Node: TNode);

    constructor Create(ownerDocument: TDocument; const namespaceURI, qualifiedName: string; withNS: Boolean);
  public
    destructor Destroy; override;

    function InsertBefore(newChild, refChild: TNode): TNode; virtual;
    function ReplaceChild(newChild, oldChild: TNode): TNode; virtual;
    function RemoveChild(oldChild: TNode): TNode; virtual;
    function AppendChild(newChild: TNode): TNode; virtual;
    function HasChildNodes: Boolean;
    function CloneNode(deep: Boolean): TNode; virtual; abstract;
    {}
    function IsSupported(const feature, version: string): Boolean;
    function HasAttributes: Boolean;
    function AncestorOf(node: TNode): Boolean;
    procedure Normalize;
    {}
    function GetInnerText: string;
    function GetInnerHTML: string;
    function GetOuterHTML: string;
    {}
    property Name: string read GetNodeName;
    property Value: string read GetNodeValue write SetNodeValue;
    property NodeType: Integer read GetNodeType;
    property ParentNode: TNode read GetParentNode write FParentNode;
    property ChildNodes: TNodeList read GetChildNodes;
    property FirstChild: TNode read GetFirstChild;
    property LastChild: TNode read GetLastChild;
    property PreviousSibling: TNode read GetPreviousSibling;
    property NextSibling: TNode read GetNextSibling;
    property Attributes: TNamedNodeMap read FAttributes;
    property OwnerDocument: TDocument read FOwnerDocument;
    property NamespaceURI: string read GetNamespaceURI;
    property Prefix: string read FPrefix write SetPrefix;
    property LocalName: string read GetLocalName;
  end;

  TNodeList = class
  private
    FOwnerNode: TNode;
    FList: TList;
  protected
    function GetLength: Integer; virtual;
    function IndexOf(node: TNode): Integer;
    procedure Add(node: TNode);
    procedure AddList(node: TNodeList);
    procedure Delete(I: Integer);
    procedure Insert(I: Integer; node: TNode);
    procedure Remove(node: TNode);
    procedure Clear(WithItems: Boolean);
    property OwnerNode: TNode read FOwnerNode;

    constructor Create(AOwnerNode: TNode);
  public                                  
    destructor Destroy; override;
    
    function GetItem(index: Integer): TNode; virtual;
    function GetFirst: TNode;
    function GetLast: TNode;
    property Items[Index: Integer]: TNode read GetItem; default;
    property Count: Integer read GetLength;
  end;

  TNamedNodeMap = class(TNodeList)
  public
    function GetNamedItem(const name: string): TNode;
    function SetNamedItem(arg: TNode): TNode;
    function RemoveNamedItem(const name: string): TNode;
    function GetNamedItemNS(const namespaceURI, localName: string): TNode;
    function SetNamedItemNS(arg: TNode): TNode;
    function RemoveNamedItemNS(const namespaceURI, localName: string): TNode;
  end;

  TCharacterData = class(TNode)
  private
    function GetLength: Integer;
  protected
    procedure SetNodeValue(const value: string); override;
    constructor Create(ownerDocument: TDocument; const data: string);
  public
    function SubstringData(offset, count: Integer): string;
    procedure AppendData(const arg: string);
    procedure DeleteData(offset, count: Integer);
    procedure InsertData(offset: Integer; arg: string);
    procedure ReplaceData(offset, count: Integer; const arg: string);
    
    property Data: string read GetNodeValue write SetNodeValue;
    property Length: Integer read GetLength;
  end;

  TComment = class(TCharacterData)
  protected
    function GetNodeName: string; override;
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;
  public
    function CloneNode(deep: Boolean): TNode; override;
  end;

  TScript = class(TCharacterData)
  protected
    function GetNodeName: string; override;
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;
  public
    function CloneNode(deep: Boolean): TNode; override;
  end;

  TTextNode = class(TCharacterData)
  protected
    function GetNodeName: string; override;
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;
  public
    function CloneNode(deep: Boolean): TNode; override;
    function SplitText(offset: Integer): TTextNode;
  end;

  TCDATASection = class(TTextNode)
  protected
    function GetNodeName: string; override;
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;
  public
    function CloneNode(deep: Boolean): TNode; override;
  end;

  TAttr = class(TNode)
  private
    function GetOwnerElement: TElement;
    function GetLength: Integer;
    function GetSpecified: Boolean;
  protected
    function GetNodeValue: string; override;
    function GetNodeType: Integer; override;
    function GetParentNode: TNode; override;
    function CanInsert(node: TNode): Boolean; override;
    function ExportNode(ownerDocument: TDocument; deep: Boolean): TNode; override;
    procedure SetNodeValue(const value: string); override;
  public
    function CloneNode(deep: Boolean): TNode; override;
    
    property Name: string read GetNodeName;
    property Specified: Boolean read GetSpecified;
    property Value: string read GetNodeValue write SetNodeValue;
    property OwnerElement: TElement read GetOwnerElement;
  end;

  TElement = class(TNode)
  private
    FIsEmpty: Boolean;
    FChildElements: TNodeList;

    procedure ReloadChildElements;
    function InsertSingleNode(newChild, refChild: TNode): TNode; override;
  protected
    function GetChildElements: TNodeList;
    function GetNodeType: Integer; override;
    function GetNodeValue: string; override;
    function CanInsert(node: TNode): Boolean; override;

    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;

    function InsertBefore(newChild, refChild: TNode): TNode; override;
    function ReplaceChild(newChild, oldChild: TNode): TNode; override;
    function RemoveChild(oldChild: TNode): TNode; override;
    function AppendChild(newChild: TNode): TNode; override;

    constructor Create(ownerDocument: TDocument; const namespaceURI, qualifiedName: string; withNS: Boolean);
    destructor Destroy; override;
  public
    function CloneNode(deep: Boolean): TNode; override;
    function GetAttribute(const name: string): string;
    function GetAttributeNode(const name: string): TAttr;
    function SetAttributeNode(newAttr: TAttr): TAttr;
    function RemoveAttributeNode(oldAttr: TAttr): TAttr;
    function GetAttributeNS(const namespaceURI, localName: string): string;
    function GetAttributeNodeNS(const namespaceURI, localName: string): TAttr;
    function SetAttributeNodeNS(newAttr: TAttr): TAttr;
    function HasAttribute(const name: string): Boolean;
    function HasAttributeNS(const namespaceURI, localName: string): Boolean;
    function CheckAttribute(const attr, value: string): Boolean;
    procedure SetAttribute(const name, value: string);
    procedure RemoveAttribute(const name: string);
    procedure SetAttributeNS(const namespaceURI, qualifiedName, value: string);
    procedure RemoveAttributeNS(const namespaceURI, localName: string);
    {}
    procedure RemoveChilds(const attr, value: string);
    {}
    function GetElementsByAttr(const attrs, values: array of string; const deeper: Boolean = True): TNodeList; overload;
    function GetElementByAttr(const attrs, values: array of string; const deeper: Boolean = True): TElement; overload;
    {}
    function GetElementsByAttr(const attr, value: string; const deeper: Boolean = True): TNodeList; overload;
    function GetElementByAttr(const attr, value: string; const deeper: Boolean = True): TElement; overload;
    {}
    function GetElementsByClass(const name: string; const deeper: Boolean = True): TNodeList;
    function GetElementByClass(const name: string; const deeper: Boolean = True): TElement;
    {}
    function GetElementsByTagName(const name: string; const deep: Integer = 0): TNodeList;
    function GetElementByTagName(const name: string; const deep: Integer = 0): TElement;
    {}
    function GetElementsByTagNameNS(const namespaceURI, localName: string; const deep: Integer = 0): TNodeList;
    function GetElementByTagNameNS(const namespaceURI, localName: string; const deep: Integer = 0): TElement;
    {}
    function GetElementByID(const elementId: string; const deeper: Boolean = True): TElement;
    {}
    function GetElementsByXPath(const XPath: string): TNodeList; overload;
    function GetElementByXPath(const XPath: string): TElement; overload;
    {}
    function GetElementsByCSSSelector(const cssSelector: string): TNodeList; overload;
    function GetElementByCSSSelector(const cssSelector: string): TElement; overload;

    property TagName: string read GetNodeName;
    property isEmpty: Boolean read FIsEmpty write FIsEmpty;
    property ChildElements: TNodeList read GetChildElements;
  end;

  TEntityReference = class(TNode)
  protected
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;

    constructor Create(ownerDocument: TDocument; const name: string);
  public
    function CloneNode(deep: Boolean): TNode; override;
  end;

  TProcessingInstruction = class(TNode)
  private
    function GetTarget: string;
    function GetData: string;
    procedure SetData(const value: string);
  protected
    function GetNodeType: Integer; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;

    constructor Create(ownerDocument: TDocument; const target, data: string);
  public
    function CloneNode(deep: Boolean): TNode; override;
    
    property Target: string read GetTarget;
    property Data: string read GetData write SetData;
  end;

  TDocumentFragment = class(TNode)
  protected
    function CanInsert(node: TNode): Boolean; override;
    function GetNodeType: Integer; override;
    function GetNodeName: string; override;
    function ExportNode(otherDocument: TDocument; deep: Boolean): TNode; override;

    constructor Create(ownerDocument: TDocument);
  public
    function CloneNode(deep: Boolean): TNode; override;
  end;

  TDocumentType = class(TNode)
  private
    FEntities: TNamedNodeMap;
    FNotations: TNamedNodeMap;
    FPublicID: string;
    FSystemID: string;
    FInternalSubset: string;
  protected
    function GetNodeType: Integer; override;
    constructor Create(ownerDocument: TDocument; const name, publicId, systemId: string);
  public
    function CloneNode(deep: Boolean): TNode; override;
    
    property Name: string read GetNodeName;
    property Entities: TNamedNodeMap read FEntities;
    property Notations: TNamedNodeMap read FNotations;
    property PublicId: string read FPublicID;
    property SystemId: string read FSystemID;
    property InternalSubset: string read FInternalSubset;
  end;

  TDocument = class(TNode)
  private
    FDocType: TDocumentType;
    FNamespaceURIList: TNamespaceURIList;
    FSearchNodeLists: TList;

    function GetDocumentElement: TElement;
  protected
    function GetNodeName: string; override;
    function GetNodeType: Integer; override;
    function CanInsert(Node: TNode): Boolean; override;
    function CreateDocType(const name, publicId, systemId: string): TDocumentType;
    procedure AddSearchNodeList(NodeList: TNodeList);
    procedure RemoveSearchNodeList(NodeList: TNodeList);
    procedure InvalidateSearchNodeLists;
    procedure SetDocType(value: TDocumentType);
  public
    constructor Create(doctype: TDocumentType);
    destructor Destroy; override;

    procedure Clear;
    function CloneNode(deep: Boolean): TNode; override;
    function CreateElement(const tagName: string): TElement;
    function CreateDocumentFragment: TDocumentFragment;
    function CreateTextNode(const data: string): TTextNode;
    function CreateComment(const data: string): TComment;
    function CreateCDATASection(const data: string): TCDATASection;
    function CreateProcessingInstruction(const target, data: string): TProcessingInstruction;
    function CreateAttribute(const name: string): TAttr;
    function CreateEntityReference(const name: string): TEntityReference;
    function ImportNode(importedNode: TNode; deep: Boolean): TNode;
    function CreateElementNS(const namespaceURI, qualifiedName: string): TElement;
    function CreateAttributeNS(const namespaceURI, qualifiedName: string): TAttr;
    function CreateScript(const data: string): TScript;

    property Doctype: TDocumentType read FDocType write SetDocType;
    property NamespaceURIList: TNamespaceURIList read FNamespaceURIList;
    property DocumentElement: TElement read GetDocumentElement;
  end;

  DomImplementation = class
  public
    class function HasFeature(const feature, version: string): Boolean;
    class function CreateDocumentType(const qualifiedName, publicId, systemId: string): TDocumentType;
    class function CreateHtmlDocumentType(htmlDocType: Integer): TDocumentType; // extension
    class function CreateEmptyDocument(doctype: TDocumentType): TDocument; // extension
    class function CreateDocument(const namespaceURI, qualifiedName: string; doctype: TDocumentType): TDocument;
  end;

implementation

uses
  HTMLp.Entities;

const
  ExceptionMsg: array[INDEX_SIZE_ERR..INVALID_ACCESS_ERR] of String = (
    'Index or size is negative, or greater than the allowed value',
    'The specified range of text does not fit into a DOMString',
    'Node is inserted somewhere it doesn''t belong ',
    'Node is used in a different document than the one that created it',
    'Invalid or illegal character is specified, such as in a name',
    'Data is specified for a node which does not support data',
    'An attempt is made to modify an object where modifications are not allowed',
    'An attempt is made to reference a node in a context where it does not exist',
    'Implementation does not support the requested type of object or operation',
    'An attempt is made to add an attribute that is already in use elsewhere',
    'An attempt is made to use an object that is not, or is no longer, usable',
    'An invalid or illegal string is specified',
    'An attempt is made to modify the type of the underlying object',
    'An attempt is made to create or change an object in a way which is incorrect with regard to namespaces',
    'A parameter or an operation is not supported by the underlying object'
  );

  ID_NAME = 'id';

type
  TDTDParams = record
    PublicId: string;
    SystemId: string;
  end;

  TDTDList = array[DTD_HTML_STRICT..DTD_XHTML_FRAMESET] of TDTDParams;

const
  DTDList: TDTDList = (
    // (publicId: '';                                       systemId: ''),
    (publicId: '-//W3C//DTD HTML 4.01//EN';              systemId: 'http://www.w3.org/TR/html4/strict.dtd'),
    (publicId: '-//W3C//DTD HTML 4.01 Transitional//EN'; systemId: 'http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd'),
    (publicId: '-//W3C//DTD HTML 4.01 Frameset//EN';     systemId: 'http://www.w3.org/TR/1999/REC-html401-19991224/frameset.dtd'),
    (publicId: '-//W3C//DTD XHTML 1.0 Strict//EN';       systemId: 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'),
    (publicId: '-//W3C//DTD XHTML 1.0 Transitional//EN'; systemId: 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'),
    (publicId: '-//W3C//DTD XHTML 1.0 Frameset//EN';     systemId: 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd')
  );

  HTML_TAG_NAME = 'html';

type
  TSearchNodeList = class(TNodeList)
  private
    FNamespaceParam : string;
    FNameParam : string;
    FSynchronized: Boolean;
    FMaxDeep: Integer;
    function GetLength: Integer; override;
    function AcceptNode(node: TNode): Boolean;
    procedure TraverseTree(rootNode: TNode; const deep: Integer = 0);
    procedure Rebuild;
  public
    constructor Create(AOwnerNode: TNode; const namespaceURI, name: string; const maxDeep: Integer = 0);
    destructor Destroy; override;
    
    procedure Invalidate; 
    function GetItem(index: Integer): TNode; override;
  end;

{
function Concat(const S1, S2: TDomString): TDomString;
begin
  SetLength(Result, Length(S1) + Length(S2));
  Move(S1[1], Result[1], 2 * Length(S1));
  Move(S2[1], Result[Length(S1) + 1], 2 * Length(S2))
end;
}

function IsNCName(const Value: string): Boolean;
begin
  //TODO
  Result := true
end;

{ =================
  TNamespaceURIList
================== }

constructor TNamespaceURIList.Create;
begin
  inherited Create;

  FList := TStringList.Create;
  FList.Add('')
end;

destructor TNamespaceURIList.Destroy;
begin
  FList.Free;

  inherited Destroy
end;

procedure TNamespaceURIList.Clear;
begin
  FList.Clear
end;

function TNamespaceURIList.GetItem(I: Integer): string;
begin
  Result := FList[I]
end;

function TNamespaceURIList.Add(const NamespaceURI: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    if FList[I] = NamespaceURI then
    begin
      Result := I;
      Exit
    end;
  Result := FList.Add(NamespaceURI)
end;

{ =================
  DomException
================== }

constructor DomException.Create(code: Integer);
begin
  inherited Create(ExceptionMsg[code]);
  FCode := code
end;

{ =================
  TNode
================== }

constructor TNode.Create(ownerDocument: TDocument; const namespaceURI, qualifiedName: string; withNS: Boolean);
var
  I: Integer;
begin
  inherited Create;
  
  FOwnerDocument := ownerDocument;
  SetNamespaceURI(namespaceURI);
  
  if withNS then
  begin
    I := Pos(':', qualifiedName);
    if I <> 0 then
    begin
      SetPrefix(Copy(qualifiedName, 1, I - 1));
      SetLocalName(Copy(qualifiedName, I + 1, Length(qualifiedName) - I))
    end
    else SetLocalName(qualifiedName);
  end
  else SetLocalName(qualifiedName);
  
  FChildNodes := TNodeList.Create(Self);
end;

destructor TNode.Destroy;
begin
  if Assigned(FChildNodes) then
  begin
    FChildNodes.Clear(True);
    FChildNodes.Free;
  end;
  
  if Assigned(FAttributes) then
  begin
    FAttributes.Clear(True);
    FAttributes.Free
  end;
  
  inherited Destroy;
end;

function TNode.GetFirstChild: TNode;
begin
  Result := nil;
  if ChildNodes.Count <> 0 then Result := ChildNodes.GetItem(0);
end;

function TNode.GetLastChild: TNode;
begin
  Result := nil;                            
  if ChildNodes.Count <> 0 then Result := ChildNodes.GetItem(ChildNodes.Count - 1);
end;

function TNode.GetPreviousSibling: TNode;       
var
  I: Integer;
begin 
  Result := nil;
  
  if Assigned(ParentNode) then
  begin
    I := ParentNode.ChildNodes.IndexOf(Self);
    
    if I > 0 then Result := ParentNode.ChildNodes.GetItem(I - 1);
  end
end;

function TNode.GetNextSibling: TNode;       
var
  I: Integer;
begin 
  Result := nil;
  
  if Assigned(ParentNode) then
  begin
    I := ParentNode.ChildNodes.IndexOf(Self);

    if (I >= 0) and (I < ParentNode.ChildNodes.Count - 1) then Result := ParentNode.ChildNodes.GetItem(I + 1);
  end
end;

function TNode.GetNodeName: string;
begin
  if FPrefix <> '' then Result := FPrefix + ':' + FNodeName
  else Result := FNodeName;
end;

function TNode.GetNodeValue: string;
begin
  Result := FNodeValue;
end;

function TNode.GetParentNode: TNode;
begin
  Result := FParentNode;
end;

function TNode.GetChildNodes: TNodeList;
begin
  Result := FChildNodes;
end;

function TNode.GetLocalName: string;
begin
  Result := FNodeName;
end;
                            
function TNode.CanInsert(Node: TNode): Boolean;
begin
  Result := False;
end;
                        
function TNode.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  raise DomException.Create(NOT_SUPPORTED_ERR)
end;

procedure TNode.SetNodeValue(const value: string);
begin
  raise DomException.Create(NO_MODIFICATION_ALLOWED_ERR)
end;

procedure TNode.SetNamespaceURI(const value: string);
begin
  //TODO validate
  if value <> '' then FNamespaceURI := FOwnerDocument.NamespaceURIList.Add(value);
end;

function TNode.GetNamespaceURI: string;
begin
  Result := FOwnerDocument.NamespaceURIList[FNamespaceURI]
end;

procedure TNode.SetPrefix(const value: string);
begin
  if not IsNCName(value) then raise DomException.Create(INVALID_CHARACTER_ERR);

  FPrefix := value;
end;

procedure TNode.SetLocalName(const value: string);
begin
  if not IsNCName(value) then raise DomException.Create(INVALID_CHARACTER_ERR);

  FNodeName := value
end;

procedure TNode.CloneChildNodesFrom(Node: TNode);
var
  childNode: TNode;
  I: Integer;
begin
  for I := 0 to Node.ChildNodes.Count - 1 do
  begin
    childNode := Node.ChildNodes.GetItem(I);
    AppendChild(childNode.CloneNode(true))
  end
end;
                                   
function TNode.InsertSingleNode(newChild, refChild: TNode): TNode;
var
  I: Integer;
begin
  if not (CanInsert(newChild))
    or newChild.AncestorOf(Self) then raise DomException.Create(HIERARCHY_REQUEST_ERR);

  if newChild <> refChild then
  begin
    if Assigned(refChild) then
    begin
      I := FChildNodes.IndexOf(refChild);
      if I < 0 then raise DomException.Create(NOT_FOUND_ERR);
      FChildNodes.Insert(I, newChild);
    end
    else FChildNodes.Add(newChild);

    if Assigned(newChild.ParentNode) then newChild.ParentNode.RemoveChild(newChild);
    newChild.FParentNode := Self;
  end;

  Result := newChild;
end;

function TNode.InsertBefore(newChild, refChild: TNode): TNode;
begin
  if newChild.OwnerDocument <> FOwnerDocument then raise DomException.Create(WRONG_DOCUMENT_ERR);

  if newChild.NodeType = DOCUMENT_FRAGMENT_NODE then
  begin
    while Assigned(newChild.FirstChild) do InsertSingleNode(newChild.FirstChild, refChild);
    Result := newChild;
  end
  else Result := InsertSingleNode(newChild, refChild);

  if Assigned(FOwnerDocument) then FOwnerDocument.InvalidateSearchNodeLists
end;

function TNode.ReplaceChild(newChild, oldChild: TNode): TNode;
begin
  if newChild <> oldChild then
  begin
    InsertBefore(newChild, oldChild);
    RemoveChild(oldChild)
  end;

  Result := oldChild;

  if Assigned(FOwnerDocument) then FOwnerDocument.InvalidateSearchNodeLists;
end;

function TNode.AppendChild(newChild: TNode): TNode;
begin
  Result := InsertBefore(newChild, nil);

  if Assigned(FOwnerDocument) then FOwnerDocument.InvalidateSearchNodeLists;
end;

function TNode.RemoveChild(oldChild: TNode): TNode;
var
  I: Integer;
begin
  I := FChildNodes.IndexOf(oldChild);
  if I < 0 then raise DomException.Create(NOT_FOUND_ERR);

  FChildNodes.Delete(I);
  oldChild.FParentNode := nil;
  Result := oldChild;

  if Assigned(FOwnerDocument) then FOwnerDocument.InvalidateSearchNodeLists;
end;

function TNode.HasChildNodes: Boolean;
begin
  Result := (FChildNodes.Count <> 0);
end;
                          
function TNode.IsSupported(const feature, version: string): Boolean;
begin
  Result := DOMImplementation.HasFeature(feature, version);
end;

function TNode.HasAttributes: Boolean;
begin
  Result := Assigned(FAttributes) and (FAttributes.Count <> 0)
end;
                         
function TNode.AncestorOf(node: TNode): Boolean;
begin
  while Assigned(node) do
  begin
    if node = self then
    begin
      Result := True;
      Exit
    end;
    
    node := node.ParentNode
  end;
  
  Result := False;
end;

procedure TNode.Normalize;
var
  childNode: TNode;
  textNode: TTextNode;
  I: Integer;
begin
  I := 0;
  while I < ChildNodes.Count do
  begin
    childNode := ChildNodes.GetItem(I);
    
    if childNode.NodeType = ELEMENT_NODE then
    begin
      (childNode as TElement).Normalize;
      Inc(I);
    end
    else if childNode.NodeType = TEXT_NODE then
    begin
      textNode := childNode as TTextNode;
      Inc(I);
      childNode := ChildNodes.GetItem(I);

      while childNode.NodeType = TEXT_NODE do
      begin
        textNode.AppendData((childNode as TTextNode).Data);
        Inc(I);
        childNode := ChildNodes.GetItem(I);
      end;
    end
    else Inc(I);
  end
end;

function TNode.GetInnerText: string;
var
  I: Integer;
begin
  Result := '';
  if NodeType = TEXT_NODE then Result := Result + Value;
  if (NodeType = ELEMENT_NODE)
    and ((Self as TElement).HasAttribute('alt')) then Result := Result + (Self as TElement).GetAttribute('alt');

  for I := 0 to FChildNodes.Count - 1 do
  begin
    Result := Result + FChildNodes[I].GetInnerText;
  end;
end;

function TNode.GetInnerHTML: string;
var
  I: Integer;
begin
  Result := '';

  for I := 0 to FChildNodes.Count - 1 do
  begin
    Result := Result + FChildNodes[I].GetOuterHTML;
  end;
end;

function TNode.GetOuterHTML: string;
var
  I: Integer;
begin
  Result := '';
  
  if NodeType = ELEMENT_NODE then
  begin
    Result := '<' + FNodeName;
    for I := 0 to FAttributes.Count - 1 do Result := Result + ' ' + FAttributes[I].Name + '="' + (FAttributes[I] as TAttr).Value + '"';
    Result := Result + '>';
  end  
  else if NodeType = TEXT_NODE then Result := Result + Value
  else if NodeType = END_ELEMENT_NODE then Result := Result + '</' + FNodeName + '>';

  for I := 0 to FChildNodes.Count - 1 do
  begin
    Result := Result + FChildNodes[I].GetOuterHTML;
  end;

  if NodeType = ELEMENT_NODE then Result := Result + '</' + FNodeName + '>';
end;

{ =================
  TNodeList
================== }

constructor TNodeList.Create(AOwnerNode: TNode);
begin
  inherited Create;
  
  FOwnerNode := AOwnerNode;
  FList := TList.Create;
end;

destructor TNodeList.Destroy;
begin
  // Clear(False);
  FreeAndNil(FList);

  inherited Destroy;
end;

function TNodeList.IndexOf(node: TNode): Integer;
begin
  Result := FList.IndexOf(node);
end;

function TNodeList.GetLength: Integer;
begin
  Result := FList.Count;
end;

procedure TNodeList.Insert(I: Integer; Node: TNode);
begin
  FList.Insert(I, Node);
end;

procedure TNodeList.Delete(I: Integer);
begin
  FList.Delete(I);
end;

procedure TNodeList.Add(node: TNode);
begin
  FList.Add(node);
end;

procedure TNodeList.AddList(node: TNodeList);
var
  I: Integer;
begin
  for I := 0 to node.Count - 1 do FList.Add(node[I]);
end;

procedure TNodeList.Remove(node: TNode);
begin
  FList.Remove(node);
end;

function TNodeList.GetItem(index: Integer): TNode;
begin
  Result := nil;
  if (index >= 0) and (index < Count) then Result := FList[index];
end;

function TNodeList.GetFirst: TNode;
begin
  Result := nil;
  if FList.Count > 0 then Result := FList[0];  
end;

function TNodeList.GetLast: TNode;
begin
  Result := nil; 
  if FList.Count > 0 then Result := FList[FList.Count - 1];
end;

procedure TNodeList.Clear(WithItems: Boolean);
var
  I: Integer;
begin
  if WithItems then
  begin
    for I := 0 to Count - 1 do Items[I].Free;
  end;
  
  FList.Clear;
end;

{ =================
  TSearchNodeList
================== }

constructor TSearchNodeList.Create(AOwnerNode: TNode; const namespaceURI, name: string; const maxDeep: Integer);
begin
  inherited Create(AOwnerNode);

  FNamespaceParam := namespaceURI;
  FNameParam := name;
  FMaxDeep := maxDeep;

  Rebuild;
end;

destructor TSearchNodeList.Destroy;
begin
  if Assigned(ownerNode)
    and Assigned(ownerNode.OwnerDocument) then ownerNode.OwnerDocument.RemoveSearchNodeList(Self);

  inherited Destroy
end;
                           
function TSearchNodeList.GetLength: Integer;
begin
  if not FSynchronized then Rebuild;
  Result := inherited GetLength
end;

function TSearchNodeList.AcceptNode(node: TNode): Boolean;
begin
  Result := (Node.NodeType = ELEMENT_NODE) and
            ((FNamespaceParam = '*') or (FNamespaceParam = node.NamespaceURI)) and
            ((FNameParam = '*') or (FNameParam = node.LocalName))
end;

procedure TSearchNodeList.TraverseTree(rootNode: TNode; const deep: Integer);
var
  I: Integer;
begin
  if (rootNode <> ownerNode) and AcceptNode(rootNode) then Add(rootNode);
  if (FMaxDeep > 0) and (deep > FMaxDeep) then Exit;

  for I := 0 to rootNode.ChildNodes.Count - 1 do
    TraverseTree(rootNode.ChildNodes.GetItem(I), deep + 1)
end;

procedure TSearchNodeList.Rebuild;
begin
  Clear(false);

  if Assigned(ownerNode) and Assigned(ownerNode.OwnerDocument) then
  begin
    TraverseTree(ownerNode, 0);
    ownerNode.OwnerDocument.AddSearchNodeList(Self);
  end;

  FSynchronized := true
end;
                           
procedure TSearchNodeList.Invalidate;
begin
  FSynchronized := false
end;

 function TSearchNodeList.GetItem(index: Integer): TNode;
begin
  if not FSynchronized then Rebuild;

  Result := inherited GetItem(index)
end;

{ =================
  TNamedNodeMap
================== }

function TNamedNodeMap.GetNamedItem(const name: string): TNode;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := GetItem(I);
    if Result.Name = name then Exit;
  end;

  Result := nil;
end;

function TNamedNodeMap.SetNamedItem(arg: TNode): TNode;
var
  Attr: TAttr;
begin
  if arg.OwnerDocument <> Self.ownerNode.OwnerDocument then raise DomException(WRONG_DOCUMENT_ERR);

  if arg.NodeType = ATTRIBUTE_NODE then
  begin
    Attr := arg as TAttr;
    if Assigned(Attr.OwnerElement)
      and (Attr.OwnerElement <> ownerNode) then raise DomException(INUSE_ATTRIBUTE_ERR)
  end;

  Result := GetNamedItem(arg.Name);
  if Assigned(Result) then Remove(Result);
  Add(arg)
end;

function TNamedNodeMap.RemoveNamedItem(const name: string): TNode;
var
  Node: TNode;
begin
  Node := GetNamedItem(name);
  if not (Assigned(Node)) then raise DomException.Create(NOT_FOUND_ERR);

  Remove(Node);
  Result := Node;
end;

function TNamedNodeMap.GetNamedItemNS(const namespaceURI, localName: string): TNode;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    Result := GetItem(I);
    if (Result.LocalName = localName)
      and (Result.NamespaceURI = namespaceURI) then Exit
  end;

  Result := nil;
end;

function TNamedNodeMap.SetNamedItemNS(arg: TNode): TNode;
var
  Attr: TAttr;
begin
  if arg.OwnerDocument <> Self.ownerNode.OwnerDocument then raise DomException(WRONG_DOCUMENT_ERR);

  if arg.NodeType = ATTRIBUTE_NODE then
  begin
    Attr := arg as TAttr;
    if Assigned(Attr.OwnerElement)
      and (Attr.OwnerElement <> ownerNode) then raise DomException(INUSE_ATTRIBUTE_ERR)
  end;

  Result := GetNamedItemNS(arg.NamespaceURI, arg.LocalName);
  if Assigned(Result) then Remove(Result);

  Add(arg);
end;

function TNamedNodeMap.RemoveNamedItemNS(const namespaceURI, localName: string): TNode;
var
  Node: TNode;
begin
  Node := GetNamedItemNS(namespaceURI, localName);
  if not (Assigned(Node)) then raise DomException.Create(NOT_FOUND_ERR);

  Remove(Node);
  Result := Node
end;

{ =================
  TEntityReference
================== }

constructor TEntityReference.Create(ownerDocument: TDocument; const name: string);
begin
  inherited Create(ownerDocument, '', name, false)
end;

function TEntityReference.GetNodeType: Integer;
begin
  Result := ENTITY_REFERENCE_NODE
end;
                            
function TEntityReference.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateEntityReference(Name)
end;

function TEntityReference.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateEntityReference(Name);
end;

{ =================
  TCharacterData
================== }

constructor TCharacterData.Create(ownerDocument: TDocument; const data: string);
begin
  inherited Create(ownerDocument, '', '', False);

  SetNodeValue(data);
end;

procedure TCharacterData.SetNodeValue(const value: string);
begin
  FNodeValue := value;
end;

function TCharacterData.GetLength: Integer;
begin
  Result := System.Length(FNodeValue);
end;

function TCharacterData.SubstringData(offset, count: Integer): string;
begin
  if (offset < 0) or (offset >= Length) or (count < 0) then raise DomException(INDEX_SIZE_ERR);
  Result := Copy(FNodeValue, offset + 1, count);
end;

procedure TCharacterData.AppendData(const arg: string);
begin
  FNodeValue := FNodeValue + arg;
end;

procedure TCharacterData.InsertData(offset: Integer; arg: string);
begin
  ReplaceData(offset, 0, arg);
end;

procedure TCharacterData.DeleteData(offset, count: Integer);
begin
  ReplaceData(offset, count, '');
end;

procedure TCharacterData.ReplaceData(offset, count: Integer; const arg: string);
begin                                  
  if (offset < 0) or (offset >= Length) or (count < 0) then raise DomException(INDEX_SIZE_ERR);
  FNodeValue := SubstringData(0, offset) + arg + SubstringData(offset + count, Length - (offset + count))
end;

{ =================
  TCDATASection
================== }

function TCDATASection.GetNodeName: string;
begin
  Result := '#cdata-section'
end;

function TCDATASection.GetNodeType: Integer;
begin
  Result := CDATA_SECTION_NODE;
end;
                      
function TCDATASection.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateCDATASection(Data);
end;

function TCDATASection.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateCDATASection(Data);
end;

{ =================
  TComment
================== }

function TComment.GetNodeName: string;
begin
  Result := '#comment'
end;

function TComment.GetNodeType: Integer;
begin
  Result := COMMENT_NODE;
end;

function TComment.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateComment(Data);
end;

function TComment.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateComment(Data);
end;

{ =================
  TTextNode
================== }

function TTextNode.GetNodeName: string;
begin
  Result := '#text'
end;

function TTextNode.GetNodeType: Integer;
begin
  Result := TEXT_NODE;
end;
                  
function TTextNode.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateTextNode(Data);
end;

function TTextNode.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateTextNode(Data);
end;

function TTextNode.SplitText(offset: Integer): TTextNode;
begin
  Result := FOwnerDocument.CreateTextNode(SubstringData(offset, Length - offset));
  DeleteData(offset, Length - offset);
  if Assigned(ParentNode) then InsertBefore(Result, NextSibling);
end;

{ =================
  TAttr
================== }

function TAttr.GetOwnerElement: TElement;
begin
  Result := FParentNode as TElement;
end;

function TAttr.GetLength: Integer;
var
  Node: TNode;
  I: Integer;
begin
  Result := 0;

  for I := 0 to ChildNodes.Count - 1 do
  begin
    Node := ChildNodes.GetItem(I);
    if Node.NodeType = TEXT_NODE then Inc(Result, (Node as TTextNode).Length)
    else if Node.NodeType = ENTITY_REFERENCE_NODE then Inc(Result);
  end
end;

function TAttr.GetNodeValue: string;
var
  Node: TNode;
  Len, Pos, I, J: Integer;
begin
  Len := GetLength;
  SetLength(Result, Len);
  Pos := 0;

  for I := 0 to ChildNodes.Count - 1 do
  begin
    Node := ChildNodes.GetItem(I);
    if Node.NodeType = TEXT_NODE then
      for J := 1 to (Node as TTextNode).Length do
      begin
        Inc(Pos);
        Result[Pos] := Node.FNodeValue[J];
      end
    else
    if Node.NodeType = ENTITY_REFERENCE_NODE then
    begin
      Inc(Pos);
      Result[Pos] := GetEntValue(Node.Name);
    end
  end
end;

function TAttr.GetNodeType: Integer;
begin
  Result := ATTRIBUTE_NODE;
end;

procedure TAttr.SetNodeValue(const value: string);
begin
  FChildNodes.Clear(False);
  AppendChild(FOwnerDocument.CreateTextNode(value))
end;

function TAttr.GetParentNode: TNode;
begin
  Result := nil;
end;
              
function TAttr.GetSpecified: Boolean;
begin
  Result := True;
end;

function TAttr.CanInsert(node: TNode): Boolean;
begin
  Result := node.NodeType in [ENTITY_REFERENCE_NODE, TEXT_NODE];
end;
                        
function TAttr.ExportNode(ownerDocument: TDocument; deep: Boolean): TNode;
begin
  Result := ownerDocument.CreateAttribute(Name);
  Result.CloneChildNodesFrom(Self);
end;

function TAttr.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateAttribute(Name);
  Result.CloneChildNodesFrom(Self);
end;

{ =================
  TElement
================== }

constructor TElement.Create(ownerDocument: TDocument; const namespaceURI, qualifiedName: string; withNS: Boolean);
begin
  inherited Create(ownerDocument, namespaceURI, qualifiedName, withNS); {?}

  FAttributes := TNamedNodeMap.Create(Self);
  FChildElements := TNamedNodeMap.Create(Self);
end;

destructor TElement.Destroy;
begin
  if Assigned(FChildElements) then
  begin
    FChildElements.Clear(False);
    FChildElements.Free;
  end;

  inherited;
end;

procedure TElement.ReloadChildElements;
var
  I: Integer;
begin
  FChildElements.Clear(False);

  for I := 0 to FChildNodes.Count - 1 do
  begin
    if FChildNodes[I].NodeType <> ELEMENT_NODE then Continue;

    FChildElements.Add(FChildNodes[I]);
  end;
end;

function TElement.GetChildElements: TNodeList;
begin
  Result := FChildElements;
end;

function TElement.GetNodeType: Integer;
begin
  Result := ELEMENT_NODE;
end;

function TElement.GetNodeValue: string;
var
  I: Integer;
  childElements: TNodeList;
  childElement: TElement;
  value, elementValue: string;
begin
  value := GetAttribute('value');

  if TagName = 'select' then
  begin
    Result := '0';

    childElements := GetElementsByXPath('option');
    try
      for I := 0 to childElements.Count - 1 do
      begin
        childElement := (childElements[I] as TElement);
        elementValue := childElement.GetAttribute('value');

        if childElement.HasAttribute('selected') then Result := IfThen(elementValue <> '', elementValue, IntToStr(I + 1));
      end;
    finally
      FreeAndNil(childElements);
    end;
  end
  else if (TagName = 'input') and (CheckAttribute('type', 'checkbox')) then
  begin
    if HasAttribute('checked') then Result := IfThen(value <> '', value, BoolToStr(True))
    else Result := BoolToStr(False);
  end
  else if value <> '' then Result := value
  else Result := GetInnerText;
end;

function TElement.CanInsert(node: TNode): Boolean;
begin
  Result := not (node.NodeType in [ENTITY_NODE, DOCUMENT_NODE, DOCUMENT_TYPE_NODE, NOTATION_NODE]);
end;

function TElement.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateElement(TagName);

  if deep then Result.CloneChildNodesFrom(Self);
end;

function TElement.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateElement(TagName);

  if deep then Result.CloneChildNodesFrom(Self);
end;


function TElement.InsertSingleNode(newChild, refChild: TNode): TNode;
begin
  inherited;

  ReloadChildElements;
end;

function TElement.InsertBefore(newChild, refChild: TNode): TNode;
begin
  inherited;

  ReloadChildElements;
end;

function TElement.ReplaceChild(newChild, oldChild: TNode): TNode;
begin
  inherited;

  ReloadChildElements;
end;

function TElement.AppendChild(newChild: TNode): TNode;
begin
  inherited;

  ReloadChildElements;
end;

function TElement.RemoveChild(oldChild: TNode): TNode;
begin
  inherited;

  ReloadChildElements;
end;

function TElement.GetAttributeNode(const name: string): TAttr;
var
  node: TNode;
begin
  Result := nil;
  node := Attributes.GetNamedItem(name);

  if Assigned(node) then Result := (node as TAttr);
end;

function TElement.GetAttribute(const name: string): string;
var
  Attr: TAttr;
begin
  Result := '';
  Attr := GetAttributeNode(name);

  if Assigned(Attr) then Result := Attr.Value;
end;

procedure TElement.SetAttribute(const name, value: string);
var
  newAttr: TAttr;
begin
  newAttr := FOwnerDocument.CreateAttribute(name);
  newAttr.Value := value;

  SetAttributeNode(newAttr);
end;

function TElement.SetAttributeNode(newAttr: TAttr): TAttr;
begin
  if Assigned(newAttr.OwnerElement) then raise DomException.Create(INUSE_ATTRIBUTE_ERR);

  Result := Attributes.SetNamedItem(newAttr) as TAttr;
  if Assigned(Result) then Result.ParentNode := nil;

  newAttr.ParentNode := Self;
end;

function TElement.RemoveAttributeNode(oldAttr: TAttr): TAttr;
begin
  if Attributes.IndexOf(oldAttr) < 0 then raise DomException.Create(NOT_FOUND_ERR);
  Attributes.Remove(oldAttr);
  oldAttr.ParentNode := nil;

  Result := oldAttr;
end;

procedure TElement.RemoveAttribute(const name: string);
begin
  Attributes.RemoveNamedItem(name).Free;
end;

{todo: ?? work ??}
procedure TElement.RemoveChilds(const attr, value: string);
var
  I: Integer;
begin
  for I := FChildNodes.Count - 1 downto 0 do
  begin
    if FChildNodes[I].NodeType <> ELEMENT_NODE then Exit;

    if (FChildNodes[I] as TElement).CheckAttribute(attr, value) then RemoveChild(FChildNodes[I]);
  end;
end;

function TElement.GetAttributeNS(const namespaceURI, localName: string): string;
var
  Attr: TAttr;
begin
  Result := '';
  Attr := GetAttributeNodeNS(namespaceURI, localName);

  if Assigned(Attr) then Result := Attr.Value;
end;

procedure TElement.SetAttributeNS(const namespaceURI, qualifiedName, value: string);
var
  newAttr: TAttr;
begin
  newAttr := FOwnerDocument.CreateAttributeNS(namespaceURI, qualifiedName);
  newAttr.Value := value;

  SetAttributeNodeNS(newAttr);
end;

procedure TElement.RemoveAttributeNS(const namespaceURI, localName: string);
begin
  Attributes.RemoveNamedItemNS(namespaceURI, localName).Free
end;

function TElement.GetAttributeNodeNS(const namespaceURI, localName: string): TAttr;
begin
  Result := Attributes.GetNamedItemNS(namespaceURI, localName) as TAttr
end;

function TElement.SetAttributeNodeNS(newAttr: TAttr): TAttr;
begin
  if Assigned(newAttr.OwnerElement) then raise DomException.Create(INUSE_ATTRIBUTE_ERR);
  Result := Attributes.SetNamedItemNS(newAttr) as TAttr;

  if Assigned(Result) then Result.FParentNode := nil;
  newAttr.FParentNode := Self
end;

function TElement.HasAttribute(const name: string): Boolean;
begin
  Result := Assigned(GetAttributeNode(name))
end;

function TElement.HasAttributeNS(const namespaceURI, localName: string): Boolean;
begin
  Result := Assigned(GetAttributeNodeNS(namespaceURI, localName))
end;

function TElement.CheckAttribute(const attr, value: string): Boolean;
var
  currentAttr: string;
  currentAttrs: TArray<string>;
begin
  currentAttr := GetAttribute(attr);
  currentAttrs := currentAttr.Split([' ']);
  try Result := MatchStr(value, currentAttrs);
  finally currentAttrs := nil; end;
end;

{

}

function TElement.GetElementsByTagName(const name: string; const deep: Integer): TNodeList;
begin
  Result := TSearchNodeList.Create(Self, '*', name, deep);
end;


function TElement.GetElementByTagName(const name: string; const deep: Integer): TElement;
begin
  with TSearchNodeList.Create(Self, '*', name, deep) do
  begin
    Result := (GetFirst as TElement);
    Free;
  end;
end;

function TElement.GetElementsByTagNameNS(const namespaceURI, localName: string; const deep: Integer): TNodeList;
begin
  Result := TSearchNodeList.Create(Self, namespaceURI, localName, deep);
end;

function TElement.GetElementByTagNameNS(const namespaceURI, localName: string; const deep: Integer): TElement;
begin
  with TSearchNodeList.Create(Self, namespaceURI, localName, deep) do
  begin
    Result := (GetFirst as TElement);
    Free;
  end;
end;

function TElement.GetElementsByAttr(const attrs, values: array of string; const deeper: Boolean): TNodeList;

  function checkAllAttr(const element: TElement; const attrs, values: array of string): Boolean;
  var
    I, checkedCount, trueCount: Integer;
  begin
    Result := False;
    
    checkedCount := Length(attrs);
    trueCount := 0;

    for I := 0 to checkedCount - 1 do
    begin
      if I >= Length(values) then Break;

      if element.CheckAttribute(attrs[I], values[I]) then Inc(trueCount);
    end;

    Result := (checkedCount = trueCount);
  end;

var
  I: Integer;
  currentNode: TNode;
  currentElement: TElement;
  subElements: TNodeList;
begin
  // Result := nil;
  // if NodeType <> ELEMENT_NODE then Exit;

  Result := TNodeList.Create(Self);
  
  for I := 0 to FChildElements.Count - 1 do
  begin
    currentNode := FChildElements.Items[I];
    currentElement := (currentNode as TElement);

    if currentNode.NodeType <> ELEMENT_NODE then Continue;

    if checkAllAttr(currentElement, attrs, values) then
    begin
      Result.Add(currentElement);
    end
    else if deeper then
    begin
      subElements := currentElement.GetElementsByAttr(attrs, values);
      try Result.AddList(subElements);
      finally FreeAndNil(subElements); end;
    end;
  end;
end;

function TElement.GetElementByAttr(const attrs, values: array of string; const deeper: Boolean): TElement;
begin
  with GetElementsByAttr(attrs, values, deeper) do
  begin
    Result := (GetFirst as TElement);

    Free;
  end;
end;

function TElement.GetElementsByAttr(const attr, value: string; const deeper: Boolean): TNodeList;
begin
  Result := GetElementsByAttr([attr], [value], deeper);
end;

function TElement.GetElementByAttr(const attr, value: string; const deeper: Boolean): TElement;
begin
  Result := GetElementByAttr([attr], [value], deeper);
end;

function TElement.GetElementsByClass(const name: string; const deeper: Boolean): TNodeList;
begin
  Result := GetElementsByAttr('class', name, deeper);
end;

function TElement.GetElementByClass(const name: string; const deeper: Boolean): TElement;
begin
  Result := GetElementByAttr('class', name, deeper);
end;

function TElement.GetElementById(const elementId: string; const deeper: Boolean): TElement;
begin
  Result := GetElementByAttr(ID_NAME, elementId, deeper);
end;

{ Helper - XPath

//div
//div[0]
//div[last]
//div[first()]
//*[@class="foo"]
//div[@data-attr]
}
function TElement.GetElementsByXPath(const XPath: string): TNodeList;

  function getElements(const element: TElement; const key: string; const deep: Boolean): TNodeList;
  var
    I: Integer;
    regexMatch: TMatch;
    itemIndex: Integer;
    tag, attr, data, divIndex: string;
    currentElement: TElement;
    currentNodeList: TNodeList;
  begin
    Result := TNodeList.Create(Self);
    regexMatch := TRegEx.Match(key, '^\/?([\w*]+)(?:\[\s*(?:@([\w-_]+)\s*(?:\=\s*[''"]{0,}(.*?)[''"]{0,}|)?|(\d+|(?:last|first)(?:\(\))?))\s*\]|)$');
    if not (regexMatch.Success) then Exit;

    with regexMatch do
    begin
      if Groups.Count > 1 then tag := Groups[1].Value;
      if Groups.Count > 2 then attr := Groups[2].Value;
      if Groups.Count > 3 then data := Groups[3].Value;
      if Groups.Count > 4 then divIndex := Groups[4].Value;
    end;

    {By Tag}
    if (tag <> '') and (tag <> '*') and (attr = '') then
    begin
      currentNodeList := element.GetElementsByTagName(tag, IfThen(deep, 0, 1));

      if divIndex = 'first' then itemIndex := 1
      else if divIndex = 'last' then itemIndex := currentNodeList.Count
      else itemIndex := StrToIntDef(divIndex, -1);

      if (itemIndex >= 0) and (itemIndex < currentNodeList.Count) then Result.Add(currentNodeList.Items[itemIndex - 1])
      else Result.AddList(currentNodeList);
    end
    {Tag and Attr}
    else
    begin
      if tag = '*' then
      begin
        currentNodeList := element.GetElementsByAttr(attr, data, deep);

        Result.AddList(currentNodeList);
      end
      else
      begin
        currentNodeList := element.GetElementsByTagName(tag, IfThen(deep, 0, 1));

        for I := 0 to currentNodeList.Count - 1 do
        begin
          currentElement := (currentNodeList[I] as TElement);

          if currentElement.CheckAttribute(attr, data) then Result.Add(currentElement);
        end;
      end;
    end;

    FreeAndNil(currentNodeList);
  end;

var
  I: Integer;
  isRoot: Boolean;
  keyList: TArray<string>;
  newXPath: string;
  rootNodeList, currentNodeList: TNodeList;
  currentElement: TElement;
begin
  Result := TNodeList.Create(Self);
  if NodeType <> ELEMENT_NODE then Exit;

  isRoot := False;
  currentElement := (Self as TElement);

  if Pos('//', XPath) = 1 then
  begin
    isRoot := True;
    newXPath := Copy(XPath, 3);
  end
  else if Pos('/', XPath) = 1 then newXPath := Copy(XPath, 2)
  else newXPath := XPath;

  keyList := SplitString(newXPath, '/');
  if Length(keyList) <= 0 then Exit;

  {Find on current element}
  rootNodeList := getElements(currentElement, keyList[0], isRoot);
  try
    if rootNodeList.Count <= 0 then Exit;

    if Length(keyList) <= 1 then
    begin
      Result.AddList(rootNodeList);
      Exit;
    end;

    Delete(keyList, 0, 1);
    newXPath := string.Join('/', keyList);

    {Find on child}
    for I := 0 to rootNodeList.Count - 1 do
    begin
      if not (rootNodeList[I] is TElement) then Continue;

      currentNodeList := (rootNodeList[I] as TElement).GetElementsByXPath(newXPath);
      try Result.AddList(currentNodeList);
      finally FreeAndNil(currentNodeList); end;
    end;
  finally
    FreeAndNil(rootNodeList);
  end;
end;

{Helper XPath}
function TElement.GetElementByXPath(const XPath: string): TElement;
var
  node: TNode;
begin
  Result := nil;
  
  node := GetElementsByXPath(XPath).GetFirst;
  if Assigned(node) then Result := (node as TElement);   
end;

{Helper CSSSelector}
function TElement.GetElementsByCSSSelector(const cssSelector: string): TNodeList;

  function copyChain(var selector: string): string;
  var
    i: Integer;
  begin
    Result := selector;

    try
      for i := 1 to High(selector) do
      begin
        if (i = 1) then Continue;

        if (selector[i] <> '.')
          and (selector[i] <> '#')
          and (selector[i] <> '>') then Continue;

        Result := Copy(selector, 1, i - 1);
        Break;
      end;
    finally
      Delete(selector, 1, i - 1);
    end;
  end;

var
  I, J: Integer;
  regexMatch: TMatch;
  keyList, XPathKeyList: TArray<string>;
  findAttrs: array of string;
  fullSelector, currentSelector: string;
  XPathChain, fullXPath: string;
  currentChain, symbol, val, paramGroup, pseudoClass: string;
  param: string;
begin
  keyList := SplitString(cssSelector, ' ');
  XPathKeyList := [];

  for I := 0 to High(keyList) do
  begin
    fullSelector := Trim(keyList[I]);
    XPathChain := '';

    while fullSelector <> '' do
    begin
      symbol := '';
      val := '';
      paramGroup := '';
      pseudoClass := '';
      currentChain := copyChain(fullSelector);

      regexMatch := TRegEx.Match(currentChain, '^([\.#]|)([0-9a-zA-Z_\-"''*]*?|)(\[.*?\]|)(?:\:{1,}(.*?)|())$');
      if not (regexMatch.Success) then Exit;

      with regexMatch do
      begin
        currentSelector := Groups[0].Value;
        if Groups.Count > 1 then symbol := Groups[1].Value;
        if Groups.Count > 2 then val := Groups[2].Value;
        if Groups.Count > 3 then paramGroup := Groups[3].Value;
        if Groups.Count > 4 then pseudoClass := Groups[4].Value;
      end;

      if symbol = '.' then param := 'class'
      else if symbol = '#' then param := 'id';

      if param <> '' then
      begin
        XPathChain := IfThen(XPathChain = '', '*', '') + XPathChain + Format('[@%s="%s"]', [param, val]);
      end
      else
      begin
        if paramGroup <> '' then
        begin
          XPathChain := XPathChain + IfThen(val <> '', val, '*') + paramGroup;
        end
        else if val <> '' then
        begin
          XPathChain := XPathChain + val;

          if pseudoClass = 'first-child' then XPathChain := XPathChain + '[1]';
        end;
      end;

      if XPathChain = '' then Exit;
    end;

    XPathKeyList := XPathKeyList + [XPathChain];
  end;

  fullXPath := string.Join('/', XPathKeyList);

  Result := GetElementsByXPath('//' + fullXPath);
end;

{Helper CSSSelector}
function TElement.GetElementByCSSSelector(const cssSelector: string): TElement;
var
  node: TNode;
begin
  Result := nil;
  
  node := GetElementsByCSSSelector(cssSelector).GetFirst;
  if Assigned(node) then Result := (node as TElement);   
end;

{ =================
  TDocumentType
================== }

constructor TDocumentType.Create(ownerDocument: TDocument; const name, publicId, systemId: string);
begin
  inherited Create(ownerDocument, '', name, false);
  FPublicID := publicId;
  FSystemID := systemId
end;

function TDocumentType.GetNodeType: Integer;
begin
  Result := DOCUMENT_TYPE_NODE
end;

function TDocumentType.CloneNode(deep: Boolean): TNode;
begin
  Result := TDocumentType.Create(FOwnerDocument, Name, PublicId, SystemId)
end;

{ =================
  TDocumentFragment
================== }

constructor TDocumentFragment.Create(ownerDocument: TDocument);
begin
  inherited Create(OwnerDocument, '', '', false)
end;

function TDocumentFragment.GetNodeType: Integer;
begin
  Result := DOCUMENT_FRAGMENT_NODE
end;

function TDocumentFragment.GetNodeName: string;
begin
  Result := '#document-fragment'
end;

function TDocumentFragment.CanInsert(node: TNode): Boolean;
begin
  Result := not (node.NodeType in [ENTITY_NODE, DOCUMENT_NODE, DOCUMENT_TYPE_NODE, NOTATION_NODE]);
end;

function TDocumentFragment.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateDocumentFragment;
  if deep then
    Result.CloneChildNodesFrom(Self)
end;

function TDocumentFragment.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateDocumentFragment;
  if deep then Result.CloneChildNodesFrom(Self)
end;

{ =================
  TDocument
================== }

constructor TDocument.Create(doctype: TDocumentType);
begin
  inherited Create(Self, '', '', False);

  FDocType := doctype;
  if Assigned(FDocType) then FDocType.FOwnerDocument := Self;
  FNamespaceURIList := TNamespaceURIList.Create;
  FSearchNodeLists := TList.Create;
end;

destructor TDocument.Destroy;
begin
  FDocType.Free;
  FNamespaceURIList.Free;
  FSearchNodeLists.Free;

  inherited Destroy;
end;

procedure TDocument.SetDocType(value: TDocumentType);
begin
  if Assigned(FDocType) then FDocType.Free;
  FDocType := value
end;

function TDocument.GetDocumentElement: TElement;
var
  Child: TNode;
  I: Integer;
begin
  for I := 0 to ChildNodes.Count - 1 do
  begin
    Child := ChildNodes.GetItem(I);
    if Child.NodeType = ELEMENT_NODE then
    begin
      Result := Child as TElement;
      Exit
    end
  end;
  
  Result := nil;
end;

function TDocument.GetNodeName: string;
begin
  Result := '#document'
end;

function TDocument.GetNodeType: Integer;
begin
  Result := DOCUMENT_NODE
end;

procedure TDocument.Clear;
begin
  if Assigned(FDocType) then
  begin
    FDocType.Free;
    FDocType := nil;
  end;
  
  FNamespaceURIList.Clear;
  FSearchNodeLists.Clear;
  FChildNodes.Clear(False);
end;

procedure TDocument.AddSearchNodeList(NodeList: TNodeList);
begin
  if FSearchNodeLists.IndexOf(NodeList) < 0 then FSearchNodeLists.Add(NodeList);
end;

procedure TDocument.RemoveSearchNodeList(NodeList: TNodeList);
begin
  FSearchNodeLists.Remove(NodeList);
end;

procedure TDocument.InvalidateSearchNodeLists;
var
  I: Integer;
begin
  for I := 0 to FSearchNodeLists.Count - 1 do TSearchNodeList(FSearchNodeLists[I]).Invalidate;
end;

function TDocument.CreateDocType(const name, publicId, systemId: string): TDocumentType;
begin
  Result := TDocumentType.Create(Self, name, publicId, systemId);
end;

function TDocument.CanInsert(Node: TNode): Boolean;
begin
  Result := (node.NodeType in [TEXT_NODE, COMMENT_NODE, PROCESSING_INSTRUCTION_NODE, SCRIPT_NODE]) or
            (node.NodeType = ELEMENT_NODE) and (DocumentElement = nil)
end;

function TDocument.CloneNode(deep: Boolean): TNode;
begin
  Result := DOMImplementation.CreateDocument(NamespaceURI, DocumentElement.Name, Doctype.CloneNode(False) as TDocumentType);
end;

function TDocument.CreateElement(const tagName: string): TElement;
begin
  Result := TElement.Create(Self, '', tagName, False);
end;

function TDocument.CreateDocumentFragment: TDocumentFragment;
begin
  Result := TDocumentFragment.Create(Self);
end;

function TDocument.CreateScript(const data: string): TScript;
begin
  Result := TScript.Create(Self, data)
end;

function TDocument.CreateTextNode(const data: string): TTextNode;
begin
  Result := TTextNode.Create(Self, data);
end;

function TDocument.CreateComment(const data: string): TComment;
begin
  Result := TComment.Create(Self, data);
end;

function TDocument.CreateCDATASection(const data: string): TCDATASection;
begin
  Result := TCDATASection.Create(Self, data);
end;

function TDocument.CreateProcessingInstruction(const target, data: string): TProcessingInstruction;
begin
  Result := TProcessingInstruction.Create(Self, target, data);
end;

function TDocument.CreateAttribute(const name: string): TAttr;
begin
  Result := TAttr.Create(Self, '', name, False);
end;

function TDocument.CreateEntityReference(const name: string): TEntityReference;
begin
  Result := TEntityReference.Create(Self, name);
end;
                                        
function TDocument.ImportNode(importedNode: TNode; deep: Boolean): TNode;
begin
  Result := importedNode.ExportNode(Self, deep);
end;

function TDocument.CreateElementNS(const namespaceURI, qualifiedName: string): TElement;
begin
  Result := TElement.Create(Self, namespaceURI, qualifiedName, True);
end;

function TDocument.CreateAttributeNS(const namespaceURI, qualifiedName: string): TAttr;
begin
  Result := TAttr.Create(Self, namespaceURI, qualifiedName, True);
end;

{ =================
  TProcessingInstruction
================== }

constructor TProcessingInstruction.Create(ownerDocument: TDocument; const target, data: string);
begin
  inherited Create(ownerDocument, '', '', False);
  
  FNodeName := target;
  FNodeValue := data;
end;

function TProcessingInstruction.GetTarget: string;
begin
  Result := FNodeName;
end;

function TProcessingInstruction.GetData: string;
begin
  Result := FNodeValue;
end;

procedure TProcessingInstruction.SetData(const value: string);
begin
  FNodeValue := value;
end;

function TProcessingInstruction.GetNodeType: Integer;
begin
  Result := PROCESSING_INSTRUCTION_NODE;
end;

function TProcessingInstruction.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateProcessingInstruction(Target, Data);
end;

function TProcessingInstruction.CloneNode(deep: Boolean): TNode;
begin
  Result := FOwnerDocument.CreateProcessingInstruction(Target, Data);
end;

{ =================
  DOMImplementation
================== }

class function DOMImplementation.HasFeature(const feature, version: string): Boolean;
begin
  Result := (UpperCase(feature) = 'CORE');
end;

class function DOMImplementation.CreateDocumentType(const qualifiedName, publicId, systemId: string): TDocumentType;
begin
  Result := TDocumentType.Create(nil, qualifiedName, publicId, systemId);
end;

class function DomImplementation.CreateHtmlDocumentType(htmlDocType: Integer): TDocumentType;
begin
  if htmlDocType in [DTD_HTML_STRICT..DTD_XHTML_FRAMESET] then
  begin
    with DTDList[htmlDocType] do Result := CreateDocumentType(HTML_TAG_NAME, publicId, systemId)
  end
  else Result := nil;
end;

class function DOMImplementation.CreateEmptyDocument(doctype: TDocumentType): TDocument;
begin
  if Assigned(doctype) and Assigned(doctype.OwnerDocument) then raise DomException.Create(WRONG_DOCUMENT_ERR);
  Result := TDocument.Create(doctype);
end;

class function DOMImplementation.CreateDocument(const namespaceURI, qualifiedName: string; doctype: TDocumentType): TDocument;
begin
  Result := CreateEmptyDocument(doctype);
  Result.AppendChild(Result.CreateElementNS(namespaceURI, qualifiedName));
end;

{ TScript }

function TScript.CloneNode(deep: Boolean): TNode;
begin
  Result := OwnerDocument.CreateScript(Data)
end;

function TScript.ExportNode(otherDocument: TDocument; deep: Boolean): TNode;
begin
  Result := otherDocument.CreateScript(Data)
end;

function TScript.GetNodeName: string;
begin
  Result := '#script';
end;

function TScript.GetNodeType: Integer;
begin
  Result := SCRIPT_NODE;
end;

end.
