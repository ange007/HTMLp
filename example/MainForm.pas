unit MainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, HtmlParser;

type
  THTMLForm = class(TForm)
    TopPanel: TPanel;
    FileNameEdit: TEdit;
    BrowseButton: TButton;
    OpenButton: TButton;
    OpenDialog: TOpenDialog;
    Memo: TMemo;
    procedure BrowseButtonClick(Sender: TObject);
    procedure OpenButtonClick(Sender: TObject);
    procedure TopPanelResize(Sender: TObject);
  private
    HtmlParser: THtmlParser;
  end;

var
  HTMLForm: THTMLForm;

implementation

{$R *.DFM}

uses
  DomCore, Formatter;

procedure THTMLForm.BrowseButtonClick(Sender: TObject);
begin
  if OpenDialog.Execute then
    FileNameEdit.Text := OpenDialog.FileName
end;

procedure THTMLForm.OpenButtonClick(Sender: TObject);
var
  S: String;
  F: TStream;
  HtmlDoc: TDocument;
  Formatter: TBaseFormatter;
begin
  F := TFileStream.Create(FileNameEdit.Text, fmOpenRead);
  try
    SetLength(S, F.Size);
    F.ReadBuffer(S[1], F.Size)
  finally
    F.Free
  end;

  HtmlParser := THtmlParser.Create;
  try
    HtmlDoc := HtmlParser.parseString(S)
  finally
    HtmlParser.Free
  end;

  Formatter := TTextFormatter.Create;
  try
    Memo.Lines.Text := Formatter.getText(HtmlDoc)
  finally
    Formatter.Free
  end;

  HtmlDoc.Free;

  Memo.SelStart := 0;
  Memo.SelLength := 0;
end;

procedure THTMLForm.TopPanelResize(Sender: TObject);
begin
  OpenButton.Left := TopPanel.Width - 70;
  BrowseButton.Left := OpenButton.Left - 42;
  FileNameEdit.Width := BrowseButton.Left - FileNameEdit.Left
end;

end.
