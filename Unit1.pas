unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, WinAPI.Windows, Utils.WindowMove,
  FMX.Edit;

type
  TForm1 = class(TForm)
    StyleBook1: TStyleBook;
    Panel1: TPanel;
    Label1: TLabel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Edit1: TEdit;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    Button4: TButton;
    Button5: TButton;
    CheckBox6: TCheckBox;
    Label2: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    FWindowMove: IWindowMove;
    { Private declarations }
  public
    { Public declarations }
  end;



var
  Form1: TForm1;
  Command,SD,Dir: string;

implementation

{$R *.fmx}

function ExecAndWait(sCommandLine, sWorkDir: string): Boolean;
var
  dwExitCode: DWORD;
  tpiProcess: TProcessInformation;
  tsiStartup: TStartupInfo;
begin
  Result := false;
  FillChar(tsiStartup, sizeof(TStartupInfo), 0);
  tsiStartup.cb := sizeof(TStartupInfo);
  tsiStartup.hStdError := 0;
  tsiStartup.wShowWindow := SW_SHOW;
  tsiStartup.dwFlags := StartF_UseStdHandles + STARTF_USESHOWWINDOW;
  if CreateProcess(nil,
    PChar(sCommandLine),
    nil, nil, false, 0, nil, PChar(sWorkDir), tsiStartup, tpiProcess) then
  begin
    if WAIT_OBJECT_0 = WaitForSingleObject(tpiProcess.hProcess, INFINITE) then
    begin
      if GetExitCodeProcess(tpiProcess.hProcess, dwExitCode) then
      begin
        if dwExitCode = 0 then
          Result := True
        else
          SetLastError(dwExitCode + $2000);
      end;
    end;
    dwExitCode := GetLastError;
    CloseHandle(tpiProcess.hProcess);
    CloseHandle(tpiProcess.hThread);
    SetLastError(dwExitCode);
    Result := True;
  end;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  Command := SD + ' /s';
  if CheckBox3.IsChecked then
    Command := Command + ' /hybrid';
  if CheckBox2.IsChecked then
    Command := Command + ' /t ' + Edit1.Text;
  if CheckBox4.IsChecked then
    Command := Command + ' /fw';
  if CheckBox6.IsChecked then
    Command := SD + ' /p';
  if CheckBox1.IsChecked then
    Command := Command + ' /f';
 if ExecAndWait(Command, Dir) then
  Showmessage('Shutdown initiated');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  Command := SD + ' /r';
  if CheckBox5.IsChecked then
    Command := Command + ' /o';
  if CheckBox4.IsChecked then
    Command := Command + ' /fw';
  if CheckBox1.IsChecked then
    Command := Command + ' /f';
  if CheckBox2.IsChecked then
    Command := Command + ' /t ' + Edit1.Text;
  if ExecAndWait(Command, Dir) then
  Showmessage('Restart initiated');
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  Command := SD + ' /h';
  if CheckBox1.IsChecked then
    Command := Command + ' /f';
  if ExecAndWait(Command, Dir) then
  Form1.Close;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Command := SD + ' /l';
  if CheckBox1.IsChecked then
    Command := Command + ' /f';
  if ExecAndWait(Command, Dir) then
  Showmessage('Logout initiated');
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
  Command := SD + ' /a';
  if ExecAndWait(Command, Dir) then
    Showmessage('Shutdown aborted');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SD:=IncludeTrailingBackslash(GetEnvironmentVariable('SYSTEMROOT'))+'system32\shutdown.exe';
  Dir:=IncludeTrailingBackslash(GetEnvironmentVariable('SYSTEMROOT'))+'system32';
  FWindowMove := TWindowMove.Create(Self) as IWindowMove;
  FWindowMove.RegisterControl(Panel1);
end;

end.
