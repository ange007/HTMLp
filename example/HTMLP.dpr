program HTMLP;

uses
  Forms,
  WStrings   in '..\WStrings.pas',
  Entities   in '..\Entities.pas',
  DOMCore    in '..\DOMCore.pas',
  HtmlTags   in '..\HtmlTags.pas',
  HtmlReader in '..\HtmlReader.pas',
  HtmlParser in '..\HTMLParser.pas',
  Formatter  in '..\Formatter.pas',
  MainForm   in 'MainForm.pas' {HTMLForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(THTMLForm, HTMLForm);
  Application.Run;
end.
