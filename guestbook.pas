unit guestbook;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DateUtils, SdfData, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    FakeLine: TBevel;
    SdfPeople: TSdfDataSet;
    YourQuoteMemo: TMemo;
    YourQuoteLabel: TLabel;
    RandQuoteLabel: TLabel;
    NameLEdit: TLabeledEdit;
    RandQuoteMemo: TMemo;
    SendBtn: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SendBtnClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
const
  TIME_FILE_PATH = 'time_ll.txt';
  HOUR_IN_SECONDS: integer = 3600;
var
  UnixTS: integer;
  TimeOffset: integer;
  PDBIndex: integer;
  NewIndex: integer;
  TimeFile: TextFile;
  RndQuote: string;
  RndName: string;

  function GetUnixNow(): int64;
  begin
    Result := DateTimeToUnix(Now());
  end;

  function IsDBEmpty(DataB: TSdfDataSet): boolean;
  var
    Val: string;
  begin
    DataB.First;
    Val := DataB.FieldByName('FieldName').AsString;
    Exit(Val.IsEmpty);
  end;

  function LineCount(FileName: string): integer;
  var
    F: TextFile;
  begin
    AssignFile(F, FileName);
    Reset(F);
    Result := 0;
    while not EOF(F) do
    begin
      Readln(F);
      Inc(Result);
    end;
    CloseFile(f);
    Exit(Result);
  end;

  function NextRandTimes(var DB: TSdfDataSet): integer;
  var
    LC: integer;
    LoopIndex: integer;
    RandIdx: integer;
  begin
    Randomize;
    LC := LineCount(DB.FileName) - 2;
    RandIdx := Random(LC + 1);
    DB.First;
    if (LC = 0) or (RandIdx <= 0) then
    begin
      Exit(0);
    end
    else
    begin
      for LoopIndex := 0 to RandIdx - 1 do
        DB.Next;
    end;
    Exit(RandIdx);
  end;

  function GoToIndex(var DB: TSdfDataSet; DBIdx: integer): integer;
  var
    LoopIndex: integer;
  begin
    DB.First;
    if DBIdx = 0 then
    begin
      Exit(0);
    end
    else
    begin
      for LoopIndex := 0 to DBIdx - 1 do
        DB.Next;
    end;
    Exit(DBIdx);
  end;

begin
  AssignFile(TimeFile, TIME_FILE_PATH);
  Reset(TimeFile);
  Readln(TimeFile, UnixTS);
  Readln(TimeFile, PDBIndex);
  if IsDBEmpty(SdfPeople) then
  begin
    RandQuoteLabel.Caption := Format(RandQuoteLabel.Caption, ['Ciclano']);
    RandQuoteMemo.Lines.Add('Ops. Não foram encontradas frases na memória...');
    RandQuoteMemo.Lines.Add('Que tal se tornar o primeiro a escrever uma?');
  end;
  // Se passou mais de uma hora desde a ultima hora exata (15:00, 16:00, etc),
  // seleciona outra frase e atualiza a hora
  if (UnixTS = 0) or (GetUnixNow() >= (double(UnixTS) + double(HOUR_IN_SECONDS))) then
  begin
    TimeOffset := GetUnixNow() mod HOUR_IN_SECONDS;
    UnixTS := GetUnixNow() - TimeOffset;
    if not IsDBEmpty(SdfPeople) then
    begin
      NewIndex := PDBIndex;
      while PDBIndex = NewIndex do
      begin
        PDBIndex := NextRandTimes(SdfPeople);
      end;
    end;
  end
  else
  begin
    PDBIndex := GoToIndex(SdfPeople, PDBIndex);
  end;
  RndName := SdfPeople.FieldByName('FieldName').AsString;
  RndQuote := SdfPeople.FieldByName('FieldQuote').AsString;
  RandQuoteLabel.Caption := Format(RandQuoteLabel.Caption, [RndName]);
  RandQuoteMemo.Lines.Add(RndQuote);

  Rewrite(TimeFile);
  Writeln(TimeFile, UnixTS);
  Writeln(TimeFile, PDBIndex);
  CloseFile(TimeFile);
end;

procedure SaveQuoteToDB(DBPath: string; PName: string; PQuote: string);
const
  ENTRY_PH: string = '"%s","%s"';
var
  DBFile: TextFile;
begin
  AssignFile(DBFile, DBPath);
  Append(DBFile);
  Writeln(DBFile, Format(ENTRY_PH, [PName, PQuote]));
  CloseFile(DBFile);
  Application.MessageBox('Enviada com sucesso!', 'Guest Book', 0);
end;

procedure TForm1.SendBtnClick(Sender: TObject);
begin
  if (Trim(NameLEdit.Text) = '') or (YourQuoteMemo.Lines.Count = 0) then
  begin
    Application.MessageBox(
      'Você deixou pelo menos 1 dos campos vazios! Por favor escreva algo em ambos os locais disponíveis e tente novamente.',
      'Guest Book', 0);
    exit;
  end
  else
  begin
    SaveQuoteToDB(SdfPeople.Filename, NameLEdit.Text, YourQuoteMemo.Lines.Text);
  end;
end;

end.
