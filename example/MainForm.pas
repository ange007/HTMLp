unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,

  HTMLp.HtmlParser, HTMLp.Helper, Buttons;

type
  THTMLForm = class(TForm)
    TopPanel: TPanel;
    FileNameEdit: TEdit;
    BrowseButton: TButton;
    OpenButton: TButton;
    Memo: TMemo;
    OpenDialog: TOpenDialog;
    PanelXPath: TPanel;
    UseXPathButton: TSpeedButton;
    XPathEdit: TEdit;
    procedure BrowseButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure TopPanelResize(Sender: TObject);
    procedure UseXPathButtonClick(Sender: TObject);
  private
    HtmlParser: THtmlParser;
  end;

var
  HTMLForm: THTMLForm;

implementation

{$R *.DFM}

uses
  HTMLp.DomCore, HTMLp.Formatter;

procedure THTMLForm.BrowseButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    FileNameEdit.Text := OpenDialog.FileName
end;

procedure THTMLForm.UseXPathButtonClick(Sender: TObject);
var
  S: String;
  F: TStringStream;
begin
  F := TStringStream.Create{('', TEncoding.UTF8)};
  try
    F.LoadFromFile(FileNameEdit.Text);
    S := F.DataString;
  finally
    F.Free
  end;

  Memo.Clear;

  ParseHTML(s).Find(XPathEdit.Text).Map( procedure(AIndex: Integer; AEl: TElement)
  begin
    Memo.Lines.Add(AEl.Value);
  end );

  Memo.SelStart := 0;
  Memo.SelLength := 0;
end;

procedure THTMLForm.OpenButtonClick(Sender: TObject);
var
  S: String;
  F: TStringStream;
  HtmlDoc: TDocument;
  Formatter: TBaseFormatter;
begin
  F := TStringStream.Create;
  try
    F.LoadFromFile(FileNameEdit.Text);
    S := F.DataString;
  finally
    FreeAndNil(F);
  end;

  HtmlParser := THtmlParser.Create;
  try
    HtmlDoc := HtmlParser.parseString(S);
  finally
    FreeAndNil(HtmlParser);
  end;

  Formatter := TTextFormatter.Create;
  try
    Memo.Lines.Text := Formatter.getText(HtmlDoc);
  finally
    FreeAndNil(Formatter);
  end;

  FreeAndNil(HtmlDoc);

  Memo.SelStart := 0;
  Memo.SelLength := 0;
end;

procedure THTMLForm.TopPanelResize(Sender: TObject);
begin
  OpenButton.Left := TopPanel.Width - 70;
  BrowseButton.Left := OpenButton.Left - 42;
  FileNameEdit.Width := BrowseButton.Left - FileNameEdit.Left;
end;

end.
