program HTMLP;

uses
  Forms,
  MainForm in 'MainForm.pas' {HTMLForm},
  HTMLp.DOMCore in '..\HTMLp.DOMCore.pas',
  HTMLp.Entities in '..\HTMLp.Entities.pas',
  HTMLp.Formatter in '..\HTMLp.Formatter.pas',
  HTMLp.Helper in '..\HTMLp.Helper.pas',
  HTMLp.HTMLParser in '..\HTMLp.HTMLParser.pas',
  HTMLp.HtmlReader in '..\HTMLp.HtmlReader.pas',
  HTMLp.HtmlTags in '..\HTMLp.HtmlTags.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(THTMLForm, HTMLForm);
  Application.Run;
end.
