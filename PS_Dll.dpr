{************************************************************}
{                                                            }
{       Библиотека PS_Dll сожержит процедуры и функции       }
{       наиболее часто использующиеся в проектах             }
{                                                            }
{       ver. 1.8 06-05-2022                                  }
{                                                            }
{************************************************************}

library PS_Dll;

uses
  ShareMem, SysUtils, Classes, Des in 'Des.pas', psnMD5 in 'psnMD5.pas',
    ShellApi, Windows, libeay32 in 'libeay32.pas',
    WinSock { D7 Controls, Dialogs };


{ Функция RoundCurrency округляет передаваемое ей значение до указанного
  количества знаков после запятой }

function RoundCurrency(Value: Double; Accuracy: Byte): Double;
begin

  case Accuracy of
    0: RoundCurrency := Round(Value);
    1: RoundCurrency := Round((Value + 0.0001) * 10) / 10;
    2: RoundCurrency := Round((Value + 0.00001) * 100) / 100;
  else
    RoundCurrency := Value;
  end;

end;


{ Функция DosToWin преобразует кодировку строки из Dos CP866
  в кодировку Windows-1251 }

function DosToWin(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalString: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
          128..178: LocalString := LocalString + Chr(Ord(InString[I]) + 64);
          179: LocalString := LocalString + Chr(124);
          180: LocalString := LocalString + Chr(43);
          191: LocalString := LocalString + Chr(43);
          192: LocalString := LocalString + Chr(43);
          193: LocalString := LocalString + Chr(43);
          194: LocalString := LocalString + Chr(43);
          195: LocalString := LocalString + Chr(43);
          196: LocalString := LocalString + Chr(45);
          197: LocalString := LocalString + Chr(43);
          217: LocalString := LocalString + Chr(43);
          218: LocalString := LocalString + Chr(43);
          224..239: LocalString := LocalString + Chr(Ord(InString[I]) + 16);
      else
        LocalString := LocalString + InString[I];
      end;

    end;

  DosToWin := LocalString;

end;


{ Функция WinToDos преобразует кодировку строки из Windows-1251
  в кодировку Dos CP866 }

function WinToDos(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalString: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
          166: LocalString := LocalString + Chr(124);
          185: LocalString := LocalString + ' ';
          192..239: LocalString := LocalString + Chr(Ord(InString[I]) - 64);
          240..255: LocalString := LocalString + Chr(Ord(InString[I]) - 16);
      else
          LocalString := LocalString + InString[I];
      end;
    end;

  WinToDos := LocalString;
end;


{ Преобразование разделителя целой и дробной части (, -> .), представленного
  в строковом виде }

function ChangeSeparator(InStringFloat: ShortString): ShortString;
var
  LocalString: ShortString;
begin

  if Pos(',' ,InStringFloat) <> 0
    then
      begin

        LocalString := Copy(InStringFloat, 1, Pos(',', InStringFloat) - 1) + '.'
          + COPY(InStringFloat, Pos(',', InStringFloat) + 1,
          Length(InStringFloat) - Pos(',' , InStringFloat));

        if (Length(LocalString) - Pos('.', LocalString)) = 1 then
          LocalString:=LocalString+'0';

        ChangeSeparator := LocalString;

      end
  else ChangeSeparator := InStringFloat + '.00';

end;


{ Преобразование разделителя целой и дробной части (. -> ,), представленного
  в строковом виде }

function ChangeSeparator2(InStringFloat: ShortString): ShortString;
var
  LocalString: ShortString;
begin

  if Pos('.', InStringFloat)<>0 then
      begin
        LocalString := Copy(InStringFloat, 1, Pos('.' ,InStringFloat) - 1)
          + ',' + COPY(InStringFloat, Pos('.' , InStringFloat) + 1,
          Length(InStringFloat) - Pos('.', InStringFloat));

        if (Length(LocalString) - Pos('.', LocalString)) = 1 then
          LocalString := LocalString + '0';

        ChangeSeparator2 := LocalString;

      end
  else ChangeSeparator2 := InStringFloat + ',00';

end;


{ Фиксированная строка, выравнивание влево }

function LeftFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    LeftFixString := Copy(Trim(InString), 1, InFixPosition)
  else LeftFixString := Trim(InString) + StringOfChar(' ', InFixPosition
    - Length(Trim(InString)));

end;


{ Фиксированная строка, выравнивание вправо }

function RightFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    RightFixString := Copy(Trim(InString), 1, InFixPosition)
  else RightFixString:=StringOfChar(' ', InFixPosition - Length(Trim(InString)))
    + Trim(InString);

end;


{ Фиксированная строка, выравнивание по центру }

function CentrFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  InString := Trim(InString);

  if Length(Trim(InString)) >= InFixPosition then
    CentrFixString := Copy(Trim(InString), 1, InFixPosition)
  else
    begin
      CentrFixString:=StringOfChar(' ', Trunc((InFixPosition
        - Length(Trim(InString))) / 2)) + Trim(InString)
        + StringOfChar(' ', InFixPosition
        - Trunc((InFixPosition - Length(Trim(InString)))/2));
    end;

end;


{ Преобразование суммы из prn-файла }

function PrnSum(InString: ShortString): ShortString;
var
    I: 0..50;
    TrSum: ShortString;
begin

  TrSum := '';

  for I := 1 to Length(InString) do
    begin
      if ((InString[I] <> ' ') and ((InString[I] = '0') or (InString[I] = '1')
        or (InString[I] = '2') or (InString[I] = '3') or (InString[I] = '4')
        or (InString[I] = '5') or (InString[I] = '6') or (InString[I] = '7')
        or (InString[I] = '8') or (InString[I]='9'))) then
        TrSum := TrSum + InString[I];
      if (InString[I] = '-') or (InString[I] = '.') or (InString[I] = ',') then
        TrSum:=TrSum + ',';
    end;

  prnSum:=TrSum;

end;


{ Преобразование строки '25 000,25' в число 25000,25 }

function TrSum(InString: ShortString): Double;
var
  I: 0..50;
  TrSumStr: ShortString;
begin

  TrSumStr := '';

  for I := 1 to Length(InString) do
    if ((InString[I] <> ' ') and ((InString[I] = ',') or (InString[I] = '0')
      or (InString[I] = '1') or (InString[I] = '2') or (InString[I] = '3')
      or (InString[I] = '4') or (InString[I] = '5') or (InString[I] = '6')
      or (InString[I] = '7') or (InString[I] = '8') or (InString[I] = '9'))) then
        TrSumStr := TrSumStr + InString[I];

  TrSum := StrToFloat(TrSumStr);

end;


{ Преобразование текстовой даты "ДД.ММ.ГГГГ" в банковский день типа Int }

function BnkDay(InValue: ShortString): Word;
var
  CountDate: Word;
  WorkindDate: TDate;
  YearVar, MonthVar, DayVar: Word;
begin

  CountDate := 1;
  DecodeDate(StrToDate(InValue), YearVar, MonthVar, DayVar);
  WorkindDate := StrToDate('01.01.' + IntToStr(YearVar));

  while WorkindDate < StrToDate(InValue) do
    begin
      WorkindDate := WorkindDate + 1;
      CountDate := CountDate + 1;
    end;

  BnkDay := CountDate;

end;


{ Функция преобразует дату 01.01.2002 в строку '01/01/2002' }

function DiaStrDate(InValue: TDate): ShortString;
begin

  DiaStrDate := Copy(DateToStr(InValue), 1, 2) + '/'
    + Copy(DateToStr(InValue), 4, 2) +'/' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция преобразует дату 01.01.2002 в строку '"01" января 2002 г.' }

function PropisStrDate(InValue: TDate): ShortString;
var
  PropisStrDateTmp: ShortString;
begin

  PropisStrDateTmp := '"' + Copy(DateToStr(InValue), 1, 2) + '"';

  case StrToInt(COPY(DateToStr(InValue), 4, 2)) of
      1: PropisStrDateTmp := PropisStrDateTmp + ' января ';
      2: PropisStrDateTmp := PropisStrDateTmp + ' февраля ';
      3: PropisStrDateTmp := PropisStrDateTmp + ' марта ';
      4: PropisStrDateTmp := PropisStrDateTmp + ' апреля ';
      5: PropisStrDateTmp := PropisStrDateTmp + ' мая ';
      6: PropisStrDateTmp := PropisStrDateTmp + ' июня ';
      7: PropisStrDateTmp := PropisStrDateTmp + ' июля ';
      8: PropisStrDateTmp := PropisStrDateTmp + ' августа ';
      9: PropisStrDateTmp := PropisStrDateTmp + ' сентября ';
      10: PropisStrDateTmp := PropisStrDateTmp + ' октября ';
      11: PropisStrDateTmp := PropisStrDateTmp + ' ноября ';
      12: PropisStrDateTmp := PropisStrDateTmp + ' декабря ';
     end;

  PropisStrDateTmp := PropisStrDateTmp + COPY(DateToStr(InValue), 7, 4) + ' г.';
  PropisStrDate := PropisStrDateTmp;

end;


{ Функция определяет в передаваемой строке, позицию номера сепаратора ^ }

function FindSeparator(InString: ShortString; NumberOfSeparator: Byte): Byte;
var
  I, CounterSeparatorVar: Byte;
begin

  FindSeparator := 0;
  CounterSeparatorVar := 0;

  for I := 1 to Length(InString) do
    begin

      if InString[I] = '^' then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
          begin
            FindSeparator := I;
            Exit;
          end;
    end;

end;


{ Функция определяет в передаваемой строке, позицию номера передаваемого символа }

function FindChar(InString: ShortString; InChar: Char; NumberOfSeparator: Byte): Byte;
var
  I, CounterSeparatorVar: Byte;
begin

  FindChar:=0;
  CounterSeparatorVar:=0;

  for I:=1 to Length(InString) do
    begin

      if Copy(InString, I, 1) = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
          begin
            FindChar := I;
            Exit;
          end;
    end;

end;


{ Функция определяет в передаваемой широкой строке, позицию номера передаваемого символа }

function FindCharWideString(InString: String; InChar: Char; NumberOfSeparator: Word): Word;
var
  I, CounterSeparatorVar: Word;
begin

  FindCharWideString := 0;
  CounterSeparatorVar := 0;

  for I:=1 to Length(InString) do
    begin
      if InString[I] = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
        begin
          FindCharWideString := I;
          Exit;
        end;
    end;

end;


{ Функция определяет в передаваемой широкой строке, позицию номера передаваемого символа }

function FindCharWideString2(InString: WideString; InChar: Char; NumberOfSeparator: Word): Longword;
var
  I: Longword;
  CounterSeparatorVar: Word;
begin

  FindCharWideString2:=0;
  CounterSeparatorVar:=0;

  for I := 1 to Length(InString) do
    begin

      if Copy(InString, I, 1) = InChar then
        CounterSeparatorVar := CounterSeparatorVar + 1;

      if (CounterSeparatorVar = NumberOfSeparator) then
        begin
          FindCharWideString2 := I;
          Exit;
        end;
    end;
end;


{ Функция определяет в передаваемой строке, позицию пробела }

function FindSpace(InString: ShortString; NumberOfSpace: Byte): Byte;
var
  I, CounterSpaceVar: Byte;
begin

  FindSpace := 0;
  CounterSpaceVar := 0;

  for I := 1 to Length(InString) do
    begin

      if InString[I] = ' ' then
        CounterSpaceVar := CounterSpaceVar + 1;

      if (CounterSpaceVar = NumberOfSpace) then
        begin
          FindSpace := I;
          Exit;
        end;

    end;

end;


{ Подсчет числа вхождений символа InChar в строку InString }

function countCharInString(InString: WideString; InChar: ShortString): Word;
var InStringTmp: WideString;
    Count: Word;
begin

  Count := 0;
  InStringTmp := InString;

  while Pos(InChar, InStringTmp) <> 0 do
    begin
      Count := Count + 1;
      InStringTmp := Copy(InStringTmp, Pos(InChar, InStringTmp) + 1,
        Length(InStringTmp) - Pos(InChar, InStringTmp));
    end;

  Result := Count;

end;


{ Функция преобразует Win строку 'Abcd' -> 'ABCD' }

function Upper(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: string;
begin

  for I := 1 to Length(InString) do
    begin

      case Ord(InString[I]) of
        97..122: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
        184: LocalStr := LocalStr + Chr(Ord(InString[I]) - 16);
        224..255: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
      else
        LocalStr := LocalStr + InString[I];
      end;

    end;

  Result := LocalStr;

end;


{ Функция преобразует Win строку 'abcd' -> 'Abcd' }

function Proper(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: String;
begin

  for I := 1 to Length(InString) do
    begin
      if I = 1 then
        case Ord(InString[I]) of
          97..122: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
          184: LocalStr := LocalStr + Chr(Ord(InString[I]) - 16);
          224..255: LocalStr := LocalStr + Chr(Ord(InString[I]) - 32);
        else
          LocalStr := LocalStr + InString[I];
        end
      else
          case Ord(InString[I]) of
            65..90   : LocalStr:=LocalStr + Chr(Ord(InString[I]) + 32);
            168      : LocalStr:=LocalStr + Chr(Ord(InString[I]) + 16);
            192..223 : LocalStr:=LocalStr + Chr(Ord(InString[I]) + 32);
          else
            LocalStr := LocalStr + InString[I];
          end;
    end;

  Result := LocalStr;
end;


{ Функция преобразует Win строку 'ABCD' -> 'abcd' }

function Lower(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: string;
begin
  for I:=1 to Length(InString) do
    begin
      case Ord(InString[I]) of
        65..90: LocalStr := LocalStr + Chr(Ord(InString[I]) + 32);
        168: LocalStr := LocalStr + Chr(Ord(InString[I]) + 16);
        192..223: LocalStr := LocalStr + Chr(Ord(InString[I]) + 32);
      else
        LocalStr := LocalStr + InString[I];
      end;
    end;
  Result := LocalStr;
end;


{ Функция преобразует строку '1000,00' -> '1 000,00' }

function Divide1000(InString: ShortString): ShortString;
var
  I, Count: -1..100;
  AfterPoint: boolean;
  TmpString: ShortString;
begin
  TmpString:='';
  if (Pos('.', InString) <> 0) or (Pos(',', InString)<>0) then
    begin
      AfterPoint := False;
      Count := -1;
    end
  else
    begin
      AfterPoint:=True;
      Count:=0;
    end;

  for I := 0 to Length(InString) - 1 do
    begin
      if (Copy(InString, Length(InString) - I, 1) = '.')
        or (Copy(InString, Length(InString) -I, 1) = ',') then
          AfterPoint := True;

      if (AfterPoint = True) then
        Count := Count + 1;

      if (AfterPoint = True) and ((Count = 3) or (Count = 6) or (Count = 9)
        or (Count = 12)) then
          TmpString := ' ' + Copy(InString, Length(InString) -I, 1) + TmpString
      else TmpString := Copy(InString, Length(InString) -I, 1) + TmpString;

    end;

  Result := Trim(TmpString);
end;


{ Функция возвращает параметр с заданным именем из ini-файла; Если нет ini
  - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND' }

function paramFromIniFile(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string[255];
  StrokaVar: ANSIString;
begin

  ParamFromIniFileVar := 'PARAMETR_NOT_FOUND';

  if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InIniFile)) = True then
    begin
        AssignFile(IniFileVar, ExtractFilePath(ParamStr(0)) + Trim(InIniFile));
        Reset(IniFileVar);
        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (COPY(StrokaVar, 1, 1)<>';') then
              begin

                if (Copy(StrokaVar, 1, Pos('=', StrokaVar) -1) = Trim(InParam)) then
                  ParamFromIniFileVar := Trim(Copy(StrokaVar, (Pos('=', StrokaVar) + 1), 255));

              end;

          end;
        CloseFile(IniFileVar);
    end
  else
    begin
      ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
      { D7 MessageDlg('Не найден файл '+ExtractFilePath(ParamStr(0))+Trim(inIniFile)+'!', mtError, [mbOk],0); }
    end;

  { D7 if ParamFromIniFileVar = 'PARAMETR_NOT_FOUND' then
     MessageDlg('В файле ' + ExtractFilePath(ParamStr(0)) + Trim(inIniFile)+' не найден параметр ' + Trim(inParam) + '!', mtError, [mbOk],0); }

  Result := ParamFromIniFileVar;
end;


{ Функция возвращает параметр с заданным именем из ini-файла; Если нет ini
  - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND' }

function ParamFromIniFileWithOutMessDlg(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string[255];
  StrokaVar: ANSIString;
begin

  ParamFromIniFileVar:='PARAMETR_NOT_FOUND';

  if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InIniFile)) = True then
    begin
        AssignFile(IniFileVar, ExtractFilePath(ParamStr(0)) + Trim(InIniFile));
        Reset(IniFileVar);
        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (Copy(StrokaVar, 1, 1) <> ';') then
                begin

                  if (Copy(StrokaVar, 1, Pos('=', StrokaVar) -1) = Trim(InParam)) then
                    ParamFromIniFileVar := Trim(Copy(StrokaVar, (Pos('=', StrokaVar) + 1), 255));

                end;

          end;
        CloseFile(IniFileVar);
    end
  else
    begin
      ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
    end;

  Result := ParamFromIniFileVar;

end;


{ Функция возвращает параметр с заданным именем из ini-файла; Если нет ini
  - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
  Результат в WideString }

function ParamFromIniFileWithOutMessDlg2(InIniFile: ShortString; InParam: ShortString): WideString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: WideString;
  StrokaVar: WideString;
begin

  ParamFromIniFileVar := 'PARAMETR_NOT_FOUND';

  if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InIniFile)) = True then
    begin
        AssignFile(IniFileVar, ExtractFilePath(ParamStr(0)) + Trim(InIniFile));
        Reset(IniFileVar);
        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (Copy(StrokaVar, 1, 1) <> ';') then
              begin
                if Trim(Copy(StrokaVar, 1, Pos('=', StrokaVar) -1) ) = Trim(InParam) then
                  ParamFromIniFileVar := Trim(Copy(StrokaVar, (POS('=', StrokaVar) + 1), 255));
              end;

          end;
        CloseFile(IniFileVar);
      end
    else
      begin
        ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
      end;

  Result:=ParamFromIniFileVar;

end;


{ Имя к ini-файлу полное - Функция возвращает параметр с заданным
  именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'.
  Если нет параметра - 'PARAMETR_NOT_FOUND' }

function ParamFromIniFileWithFullPath(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string[255];
  StrokaVar: ANSIString;
begin

  ParamFromIniFileVar := 'PARAMETR_NOT_FOUND';
  InIniFile := Trim(InIniFile);
  if FileExists(InIniFile) = True then
    begin
        AssignFile(IniFileVar, InIniFile);
        Reset(IniFileVar);
        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (Copy(StrokaVar, 1, 1) <> ';') then
              begin

                IF (Copy(StrokaVar, 1, Pos('=', StrokaVar) -1) = Trim(InParam)) then
                  ParamFromIniFileVar := Trim(Copy(StrokaVar, (Pos('=', StrokaVar) + 1), 255));

              end;

          end;
        CloseFile(IniFileVar);
    end
  else
    begin
        ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
        { D7 MessageDlg('Не найден файл ' + InIniFile + '!', mtError, [mbOk],0); }
    end;

  { D7 IF ParamFromIniFileVar = 'PARAMETR_NOT_FOUND' then
   MessageDlg('В файле ' + ExtractFilePath(InIniFile) + ' не найден параметр '
     + Trim(InParam) + '!', mtError, [mbOk], 0); }

  Result := ParamFromIniFileVar;

end;


{ Имя к ini-файлу полное - Функция возвращает параметр с заданным именем
  из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'.
  Если нет параметра - 'PARAMETR_NOT_FOUND' без MessageDlg }

function ParamFromIniFileWithFullPathWithOutMessDlg(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string[255];
  StrokaVar: ANSIString;
begin
  ParamFromIniFileVar := 'PARAMETR_NOT_FOUND';
  InIniFile := Trim(InIniFile);

  if FileExists(InIniFile) = True then
    begin
        AssignFile(IniFileVar, InIniFile);
        Reset(IniFileVar);
        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (Copy(StrokaVar, 1, 1) <> ';') then
              begin

                if (Copy(StrokaVar, 1, Pos('=', StrokaVar) -1) = Trim(InParam)) then
                  ParamFromIniFileVar := Trim(Copy(StrokaVar, (Pos('=', StrokaVar) + 1), 255));

              end;

          end;
        CloseFile(IniFileVar);
    end
    else
      begin
        ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
      end;

  Result := ParamFromIniFileVar;

end;


{ Функция ищет ini файл и параметр в нем; Если все нормально
  - возвращается значение параметра,
  если нет - то заначение функциий 'INIFILE_NOT_FOUND' или 'PARAMETR_NOT_FOUND' }

function ParamFoundFromIniFile(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string[255];
  StrokaVar: ANSIString;
begin

  ParamFromIniFileVar := 'PARAMETR_NOT_FOUND';

  if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InIniFile)) = True then
    begin
        AssignFile(IniFileVar, ExtractFilePath(ParamStr(0)) + Trim(InIniFile));
        Reset(IniFileVar);

        while Eof(IniFileVar) = false do
          begin
            Readln(IniFileVar, StrokaVar);

            if (Copy(StrokaVar, 1, 1) <> ';') then
              begin

                if (Copy(StrokaVar, 1, Pos('=', StrokaVar) - 1) = Trim(InParam)) then
                  ParamFromIniFileVar := Trim(Copy(StrokaVar, (Pos('=', StrokaVar) + 1), 255));

              end;

          end;
        CloseFile(IniFileVar);
    end
  else
    begin
      ParamFromIniFileVar := 'INIFILE_NOT_FOUND';
    end;

  Result := ParamFromIniFileVar;
end;


{ Функция добавляет перед числом нули 1 до нужного количества знаков '0001' }

function BeforZero(InValue: Integer; InLength: Word): ShortString;
var
  I: Word;
  StringZero: ShortString;
begin
  StringZero:='';

  for I := 1 to (InLength - Length(IntToStr(InValue))) do
    StringZero:=StringZero + '0';

  Result := StringZero + IntToStr(InValue);
end;


 { Автонумерация документа из 12-х знаков с ведением электронного жунала }

function ID12docFromJournal(InJournal: ShortString; InNameDoc: ShortString): Word;
var
  TxtJournal: TextFile;
  StrokaVar: ShortString;
  IdDocVar: Word;
begin

  IdDocVar:=0;
  if FileExists(ExtractFilePath(ParamStr(0)) + InJournal) = True then
    begin
      AssignFile(TxtJournal, ExtractFilePath(ParamStr(0)) + InJournal);
      Reset(TxtJournal);
      while Eof(TxtJournal) = false do
        begin
          Readln(TxtJournal, StrokaVar);
          if ((Copy(StrokaVar, 1, 1) = '0') or (Copy(StrokaVar, 1, 1) = '1')
            or(Copy(StrokaVar, 1, 1) = '2') or (Copy(StrokaVar, 1, 1) = '3')
            or(Copy(StrokaVar, 1, 1) = '4') or (Copy(StrokaVar, 1, 1) = '5')
            or(Copy(StrokaVar, 1, 1) = '6') or (Copy(StrokaVar, 1, 1) = '7')
            or(Copy(StrokaVar, 1, 1) = '8') or (Copy(StrokaVar, 1, 1) = '9'))
            then IdDocVar := StrToInt(Trim(Copy(StrokaVar, 1, 12)));
        end;
        CloseFile(TxtJournal);
    end;

  if IdDocVar = 999999999999 then
    IdDocVar:=1
  else IdDocVar := IdDocVar + 1;

  AssignFile(TxtJournal, ExtractFilePath(ParamStr(0)) + InJournal);
  if FileExists(ExtractFilePath(ParamStr(0))+InJournal)=True then
    Append(TxtJournal)
  else
    begin
      ReWrite(TxtJournal);
      WriteLn(TxtJournal, 'Филиал АБ "Газпромбанк" (ЗАО) в г.Белоярский');
      WriteLn(TxtJournal, 'Отдел Банковских карт');
      WriteLn(TxtJournal, ' ');
      WriteLn(TxtJournal, 'Электронный журнал регистрации документов');
      WriteLn(TxtJournal, 'Начат: '+DateToStr(Now));
      WriteLn(TxtJournal, '------------------------------------------------------------------------------------------');
      WriteLn(TxtJournal, '      #     |   Дата   |                        Примечание                               |');
      WriteLn(TxtJournal, '------------------------------------------------------------------------------------------');
    end;
  WriteLn(TxtJournal, LeftFixString(IntToStr(IdDocVar), 12) + '|'
    + DateToStr(Now) + '|' + DosToWin(InNameDoc));
  CloseFile(TxtJournal);
  Result:=IdDocVar;
end;


{ Преобразование даты в формате cтроки в Integer }

function DateTimeToSec(InValue: ShortString): Integer;
begin
  Result := Round((StrToDate(Copy(InValue, 1, 2) + '.' + Copy(InValue, 4, 2) + '.20'
    + Copy(InValue, 7, 2)) - StrToDate('01.01.2000'))) * 86400
    + StrToInt(Copy(InValue, 16, 2)) + StrToInt(Copy(InValue, 13, 2)) * 60
    + StrToInt(Copy(InValue, 10, 2)) * 3600;
end;


{ Преобразование стироки String в PChar }

function StrToPchar(InString: string): Pchar;
begin
  InString := InString + #0;
  Result := StrPCopy(@InString[1], InString);
end;


{ Процедура выводит в лог файл с именем InFileName строку InString
с переводом каретки если InLn = 'Ln' }

procedure ToLogFileWithName(InFileName: ShortString; InString: ShortString; InLn: ShortString);
var
  LogFile: TextFile;
begin

  try
    AssignFile(LogFile, ExtractFilePath(ParamStr(0)) + Trim(InFileName));
    if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InFileName)) = True then
      Append(LogFile)
    else ReWrite(LogFile);

    if InLn = 'Ln' then
      WriteLn(LogFile, DateToStr(Now) + ' ' + TimeToStr(Now) + ': ' + InString)
      else Write(LogFile, ' ' + InString);
    CloseFile(LogFile);
  except
    on E: Exception do WriteLn(E.Message);
  end;

end;


{ Процедура выводит в лог файл с Широкой строкой с именем InFileName
строку InString с переводом каретки если InLn = 'Ln' }

procedure ToLogFileWideStringWithName(InFileName: ShortString; InString: string; InLn: ShortString);
var
  LogFile:TextFile;
begin

  try
    AssignFile(LogFile, ExtractFilePath(ParamStr(0)) + Trim(InFileName));
    if FileExists(ExtractFilePath(ParamStr(0)) + Trim(InFileName)) = True then
      Append(LogFile)
    else ReWrite(LogFile);
    if InLn = 'Ln' then WriteLn(LogFile, DateToStr(Now) + ' ' + TimeToStr(Now)
      + ': ' + InString)
    else Write(LogFile, ' ' + InString);
    CloseFile(LogFile);
  except
    on E: Exception do WriteLn(E.Message);
  end;

end;


{ Полный путь к log-файлу }

procedure ToLogFileWithFullName(InFileName: ShortString; InString: ShortString; InLn: ShortString);
var
  LogFile: TextFile;
begin
  AssignFile(LogFile, InFileName);
  if FileExists(InFileName) = True then
    Append(LogFile)
  else ReWrite(LogFile);
  if InLn = 'Ln' then
    WriteLn(LogFile, DateToStr(Now) + ' ' + TimeToStr(Now) + ': ' + InString)
  else Write(LogFile, ' ' + InString);
  CloseFile(LogFile);
end;


{ Полный путь к лог-файлу с использованием WideString }

procedure ToLogFileWideStringWithFullName(InFileName: ShortString; InString: WideString; InLn: ShortString);
var
  LogFile: TextFile;
begin
  AssignFile(LogFile, InFileName);
  if FileExists(InFileName) = True then
    Append(LogFile)
  else ReWrite(LogFile);
  if InLn = 'Ln' then
    WriteLn(LogFile, DateToStr(Now) + ' ' + TimeToStr(Now) + ': ' + InString)
  else Write(LogFile, ' ' + InString);
  CloseFile(LogFile);
end;


{ Функция преобразует строку Кириллицы в Латиницу по таблице транслитерации
  с www.beonline.ru }

function TranslitBeeLine(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: string;
begin
  for I := 1 to Length(InString) do
    begin
      case InString[I] of
        'Й': LocalStr := LocalStr + 'J';
        'Ц': LocalStr := LocalStr + 'TS';
        'У': LocalStr := LocalStr + 'U';
        'К': LocalStr := LocalStr + 'K';
        'Е': LocalStr := LocalStr + 'E';
        'Н': LocalStr := LocalStr + 'N';
        'Г': LocalStr := LocalStr + 'G';
        'Ш': LocalStr := LocalStr + 'SH';
        'Щ': LocalStr := LocalStr + 'SCH';
        'З': LocalStr := LocalStr + 'Z';
        'Х': LocalStr := LocalStr + 'H';
        'Ъ': LocalStr := LocalStr + '"';
        'Ф': LocalStr := LocalStr + 'F';
        'Ы': LocalStr := LocalStr + 'Y';
        'В': LocalStr := LocalStr + 'V';
        'А': LocalStr := LocalStr + 'A';
        'П': LocalStr := LocalStr + 'P';
        'Р': LocalStr := LocalStr + 'R';
        'О': LocalStr := LocalStr + 'O';
        'Л': LocalStr := LocalStr + 'L';
        'Д': LocalStr := LocalStr + 'D';
        'Ж': LocalStr := LocalStr + 'ZH';
        'Э': LocalStr := LocalStr + 'E';
        'Я': LocalStr := LocalStr + 'YA';
        'Ч': LocalStr := LocalStr + 'CH';
        'С': LocalStr := LocalStr + 'S';
        'М': LocalStr := LocalStr + 'M';
        'И': LocalStr := LocalStr + 'I';
        'Т': LocalStr := LocalStr + 'T';
        'Ь': LocalStr := LocalStr + '"';
        'Б': LocalStr := LocalStr + 'B';
        'Ю': LocalStr := LocalStr + 'YU';
        'й': LocalStr := LocalStr + 'j';
        'ц': LocalStr := LocalStr + 'ts';
        'у': LocalStr := LocalStr + 'u';
        'к': LocalStr := LocalStr + 'k';
        'е': LocalStr := LocalStr + 'e';
        'н': LocalStr := LocalStr + 'n';
        'г': LocalStr := LocalStr + 'g';
        'ш': LocalStr := LocalStr + 'sh';
        'щ': LocalStr := LocalStr + 'sch';
        'з': LocalStr := LocalStr + 'z';
        'х': LocalStr := LocalStr + 'h';
        'ъ': LocalStr := LocalStr + '"';
        'ф': LocalStr := LocalStr + 'f';
        'ы': LocalStr := LocalStr + 'y';
        'в': LocalStr := LocalStr + 'v';
        'а': LocalStr := LocalStr + 'a';
        'п': LocalStr := LocalStr + 'p';
        'р': LocalStr := LocalStr + 'r';
        'о': LocalStr := LocalStr + 'o';
        'л': LocalStr := LocalStr + 'l';
        'д': LocalStr := LocalStr + 'd';
        'ж': LocalStr := LocalStr + 'zh';
        'э': LocalStr := LocalStr + 'e';
        'я': LocalStr := LocalStr + 'ya';
        'ч': LocalStr := LocalStr + 'ch';
        'с': LocalStr := LocalStr + 's';
        'м': LocalStr := LocalStr + 'm';
        'и': LocalStr := LocalStr + 'i';
        'т': LocalStr := LocalStr + 't';
        'ь': LocalStr := LocalStr + '"';
        'б': LocalStr := LocalStr + 'b';
        'ю': LocalStr := LocalStr + 'yu';
        else LocalStr := LocalStr + InString[I];
      end;
    end;
  Result := LocalStr;
end;


{ Функция преобразует дату 06.05.2006 (06 мая 2006) в строку формата MS SQL '05.06.2006'
     06.05.2006 10:01:05 }

function FormatMsSqlDate(InValue: TDate): ShortString;
begin
  Result := Copy(DateToStr(InValue), 4, 2) + '.' + Copy(DateToStr(InValue), 1, 2)
    + '.' + Copy(DateToStr(InValue), 7, 4);
end;


{ Функция преобразует строку в формате даты и времени
  TTimeStamp '04-04-2007 15:22:11 +0300' в тип TDateTime
  ( корректировку часового пояса +0300 не учитывая ) }

function StrFormatTimeStampToDateTime(InStrFormatTimeStamp: ShortString): TDateTime;
begin
  Result := StrToDateTime(Copy(InStrFormatTimeStamp, 1, 2) + '.'
    + Copy(InStrFormatTimeStamp, 4, 2) + '.'
    + Copy(InStrFormatTimeStamp, 7, 4) + '.'
    + ' ' + Copy(InStrFormatTimeStamp, 12, 8));
end;


{ Функция преобразует строку в формате даты и времени
  TTimeStamp '04-04-2007 15:22:11 +0300' в строку '04.04.2007 15:22:11'
  ( корректировку часового пояса +0300 не учитываем ) }

function StrTimeStampToStrDateTime(InStrFormatTimeStamp: ShortString): ShortString;
begin

  StrTimeStampToStrDateTime := Copy(InStrFormatTimeStamp, 1, 2) + '.'
    + Copy(InStrFormatTimeStamp, 4, 2) + '.'
    + Copy(InStrFormatTimeStamp, 7, 4) + '. '
    + Copy(InStrFormatTimeStamp, 12, 8);

end;


{ Функция DateTimeToStrFormat преобразует дату и время  01.01.2007 1:02:00
  в строку '0101200710200' }

function DateTimeToStrFormat(In_DateTime: TDateTime): ShortString;
var
  DateTimeToStrFormatVar: ShortString;
begin

  DateTimeToStrFormatVar := StringReplace(DateTimeToStr(In_DateTime), ' ', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar := StringReplace(DateTimeToStrFormatVar, '.', '', [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar := StringReplace(DateTimeToStrFormatVar, ':', '', [rfReplaceAll, rfIgnoreCase]);
  Result := DateTimeToStrFormatVar;

end;


{ Функция DecodeCurCodeToISO преобразует код валюты 810 в ISO: "RUR" }

function DecodeCurCodeToISO(InCurrCode: Word): ShortString;
begin

  case InCurrCode of
    0   : decodeCurCodeToISO := 'RUR';
    4   : decodeCurCodeToISO := 'AFA';  //    Афгани
    8   : decodeCurCodeToISO := 'ALL';  //    Лек
    12  : decodeCurCodeToISO := 'DZD';  //    Алжирский динар
    20  : decodeCurCodeToISO := 'ADP';  //    Андорская песета
    31  : decodeCurCodeToISO := 'AZM';  //    Азербайджанский манат
    32  : decodeCurCodeToISO := 'ARS';  //    Аргентинское песо
    36  : decodeCurCodeToISO := 'AUD';  //    Австралийский доллар
    40  : decodeCurCodeToISO := 'ATS';  //    Шиллинг
    44  : decodeCurCodeToISO := 'BSD';  //    Багамский доллар
    48  : decodeCurCodeToISO := 'BHD';  //    Бахрейнский динар
    50  : decodeCurCodeToISO := 'BDT';  //    Така
    51  : decodeCurCodeToISO := 'AMD';  //    Армянский драм
    52  : decodeCurCodeToISO := 'BBD';  //    Барбадосский доллар
    56  : decodeCurCodeToISO := 'BEF';  //    Бельгийский франк
    60  : decodeCurCodeToISO := 'BMD';  //    Бермудский доллар
    64  : decodeCurCodeToISO := 'BTN';  //    Нгултрум
    68  : decodeCurCodeToISO := 'BOB';  //    Боливиано
    72  : decodeCurCodeToISO := 'BWP';  //    Пула
    84  : decodeCurCodeToISO := 'BZD';  //    Белизский доллар
    90  : decodeCurCodeToISO := 'SBD';  //    Доллар Соломоновых
    96  : decodeCurCodeToISO := 'BND';  //    Брунейский доллар
    100 : decodeCurCodeToISO := 'BGL';  //    Лев
    104 : decodeCurCodeToISO := 'MMK';  //    Кьят
    108 : decodeCurCodeToISO := 'BIF';  //    Бурундийский франк
    116 : decodeCurCodeToISO := 'KHR';  //    Риель
    124 : decodeCurCodeToISO := 'CAD';  //    Канадский доллар
    132 : decodeCurCodeToISO := 'CVE';  //    Эскудо Кабо - Верде
    136 : decodeCurCodeToISO := 'KYD';  //    Доллар Каймановых
    144 : decodeCurCodeToISO := 'LKR';  //    Шри - Ланкийская рупия
    152 : decodeCurCodeToISO := 'CLP';  //    Чилийское песо
    156 : decodeCurCodeToISO := 'CNY';  //    Юань Ренминби
    170 : decodeCurCodeToISO := 'COP';  //    Колумбийское песо
    174 : decodeCurCodeToISO := 'KMF';  //    Франк Коморских
    188 : decodeCurCodeToISO := 'CRC';  //    Костариканский колон
    191 : decodeCurCodeToISO := 'HRK';  //    Куна
    192 : decodeCurCodeToISO := 'CUP';  //    Кубинское песо
    196 : decodeCurCodeToISO := 'CYP';  //    Кипрский фунт
    203 : decodeCurCodeToISO := 'CZK';  //    Чешская крона
    208 : decodeCurCodeToISO := 'DKK';  //    Датская крона
    214 : decodeCurCodeToISO := 'DOP';  //    Доминиканское песо
    218 : decodeCurCodeToISO := 'ECS';  //    Сукре
    222 : decodeCurCodeToISO := 'SVC';  //    Сальвадорский колон
    230 : decodeCurCodeToISO := 'ETB';  //    Эфиопский быр
    232 : decodeCurCodeToISO := 'ERN';  //    Накфа
    233 : decodeCurCodeToISO := 'EEK';  //    Крона
    238 : decodeCurCodeToISO := 'FKP';  //    Фунт Фолклендских
    242 : decodeCurCodeToISO := 'FJD';  //    Доллар Фиджи
    246 : decodeCurCodeToISO := 'FIM';  //    Марка
    250 : decodeCurCodeToISO := 'FRF';  //    Французский франк
    262 : decodeCurCodeToISO := 'DJF';  //    Франк Джибути
    270 : decodeCurCodeToISO := 'GMD';  //    Даласи
    276 : decodeCurCodeToISO := 'DEM';  //    Немецкая марка
    288 : decodeCurCodeToISO := 'GHC';  //    Седи
    292 : decodeCurCodeToISO := 'GIP';  //    Гибралтарский фунт
    300 : decodeCurCodeToISO := 'GRD';  //    Драхма
    320 : decodeCurCodeToISO := 'GTQ';  //    Кетсаль
    324 : decodeCurCodeToISO := 'GNF';  //    Гвинейский франк
    328 : decodeCurCodeToISO := 'GYD';  //    Гайанский доллар
    332 : decodeCurCodeToISO := 'HTG';  //    Гурд
    340 : decodeCurCodeToISO := 'HNL';  //    Лемпира
    344 : decodeCurCodeToISO := 'HKD';  //    Гонконгский доллар
    348 : decodeCurCodeToISO := 'HUF';  //    Форинт
    352 : decodeCurCodeToISO := 'ISK';  //    Исландская крона
    356 : decodeCurCodeToISO := 'INR';  //    Индийская рупия
    360 : decodeCurCodeToISO := 'IDR';  //    Рупия
    364 : decodeCurCodeToISO := 'IRR';  //    Иранский риал
    368 : decodeCurCodeToISO := 'IQD';  //    Иракский динар
    372 : decodeCurCodeToISO := 'IEP';  //    Ирландский фунт
    376 : decodeCurCodeToISO := 'ILS';  //    Новый израильский
    380 : decodeCurCodeToISO := 'ITL';  //    Итальянская лира
    388 : decodeCurCodeToISO := 'JMD';  //    Ямайский доллар
    392 : decodeCurCodeToISO := 'JPY';  //    Йена
    398 : decodeCurCodeToISO := 'KZT';  //    Тенге
    400 : decodeCurCodeToISO := 'JOD';  //    Иорданский динар
    404 : decodeCurCodeToISO := 'KES';  //    Кенийский шиллинг
    408 : decodeCurCodeToISO := 'KPW';  //    Северо - корейская вона
    410 : decodeCurCodeToISO := 'KRW';  //    Вона
    414 : decodeCurCodeToISO := 'KWD';  //    Кувейтский динар
    417 : decodeCurCodeToISO := 'KGS';  //    Сом
    418 : decodeCurCodeToISO := 'LAK';  //    Кип
    422 : decodeCurCodeToISO := 'LBP';  //    Ливанский фунт
    426 : decodeCurCodeToISO := 'LSL';  //    Лоти
    428 : decodeCurCodeToISO := 'LVL';  //    Латвийский лат
    430 : decodeCurCodeToISO := 'LRD';  //    Либерийский доллар
    434 : decodeCurCodeToISO := 'LYD';  //    Ливийский динар
    440 : decodeCurCodeToISO := 'LTL';  //    Литовский лит
    442 : decodeCurCodeToISO := 'LUF';  //    Люксембургский франк
    446 : decodeCurCodeToISO := 'MOP';  //    Патака
    450 : decodeCurCodeToISO := 'MGF';  //    Малагасийский франк
    454 : decodeCurCodeToISO := 'MWK';  //    Квача
    458 : decodeCurCodeToISO := 'MYR';  //    Малайзийский ринггит
    462 : decodeCurCodeToISO := 'MVR';  //    Руфия
    470 : decodeCurCodeToISO := 'MTL';  //    Мальтийская лира
    478 : decodeCurCodeToISO := 'MRO';  //    Угия
    480 : decodeCurCodeToISO := 'MUR';  //    Маврикийская рупия
    484 : decodeCurCodeToISO := 'MXN';  //    Мексиканское песо
    496 : decodeCurCodeToISO := 'MNT';  //    Тугрик
    498 : decodeCurCodeToISO := 'MDL';  //    Молдавский лей
    504 : decodeCurCodeToISO := 'MAD';  //    Марокканский дирхам
    508 : decodeCurCodeToISO := 'MZM';  //    Метикал
    512 : decodeCurCodeToISO := 'OMR';  //    Оманский риал
    516 : decodeCurCodeToISO := 'NAD';  //    Доллар Намибии
    524 : decodeCurCodeToISO := 'NPR';  //    Непальская рупия
    528 : decodeCurCodeToISO := 'NLG';  //    Нидерландский гульден
    532 : decodeCurCodeToISO := 'ANG';  //    Нидерландский
    533 : decodeCurCodeToISO := 'AWG';  //    Арубанский гульден
    548 : decodeCurCodeToISO := 'VUV';  //    Вату
    554 : decodeCurCodeToISO := 'NZD';  //    Новозеландский доллар
    558 : decodeCurCodeToISO := 'NIO';  //    Золотая кордоба
    566 : decodeCurCodeToISO := 'NGN';  //    Найра
    578 : decodeCurCodeToISO := 'NOK';  //    Норвежская крона
    586 : decodeCurCodeToISO := 'PKR';  //    Пакистанская рупия
    590 : decodeCurCodeToISO := 'PAB';  //    Бальбоа
    598 : decodeCurCodeToISO := 'PGK';  //    Кина
    600 : decodeCurCodeToISO := 'PYG';  //    Гуарани
    604 : decodeCurCodeToISO := 'PEN';  //    Новый соль
    608 : decodeCurCodeToISO := 'PHP';  //    Филиппинское песо
    620 : decodeCurCodeToISO := 'PTE';  //    Португальское эскудо
    624 : decodeCurCodeToISO := 'GWP';  //    Песо Гвинеи - Бисау
    626 : decodeCurCodeToISO := 'TPE';  //    Тиморское эскудо
    634 : decodeCurCodeToISO := 'QAR';  //    Катарский риал
    642 : decodeCurCodeToISO := 'ROL';  //    Лей
    643 : decodeCurCodeToISO := 'RUB';  //    Российский рубль
    646 : decodeCurCodeToISO := 'RWF';  //    Франк Руанды
    654 : decodeCurCodeToISO := 'SHP';  //    Фунт Острова Святой
    678 : decodeCurCodeToISO := 'STD';  //    Добра
    682 : decodeCurCodeToISO := 'SAR';  //    Саудовский риял
    690 : decodeCurCodeToISO := 'SCR';  //    Сейшельская рупия
    694 : decodeCurCodeToISO := 'SLL';  //    Леоне
    702 : decodeCurCodeToISO := 'SGD';  //    Сингапурский доллар
    703 : decodeCurCodeToISO := 'SKK';  //    Словацкая крона
    704 : decodeCurCodeToISO := 'VND';  //    Донг
    705 : decodeCurCodeToISO := 'SIT';  //    Толар
    706 : decodeCurCodeToISO := 'SOS';  //    Сомалийский шиллинг
    710 : decodeCurCodeToISO := 'ZAR';  //    Рэнд
    716 : decodeCurCodeToISO := 'ZWD';  //    Доллар Зимбабве
    724 : decodeCurCodeToISO := 'ESP';  //    Испанская песета
    736 : decodeCurCodeToISO := 'SDD';  //    Суданский динар
    740 : decodeCurCodeToISO := 'SRG';  //    Суринамский гульден
    748 : decodeCurCodeToISO := 'SZL';  //    Лилангени
    752 : decodeCurCodeToISO := 'SEK';  //    Шведская крона
    756 : decodeCurCodeToISO := 'CHF';  //    Швейцарский франк
    760 : decodeCurCodeToISO := 'SYP';  //    Сирийский фунт
    764 : decodeCurCodeToISO := 'THB';  //    Бат
    776 : decodeCurCodeToISO := 'TOP';  //    Паанга
    780 : decodeCurCodeToISO := 'TTD';  //    Доллар Тринидада и
    784 : decodeCurCodeToISO := 'AED';  //    Дирхам (ОАЭ)
    788 : decodeCurCodeToISO := 'TND';  //    Тунисский динар
    792 : decodeCurCodeToISO := 'TRL';  //    Турецкая лира
    795 : decodeCurCodeToISO := 'TMM';  //    Манат
    800 : decodeCurCodeToISO := 'UGX';  //    Угандийский шиллинг
    807 : decodeCurCodeToISO := 'MKD';  //    Динар
    810 : decodeCurCodeToISO := 'RUR';  //    Российский рубль
    818 : decodeCurCodeToISO := 'EGP';  //    Египетский фунт
    826 : decodeCurCodeToISO := 'GBP';  //    Фунт стерлингов
    834 : decodeCurCodeToISO := 'TZS';  //    Танзанийский шиллинг
    840 : decodeCurCodeToISO := 'USD';  //    Доллар США
    858 : decodeCurCodeToISO := 'UYU';  //    Уругвайское песо
    860 : decodeCurCodeToISO := 'UZS';  //    Узбекский сум
    862 : decodeCurCodeToISO := 'VEB';  //    Боливар
    882 : decodeCurCodeToISO := 'WST';  //    Тала
    886 : decodeCurCodeToISO := 'YER';  //    Йеменский риал
    891 : decodeCurCodeToISO := 'YUM';  //    Новый динар
    894 : decodeCurCodeToISO := 'ZMK';  //    Квача (замбийская)
    901 : decodeCurCodeToISO := 'TWD';  //    Новый тайваньский
    950 : decodeCurCodeToISO := 'XAF';  //    Франк КФА ВЕАС
    951 : decodeCurCodeToISO := 'XCD';  //    Восточно - карибский
    952 : decodeCurCodeToISO := 'XOF';  //    Франк КФА ВСЕАО
    953 : decodeCurCodeToISO := 'XPF';  //    Франк КФП
    960 : decodeCurCodeToISO := 'XDR';  //    СДР (специальные права
    972 : decodeCurCodeToISO := 'TJS';  //    Сомони
    973 : decodeCurCodeToISO := 'AOA';  //    Кванза
    974 : decodeCurCodeToISO := 'BYR';  //    Белорусский рубль
    975 : decodeCurCodeToISO := 'BGN';  //    Болгарский лев
    976 : decodeCurCodeToISO := 'CDF';  //    Конголезский франк
    977 : decodeCurCodeToISO := 'ВАМ';  //    Конвертируемая марка
    978 : decodeCurCodeToISO := 'EUR';  //    Евро
    980 : decodeCurCodeToISO := 'UAH';  //    Гривна
    981 : decodeCurCodeToISO := 'GEL';  //    Лари
    985 : decodeCurCodeToISO := 'PLN';  //    Злотый
    986 : decodeCurCodeToISO := 'BRL';  //    Бразильский реал
  end;

end;


{ Преобразование строки "01-05" в дату 31.01.2005 }

function CardExpDate_To_Date(InCardExpDate: ShortString): TDate;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin

  DecodeDate(StrToDate('01.' + Copy(InCardExpDate, 1, 2) + '.20'
    + Copy(InCardExpDate, 4, 2)), Year, Month, Day);

  if Month = 12 then
    Result := StrToDate('01.' + IntToStr(1) + '.'
      + IntToStr(StrToInt('20' + Copy(InCardExpDate, 4, 2)) + 1) ) - 1
    else Result := StrToDate('01.' + IntToStr(Month + 1) + '.20'
      + Copy(InCardExpDate, 4, 2)) - 1;

end;


{ Преобразование номера карты по первым 9-ти цифрам в тип карты (филиал) }

function DecodeTypeCard(InCardNumber: ShortString): ShortString;
var
  DecodeTypeCardVar: ShortString;
begin

  DecodeTypeCardVar := 'type not define';
  if (Copy(InCardNumber, 1, 9) = '487417315') then DecodeTypeCardVar := 'VISA Electron';
  if (Copy(InCardNumber, 1, 9) ='487415515') then DecodeTypeCardVar := 'VISA Classic';
  IF (Copy(InCardNumber, 1, 9) ='487416315') then DecodeTypeCardVar := 'VISA Gold';
  IF (Copy(InCardNumber, 1, 9) ='676454115') then DecodeTypeCardVar := 'Maestro';
  IF (Copy(InCardNumber, 1, 9) ='548999015') then DecodeTypeCardVar := 'MasterCard';
  IF (Copy(InCardNumber, 1, 9) ='549000215') then DecodeTypeCardVar := 'MasterCard Gold';

  IF (Copy(InCardNumber, 1, 6) ='602208') then DecodeTypeCardVar := 'Union Card';

  IF (Copy(InCardNumber, 1, 9) ='487417415') then DecodeTypeCardVar := 'VISA Electron Пенсионная';
  IF (Copy(InCardNumber, 1, 9) ='487415415') then DecodeTypeCardVar := 'VISA Classic Пенсионная';
  IF (Copy(InCardNumber, 1, 9) ='487416415') then DecodeTypeCardVar := 'VISA Gold Пенсионная';

  Result := DecodeTypeCardVar;

end;


{ Преобразование номера карты по первым 6-ти цифрам в тип карты (Газпромбанк) }

function DecodeTypeCardGPB(InCardNumber: ShortString): ShortString;
var
  DecodeTypeCardVar:ShortString;
begin

  DecodeTypeCardVar := 'type not define';

  if (Copy(InCardNumber, 1, 6) = '487417') then DecodeTypeCardVar := 'VISA Electron';
  if (Copy(InCardNumber, 1, 6) = '487415') then DecodeTypeCardVar := 'VISA Classic';
  if (Copy(InCardNumber, 1, 6) = '487416') then DecodeTypeCardVar := 'VISA Gold';
  if (Copy(InCardNumber, 1, 6) = '676454') then DecodeTypeCardVar := 'Maestro';
  if (Copy(InCardNumber, 1, 6) = '548999') then DecodeTypeCardVar := 'MasterCard';
  if (Copy(InCardNumber, 1, 6) = '549000') then DecodeTypeCardVar := 'MasterCard Gold';

  Result := DecodeTypeCardVar;

end;


 { Преобразование PChar в String }

function PCharToStr(P:Pchar): string;
begin
  Result := P;
end;


{ Функция преобразует дату 01.01.2002 в строку '01/01/2002' }

function StrDateFormat1(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8  then
    Result := Copy(DateToStr(InValue), 1, 2) + '/'
      + Copy(DateToStr(InValue), 4, 2) + '/' + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + '/'
      + Copy(DateToStr(InValue), 4, 2) + '/' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция StrDateFormat2() преобразует дату 01.01.2002 в строку '01-01-2002' }

function StrDateFormat2(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    Result := Copy(DateToStr(InValue), 1, 2) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-' + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-' + Copy(DateToStr(InValue), 7, 4);

end;


{ Сумма прописью }

function SummaPropis(InSum: Double): WideString;

  function NumbersToStrings(Digit1: Longint; Digit2: Integer): string;
  const
    NumbersInWords: array [1..9] of string [6] = ('один', 'два', 'три', 'четыре',
      'пять', 'шесть', 'семь', 'восемь', 'девять');
    NumbersInWords2: array [1..9] of string [6] = ('одна', 'две', 'три', 'четыре',
      'пять', 'шесть', 'семь', 'восемь', 'девять');
    NumbersInWords3: array [1..9] of string [12] = ('одиннадцать', 'двенадцать',
      'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать',
        'восемнадцать', 'девятнадцать');
    NumbersInWords4: array [1..9] of string [11] = ('десять', 'двадцать',
      'тридцать', 'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят',
        'девяносто');
    NumbersInWords5: array [1..9] of string [9] = ('сто', 'двести', 'триста',
      'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот');
  var
    StringVar: string;
    I: Longint;
  begin

    StringVar := '';

    I := Digit1 div 100;

    if I <> 0 then
      StringVar := NumbersInWords5[I] + ' ';

    Digit1 := Digit1 mod 100;

    I := Digit1 div 10;

    if (Digit1 > 10) and (Digit1 < 20) then
      StringVar := StringVar + NumbersInWords3[Digit1-10] + ' '
    else
      begin
        if I <> 0 then
          StringVar := StringVar + NumbersInWords4[I] + ' ';
          Digit1 := Digit1 mod 10;
          if Digit1 <> 0 then
            if Digit2 = 0 then
              StringVar := StringVar + NumbersInWords2[Digit1] + ' '
            else StringVar := StringVar + NumbersInWords[Digit1] + ' ';
      end;

    NumbersToStrings := StringVar;

  end;

var
  I: Longint;
  J: Longint;
  R: Real;
  StringVar: string;
begin

  StringVar := '';
  J := Trunc(InSum / 1000000000.0);
  R := J;
  R := InSum - R * 1000000000.0;
  I := Trunc(R);

  if J<>0 then
    begin

      StringVar:= StringVar + NumbersToStrings(J, 1) + 'миллиард';

      J := J mod 100;

      if (J>10) and (J<20) then
        StringVar := StringVar + 'ов '
      else
        case J mod 10 of
          0: StringVar := StringVar + 'ов ';
          1: StringVar := StringVar + ' ';
          2..4: StringVar := StringVar + 'а ';
          5..9: StringVar := StringVar + 'ов ';
        end;
    end;

  J := I div 1000000;
  if J <> 0 then
    begin
      StringVar := StringVar + NumbersToStrings(J, 1) + 'миллион';
      J := J mod 100;
      if (J > 10) and (J < 20) then
        StringVar := StringVar + 'ов '
      else
        case J mod 10 of
          0: StringVar := StringVar + 'ов ';
          1: StringVar := StringVar + ' ';
          2..4: StringVar := StringVar + 'а ';
          5..9: StringVar := StringVar + 'ов ';
        end;
    end;

  I := I mod 1000000;
  J := I div 1000;

  if J <> 0 then
    begin

      StringVar := StringVar + NumbersToStrings(J, 0) + 'тысяч';

      J := J mod 100;

      if (J>10) and (J<20) then
        StringVar := StringVar + ' '
      else
        case J mod 10 of
          0: StringVar := StringVar + ' ';
          1: StringVar := StringVar + 'а ';
          2..4: StringVar := StringVar + 'и ';
          5..9: StringVar := StringVar + ' ';
        end;

end;

  I := I mod 1000;

  J := I;

  if J <> 0 then
    StringVar := StringVar + NumbersToStrings(J, 1);

  I := Round(Frac(InSum) * 100.0);

  Result := AnsiUpperCase(Copy(StringVar, 1, 1)) + Copy(StringVar, 2, (Length(StringVar) - 1));

end;


{ Функция SummaPropis2() - сумма прописью второй вариант реализации логики }

function SummaPropis2(InSum: Double): WideString;

  function NumbersToStrings(Digit1: Longint; Digit2: Integer): string;
  const
    NumbersInWords: array [1..9] of string [6] = ('один', 'два', 'три', 'четыре',
      'пять', 'шесть', 'семь', 'восемь', 'девять');
    NumbersInWords2: array [1..9] of string [6] = ('одна', 'две', 'три', 'четыре',
      'пять', 'шесть', 'семь', 'восемь', 'девять');
    NumbersInWords3: array [1..9] of string [12] = ('одиннадцать', 'двенадцать',
      'тринадцать', 'четырнадцать', 'пятнадцать', 'шестнадцать', 'семнадцать',
        'восемнадцать', 'девятнадцать');
    NumbersInWords4: array [1..9] of string [11] = ('десять', 'двадцать', 'тридцать',
      'сорок', 'пятьдесят', 'шестьдесят', 'семьдесят', 'восемьдесят', 'девяносто');
    NumbersInWords5: array [1..9] of string [9] = ('сто', 'двести', 'триста',
      'четыреста', 'пятьсот', 'шестьсот', 'семьсот', 'восемьсот', 'девятьсот');
  var
    StringVar: string;
    I: Longint;
  begin
    StringVar := '';
    I := Digit1 div 100;
    if I <> 0 then
      StringVar := NumbersInWords5[I] + ' ';
    Digit1 := Digit1 mod 100;
    I := Digit1 div 10;
    if (Digit1>10) and (Digit1<20) then
      StringVar := StringVar + NumbersInWords3[Digit1 - 10] + ' '
    else
      begin
        if I <> 0 then
          StringVar := StringVar + NumbersInWords4[I] + ' ';
          Digit1 := Digit1 mod 10;
          if Digit1 <> 0 then
            if Digit2 = 0 then
              StringVar := StringVar + NumbersInWords2[Digit1] + ' '
            else
              StringVar := StringVar + NumbersInWords[Digit1] + ' ';
            end;
    NumbersToStrings := StringVar;
  end;
var
  I: Longint;
  J: Longint;
  R: Real;
  StringVar: string;
begin

  StringVar := '';
  J := Trunc(InSum / 1000000000.0);
  R := J;
  R := InSum - R * 1000000000.0;
  I := Trunc(R);

  if J <> 0 then
    begin
      StringVar := StringVar + NumbersToStrings(J, 1) + 'миллиард';
      J := J mod 100;
      if (J > 10) and ( J < 20) then
        StringVar := StringVar + 'ов '
      else
        case J mod 10 of
          0: StringVar := StringVar + 'ов ';
          1: StringVar := StringVar + ' ';
          2..4: StringVar := StringVar + 'а ';
          5..9: StringVar:= StringVar + 'ов ';
        end;
    end;

  J := I div 1000000;

  if J <> 0 then
    begin
      StringVar := StringVar + NumbersToStrings(J, 1) + 'миллион';
      J := J mod 100;
      if (J > 10) and (J < 20) then
        StringVar := StringVar + 'ов '
      else
        case J mod 10 of
          0: StringVar := StringVar + 'ов ';
          1: StringVar := StringVar + ' ';
          2..4: StringVar := StringVar + 'а ';
          5..9: StringVar := StringVar + 'ов ';
        end;
    end;

  I := I mod 1000000;
  J := I div 1000;

  if J <> 0 then
    begin
      StringVar := StringVar + NumbersToStrings(J, 0) + 'тысяч';
      J := J mod 100;
      if (J > 10) and (J < 20) then
        StringVar := StringVar + ' '
      else
        case J mod 10 of
          0: StringVar := StringVar + ' ';
          1: StringVar := StringVar + 'а ';
          2..4: StringVar := StringVar + 'и ';
          5..9: StringVar := StringVar + ' ';
        end;
end;
  I := I mod 1000;
  J := I;

  if J <> 0 then
    StringVar := StringVar + NumbersToStrings(J, 1);

  StringVar := StringVar +'руб. ';
  I := Round(Frac(InSum) * 100.0);
  StringVar := StringVar + beforZero(I, 2) + ' коп.';

  Result := AnsiUpperCase(Copy(StringVar, 1, 1)) + Copy(StringVar, 2, (Length(StringVar) - 1));

end;


{ Функция StrDateFormat3() преобразует дату 01.02.2002 в строку '2002-02-01' }

function StrDateFormat3(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8  then
    Result := Copy(DateToStr(InValue), 7, 2) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-'
        + Copy(DateToStr(InValue), 1, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 7, 4) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-' + Copy(DateToStr(InValue), 1, 2);

end;


{ Функция передает Год из даты }

function YearFromDate(InDate: TDate): Word;
var
  YearVar, MonthVar, DayVar: Word;
begin

  DecodeDate(InDate, YearVar, MonthVar, DayVar);
  Result := YearVar;

end;


{ Функция из исходной строки InString получает Хэш-функцию MD5 }

function GenHashMD5(InString: ShortString): ShortString;
begin
  Result := MD5DigestToStr(MD5String(InString));
end;


{ Копирование файла }

function WindowsCopyFile(FromFile, ToDir: string): boolean;
var
  F : TShFileOpStruct;
begin

  F.Wnd := 0;
  F.wFunc := FO_COPY;
  FromFile := FromFile + #0;
  F.pFrom := Pchar(FromFile);
  ToDir := ToDir + #0;
  F.pTo := Pchar(ToDir);
  F.fFlags := FOF_ALLOWUNDO or FOF_NOCONFIRMATION;
  Result:=ShFileOperation(F) = 0;

end;


{ 44. Определение в системе переменной "Temp" как C:\Temp\ }
{ D7
function GetTempPathSystem: ShortString;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer)-1,Buffer));
end; }


{ 45. Определение текущего каталога как C:\WORK }
{ D7
function GetCurrDir: ShortString;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetCurrentDirectory(Sizeof(Buffer)-1, Buffer));
end; }


{ Определение короткого имени файла "D:\WORK\read.txt" -> "read.txt" }

function getShortFileName(InFileName: ShortString): ShortString;
begin
  Result := ExtractFileName(InFileName);
end;


{ Определение пути по имени файла "D:\WORK\read.txt" -> "D:\WORK\" }

function getFilePath(InFileName: ShortString): ShortString;
begin
  Result := ExtractFilePath(InFileName);
end;


{ Определение короткого имени файла без расширения "D:\WORK\read.txt" -> "read" }

function getShortFileNameWithoutExt(InFileName:ShortString):ShortString;
begin
  Result := Copy(ExtractFileName(InFileName), 1, Pos('.', ExtractFileName(InFileName)) - 1);
end;


{ Функция преобразует дату 01.02.2002 в строку '01022002' ДДММГГГГ }

function StrDateFormat4(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8  then
    StrDateFormat4 := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    StrDateFormat4 := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция преобразует дату 01.02.2002 в строку '010202' ДДММГГ }

function StrDateFormat5(InValue: TDate): shortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    Result:=Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 9, 2);

end;



// ---- Waiting Coding Style ---


{ 51. Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГГГЧЧММСС }
Function StrDateFormat6(in_value : TDateTime) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat6:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,4) +COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
end;

{ 52. Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГЧЧММСС }
Function StrDateFormat7(in_value : TDateTime) : shortString;
var tmp_StrDateFormat7: shortString;
begin
  IF Length(DateToStr(in_value))=8 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),7,2);
  IF Length(DateToStr(in_value))=10 THEN tmp_StrDateFormat7:=COPY(DateToStr(in_value),1,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),9,2);
  { Время - если до 10:00:00 }
  IF Length(TimeToStr(in_value))=7
    THEN
      begin
        tmp_StrDateFormat7:=tmp_StrDateFormat7+'0';
        tmp_StrDateFormat7:=tmp_StrDateFormat7+COPY(TimeToStr(in_value),1,1)+COPY(TimeToStr(in_value),3,2)+COPY(TimeToStr(in_value),6,2);
      end
    ELSE
      begin
        tmp_StrDateFormat7:=tmp_StrDateFormat7+COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);
      end;
  { Результат }
  StrDateFormat7:=tmp_StrDateFormat7;
end;

{ 53. Функция находит в строке значение мужду двумя символами }
Function VariableBetweenChars(In_String: shortString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindChar(In_String, In_Char, In_CharNumberStart)+1, FindChar(In_String, In_Char, In_CharNumberEnd)-FindChar(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenChars:=VariableBetweenChars_tmp;
end;

{ 54. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):ShortString;
var VariableBetweenChars_tmp:ShortString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString:=VariableBetweenChars_tmp;
end;

{ 54+. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString2(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString(In_String, In_Char, In_CharNumberEnd)-FindCharWideString(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString2:=VariableBetweenChars_tmp;
end;

{ 54++. Функция находит в строке значение мужду двумя символами - вариант обработки Широкой строки }
Function VariableBetweenCharsWideString3(In_String: WideString; In_Char:Char; In_CharNumberStart:Byte; In_CharNumberEnd:Byte):WideString;
var VariableBetweenChars_tmp:WideString;
begin
  VariableBetweenChars_tmp:='';
  VariableBetweenChars_tmp:=COPY(In_String, FindCharWideString2(In_String, In_Char, In_CharNumberStart)+1, FindCharWideString2(In_String, In_Char, In_CharNumberEnd)-FindCharWideString2(In_String, In_Char, In_CharNumberStart)-1);
  VariableBetweenCharsWideString3:=VariableBetweenChars_tmp;
end;

{ 55. Функция преобразует строку в формате даты и времени Инфоточки ITD '04-04-07 15:22:11' в тип TDateTime }
Function StrFormatDateTimeITDToDateTime(In_StrFormatDateTimeITD:ShortString):TDateTime;
begin
  StrFormatDateTimeITDToDateTime:=StrToDateTime(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2)+COPY(In_StrFormatDateTimeITD,9,9));
end;

{ 56. Функция преобразует строку в формате даты и времени Инфоточки ITD '04-04-07 15:22:11' в тип TDate }
Function StrFormatDateTimeITDToDate(In_StrFormatDateTimeITD:ShortString):TDate;
begin
  StrFormatDateTimeITDToDate:=StrToDate(COPY(In_StrFormatDateTimeITD,1,2)+'.'+COPY(In_StrFormatDateTimeITD,4,2)+'.20'+COPY(In_StrFormatDateTimeITD,7,2));
end;

{ 57. Функция преобразует тип TDateTime в строковый формат даты и времени ITD }
Function DateTimeToStrFormatITDDateTime(In_DateTime:TDateTime):ShortString;
begin
  DateTimeToStrFormatITDDateTime:=COPY(DateTimeToStr(In_DateTime),1,2)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),9,11);
end;

{ 58. Функция для передаваемой строки In_StringForSign формирует ЭЦП RSA/MD5 с длиной ключа 1024 бит в кодировке hex. В In_fileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }
function Sign_RSA_MD5_hex_WideStr(In_fileRSAPrivateKey:String; In_StringForSign:WideString ): WideString;
var
   Len: cardinal;
   mdctx: EVP_MD_CTX;
   inbuf, outbuf: array of char;
   key: pEVP_PKEY;
   a : pEVP_PKEY;
   keyfile: pBIO;
   nTamanho : integer;
   FileStream: TFileStream;
   oST : TStringStream;
begin

     { Проверяем наличие файла, содержащего RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Файл '+In_fileRSAPrivateKey+' не найден!');

           { Пример содержимого файла "RSA PRIVATE KEY"

           -----BEGIN RSA PRIVATE KEY-----
           MIICXQIBAAKBgQCargbCJN+e7X80hawa+7hv4QjiEv6SisYsaVJ5HYqCCMYVYlsd
           mnbF4AK7VJTEpJrdKs64DPAbbAPWKFHeH6U2CEBurrveoejznksC6NI57SAoEev2
           ORGyhmwhrk5ztDJWJmaKv5Ne+YKRnVeMCgxZZe5LoxCmcQnmcUmIE/D7VwIDAQAB
           AoGADiY7MglDd3tMNpa/vpwmK/3O3TdVmDwfkrJzu+aK5Ag/bndX1GZr1P//3/kF
           vtM7411mGYn9cNS5qR55FrOYXiuLdNr2n550oCNTFvR7dwty3vewDHX74ybmlouU
           K1swtLaYYqd2GbyH1od9Pkqe1XOF4ayO9tO+r1EQhkNiyOECQQDKubFVTGJGMQAL
           oOSQBYIj2vQT6xT1B0ZHr1mFpkpYEZXEuPBt8xRGF42yyy4Zx4lNrw1Cv9jKEhzx
           Cbe4f4pHAkEAw1QT446MU1amf1p3hwc9fZsEUAilOZtDWGmfHWVK6JKvanh4dmc7
           r3cDF0RsStW9wp1kyhrEvWhODzkjarp+cQJBAKpTgEoRhlRBIS+j+8WBy0kC0qXV
           kuMYPJVIH6gqAjaid7o0RFWssTD+4yAAk/g27Qam+DZH6AZHV6exKXpLNksCQQCg
           Zpj2k4bUoSGVD3t8XQu36+a8unzEM6Y4InRRtW6wUlTOwCNcSCYRT1AweTXctm1g
           NdQgy56oU9FWWvukl4VhAkBuBRx5Xm6ZK13AG2uvTjA1Gjn5miuyufcuSj6DGeK7
           XQuxyS71pJ2nrRs3vAFjzytULpdfrxJa3gpdH+ZJdtQO
           -----END RSA PRIVATE KEY-----
           }

         end;

     { Передается на вход строка, поэтому не проверяем наличие файла
     if FileExists(In_StringForSign) = false then
     begin
          raise Exception.Create('Arquivo para ser assinado nao foi encontrado.');
     end;}

     a := nil;

     OpenSSL_add_all_algorithms;   //
     OpenSSL_add_all_ciphers;      // InitOpenSSL
     OpenSSL_add_all_digests;      //
     ERR_load_crypto_strings;      //

     try
        keyfile := BIO_new(BIO_s_file());
        BIO_read_filename(keyfile, PChar(In_fileRSAPrivateKey));
        key := PEM_read_bio_PrivateKey(keyfile, a, nil, nil);
        if key = nil then
        begin
             raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Ошибка чтения PRIVATE KEY из файла '+In_fileRSAPrivateKey+' !');
        end;

        //FileStream := TFileStream.Create(In_StringForSign, fmOpenRead);
        //nTamanho := FileStream.Size;

        oST := TStringStream.Create('');

        //oST.CopyFrom(FileStream,nTamanho);

        { Запись в oST данных из FileStream }
        oST.WriteString(In_StringForSign);

        { Размер строки }
        nTamanho:=Length(In_StringForSign);

        if nTamanho < 1024 then
        begin
             nTamanho := 1024;
        end;

        SetLength(inbuf,nTamanho + 1);
        SetLength(outbuf,nTamanho + 1);

        StrPCopy(pchar(inbuf), oST.DataString);
        oST.Free;

        //FileStream.Free;

        EVP_SignInit(@mdctx, EVP_md5());
        EVP_SignUpdate(@mdctx, pchar(inbuf), StrLen(pchar(inbuf)));
        EVP_SignFinal(@mdctx, pchar(outbuf), Len, key);

        BIO_free(keyfile);

        BinToHex(pchar(outbuf),pchar(inbuf),Len);
        inbuf[2*Len]:=#0;

        { Результат выводим в символах нижнего регистра - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 59. Функция для файла In_StringForSign формирует ЭЦП RSA/MD5 с длиной ключа 1024 бит в кодировке hex. В In_fileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }
function Sign_RSA_MD5_hex_File(In_fileRSAPrivateKey:String; In_FileNameForSign:WideString ): WideString;
var
   Len: cardinal;
   mdctx: EVP_MD_CTX;
   inbuf, outbuf: array of char;
   key: pEVP_PKEY;
   a : pEVP_PKEY;
   keyfile: pBIO;
   nTamanho : integer;
   FileStream: TFileStream;
   oST : TStringStream;
begin

     { Проверяем наличие файла, содержащего RSA PRIVATE KEY  }
     if FileExists(In_fileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_File: Файл '+In_fileRSAPrivateKey+' не найден!');

           { Пример содержимого файла "RSA PRIVATE KEY"

           -----BEGIN RSA PRIVATE KEY-----
           MIICXQIBAAKBgQCargbCJN+e7X80hawa+7hv4QjiEv6SisYsaVJ5HYqCCMYVYlsd
           mnbF4AK7VJTEpJrdKs64DPAbbAPWKFHeH6U2CEBurrveoejznksC6NI57SAoEev2
           ORGyhmwhrk5ztDJWJmaKv5Ne+YKRnVeMCgxZZe5LoxCmcQnmcUmIE/D7VwIDAQAB
           AoGADiY7MglDd3tMNpa/vpwmK/3O3TdVmDwfkrJzu+aK5Ag/bndX1GZr1P//3/kF
           vtM7411mGYn9cNS5qR55FrOYXiuLdNr2n550oCNTFvR7dwty3vewDHX74ybmlouU
           K1swtLaYYqd2GbyH1od9Pkqe1XOF4ayO9tO+r1EQhkNiyOECQQDKubFVTGJGMQAL
           oOSQBYIj2vQT6xT1B0ZHr1mFpkpYEZXEuPBt8xRGF42yyy4Zx4lNrw1Cv9jKEhzx
           Cbe4f4pHAkEAw1QT446MU1amf1p3hwc9fZsEUAilOZtDWGmfHWVK6JKvanh4dmc7
           r3cDF0RsStW9wp1kyhrEvWhODzkjarp+cQJBAKpTgEoRhlRBIS+j+8WBy0kC0qXV
           kuMYPJVIH6gqAjaid7o0RFWssTD+4yAAk/g27Qam+DZH6AZHV6exKXpLNksCQQCg
           Zpj2k4bUoSGVD3t8XQu36+a8unzEM6Y4InRRtW6wUlTOwCNcSCYRT1AweTXctm1g
           NdQgy56oU9FWWvukl4VhAkBuBRx5Xm6ZK13AG2uvTjA1Gjn5miuyufcuSj6DGeK7
           XQuxyS71pJ2nrRs3vAFjzytULpdfrxJa3gpdH+ZJdtQO
           -----END RSA PRIVATE KEY-----
           }

         end;

     { Проверяем наличие файла }
     if FileExists(In_FileNameForSign) = false then
     begin
          raise Exception.Create('Sign_RSA_MD5_hex_File: Не найден файл '+In_FileNameForSign+'!');
     end;

     a := nil;

     OpenSSL_add_all_algorithms;   //
     OpenSSL_add_all_ciphers;      // InitOpenSSL
     OpenSSL_add_all_digests;      //
     ERR_load_crypto_strings;      //

     try
        keyfile := BIO_new(BIO_s_file());
        BIO_read_filename(keyfile, PChar(In_fileRSAPrivateKey));
        key := PEM_read_bio_PrivateKey(keyfile, a, nil, nil);
        if key = nil then
        begin
             raise Exception.Create('Sign_RSA_MD5_hex_File: Ошибка чтения PRIVATE KEY из файла '+In_fileRSAPrivateKey+' !');
        end;

        FileStream := TFileStream.Create(In_FileNameForSign, fmOpenRead);
        nTamanho := FileStream.Size;

        oST := TStringStream.Create('');
        oST.CopyFrom(FileStream,nTamanho);

        if nTamanho < 1024 then
        begin
             nTamanho := 1024;
        end;

        SetLength(inbuf,nTamanho + 1);
        SetLength(outbuf,nTamanho + 1);

        StrPCopy(pchar(inbuf), oST.DataString);
        oST.Free;

        //FileStream.Free;

        EVP_SignInit(@mdctx, EVP_md5());
        EVP_SignUpdate(@mdctx, pchar(inbuf), StrLen(pchar(inbuf)));
        EVP_SignFinal(@mdctx, pchar(outbuf), Len, key);

        BIO_free(keyfile);

        BinToHex(pchar(outbuf),pchar(inbuf),Len);
        inbuf[2*Len]:=#0;

        { Результат выводим в символах нижнего регистра - LowerCase }
        Result := LowerCase( StrPas(pchar(inbuf)) );

     finally
            EVP_cleanup;                  // FreeOpenSSL
     end;
end;

{ 60. Функция производит перемешку между собой случайным образом символов передаваемых в качестве параметра (перемешка mixing строки) }
Function mixingString(In_String:ShortString):ShortString;
var maxLengtIn_String:Word;
    s_tmp :ShortString;
    myHour, myMin, mySec, myMilli, mySecStamp : Word;
    i, posInS : Word;
begin

  { Временной срез }
  DecodeTime(Time, myHour, myMin, mySecStamp, myMilli);

  { Определяем длину в исходной строке }
  maxLengtIn_String:=Length(In_String);

  { Алгоритм работает для строки с нечетным количеством символов }
  IF (maxLengtIn_String MOD 2)=0
    THEN
      begin
        { Если длина четна, то добавляем 1 символ }
        In_String:=In_String+COPY(In_String,1,1);
      end; // If

  { Цикл }
  FOR i:=1 TO (mySecStamp+7) DO
    begin

      { Выполняем перемешку при каждом четном цикле }
      IF (i MOD 2)=0
        THEN
          begin
            In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);
          end // If
        ELSE
          begin
            { Выполняем перемешку при каждом нечетном цикле }
            In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);
          end;

      { Временной срез }
      DecodeTime(Time, myHour, myMin, mySec, myMilli);

      { Выполняем перемешку в зависимости от четности Миллисекунд }
      IF (myMilli MOD 2)=0
        THEN In_String:=COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)+COPY(In_String,1,(Length(In_String) DIV 2)-1);

      { Выполняем перемешку в зависимости от четности Секунд }
      IF (mySec mod 2)=0
        THEN In_String:=COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1), (Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2), Length(COPY(In_String,1,(Length(In_String) DIV 2)-1))-(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)+1)+COPY(COPY(In_String,1,(Length(In_String) DIV 2)-1),1,(Length(COPY(In_String,1,(Length(In_String) DIV 2)-1)) DIV 2)-1)
                    + COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1);

      { Выполняем перемешку в зависимости от четности Минут }
      IF (myMin mod 2)=0
        THEN In_String:=COPY(In_String,1,(Length(In_String) DIV 2)-1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1), (Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2), Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1))-(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)+1)+COPY(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1),1,(Length(COPY(In_String, (Length(In_String) DIV 2), Length(In_String)-(Length(In_String) DIV 2)+1)) DIV 2)-1);

      { Делаем перестановку между 1-ым и 2-ым символом и так до конца посмледовательности }
      s_tmp:=''; posInS:=1;
      WHILE (posInS<Length(In_String)) DO
        begin
          //Application.ProcessMessages;
          { Новые миллисекунды }
          DecodeTime(Time, myHour, myMin, mySec, myMilli);
          IF (Random(myMilli) MOD 2)=0 THEN s_tmp:=s_tmp+In_String[posInS]+In_String[posInS+1] ELSE s_tmp:=s_tmp+In_String[posInS+1]+In_String[posInS];
          posInS:=posInS+2;
        end;
      IF posInS>=Length(In_String) THEN s_tmp:=s_tmp+In_String[posInS];
      { Результат }
      In_String:=s_tmp;
      //Application.ProcessMessages;
    end; // For

  { Приводим длину к исходной }
  IF maxLengtIn_String<>Length(In_String) THEN In_String:=COPY(In_String,2,Length(In_String)-1);

  Result:=In_String;
end;

{ 61. Функция выполняет StrToFloat с проверкой в In_String разделителя, соответствующего системно-установленному }
Function StrToFloat2(In_String:ShortString):Extended;
var pcLCA: array [0..20] of Char;
begin

  { Определяем системную переменную LOCALE_SDECIMAL }
  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, pcLCA, 19);

  { Если в In_String разделитель "." а в системе "," }
  IF (POS('.', In_String)<>0)AND(POS(',', In_String)=0)AND(pcLCA[0]=',')
    THEN  In_String:=StringReplace(In_String, '.', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  { Если в In_String разделитель "," а в системе "." }
  IF (POS(',', In_String)<>0)AND(POS('.', In_String)=0)AND(pcLCA[0]='.')
    THEN  In_String:=StringReplace(In_String, ',', pcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  Result:=StrToFloat(In_String);

end;

{ 62. Функция получает сумму в строковом виде и преобразует разделитель к точке, запятой и копейки
    123 -> 123.00
    123 -> 123,00

    SumFormat('123', '.', 2)
               }
Function SumFormat(In_SumStr:ShortString; In_Separator:ShortString; In_Decimal:Word):ShortString;
var tmp_Sum:ShortString;
    i:Word;
    minus:Boolean;
begin

  In_SumStr:=Trim(In_SumStr);

  { Определяем знак }
  IF COPY(In_SumStr,1,1)='-'
    THEN
      begin
        minus:=True;
        In_SumStr:=COPY(In_SumStr, 2, Length(In_SumStr)-1);
      end
    ELSE minus:=False;

  { Определяем - есть ли разделитель. Он может быть: "." "," "=" }
  tmp_Sum:='';

  FOR i:=1 TO Length(In_SumStr) DO
    begin

      IF ((In_SumStr[i]<>' ')AND((In_SumStr[i]='0')OR(In_SumStr[i]='1')OR(In_SumStr[i]='2')OR(In_SumStr[i]='3')OR(In_SumStr[i]='4')OR(In_SumStr[i]='5')OR(In_SumStr[i]='6')OR(In_SumStr[i]='7')OR(In_SumStr[i]='8')OR(In_SumStr[i]='9')))
        THEN tmp_Sum:=tmp_Sum+In_SumStr[i];

      // Замена разделителя дробной части
      IF (In_SumStr[i]='-')or(In_SumStr[i]='.')or(In_SumStr[i]=',')or(In_SumStr[i]='=') THEN tmp_Sum:=tmp_Sum+In_Separator;

    end; // For

  { Разделитель }
  IF (POS(In_Separator, tmp_Sum)=0)AND(In_Decimal<>0)
    THEN tmp_Sum:=tmp_Sum+In_Separator;

  { Если In_Decimal=0, то удаляем справа за разделителем все символы 0 }
  IF (In_Decimal=0)
    THEN
      begin
        IF (POS('1',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('2',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('3',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('4',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('5',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('6',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('7',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('8',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)AND(POS('9',COPY(tmp_Sum, POS(In_Separator, tmp_Sum)+1, Length(tmp_Sum)-POS(In_Separator, tmp_Sum)))=0)
          THEN tmp_Sum:=COPY(tmp_Sum, 1, POS(In_Separator, tmp_Sum)-1 );
      end; // If

  { Если есть разделитель, то считаем число знаков после него и если это число меньше чем In_Decimal - добавляем нулями }
  IF (POS(In_Separator, tmp_Sum)<>0)AND( ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) <In_Decimal)
    THEN
      begin
        FOR i:=1 TO ( In_Decimal - ( Length(tmp_Sum) - POS(In_Separator, tmp_Sum) ) ) DO
          begin
            tmp_Sum:=tmp_Sum+'0';
          end;
      end; // If

  { Подставляем знак }
  IF minus=True THEN Result:='-'+tmp_Sum ELSE Result:=tmp_Sum;

end;




{ Функция преобразует тип TDateTime в строковый формат даты и времени для сервера "Сирены" 2009-06-09T01:01:01.123456 }
Function DateTimeToStrFormatSirenaDateTime(In_DateTime:TDateTime):ShortString;
var  myHour, myMin, mySec, myMilli : Word;
begin
  { Временной срез }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );
  DateTimeToStrFormatSirenaDateTime:=COPY(DateTimeToStr(In_DateTime),7,4)+'-'+COPY(DateTimeToStr(In_DateTime),4,2)+'-'+COPY(DateTimeToStr(In_DateTime),1,2)
                                       +'T'
                                         { Время }
                                         +beforZero(myHour,2)+':'+beforZero(myMin,2)+':'+beforZero(mySec,2)
                                         {+COPY(DateTimeToStr(In_DateTime), POS(' ', DateTimeToStr(In_DateTime))+1, Length(DateTimeToStr(In_DateTime))-POS(' ', DateTimeToStr(In_DateTime)))}
                                           { миллисекунды через точку }
                                           +'.'+beforZero(myMilli,6);
end;

{ Функция преобразует дату 01.02.2002 в строку '020201' ГГММДД }
Function StrDateFormat8(in_value : TDate) : shortString;
begin
  IF Length(DateToStr(in_value))=8  THEN StrDateFormat8:=COPY(DateToStr(in_value),7,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
  IF Length(DateToStr(in_value))=10 THEN StrDateFormat8:=COPY(DateToStr(in_value),9,2)+COPY(DateToStr(in_value),4,2)+COPY(DateToStr(in_value),1,2);
end;

{ Функция преобразует дату и время 23.02.2009 12:37:00 в строку ДДММГГЧЧММССMs }
Function StrDateFormat9(In_DateTime : TDateTime) : shortString;
var tmp_StrDateFormat9: shortString;
    myHour, myMin, mySec, myMilli : Word;
begin

  { Временной срез }
  DecodeTime( In_DateTime, myHour, myMin, mySec, myMilli );

  IF Length(DateToStr(In_DateTime))=8 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),7,2);
  IF Length(DateToStr(In_DateTime))=10 THEN tmp_StrDateFormat9:=COPY(DateToStr(In_DateTime),1,2)+COPY(DateToStr(In_DateTime),4,2)+COPY(DateToStr(In_DateTime),9,2);
  { Время - если до 10:00:00 }
  IF Length(TimeToStr(In_DateTime))=7
    THEN
      begin
        tmp_StrDateFormat9:=tmp_StrDateFormat9+'0';
        tmp_StrDateFormat9:=tmp_StrDateFormat9+COPY(TimeToStr(In_DateTime),1,1)+COPY(TimeToStr(In_DateTime),3,2)+COPY(TimeToStr(In_DateTime),6,2);
      end
    ELSE
      begin
        tmp_StrDateFormat9:=tmp_StrDateFormat9+COPY(TimeToStr(In_DateTime),1,2)+COPY(TimeToStr(In_DateTime),4,2)+COPY(TimeToStr(In_DateTime),7,2);
      end;
  { Результат }
  StrDateFormat9:=tmp_StrDateFormat9+IntToStr(myMilli);
end;

{  Функция преобразует дату и время 23.02.2009 12:37:00 в строку ГГГГММДДЧЧММСС }
Function StrDateFormat10(in_value : TDateTime) : shortString;
begin
  Result:='';

  IF Length(DateToStr(in_value))=8
    THEN Result:=Result+COPY(DateToStr(in_value),7,2)
                          +COPY(DateToStr(in_value),4,2)
                          +COPY(DateToStr(in_value),1,2);

  IF Length(DateToStr(in_value))=10
    THEN Result:=Result+COPY(DateToStr(in_value),7,4)
                          +COPY(DateToStr(in_value),4,2)
                          +COPY(DateToStr(in_value),1,2);

  IF Length(TimeToStr(in_value))=7
    THEN Result:=Result+'0'+COPY(TimeToStr(in_value),1,1)+COPY(TimeToStr(in_value),3,2)+COPY(TimeToStr(in_value),6,2);

  IF Length(TimeToStr(in_value))=8
    THEN Result:=Result+COPY(TimeToStr(in_value),1,2)+COPY(TimeToStr(in_value),4,2)+COPY(TimeToStr(in_value),7,2);

end;


{ Генерация UserName }
Function RandomUserName(PWLen: Word): ShortString;
var
  StrTableUserName: ShortString;
  N, K, X, Y: integer;// проверяем максимальную длину пароля
  Flags: TReplaceFlags;
begin

  { таблица символов, используемых в пароле }
  StrTableUserName:='1234567890';

  { Создаем уникальность таблицы символов, используя - mixingString }
  StrTableUserName:=DateTimeToStrFormat(Now)+StrTableUserName+DateTimeToStrFormat(Now);
  StrTableUserName:=mixingString(StrTableUserName);

  { Удаляем из этой уникальности: Нуль }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserName:=StringReplace(StrTableUserName, '0', '', Flags);

  if (PWlen > Length(StrTableUserName))
    then K := Length(StrTableUserName)-1
      else K := PWLen;
  SetLength(result, K); // устанавливаем длину конечной строки
  Y := Length(StrTableUserName); // Длина Таблицы для внутреннего цикла
  N := 0; // начальное значение цикла

  while N < K do
    begin// цикл для создания K символов
      X := Random(Y) + 1; // берём следующий случайный символ
      // проверяем присутствие этого символа в конечной строке
      if (pos(StrTableUserName[X], result) = 0)
        then
          begin
            inc(N); // символ не найден
            Result[N]:=StrTableUserName[X]; // теперь его сохраняем
          end; // If
    end; // While
end;

{ Генерация UserPassword }
Function RandomUserPassword(PWLen: Word): ShortString;
var
  N, K, X, Y: integer;// проверяем максимальную длину пароля
  StrTableUserPassword:ShortString;
  Flags: TReplaceFlags;
begin

  { таблица символов, используемых в пароле }
  // StrTableUserPassword:='1lwEkj532hefy89r4U38LEL384FV37847rfWFWKLlvhEERnsdfkiesu38KL543789JH332U84hfgHFgfdDY7Jhh8u4jc878weDfq534sxnewg4653sHyt28dh37dh36dh3kglgnbvhrf743jdjh437edhgafdh46sgd63g63GDJASG36d4GD5Wj5gf32HGXD';
  StrTableUserPassword:='qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789';

  { Создаем уникальность таблицы символов, используя - mixingString }
  StrTableUserPassword:=DateTimeToStrFormat(Now)+StrTableUserPassword+DateTimeToStrFormat(Now);
  StrTableUserPassword:=mixingString(StrTableUserPassword);

  { Удаляем из этой уникальности: Нуль }
  Flags:= [rfReplaceAll, rfIgnoreCase];
  StrTableUserPassword:=StringReplace(StrTableUserPassword, '0', '', Flags);

  { Удаляем из этой уникальности: "o" и "O" }
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'o', '', Flags);
  StrTableUserPassword:=StringReplace(StrTableUserPassword, 'O', '', Flags);

  if (PWlen > Length(StrTableUserPassword))
    then K := Length(StrTableUserPassword)-1
      else K := PWLen;
  SetLength(result, K); // устанавливаем длину конечной строки
  Y := Length(StrTableUserPassword); // Длина Таблицы для внутреннего цикла
  N := 0; // начальное значение цикла

  while N < K do
    begin// цикл для создания K символов
      X := Random(Y) + 1; // берём следующий случайный символ
      // проверяем присутствие этого символа в конечной строке
      if (pos(StrTableUserPassword[X], result) = 0)
        then
          begin
            inc(N); // символ не найден
            Result[N]:=StrTableUserPassword[X]; // теперь его сохраняем
          end; // If
    end; // While
end;

// Функция преобразует американский расчет дня недели в российский
Function RussianDayOfWeek(In_DayOfWeek:Byte):Byte;
begin
  IF in_DayOfWeek = 1
    THEN
      RussianDayOfWeek:=7
    ELSE
      RussianDayOfWeek:=in_DayOfWeek-1
end;

// Функция преобразует американский расчет дня недели в российский из даты
Function RussianDayOfWeekFromDate(In_Date:TDate):Byte;
var DayOfWeekVar:Byte;
begin

  DayOfWeekVar:=DayOfWeek( In_Date );

  IF DayOfWeekVar = 1
    THEN Result:=7
      ELSE Result:=DayOfWeekVar-1
end;

{ Количество выходных дней (субб., вскр.) между 2-мя датами }
Function daysOffBetweenDates(In_DateBegin:TDate; In_DateEnd:TDate):Word;
var currDate:TDate;
begin
  Result:=0;
  currDate:=In_DateBegin;
  WHILE currDate<=In_DateEnd DO
    begin
      {IF (RussianDayOfWeekFromDate(currDate)=6)OR(RussianDayOfWeekFromDate(currDate)=7)}
      IF ( (RussianDayOfWeekFromDate(currDate)=6)OR(RussianDayOfWeekFromDate(currDate)=7) ) AND (currDate<>In_DateBegin)
        THEN Result:=Result+1;
      currDate:=currDate+1;
    end;
end;

{ Получение параметра (ShortString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
Function paramFromString(In_StringAnswer:WideString; In_Param:ShortString):ShortString;
begin
  { Версия не адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ Получение параметра (WideString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
Function paramFromString2(In_StringAnswer:WideString; In_Param:ShortString):WideString;
begin
  { Версия не адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS(In_Param, In_StringAnswer)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param, In_StringAnswer)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param, In_StringAnswer)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ Получение параметра (WideString) из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; "
   - Адаптирована к параметр_номер_1 и параметр_номер_11.
   - Адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }
Function paramFromString3(In_StringAnswer:WideString; In_Param:ShortString):WideString;
var In_StringAnswer_tmp:WideString;
    In_Param_tmp:ShortString;
begin
  In_Param_tmp:=AnsiLowerCase(In_Param);
  In_StringAnswer_tmp:=AnsiLowerCase(In_StringAnswer);

  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  IF POS('=', In_Param_tmp)=0 THEN In_Param_tmp:=In_Param_tmp+'=';

  IF POS(In_Param_tmp, In_StringAnswer_tmp)<>0 THEN Result:=COPY(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param)+1)), 1, POS(';', COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param), (Length(In_StringAnswer)- POS(In_Param_tmp, In_StringAnswer_tmp)+Length(In_Param)+1)))-1) ELSE Result:='';
end;

{ Сохранение значение параметра в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
Function setParamFromString(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):ShortString;
var beforeSubstring, afterSubstring:ShortString; //str1:ShortString;
begin
  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';
  { Если параметр есть в строке }
  IF POS(In_Param, In_StringAnswer)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param, In_StringAnswer)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param, In_StringAnswer), Length(In_StringAnswer)-POS(In_Param, In_StringAnswer)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { Если параметра нет в строке, то дописываем его в конец }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ Сохранение значение параметра (WideString) в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " Версия, адаптированная к регистру! }
Function setParamFromString2(In_StringAnswer:WideString; In_Param:ShortString; In_Value:ShortString):WideString;
var beforeSubstring, afterSubstring:WideString;
    In_StringAnswer_tmp:WideString;
    In_Param_tmp:ShortString;
begin

  { Версия, адаптированная к регистру! }
  In_Param_tmp:=AnsiLowerCase(In_Param);
  In_StringAnswer_tmp:=AnsiLowerCase(In_StringAnswer);

  IF POS('=', In_Param)=0 THEN In_Param:=In_Param+'=';

  { Если параметр есть в строке }
  IF POS(In_Param_tmp, In_StringAnswer_tmp)<>0
    THEN
      begin
        beforeSubstring:=COPY(In_StringAnswer, 1, POS(In_Param_tmp, In_StringAnswer_tmp)-1 );
        afterSubstring:=COPY(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ), POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))+1, Length(COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))-POS(';',COPY(In_StringAnswer, POS(In_Param_tmp, In_StringAnswer_tmp), Length(In_StringAnswer)-POS(In_Param_tmp, In_StringAnswer_tmp)+1 ))) ;
        Result:=beforeSubstring+In_Param+In_Value+';'+afterSubstring;
      end
    ELSE
      begin
        { Если параметра нет в строке, то дописываем его в конец }
        Result:=In_StringAnswer+' '+In_Param+In_Value+';';
      end;
end;

{ Получение количества параметров в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
Function countParamFromString(In_StringAnswer:WideString):Word;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
begin
  { Число параметров равно числу знаков = }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  { Поиск в подстроке }
  WHILE findChar=True DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False
          end
        ELSE
          begin
            countChar:=countChar+1;
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While
  Result:=countChar;
end;

{ Получение наименование параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = параметр_номер_2 }
Function paramNameFromString(In_StringAnswer:WideString; In_ParamNumber:Word):ShortString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { Определим в posRAVNO позицию знака "=" для искомого параметра }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { Поиск в подстроке }
  WHILE (findChar=True)AND(countChar<In_ParamNumber) DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False;
            posRAVNO:=0;
          end
        ELSE
          begin
            countChar:=countChar+1;
            posRAVNO:=posRAVNO+POS('=', subStrForFind);
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While

  { Определим в подстроке "начало-posRAVNO" }
  IF posRAVNO<>0
    THEN
      begin
        subStrForFind:=COPY(In_StringAnswer, 1, posRAVNO-1);
        posCurrent:=posRAVNO-1;
        Result:='';
        WHILE (posCurrent>=1)AND(COPY(subStrForFind, posCurrent, 1)<>' ')AND(COPY(subStrForFind, posCurrent, 1)<>';') DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent-1;
          end; // While
        { Получили имя параметра в зеркальном отображении: 2_ртемарап ("параметр_2"). Выполняем обратное преобразование }
        posCurrent:=Length(Result);
        subStrForFind:=Result;
        Result:='';
        WHILE (posCurrent>=1) DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent-1;
          end; // While
      end
    ELSE
      begin
        Result:='';
      end;
end;

{ Получение значение параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = 200.00 }
Function paramValueFromString(In_StringAnswer:WideString; In_ParamNumber:Word):WideString;
var countChar:Word;
    findChar:Boolean;
    subStrForFind:WideString;
    posRAVNO, posCurrent:Word;
begin
  { Определим в posRAVNO позицию знака "=" для искомого параметра }
  countChar:=0;
  findChar:=True;
  subStrForFind:=In_StringAnswer;
  posRAVNO:=0;
  { Поиск в подстроке }
  WHILE (findChar=True)AND(countChar<In_ParamNumber) DO
    begin
      IF POS('=', subStrForFind)=0
        THEN
          begin
            findChar:=False;
            posRAVNO:=0;
          end
        ELSE
          begin
            countChar:=countChar+1;
            posRAVNO:=posRAVNO+POS('=', subStrForFind);
            subStrForFind:=COPY(subStrForFind, POS('=', subStrForFind)+1, Length(subStrForFind)-POS('=', subStrForFind) );
          end;
    end; // While
  { Определим в подстроке "(posRAVNO+1)-конец" }
  IF posRAVNO<>0
    THEN
      begin
        subStrForFind:=COPY(In_StringAnswer, posRAVNO+1, Length(In_StringAnswer)-posRAVNO );
        posCurrent:=1;
        Result:='';
        WHILE (posCurrent<=Length(subStrForFind))AND(COPY(subStrForFind, posCurrent, 1)<>';') DO
          begin
            Result:=Result+COPY(subStrForFind, posCurrent, 1);
            posCurrent:=posCurrent+1;
          end; // While
      end
    ELSE
      begin
        Result:='';
      end;
end;

{ Функция из двойного параметра 1234-9044951501 выделяет первый 1234 (при In_ParamNumber=1) или второй 9044951501 (при In_ParamNumber=2) параметр }
Function getParamFromDoublePayment(In_DoubleAutData:ShortString; In_ParamNumber:Byte):ShortString;
var  autData, autData1, autData2:ShortString;
begin

  { В autData удаляем пробелы }
  autData:=StringReplace(In_DoubleAutData, ' ', '', [rfReplaceAll]);

  { Разбиваем autData на autData1 и autData2 }
  IF (POS('-',autData)<>0)
    THEN
      begin
        { Номер телефона }
        autData2:=COPY(autData, POS('-',autData)+1, Length(autData)-POS('-',autData) );
        { Данные для авторизации в Элси ДДММГГNNNNN }
        autData1:=COPY(autData, 1, POS('-',autData)-1 );
      end
    ELSE
      begin
        { Номер телефона }
        autData2:='';
        { Данные для авторизации в Элси ДДММГГNNNNN }
        autData1:=autData;
      end; // If

  { Результат }
  IF In_ParamNumber=1 THEN Result:=autData1 ELSE Result:=autData2;

end;

{ Перед передачей разультата для PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) спецсимволы " ; = # необходимо замаскировать функцией ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - производит маскирование. In_Mask_DeMask=DeMask - производит де-маскирование }
Function ps_paymGate_maskSymbol(In_String:WideString; In_Mask_DeMask:ShortString ):WideString;
begin
  { Если задано маскирование }
  IF In_Mask_DeMask='Mask'
    THEN
      begin
        { " -> &quot }
        In_String:=StringReplace(In_String, '"', '&quot', [rfReplaceAll] );
        { ; -> &quo4 }
        In_String:=StringReplace(In_String, ';', '&quo4', [rfReplaceAll] );
        { = -> &quou }
        In_String:=StringReplace(In_String, '=', 'quou', [rfReplaceAll] );
        { # -> &quo3 }
        In_String:=StringReplace(In_String, '#', '&quo3', [rfReplaceAll] );
      end; // If

  { Если задано Де-маскирование }
  IF In_Mask_DeMask='DeMask'
    THEN
      begin
        { &quot -> "  }
        In_String:=StringReplace(In_String, '&quot', '"', [rfReplaceAll] );
        { &quo4 -> ;  }
        In_String:=StringReplace(In_String, '&quo4', ';', [rfReplaceAll] );
        { &quou -> =  }
        In_String:=StringReplace(In_String, 'quou', '=', [rfReplaceAll] );
        { &quo3 -> # }
        In_String:=StringReplace(In_String, '&quo3', '#', [rfReplaceAll] );
      end; // If
  { Результат }
  Result:=In_String;
end;

{ Функция определяет локальный Ip адрес }
Function GetLocalIP: ShortString;
const WSVer = $101; var wsaData: TWSAData; P: PHostEnt; Buf: array [0..127] of Char;
begin
  Result:= '';
  if WSAStartup(WSVer, wsaData) = 0 then begin
    if GetHostName(@Buf, 128) = 0 then begin
      P := GetHostByName(@Buf);
      if P <> nil then Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
    end;
    WSACleanup;
  end;
end;

{ Маскирование середины строки }
Function maskString(In_StringForMask:ShortString):ShortString;
var startPosMask, endPosMask, i:Word;
begin
  Result:='';
  { Позиция начала маскирования }
  startPosMask:= ((Length(In_StringForMask) Div 2) Div 2)+2;
  { Позиция окончания маскирования }
  endPosMask:= (Length(In_StringForMask) Div 2) + ((Length(In_StringForMask) Div 2) Div 2);
  FOR i:=1 TO Length(In_StringForMask) DO
    begin
      { Находимся в диапазоне маскирования? }
      IF (i>=startPosMask)AND(i<=endPosMask)
        THEN
          begin
            { Маскируем }
            Result:=Result+'X';
          end
        ELSE
          begin
            Result:=Result+In_StringForMask[i];
          end; // If
    end; // For
end;

    { *** Конец раздела описания процедур и функций DLL *** }

    exports

{ *** Начало перечня экспортируемых из Dll процедур и функций *** }

// 1. Функция RoundCurrency округляет передаваемое ей значение до указанного количества знаков после запятой
RoundCurrency Name 'RoundCurrency',

// 2. Функция DosToWin преобразует Dos кодировку входящей строки в символы кодировки Windows
DosToWin Name 'DosToWin',

// 3. Функция WinToDos преобразует Windows кодировку входящей строки в символы кодировки Dos
WinToDos Name 'WinToDos',

// 4. Преобразование разделителя целой и дробной части (, -> .), представленного в строковом виде
ChangeSeparator Name 'ChangeSeparator',

// 5. Преобразование разделителя целой и дробной части (. -> ,), представленного в строковом виде
ChangeSeparator2 Name 'ChangeSeparator2',

// 6. Фиксированная строка выравнивание влево
LeftFixString Name 'LeftFixString',

// 7. Фиксированная строка выравнивание вправо
RightFixString Name 'RightFixString',

// 8. Фиксированная строка выравнивание по центру
CentrFixString Name 'CentrFixString',

// 9. Преобразование суммы из prn-файла
prnSum Name 'prnSum',

// 10. Преобразование строки '25 000,25' в число 25000,25
TrSum Name 'TrSum',

// 11. Преобразование текстовой даты "ДД.ММ.ГГГГ" в банковский день типа Int
bnkDay Name 'bnkDay',

// 12. Функция преобразует дату 01.01.2002 в строку '01/01/2002'
DiaStrDate Name 'DiaStrDate',

// 13. Функция преобразует дату 01.01.2002 в строку '"01" января 2002 г.'
PropisStrDate Name 'PropisStrDate',

// 14. Функция определяет в передаваемой строке, позицию номера сепаратора ^
FindSeparator Name 'FindSeparator',

// 15. Функция определяет в передаваемой строке, позицию номера передаваемого символа
FindChar Name 'FindChar',

// 15+. Функция определяет в передаваемой строке, позицию номера передаваемого символа
FindCharWideString Name 'FindCharWideString',

FindCharWideString2 Name 'FindCharWideString2',

// 16. Функция определяет в передаваемой строке, позицию пробела
FindSpace Name 'FindSpace',

{ Подсчет числа вхождений символа In_Char в строку In_String }
countCharInString Name 'countCharInString',

// 17. Функция преобразует Win строку 'Abcd' -> 'ABCD'
Upper Name 'Upper',

// 18. Функция преобразует Win строку 'abcd' -> 'Abcd'
Proper Name 'Proper',

// 19. Функция преобразует Win строку 'ABCD' -> 'abcd'
Lower Name 'Lower',

// 20. Функция преобразует строку '1000,00' -> '1 000,00'
Divide1000 Name 'Divide1000',

// 21. Функция возвращает параметр с заданным именем из ini-файла; Если нет ini - 'INIFILE_NOT_FOUND'. Если нет параметра - 'PARAMETR_NOT_FOUND'
paramFromIniFile Name 'paramFromIniFile',

paramFromIniFileWithOutMessDlg Name 'paramFromIniFileWithOutMessDlg',

paramFromIniFileWithOutMessDlg2 Name 'paramFromIniFileWithOutMessDlg2',

paramFromIniFileWithFullPath Name 'paramFromIniFileWithFullPath',

paramFromIniFileWithFullPathWithOutMessDlg Name 'paramFromIniFileWithFullPathWithOutMessDlg',

// 22. Функция ищет ini файл и параметр в нем; Если все нормально - возвращается значение параметра, если нет - то заначение функциий 'INIFILE_NOT_FOUND' или 'PARAMETR_NOT_FOUND'
paramFoundFromIniFile Name 'paramFoundFromIniFile',

// 23. Функция добавляет перед числом нули 1 до нужного количества знаков-> '0001'
beforZero Name 'beforZero',

// 24. Автонумерация документа из 12-х знаков с ведением электронного жунала
ID12docFromJournal Name 'ID12docFromJournal',

// 25. Преобразование Строки '01-01-05 01:01:01'
dateTimeToSec Name 'dateTimeToSec',

// 26. Преобразование String в PChar
StrToPchar Name 'StrToPchar',

// 27. Процедура выводит в лог файл с именем InFileName строку InString с переводом каретки если InLn='Ln'
ToLogFileWithName Name 'ToLogFileWithName',

// 27+. Процедура выводит в лог файл с именем InFileName строку InString с переводом каретки если InLn='Ln'
ToLogFileWideStringWithName Name 'ToLogFileWideStringWithName',

// 27++.
ToLogFileWithFullName Name 'ToLogFileWithFullName',

ToLogFileWideStringWithFullName Name 'ToLogFileWideStringWithFullName',

// 28. Функция преобразует строку Кириллицы в Латиницу по таблице транслитерации с www.beonline.ru
TranslitBeeLine Name 'TranslitBeeLine',

// 29. Функция преобразует дату 01.01.2002 в строку '01/01/2002'
formatMSSqlDate Name 'formatMSSqlDate',

// 30. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в тип TDateTime ( корректировку часового пояса +0300 пока не учитываем )
StrFormatTimeStampToDateTime Name 'StrFormatTimeStampToDateTime',

// 31. Функция преобразует строку в формате даты и времени TTimeStamp '04-04-2007 15:22:11 +0300' в строку '04.04.2007 15:22:11'  ( корректировку часового пояса +0300 пока не учитываем )
StrTimeStampToStrDateTime Name 'StrTimeStampToStrDateTime',

// 32. Функция DateTimeToStrFormat преобразует дату и время  01.01.2007 1:02:00 в строку '0101200710200'
DateTimeToStrFormat Name 'DateTimeToStrFormat',

decodeCurCodeToISO  Name 'decodeCurCodeToISO',

cardExpDate_To_Date Name 'cardExpDate_To_Date',

decodeTypeCard Name 'decodeTypeCard',

decodeTypeCardGPB Name 'decodeTypeCardGPB',

PCharToStr Name 'PCharToStr',

StrDateFormat1 Name 'StrDateFormat1',

StrDateFormat2 Name 'StrDateFormat2',

SummaPropis Name 'SummaPropis',

SummaPropis2 Name 'SummaPropis2',

StrDateFormat3 Name 'StrDateFormat3',

YearFromDate Name 'YearFromDate',

CryptDES Name 'CryptDES',

DeCryptDES Name 'DeCryptDES',

GenHashMD5 Name 'GenHashMD5',

WindowsCopyFile Name 'WindowsCopyFile',

{ D7 GetTempPathSystem Name 'GetTempPathSystem', }

{ D7 GetCurrDir Name 'GetCurrDir', }

getShortFileName Name 'getShortFileName',

getFilePath Name 'getFilePath',

getShortFileNameWithoutExt Name 'getShortFileNameWithoutExt',

StrDateFormat4 Name 'StrDateFormat4',

StrDateFormat5 Name 'StrDateFormat5',

StrDateFormat6 Name 'StrDateFormat6',

StrDateFormat7 Name 'StrDateFormat7',

VariableBetweenChars Name 'VariableBetweenChars',

VariableBetweenCharsWideString Name 'VariableBetweenCharsWideString',

VariableBetweenCharsWideString2 Name 'VariableBetweenCharsWideString2',

VariableBetweenCharsWideString3 Name 'VariableBetweenCharsWideString3',

StrFormatDateTimeITDToDateTime Name 'StrFormatDateTimeITDToDateTime',

StrFormatDateTimeITDToDate Name 'StrFormatDateTimeITDToDate',

DateTimeToStrFormatITDDateTime Name 'DateTimeToStrFormatITDDateTime',

Sign_RSA_MD5_hex_WideStr Name 'Sign_RSA_MD5_hex_WideStr',

Sign_RSA_MD5_hex_File Name 'Sign_RSA_MD5_hex_File',

mixingString Name 'mixingString',

StrToFloat2 Name 'StrToFloat2',

SumFormat Name 'SumFormat',

DateTimeToStrFormatSirenaDateTime Name 'DateTimeToStrFormatSirenaDateTime',

StrDateFormat8 Name 'StrDateFormat8',

StrDateFormat9 Name 'StrDateFormat9',

StrDateFormat10 Name 'StrDateFormat10',

RandomUserName Name 'RandomUserName',

RandomUserPassword Name 'RandomUserPassword',

RussianDayOfWeek Name 'RussianDayOfWeek',

RussianDayOfWeekFromDate Name 'RussianDayOfWeekFromDate',

daysOffBetweenDates Name 'daysOffBetweenDates',

{ Результат ShortString: Получение параметра из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
paramFromString Name 'paramFromString',

{ Получение количества параметров в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
countParamFromString Name 'countParamFromString',

{ Получение наименование параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = параметр_номер_2 }
paramNameFromString Name 'paramNameFromString',

{ Получение значение параметра по его порядковому номеру. Для "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = 200.00 }
paramValueFromString Name 'paramValueFromString',

{ Результат WideString: Получение параметра из строки "параметр_номер_1=100.00; параметр_номер_2=200.00; " - Адаптирована к параметр_номер_1 и параметр_номер_11 }
paramFromString2 Name 'paramFromString2',

{ Результат WideString, адаптирована к регистру! }
paramFromString3 Name 'paramFromString3',

{ Сохранение значение параметра в строке "параметр_номер_1=100.00; параметр_номер_2=200.00; " }
setParamFromString Name 'setParamFromString',

{ Широкая строка! Адаптирована к регистру }
setParamFromString2 Name 'setParamFromString2',

getParamFromDoublePayment Name 'getParamFromDoublePayment',

{ Перед передачей разультата для PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) спецсимволы " ; = # необходимо замаскировать функцией ps_paymGate_maskSymbol. In_Mask_DeMask=Mask - производит маскирование. In_Mask_DeMask=DeMask - производит де-маскирование }
ps_paymGate_maskSymbol Name 'ps_paymGate_maskSymbol',

{ Функция определяет локальный Ip адрес }
GetLocalIP Name 'GetLocalIP',

{ Маскирование середины строки }
maskString Name 'maskString'

;

{ *** Конец перечня экспортируемых из Dll процедур и функций *** }

begin
{ *** Начало блока инициализации Dll *** }
{ Код, помещенный в блоке инициализации автоматически выполняется при загрузке Dll }



{ *** Конец блока инициализации библиотеки *** }
end.
