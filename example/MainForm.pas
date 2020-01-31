unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IdHTTP,

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
    procedure UseXPathButtonClick(Sender: TObject);
  private
    HtmlParser: THTMLParser;
    function GetHTML(const fileName: string): string;
  end;

var
  HTMLForm: THTMLForm;

implementation

{$R *.DFM}

uses
  HTMLp.DomCore, HTMLp.Formatter;

procedure THTMLForm.BrowseButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then FileNameEdit.Text := OpenDialog.FileName
end;

function THTMLForm.GetHTML(const fileName: string): string;
var
  S: String;
  F: TStringStream;
begin
  if Pos('http', fileName) = 1 then
  begin
    with TIdHTTP.Create(nil) do
    begin
      HandleRedirects := True;

      try Result := Get(fileName);
      except
        on e: Exception do ShowMessage(e.Message);
      end;

      Free;
    end;
  end
  else
  begin
    F := TStringStream.Create{('', TEncoding.UTF8)};
    try
      F.LoadFromFile(FileNameEdit.Text);
      Result := F.DataString;
    finally
      F.Free
    end;
  end;
end;

procedure THTMLForm.UseXPathButtonClick(Sender: TObject);
var
  S: string;
begin
  S := GetHTML(FileNameEdit.Text);
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
  S: string;
  HtmlDoc: TDocument;
  Formatter: TBaseFormatter;
begin
  S := GetHTML(FileNameEdit.Text);
  Memo.Clear;

  HtmlParser := THTMLParser.Create;
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

end.
