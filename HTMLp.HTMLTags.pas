unit HTMLp.HTMLTags;

interface

uses
  Classes,

  HTMLp.DomCore;

const
  MAX_TAGS_COUNT  = 128;
  MAX_FLAGS_COUNT = 32;

type
  THTMLTagSet = set of 0..MAX_TAGS_COUNT - 1;
  THTMLTagFlags = set of 0..MAX_FLAGS_COUNT - 1;

  THTMLTag = class
  private
    FName: WideString;
    FNumber: Integer;
    FParserFlags: THTMLTagFlags;
    FFormatterFlags: THTMLTagFlags;
  public
    constructor Create(const AName: WideString; ANumber: Integer; AParserFlags, AFormatterFlags: THTMLTagFlags);

    property Name: WideString read FName;
    property Number: Integer read FNumber;
    property ParserFlags: THTMLTagFlags read FParserFlags;
    property FormatterFlags: THTMLTagFlags read FFormatterFlags;
  end;

  TCompareTag = function(Tag: THTMLTag): Integer of object;

  THTMLTagList = class
  private
    FList: TList;
    FUnknownTag: THTMLTag;
    FSearchName: WideString;
    FSearchNumber: Integer;
    function CompareName(Tag: THTMLTag): Integer;
    function CompareNumber(Tag: THTMLTag): Integer;
    function GetTag(Compare: TCompareTag): THTMLTag;
  public
    constructor Create;
    destructor Destroy; override;

    function GetTagByName(const Name: WideString): THTMLTag;
    function GetTagByNumber(Number: Integer): THTMLTag;
  end;

  TURLSchemes = class(TStringList)
  private
    FMaxLen: Integer;
  public
    function Add(const S: string): Integer; override;
    function IsURL(const S: string): Boolean;
    function GetScheme(const S: string): string;

    property MaxLen: Integer read FMaxLen;
  end;

var
  HTMLTagList: THTMLTagList;
  URLSchemes: TURLSchemes;

const
  UNKNOWN_TAG    = 0;
  A_TAG          = 1;
  ABBR_TAG       = 2;
  ACRONYM_TAG    = 3;
  ADDRESS_TAG    = 4;
  APPLET_TAG     = 5;
  AREA_TAG       = 6;
  B_TAG          = 7;
  BASE_TAG       = 8;
  BASEFONT_TAG   = 9;
  BDO_TAG        = 10;
  BIG_TAG        = 11;
  BLOCKQUOTE_TAG = 12;
  BODY_TAG       = 13;
  BR_TAG         = 14;
  BUTTON_TAG     = 15;
  CAPTION_TAG    = 16;
  CENTER_TAG     = 17;
  CITE_TAG       = 18;
  CODE_TAG       = 19;
  COL_TAG        = 20;
  COLGROUP_TAG   = 21;
  DD_TAG         = 22;
  DEL_TAG        = 23;
  DFN_TAG        = 24;
  DIR_TAG        = 25;
  DIV_TAG        = 26;
  DL_TAG         = 27;
  DT_TAG         = 28;
  EM_TAG         = 29;
  FIELDSET_TAG   = 30;
  FONT_TAG       = 31;
  FORM_TAG       = 32;
  FRAME_TAG      = 33;
  FRAMESET_TAG   = 34;
  H1_TAG         = 35;
  H2_TAG         = 36;
  H3_TAG         = 37;
  H4_TAG         = 38;
  H5_TAG         = 39;
  H6_TAG         = 40;
  HEAD_TAG       = 41;
  HR_TAG         = 42;
  HTML_TAG       = 43;
  I_TAG          = 44;
  IFRAME_TAG     = 45;
  IMG_TAG        = 46;
  INPUT_TAG      = 47;
  INS_TAG        = 48;
  ISINDEX_TAG    = 49;
  KBD_TAG        = 50;
  LABEL_TAG      = 51;
  LEGEND_TAG     = 52;
  LI_TAG         = 53;
  LINK_TAG       = 54;
  MAP_TAG        = 55;
  MENU_TAG       = 56;
  META_TAG       = 57;
  NOFRAMES_TAG   = 58;
  NOSCRIPT_TAG   = 59;
  OBJECT_TAG     = 60;
  OL_TAG         = 61;
  OPTGROUP_TAG   = 62;
  OPTION_TAG     = 63;
  P_TAG          = 64;
  PARAM_TAG      = 65;
  PRE_TAG        = 66;
  Q_TAG          = 67;
  S_TAG          = 68;
  SAMP_TAG       = 69;
  SCRIPT_TAG     = 70;
  SELECT_TAG     = 71;
  SMALL_TAG      = 72;
  SPAN_TAG       = 73;
  STRIKE_TAG     = 74;
  STRONG_TAG     = 75;
  STYLE_TAG      = 76;
  SUB_TAG        = 77;
  SUP_TAG        = 78;
  TABLE_TAG      = 79;
  TBODY_TAG      = 80;
  TD_TAG         = 81;
  TEXTAREA_TAG   = 82;
  TFOOT_TAG      = 83;
  TH_TAG         = 84;
  THEAD_TAG      = 85;
  TITLE_TAG      = 86;
  TR_TAG         = 87;
  TT_TAG         = 88;
  U_TAG          = 89;
  UL_TAG         = 90;
  VAR_TAG        = 91;
  {}
  SOURCE_TAG     = 92;
  TRACK_TAG      = 93;
  WBR_TAG        = 94;
  EMBED_TAG      = 95;
  ASIDE_TAG      = 96;
  ARTICLE_TAG    = 97;
  BDI_TAG        = 98;
  FIGURE_TAG     = 99;
  FOOTER_TAG     = 100;
  FIGCAPTION_TAG = 101;
  HEADER_TAG     = 102;
  MAIN_TAG       = 103;
  MARK_TAG       = 104;
  NAV_TAG        = 105;
  TIME_TAG       = 106;
  SECTION_TAG    = 107;
  PLAINTEXT_TAG  = 108;
  XMP_TAG        = 109;
  VIDEO_TAG      = 110;
  AUDIO_TAG      = 111;

  {https://developer.mozilla.org/en-US/docs/Web/HTML/Block-level_elements}
  BlockTags               = [ADDRESS_TAG, TIME_TAG, BLOCKQUOTE_TAG, CENTER_TAG, DIV_TAG, DL_TAG, FIELDSET_TAG, {FORM_TAG,} A_TAG, H1_TAG,
                              H2_TAG, H3_TAG, H4_TAG, H5_TAG, H6_TAG, HR_TAG, NOSCRIPT_TAG, OL_TAG, PRE_TAG, TABLE_TAG, UL_TAG,
                              ARTICLE_TAG, SECTION_TAG, ASIDE_TAG, MAIN_TAG, HEADER_TAG, FOOTER_TAG];
  {}
  BlockParentTags         = [ADDRESS_TAG, BLOCKQUOTE_TAG, CENTER_TAG, DIV_TAG, DL_TAG, FIELDSET_TAG, A_TAG,
                              H1_TAG, H2_TAG, H3_TAG, H4_TAG, H5_TAG, H6_TAG, HR_TAG, LI_TAG, NOSCRIPT_TAG, OL_TAG, PRE_TAG, TD_TAG, TH_TAG, UL_TAG,
                              ARTICLE_TAG, SECTION_TAG, ASIDE_TAG, MAIN_TAG, HEADER_TAG, FOOTER_TAG];
  {https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/The_head_metadata_in_HTML}
  HeadTags                = [BASE_TAG, LINK_TAG, META_TAG, SCRIPT_TAG, STYLE_TAG, TITLE_TAG];
  {https://developer.mozilla.org/en-US/docs/Glossary/Empty_element}
  EmptyTags               = [AREA_TAG, BASE_TAG, BASEFONT_TAG, BR_TAG, COL_TAG, FRAME_TAG, EMBED_TAG, HR_TAG, IMG_TAG, INPUT_TAG, ISINDEX_TAG,
                              LINK_TAG, META_TAG, PARAM_TAG, SOURCE_TAG, TRACK_TAG, WBR_TAG];
  {}
  NeedFindParentTags      = [COL_TAG, COLGROUP_TAG, DD_TAG, DT_TAG, LI_TAG, OPTION_TAG, P_TAG, TABLE_TAG, TBODY_TAG, TD_TAG,
                              TFOOT_TAG, TH_TAG, THEAD_TAG, TR_TAG];
  {Other}
  PreserveWhiteSpaceTags  = [PRE_TAG];
  ListItemParentTags      = [DIR_TAG, MENU_TAG, OL_TAG, UL_TAG];
  DefItemParentTags       = [DL_TAG];
  TableSectionParentTags  = [TABLE_TAG];
  ColParentTags           = [COLGROUP_TAG];
  RowParentTags           = [TABLE_TAG, TBODY_TAG, TFOOT_TAG, THEAD_TAG];
  CellParentTags          = [TR_TAG];
  OptionParentTags        = [OPTGROUP_TAG, SELECT_TAG];
  PlainTextTags           = [CODE_TAG, SCRIPT_TAG, PLAINTEXT_TAG, XMP_TAG];

implementation

uses
  SysUtils;

constructor THTMLTag.Create(const AName: WideString; ANumber: Integer; AParserFlags, AFormatterFlags: THTMLTagFlags);
begin
  inherited Create;

  FName := AName;
  FNumber := ANumber
end;

constructor THTMLTagList.Create;
begin
  inherited Create;

  FList := TList.Create;
  FList.Capacity := MAX_TAGS_COUNT;
  FList.Add(THTMLTag.Create('a',          A_TAG,          [], []));
  FList.Add(THTMLTag.Create('abbr',       ABBR_TAG,       [], []));
  FList.Add(THTMLTag.Create('acronym',    ACRONYM_TAG,    [], []));
  FList.Add(THTMLTag.Create('address',    ADDRESS_TAG,    [], []));
  FList.Add(THTMLTag.Create('applet',     APPLET_TAG,     [], []));
  FList.Add(THTMLTag.Create('area',       AREA_TAG,       [], []));
  FList.Add(THTMLTag.Create('aside',      ASIDE_TAG,      [], []));
  FList.Add(THTMLTag.Create('article',    ARTICLE_TAG,    [], []));
  FList.Add(THTMLTag.Create('audio',      AUDIO_TAG,      [], []));
  FList.Add(THTMLTag.Create('b',          B_TAG,          [], []));
  FList.Add(THTMLTag.Create('base',       BASE_TAG,       [], []));
  FList.Add(THTMLTag.Create('basefont',   BASEFONT_TAG,   [], []));
  FList.Add(THTMLTag.Create('bdo',        BDO_TAG,        [], []));
  FList.Add(THTMLTag.Create('big',        BIG_TAG,        [], []));
  FList.Add(THTMLTag.Create('blockquote', BLOCKQUOTE_TAG, [], []));
  FList.Add(THTMLTag.Create('body',       BODY_TAG,       [], []));
  FList.Add(THTMLTag.Create('br',         BR_TAG,         [], []));
  FList.Add(THTMLTag.Create('button',     BUTTON_TAG,     [], []));
  FList.Add(THTMLTag.Create('bdi',        BDI_TAG,        [], []));
  FList.Add(THTMLTag.Create('caption',    CAPTION_TAG,    [], []));
  FList.Add(THTMLTag.Create('center',     CENTER_TAG,     [], []));
  FList.Add(THTMLTag.Create('cite',       CITE_TAG,       [], []));
  FList.Add(THTMLTag.Create('code',       CODE_TAG,       [], []));
  FList.Add(THTMLTag.Create('col',        COL_TAG,        [], []));
  FList.Add(THTMLTag.Create('colgroup',   COLGROUP_TAG,   [], []));
  FList.Add(THTMLTag.Create('dd',         DD_TAG,         [], []));
  FList.Add(THTMLTag.Create('del',        DEL_TAG,        [], []));
  FList.Add(THTMLTag.Create('dfn',        DFN_TAG,        [], []));
  FList.Add(THTMLTag.Create('dir',        DIR_TAG,        [], []));
  FList.Add(THTMLTag.Create('div',        DIV_TAG,        [], []));
  FList.Add(THTMLTag.Create('dl',         DL_TAG,         [], []));
  FList.Add(THTMLTag.Create('dt',         DT_TAG,         [], []));
  FList.Add(THTMLTag.Create('em',         EM_TAG,         [], []));
  FList.Add(THTMLTag.Create('embed',      EMBED_TAG,      [], []));
  FList.Add(THTMLTag.Create('fieldset',   FIELDSET_TAG,   [], []));
  FList.Add(THTMLTag.Create('font',       FONT_TAG,       [], []));
  FList.Add(THTMLTag.Create('form',       FORM_TAG,       [], []));
  FList.Add(THTMLTag.Create('frame',      FRAME_TAG,      [], []));
  FList.Add(THTMLTag.Create('frameset',   FRAMESET_TAG,   [], []));
  FList.Add(THTMLTag.Create('figure',     FIGURE_TAG,     [], []));
  FList.Add(THTMLTag.Create('footer',     FOOTER_TAG,     [], []));
  FList.Add(THTMLTag.Create('figcaption', FIGCAPTION_TAG, [], []));
  FList.Add(THTMLTag.Create('h1',         H1_TAG,         [], []));
  FList.Add(THTMLTag.Create('h2',         H2_TAG,         [], []));
  FList.Add(THTMLTag.Create('h3',         H3_TAG,         [], []));
  FList.Add(THTMLTag.Create('h4',         H4_TAG,         [], []));
  FList.Add(THTMLTag.Create('h5',         H5_TAG,         [], []));
  FList.Add(THTMLTag.Create('h6',         H6_TAG,         [], []));
  FList.Add(THTMLTag.Create('head',       HEAD_TAG,       [], []));
  FList.Add(THTMLTag.Create('header',     HEADER_TAG,       [], []));
  FList.Add(THTMLTag.Create('hr',         HR_TAG,         [], []));
  FList.Add(THTMLTag.Create('html',       HTML_TAG,       [], []));
  FList.Add(THTMLTag.Create('i',          I_TAG,          [], []));
  FList.Add(THTMLTag.Create('iframe',     IFRAME_TAG,     [], []));
  FList.Add(THTMLTag.Create('img',        IMG_TAG,        [], []));
  FList.Add(THTMLTag.Create('input',      INPUT_TAG,      [], []));
  FList.Add(THTMLTag.Create('ins',        INS_TAG,        [], []));
  FList.Add(THTMLTag.Create('isindex',    ISINDEX_TAG,    [], []));
  FList.Add(THTMLTag.Create('kbd',        KBD_TAG,        [], []));
  FList.Add(THTMLTag.Create('label',      LABEL_TAG,      [], []));
  FList.Add(THTMLTag.Create('legend',     LEGEND_TAG,     [], []));
  FList.Add(THTMLTag.Create('li',         LI_TAG,         [], []));
  FList.Add(THTMLTag.Create('link',       LINK_TAG,       [], []));
  FList.Add(THTMLTag.Create('map',        MAP_TAG,        [], []));
  FList.Add(THTMLTag.Create('menu',       MENU_TAG,       [], []));
  FList.Add(THTMLTag.Create('meta',       META_TAG,       [], []));
  FList.Add(THTMLTag.Create('main',       MAIN_TAG,       [], []));
  FList.Add(THTMLTag.Create('mark',       MARK_TAG,       [], []));
  FList.Add(THTMLTag.Create('noframes',   NOFRAMES_TAG,   [], []));
  FList.Add(THTMLTag.Create('noscript',   NOSCRIPT_TAG,   [], []));
  FList.Add(THTMLTag.Create('nav',        NAV_TAG,        [], []));
  FList.Add(THTMLTag.Create('object',     OBJECT_TAG,     [], []));
  FList.Add(THTMLTag.Create('ol',         OL_TAG,         [], []));
  FList.Add(THTMLTag.Create('optgroup',   OPTGROUP_TAG,   [], []));
  FList.Add(THTMLTag.Create('option',     OPTION_TAG,     [], []));
  FList.Add(THTMLTag.Create('p',          P_TAG,          [], []));
  FList.Add(THTMLTag.Create('param',      PARAM_TAG,      [], []));
  FList.Add(THTMLTag.Create('pre',        PRE_TAG,        [], []));
  FList.Add(THTMLTag.Create('plaintext',  PLAINTEXT_TAG,  [], []));
  FList.Add(THTMLTag.Create('q',          Q_TAG,          [], []));
  FList.Add(THTMLTag.Create('s',          S_TAG,          [], []));
  FList.Add(THTMLTag.Create('samp',       SAMP_TAG,       [], []));
  FList.Add(THTMLTag.Create('script',     SCRIPT_TAG,     [], []));
  FList.Add(THTMLTag.Create('select',     SELECT_TAG,     [], []));
  FList.Add(THTMLTag.Create('small',      SMALL_TAG,      [], []));
  FList.Add(THTMLTag.Create('span',       SPAN_TAG,       [], []));
  FList.Add(THTMLTag.Create('strike',     STRIKE_TAG,     [], []));
  FList.Add(THTMLTag.Create('strong',     STRONG_TAG,     [], []));
  FList.Add(THTMLTag.Create('style',      STYLE_TAG,      [], []));
  FList.Add(THTMLTag.Create('sub',        SUB_TAG,        [], []));
  FList.Add(THTMLTag.Create('sup',        SUP_TAG,        [], []));
  FList.Add(THTMLTag.Create('source',     SOURCE_TAG,     [], []));
  FList.Add(THTMLTag.Create('section',    SECTION_TAG,    [], []));
  FList.Add(THTMLTag.Create('table',      TABLE_TAG,      [], []));
  FList.Add(THTMLTag.Create('tbody',      TBODY_TAG,      [], []));
  FList.Add(THTMLTag.Create('td',         TD_TAG,         [], []));
  FList.Add(THTMLTag.Create('textarea',   TEXTAREA_TAG,   [], []));
  FList.Add(THTMLTag.Create('tfoot',      TFOOT_TAG,      [], []));
  FList.Add(THTMLTag.Create('th',         TH_TAG,         [], []));
  FList.Add(THTMLTag.Create('thead',      THEAD_TAG,      [], []));
  FList.Add(THTMLTag.Create('title',      TITLE_TAG,      [], []));
  FList.Add(THTMLTag.Create('tr',         TR_TAG,         [], []));
  FList.Add(THTMLTag.Create('tt',         TT_TAG,         [], []));
  FList.Add(THTMLTag.Create('track',      TRACK_TAG,      [], []));
  FList.Add(THTMLTag.Create('time',       TIME_TAG,       [], []));
  FList.Add(THTMLTag.Create('u',          U_TAG,          [], []));
  FList.Add(THTMLTag.Create('ul',         UL_TAG,         [], []));
  FList.Add(THTMLTag.Create('var',        VAR_TAG,        [], []));
  FList.Add(THTMLTag.Create('video',      VIDEO_TAG,      [], []));
  FList.Add(THTMLTag.Create('wbr',        WBR_TAG,        [], []));
  FList.Add(THTMLTag.Create('xmp',        XMP_TAG,        [], []));

  FUnknownTag := THTMLTag.Create('', UNKNOWN_TAG, [], [])
end;

destructor THTMLTagList.Destroy;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do THTMLTag(FList[I]).Free;
  FList.Free;
  FUnknownTag.Free;

  inherited Destroy
end;

function THTMLTagList.GetTag(Compare: TCompareTag): THTMLTag;
var
  I, Low, High, Rel: Integer;
begin
  Low := -1;
  High := FList.Count - 1;
  while High - Low > 1 do
  begin
    I := (High + Low) div 2;
    Result := FList[I];
    Rel := Compare(Result);
    if Rel < 0 then High := I
    else if Rel > 0 then Low := I
    else Exit
  end;
  if High >= 0 then
  begin
    Result := FList[High];
    if Compare(Result) = 0 then Exit
  end;

  Result := nil
end;

function THTMLTagList.CompareName(Tag: THTMLTag): Integer;
begin
  Result := CompareStr(FSearchName, Tag.Name)
end;

function THTMLTagList.CompareNumber(Tag: THTMLTag): Integer;
begin
  Result := (FSearchNumber - Tag.Number);
end;

function THTMLTagList.GetTagByName(const Name: WideString): THTMLTag;
begin
  FSearchName := Name;
  Result := GetTag(CompareName);
  if Result = nil then Result := FUnknownTag;
end;

function THTMLTagList.GetTagByNumber(Number: Integer): THTMLTag;
begin
  FSearchNumber := Number;
  Result := GetTag(CompareNumber);
end;

function TURLSchemes.Add(const S: String): Integer;
begin
  if Length(S) > FMaxLen then FMaxLen := Length(S);
  Result := inherited Add(S);
end;

function TURLSchemes.IsURL(const S: String): Boolean;
begin
  Result := IndexOf(LowerCase(S)) >= 0
end;

function TURLSchemes.GetScheme(const S: String): String;
const
  SchemeChars = [Ord('A')..Ord('Z'), Ord('a')..Ord('z')];
var
  I: Integer;
begin
  Result := '';
  for I := 1 to MaxLen + 1 do
  begin
    if I > Length(S) then
      Exit;
    if S[I] = ':' then
    begin
      if IsURL(Copy(S, 1, I - 1)) then
        Result := Copy(S, 1, I - 1);
      Exit
    end
  end
end;

initialization
  HTMLTagList := THTMLTagList.Create;
  URLSchemes := TURLSchemes.Create;
  URLSchemes.Add('http');
  URLSchemes.Add('https');
  URLSchemes.Add('ftp');
  URLSchemes.Add('mailto');
  URLSchemes.Add('news');
  URLSchemes.Add('nntp');
  URLSchemes.Add('gopher');

finalization
  HTMLTagList.Free;
  URLSchemes.Free;

end.
