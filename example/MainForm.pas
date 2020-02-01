unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, IdHTTP, StrUtils,

  HTMLp.HTMLParser, HTMLp.Helper, Buttons;

type
  THTMLForm = class(TForm)
    TopPanel: TPanel;
    FileNameEdit: TEdit;
    BrowseButton: TButton;
    ToTextButton: TButton;
    Memo: TMemo;
    OpenDialog: TOpenDialog;
    PanelXPath: TPanel;
    UseXPathButton: TSpeedButton;
    XPathEdit: TEdit;
    MultiThreadTest: TButton;
    procedure BrowseButtonClick(Sender: TObject);
    procedure ToTextButtonClick(Sender: TObject);
    procedure UseXPathButtonClick(Sender: TObject);
    procedure MultiThreadTestClick(Sender: TObject);
  public
  private
    HTMLParser: THTMLParser;
  end;

  function GetHTML(const fileName: string): string;

var
  HTMLForm: THTMLForm;

implementation

{$R *.DFM}

uses
  HTMLp.DomCore, HTMLp.Formatter;

function GetHTML(const fileName: string): string;
var
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
    F := TStringStream.Create({'', TEncoding.UTF8});
    try
      F.LoadFromFile(fileName);
      Result := F.DataString;
    finally
      F.Free
    end;
  end;
end;

procedure THTMLForm.MultiThreadTestClick(Sender: TObject);
var
  i: Integer;
  thread: TThread;
begin
  Memo.Clear;

  for i := 0 to 50 do
  begin
    thread := TThread.CreateAnonymousThread(procedure( )
    var
      HTML, body: string;
      HTMLDoc: TDocument;
    begin
      with THTMLParser.Create do
      begin
        HTML := GetHTML(FileNameEdit.Text);
        HTMLDoc := parseString(HTML);
        body := HTMLDoc.GetInnerHTML;

        FreeAndNil(HTMLDoc);
        Free;
      end;

      TThread.Synchronize(TThread.Current, procedure begin HTMLForm.Memo.Lines.Add(IfThen(body <> '', 'GOOD', 'BAD')); end);
      Sleep(3000);
    end);

    {}
    thread.Start;
  end;
end;

procedure THTMLForm.BrowseButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then FileNameEdit.Text := OpenDialog.FileName
end;

procedure THTMLForm.UseXPathButtonClick(Sender: TObject);
var
  HTML: string;
begin
  HTML := GetHTML(FileNameEdit.Text);
  Memo.Clear;

  ParseHTML(HTML).Find(XPathEdit.Text).Map( procedure(AIndex: Integer; AEl: TElement)
  begin
    Memo.Lines.Add(AEl.Value);
  end );

  Memo.SelStart := 0;
  Memo.SelLength := 0;
end;

procedure THTMLForm.ToTextButtonClick(Sender: TObject);
var
  HTML: string;
  HTMLDoc: TDocument;
  Formatter: TBaseFormatter;
begin
  HTML := GetHTML(FileNameEdit.Text);
  Memo.Clear;

  HTMLParser := THTMLParser.Create;
  try
    HTMLDoc := HTMLParser.parseString(HTML);
  finally
    FreeAndNil(HTMLParser);
  end;

  Formatter := TTextFormatter.Create;
  try
    Memo.Lines.Text := Formatter.getText(HTMLDoc);
  finally
    FreeAndNil(Formatter);
  end;

  FreeAndNil(HTMLDoc);

  Memo.SelStart := 0;
  Memo.SelLength := 0;
end;

end.
