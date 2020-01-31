program HTMLP;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Forms,
  MainForm in 'MainForm.pas' {HTMLForm},
  HTMLp.DOMCore in '..\HTMLp.DOMCore.pas',
  HTMLp.Entities in '..\HTMLp.Entities.pas',
  HTMLp.Formatter in '..\HTMLp.Formatter.pas',
  HTMLp.Helper in '..\HTMLp.Helper.pas',
  HTMLp.HTMLParser in '..\HTMLp.HTMLParser.pas',
  HTMLp.HTMLReader in '..\HTMLp.HTMLReader.pas',
  HTMLp.HTMLTags in '..\HTMLp.HTMLTags.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(THTMLForm, HTMLForm);
  Application.Run;
end.
