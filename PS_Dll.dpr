{************************************************************}
{                                                            }
{       Библиотека PS_Dll сожержит процедуры и функции       }
{       наиболее часто использующиеся в проектах             }
{                                                            }
{       ver. 1.15 25-05-2022                                  }
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
    0: Result := Round(Value);
    1: Result := Round((Value + 0.0001) * 10) / 10;
    2: Result := Round((Value + 0.00001) * 100) / 100;
  else
    Result := Value;
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

  Result := LocalString;

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

  Result := LocalString;

end;


{ Функция ChangeSeparator преобразует разделитель целой и дробной части (, -> .),
  представленного в строковом виде }

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
          LocalString := LocalString + '0';

        Result := LocalString;

      end
  else Result := InStringFloat + '.00';

end;


{ Функция ChangeSeparator2 осуществляет преобразование разделителя целой
  и дробной части (. -> ,), представленного в строковом виде }

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

        Result := LocalString;

      end
  else Result := InStringFloat + ',00';

end;


{ Функция LeftFixString возвращает фиксированную строку с выравниванием влево }

function LeftFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    Result := Copy(Trim(InString), 1, InFixPosition)
  else Result := Trim(InString) + StringOfChar(' ', InFixPosition
    - Length(Trim(InString)));

end;


{ Функция RightFixString возвращает фиксированную строку с выравниванием вправо }

function RightFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  if Length(Trim(InString)) >= InFixPosition then
    Result := Copy(Trim(InString), 1, InFixPosition)
  else Result := StringOfChar(' ', InFixPosition - Length(Trim(InString)))
    + Trim(InString);

end;


{ Функция CentrFixString возвращает фиксированную строку с выравниванием по центру }

function CentrFixString(InString: ShortString; InFixPosition: Byte): ShortString;
begin

  InString := Trim(InString);

  if Length(Trim(InString)) >= InFixPosition then
    CentrFixString := Copy(Trim(InString), 1, InFixPosition)
  else
    begin
      Result := StringOfChar(' ', Trunc((InFixPosition
        - Length(Trim(InString))) / 2)) + Trim(InString)
        + StringOfChar(' ', InFixPosition
        - Trunc((InFixPosition - Length(Trim(InString))) / 2));
    end;

end;


{ Функция PrnSum осуществляет преобразование суммы с строковом виде из prn-файла }

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

  Result := TrSum;

end;


{ Функция TrSum осуществляет преобразование строки '25 000,25' в число 25000,25 }

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

  Result := StrToFloat(TrSumStr);

end;


{ Функция BnkDay преобразует дату в формате "ДД.ММ.ГГГГ" в банковский день типа Int }

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

  Result := CountDate;

end;


{ Функция DiaStrDate преобразует дату 01.01.2002 в строку '01/01/2002' }

function DiaStrDate(InValue: TDate): ShortString;
begin

  Result := Copy(DateToStr(InValue), 1, 2) + '/'
    + Copy(DateToStr(InValue), 4, 2) + '/' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция PropisStrDate преобразует дату 01.01.2002 в строку '"01" января 2002 г.' }

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

  Result := PropisStrDateTmp;

end;


{ Функция FindSeparator определяет в передаваемой строке,
  позицию номера сепаратора '^' }

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


{ Функция FindChar определяет в передаваемой строке, позицию номера передаваемого
  символа }

function FindChar(InString: ShortString; InChar: Char;
  NumberOfSeparator: Byte): Byte;
var
  I, CounterSeparatorVar: Byte;
begin

  FindChar := 0;
  CounterSeparatorVar := 0;

  for I := 1 to Length(InString) do
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


{ Функция FindCharWideString определяет в передаваемой строке, позицию номера
  символа }

function FindCharWideString(InString: String; InChar: Char;
  NumberOfSeparator: Word): Word;
var
  I, CounterSeparatorVar: Word;
begin

  FindCharWideString := 0;
  CounterSeparatorVar := 0;

  for I := 1 to Length(InString) do
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


{ Функция FindCharWideString2 определяет в передаваемой строке, позицию номера
  символа }

function FindCharWideString2(InString: WideString; InChar: Char;
  NumberOfSeparator: Word): Longword;
var
  I: Longword;
  CounterSeparatorVar: Word;
begin

  FindCharWideString2 := 0;
  CounterSeparatorVar := 0;

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


{ Функция FindSpace определяет в передаваемой строке позицию пробела }

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


{ Функция countCharInString осушествляет подсчет числа вхождений символа
  InChar в передаваемую строку InString }

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


{ Функция Upper преобразует строку в кодировке Win в заглавные символы,
  пример Upper('Abcd') результат 'ABCD' }

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


{ Функция Proper преобразует строку в кодировке Win в первую заглавную букву,
  остальные - строчные пример для Proper('abcd') результат 'Abcd' }

function Proper(InString: ShortString): ShortString;
var
  I: 1..1000;
  LocalStr: string;
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


{ Функция Lower преобразует строку в кодировке Win в строку из строчных букв,
  пример для Lower('ABCD') результат 'abcd' }

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


{ Функция Divide1000 преобразует строку с числами, добавляя пробел-разделитель
  в тысячах. Пример для Divide1000('1000,00') рузультат '1 000,00' }

function Divide1000(InString: ShortString): ShortString;
var
  I, Count: -1..100;
  AfterPoint: boolean;
  StringVar: ShortString;
begin

  StringVar := '';

  if (Pos('.', InString) <> 0) or (Pos(',', InString) <> 0) then
    begin
      AfterPoint := False;
      Count := -1;
    end
  else
    begin
      AfterPoint := True;
      Count := 0;
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
          StringVar := ' ' + Copy(InString, Length(InString) -I, 1) + StringVar
      else StringVar := Copy(InString, Length(InString) -I, 1) + StringVar;

    end;

  Result := Trim(StringVar);

end;


{ Функция ParamFromIniFile возвращает параметр с заданным именем из ini-файла;
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

function ParamFromIniFile(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string;
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

            if (COPY(StrokaVar, 1, 1) <> ';') then
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


{ Функция ParamFromIniFileWithOutMessDlg возвращает параметр с заданным именем
  из ini-файла;
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

function ParamFromIniFileWithOutMessDlg(InIniFile: ShortString;
  InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string;
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


{ Функция ParamFromIniFileWithOutMessDlg2 возвращает параметр с заданным именем
  из ini-файла;
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

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
                if Trim(Copy(StrokaVar, 1, Pos('=', StrokaVar) - 1)) = Trim(InParam) then
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


{ Функция ParamFromIniFileWithFullPath возвращает параметр с заданным именем
  из ini-файла;
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

function ParamFromIniFileWithFullPath(InIniFile: ShortString;
  InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string;
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

                IF (Copy(StrokaVar, 1, Pos('=', StrokaVar) - 1) = Trim(InParam)) then
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


{ Функция ParamFromIniFileWithFullPathWithOutMessDlg возвращает параметр
  с заданным именем из ini-файла.
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

function ParamFromIniFileWithFullPathWithOutMessDlg(InIniFile: ShortString;
InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string;
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


{ Функция ParamFoundFromIniFile возвращает параметр
  с заданным именем из ini-файла.
  Если нет ini-файла, то результат 'INIFILE_NOT_FOUND'.
  Если нет в ini-файле нет параметра - возвращаемый результат 'PARAMETR_NOT_FOUND' }

function ParamFoundFromIniFile(InIniFile: ShortString; InParam: ShortString): ShortString;
var
  IniFileVar: Textfile;
  ParamFromIniFileVar: string;
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


{ Функция BeforZero добавляет перед числом нули до нужного количества знаков.
  Пример BeforZero(1, 4), результат '0001' }

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


 { Функция ID12docFromJournal производит автонумерацию документа из 12-х знаков
   с ведением электронного жунала }

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
    IdDocVar := 1
  else IdDocVar := IdDocVar + 1;

  AssignFile(TxtJournal, ExtractFilePath(ParamStr(0)) + InJournal);
  if FileExists(ExtractFilePath(ParamStr(0)) + InJournal)=True then
    Append(TxtJournal)
  else
    begin
      ReWrite(TxtJournal);
      WriteLn(TxtJournal, 'Филиал АБ "Газпромбанк" (ЗАО) в г.Белоярский');
      WriteLn(TxtJournal, 'Отдел Банковских карт');
      WriteLn(TxtJournal, ' ');
      WriteLn(TxtJournal, 'Электронный журнал регистрации документов');
      WriteLn(TxtJournal, 'Начат: ' + DateToStr(Now));
      WriteLn(TxtJournal, '------------------------------------------------------------------------------------------');
      WriteLn(TxtJournal, '      #     |   Дата   |                        Примечание                               |');
      WriteLn(TxtJournal, '------------------------------------------------------------------------------------------');
    end;
  WriteLn(TxtJournal, LeftFixString(IntToStr(IdDocVar), 12) + '|'
    + DateToStr(Now) + '|' + DosToWin(InNameDoc));
  CloseFile(TxtJournal);

  Result:=IdDocVar;

end;


{ Функция DateTimeToSec преобразует дату в формате cтроки в Integer от 01.01.2000 г. }

function DateTimeToSec(InValue: ShortString): Integer;
begin

  Result := Round((StrToDate(Copy(InValue, 1, 2) + '.' + Copy(InValue, 4, 2) + '.20'
    + Copy(InValue, 7, 2)) - StrToDate('01.01.2000'))) * 86400
    + StrToInt(Copy(InValue, 16, 2)) + StrToInt(Copy(InValue, 13, 2)) * 60
    + StrToInt(Copy(InValue, 10, 2)) * 3600;

end;


{ Функция StrToPchar возвращает строку PChar из передаваемой ей в качестве
  аргумента строки типа String }

function StrToPchar(InString: string): Pchar;
begin

  InString := InString + #0;
  Result := StrPCopy(@InString[1], InString);

end;


{ Процедура ToLogFileWithName выводит в log-файл с именем InFileName строку
  InString передаваемую в качестве аргумента с переводом каретки если InLn = 'Ln' }

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


{ Процедура ToLogFileWideStringWithName выводит в log-файл с именем InFileName строку
  InString передаваемую в качестве аргумента с переводом каретки если InLn = 'Ln' }

procedure ToLogFileWideStringWithName(InFileName: ShortString; InString: string;
  InLn: ShortString);
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

{ Процедура ToLogFileWithFullName выводит в log-файл с именем InFileName
  (имя файла с полным путем) строку InString передаваемую в качестве аргумента
  с переводом каретки если InLn = 'Ln' }

procedure ToLogFileWithFullName(InFileName: ShortString; InString: ShortString;
  InLn: ShortString);
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


{ Процедура ToLogFileWideStringWithFullName выводит в log-файл
  с именем InFileName строку InString передаваемую в качестве аргумента
  с переводом каретки если InLn = 'Ln' }

procedure ToLogFileWideStringWithFullName(InFileName: ShortString;
  InString: WideString; InLn: ShortString);
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


{ Функция TranslitBeeLine преобразует строку, передаваемую в качестве аргумента
  из Кириллицу в Латиницу по таблице транслитерации с www.beonline.ru }

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


{ Функция FormatMsSqlDate преобразует дату 06.05.2006 (06 мая 2006), передаваемую
  в качестве аргумента в строку формата MS SQL '05.06.2006' 06.05.2006 10:01:05 }

function FormatMsSqlDate(InValue: TDate): ShortString;
begin

  Result := Copy(DateToStr(InValue), 4, 2) + '.' + Copy(DateToStr(InValue), 1, 2)
    + '.' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция StrFormatTimeStampToDateTime преобразует строку в формате даты и времени
  TTimeStamp '04-04-2007 15:22:11 +0300' в тип TDateTime
  (без корректировки часового пояса +0300) }

function StrFormatTimeStampToDateTime(InStrFormatTimeStamp: ShortString): TDateTime;
begin

  Result := StrToDateTime(Copy(InStrFormatTimeStamp, 1, 2) + '.'
    + Copy(InStrFormatTimeStamp, 4, 2) + '.'
    + Copy(InStrFormatTimeStamp, 7, 4) + '.'
    + ' ' + Copy(InStrFormatTimeStamp, 12, 8));

end;


{ Функция StrTimeStampToStrDateTime преобразует строку в формате даты и времени
  TTimeStamp '04-04-2007 15:22:11 +0300' в строку '04.04.2007 15:22:11'
  (без корректировки часового пояса +0300) }

function StrTimeStampToStrDateTime(InStrFormatTimeStamp: ShortString): ShortString;
begin

  Result := Copy(InStrFormatTimeStamp, 1, 2) + '.'
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

  DateTimeToStrFormatVar := StringReplace(DateTimeToStr(In_DateTime), ' ', '',
    [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar := StringReplace(DateTimeToStrFormatVar, '.', '',
    [rfReplaceAll, rfIgnoreCase]);
  DateTimeToStrFormatVar := StringReplace(DateTimeToStrFormatVar, ':', '',
    [rfReplaceAll, rfIgnoreCase]);
  Result := DateTimeToStrFormatVar;

end;


{ Функция DecodeCurCodeToISO преобразует цифровой код валюты в код ISO.
  Пример для DecodeCurCodeToISO(810) результат будет "RUR" }

function DecodeCurCodeToISO(InCurrCode: Word): ShortString;
begin

  case InCurrCode of
    0   : Result := 'RUR';
    4   : Result := 'AFA';  //    Афгани
    8   : Result := 'ALL';  //    Лек
    12  : Result := 'DZD';  //    Алжирский динар
    20  : Result := 'ADP';  //    Андорская песета
    31  : Result := 'AZM';  //    Азербайджанский манат
    32  : Result := 'ARS';  //    Аргентинское песо
    36  : Result := 'AUD';  //    Австралийский доллар
    40  : Result := 'ATS';  //    Шиллинг
    44  : Result := 'BSD';  //    Багамский доллар
    48  : Result := 'BHD';  //    Бахрейнский динар
    50  : Result := 'BDT';  //    Така
    51  : Result := 'AMD';  //    Армянский драм
    52  : Result := 'BBD';  //    Барбадосский доллар
    56  : Result := 'BEF';  //    Бельгийский франк
    60  : Result := 'BMD';  //    Бермудский доллар
    64  : Result := 'BTN';  //    Нгултрум
    68  : Result := 'BOB';  //    Боливиано
    72  : Result := 'BWP';  //    Пула
    84  : Result := 'BZD';  //    Белизский доллар
    90  : Result := 'SBD';  //    Доллар Соломоновых
    96  : Result := 'BND';  //    Брунейский доллар
    100 : Result := 'BGL';  //    Лев
    104 : Result := 'MMK';  //    Кьят
    108 : Result := 'BIF';  //    Бурундийский франк
    116 : Result := 'KHR';  //    Риель
    124 : Result := 'CAD';  //    Канадский доллар
    132 : Result := 'CVE';  //    Эскудо Кабо - Верде
    136 : Result := 'KYD';  //    Доллар Каймановых
    144 : Result := 'LKR';  //    Шри - Ланкийская рупия
    152 : Result := 'CLP';  //    Чилийское песо
    156 : Result := 'CNY';  //    Юань Ренминби
    170 : Result := 'COP';  //    Колумбийское песо
    174 : Result := 'KMF';  //    Франк Коморских
    188 : Result := 'CRC';  //    Костариканский колон
    191 : Result := 'HRK';  //    Куна
    192 : Result := 'CUP';  //    Кубинское песо
    196 : Result := 'CYP';  //    Кипрский фунт
    203 : Result := 'CZK';  //    Чешская крона
    208 : Result := 'DKK';  //    Датская крона
    214 : Result := 'DOP';  //    Доминиканское песо
    218 : Result := 'ECS';  //    Сукре
    222 : Result := 'SVC';  //    Сальвадорский колон
    230 : Result := 'ETB';  //    Эфиопский быр
    232 : Result := 'ERN';  //    Накфа
    233 : Result := 'EEK';  //    Крона
    238 : Result := 'FKP';  //    Фунт Фолклендских
    242 : Result := 'FJD';  //    Доллар Фиджи
    246 : Result := 'FIM';  //    Марка
    250 : Result := 'FRF';  //    Французский франк
    262 : Result := 'DJF';  //    Франк Джибути
    270 : Result := 'GMD';  //    Даласи
    276 : Result := 'DEM';  //    Немецкая марка
    288 : Result := 'GHC';  //    Седи
    292 : Result := 'GIP';  //    Гибралтарский фунт
    300 : Result := 'GRD';  //    Драхма
    320 : Result := 'GTQ';  //    Кетсаль
    324 : Result := 'GNF';  //    Гвинейский франк
    328 : Result := 'GYD';  //    Гайанский доллар
    332 : Result := 'HTG';  //    Гурд
    340 : Result := 'HNL';  //    Лемпира
    344 : Result := 'HKD';  //    Гонконгский доллар
    348 : Result := 'HUF';  //    Форинт
    352 : Result := 'ISK';  //    Исландская крона
    356 : Result := 'INR';  //    Индийская рупия
    360 : Result := 'IDR';  //    Рупия
    364 : Result := 'IRR';  //    Иранский риал
    368 : Result := 'IQD';  //    Иракский динар
    372 : Result := 'IEP';  //    Ирландский фунт
    376 : Result := 'ILS';  //    Новый израильский
    380 : Result := 'ITL';  //    Итальянская лира
    388 : Result := 'JMD';  //    Ямайский доллар
    392 : Result := 'JPY';  //    Йена
    398 : Result := 'KZT';  //    Тенге
    400 : Result := 'JOD';  //    Иорданский динар
    404 : Result := 'KES';  //    Кенийский шиллинг
    408 : Result := 'KPW';  //    Северо - корейская вона
    410 : Result := 'KRW';  //    Вона
    414 : Result := 'KWD';  //    Кувейтский динар
    417 : Result := 'KGS';  //    Сом
    418 : Result := 'LAK';  //    Кип
    422 : Result := 'LBP';  //    Ливанский фунт
    426 : Result := 'LSL';  //    Лоти
    428 : Result := 'LVL';  //    Латвийский лат
    430 : Result := 'LRD';  //    Либерийский доллар
    434 : Result := 'LYD';  //    Ливийский динар
    440 : Result := 'LTL';  //    Литовский лит
    442 : Result := 'LUF';  //    Люксембургский франк
    446 : Result := 'MOP';  //    Патака
    450 : Result := 'MGF';  //    Малагасийский франк
    454 : Result := 'MWK';  //    Квача
    458 : Result := 'MYR';  //    Малайзийский ринггит
    462 : Result := 'MVR';  //    Руфия
    470 : Result := 'MTL';  //    Мальтийская лира
    478 : Result := 'MRO';  //    Угия
    480 : Result := 'MUR';  //    Маврикийская рупия
    484 : Result := 'MXN';  //    Мексиканское песо
    496 : Result := 'MNT';  //    Тугрик
    498 : Result := 'MDL';  //    Молдавский лей
    504 : Result := 'MAD';  //    Марокканский дирхам
    508 : Result := 'MZM';  //    Метикал
    512 : Result := 'OMR';  //    Оманский риал
    516 : Result := 'NAD';  //    Доллар Намибии
    524 : Result := 'NPR';  //    Непальская рупия
    528 : Result := 'NLG';  //    Нидерландский гульден
    532 : Result := 'ANG';  //    Нидерландский
    533 : Result := 'AWG';  //    Арубанский гульден
    548 : Result := 'VUV';  //    Вату
    554 : Result := 'NZD';  //    Новозеландский доллар
    558 : Result := 'NIO';  //    Золотая кордоба
    566 : Result := 'NGN';  //    Найра
    578 : Result := 'NOK';  //    Норвежская крона
    586 : Result := 'PKR';  //    Пакистанская рупия
    590 : Result := 'PAB';  //    Бальбоа
    598 : Result := 'PGK';  //    Кина
    600 : Result := 'PYG';  //    Гуарани
    604 : Result := 'PEN';  //    Новый соль
    608 : Result := 'PHP';  //    Филиппинское песо
    620 : Result := 'PTE';  //    Португальское эскудо
    624 : Result := 'GWP';  //    Песо Гвинеи - Бисау
    626 : Result := 'TPE';  //    Тиморское эскудо
    634 : Result := 'QAR';  //    Катарский риал
    642 : Result := 'ROL';  //    Лей
    643 : Result := 'RUB';  //    Российский рубль
    646 : Result := 'RWF';  //    Франк Руанды
    654 : Result := 'SHP';  //    Фунт Острова Святой
    678 : Result := 'STD';  //    Добра
    682 : Result := 'SAR';  //    Саудовский риял
    690 : Result := 'SCR';  //    Сейшельская рупия
    694 : Result := 'SLL';  //    Леоне
    702 : Result := 'SGD';  //    Сингапурский доллар
    703 : Result := 'SKK';  //    Словацкая крона
    704 : Result := 'VND';  //    Донг
    705 : Result := 'SIT';  //    Толар
    706 : Result := 'SOS';  //    Сомалийский шиллинг
    710 : Result := 'ZAR';  //    Рэнд
    716 : Result := 'ZWD';  //    Доллар Зимбабве
    724 : Result := 'ESP';  //    Испанская песета
    736 : Result := 'SDD';  //    Суданский динар
    740 : Result := 'SRG';  //    Суринамский гульден
    748 : Result := 'SZL';  //    Лилангени
    752 : Result := 'SEK';  //    Шведская крона
    756 : Result := 'CHF';  //    Швейцарский франк
    760 : Result := 'SYP';  //    Сирийский фунт
    764 : Result := 'THB';  //    Бат
    776 : Result := 'TOP';  //    Паанга
    780 : Result := 'TTD';  //    Доллар Тринидада и
    784 : Result := 'AED';  //    Дирхам (ОАЭ)
    788 : Result := 'TND';  //    Тунисский динар
    792 : Result := 'TRL';  //    Турецкая лира
    795 : Result := 'TMM';  //    Манат
    800 : Result := 'UGX';  //    Угандийский шиллинг
    807 : Result := 'MKD';  //    Динар
    810 : Result := 'RUR';  //    Российский рубль
    818 : Result := 'EGP';  //    Египетский фунт
    826 : Result := 'GBP';  //    Фунт стерлингов
    834 : Result := 'TZS';  //    Танзанийский шиллинг
    840 : Result := 'USD';  //    Доллар США
    858 : Result := 'UYU';  //    Уругвайское песо
    860 : Result := 'UZS';  //    Узбекский сум
    862 : Result := 'VEB';  //    Боливар
    882 : Result := 'WST';  //    Тала
    886 : Result := 'YER';  //    Йеменский риал
    891 : Result := 'YUM';  //    Новый динар
    894 : Result := 'ZMK';  //    Квача (замбийская)
    901 : Result := 'TWD';  //    Новый тайваньский
    950 : Result := 'XAF';  //    Франк КФА ВЕАС
    951 : Result := 'XCD';  //    Восточно - карибский
    952 : Result := 'XOF';  //    Франк КФА ВСЕАО
    953 : Result := 'XPF';  //    Франк КФП
    960 : Result := 'XDR';  //    СДР (специальные права
    972 : Result := 'TJS';  //    Сомони
    973 : Result := 'AOA';  //    Кванза
    974 : Result := 'BYR';  //    Белорусский рубль
    975 : Result := 'BGN';  //    Болгарский лев
    976 : Result := 'CDF';  //    Конголезский франк
    977 : Result := 'ВАМ';  //    Конвертируемая марка
    978 : Result := 'EUR';  //    Евро
    980 : Result := 'UAH';  //    Гривна
    981 : Result := 'GEL';  //    Лари
    985 : Result := 'PLN';  //    Злотый
    986 : Result := 'BRL';  //    Бразильский реал
  end;

end;


{ Функция CardExpDate_To_Date возвращает строку, переданню ей в качестве аргумента
  в тип даты. Пример для CardExpDate_To_Date("01-05") результат будет 31.01.2005 }

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


{ Функция DecodeTypeCard производит преобразование номера карты по первым
  9-ти цифрам в тип карты (филиал) }

function DecodeTypeCard(InCardNumber: ShortString): ShortString;
var
  DecodeTypeCardVar: ShortString;
begin

  DecodeTypeCardVar := 'type not define';

  if (Copy(InCardNumber, 1, 9) = '487417315') then DecodeTypeCardVar := 'VISA Electron';
  if (Copy(InCardNumber, 1, 9) = '487415515') then DecodeTypeCardVar := 'VISA Classic';
  IF (Copy(InCardNumber, 1, 9) = '487416315') then DecodeTypeCardVar := 'VISA Gold';
  IF (Copy(InCardNumber, 1, 9) = '676454115') then DecodeTypeCardVar := 'Maestro';
  IF (Copy(InCardNumber, 1, 9) = '548999015') then DecodeTypeCardVar := 'MasterCard';
  IF (Copy(InCardNumber, 1, 9) = '549000215') then DecodeTypeCardVar := 'MasterCard Gold';

  IF (Copy(InCardNumber, 1, 6) = '602208') then DecodeTypeCardVar := 'Union Card';

  IF (Copy(InCardNumber, 1, 9) = '487417415') then DecodeTypeCardVar := 'VISA Electron Пенсионная';
  IF (Copy(InCardNumber, 1, 9) = '487415415') then DecodeTypeCardVar := 'VISA Classic Пенсионная';
  IF (Copy(InCardNumber, 1, 9) = '487416415') then DecodeTypeCardVar := 'VISA Gold Пенсионная';

  Result := DecodeTypeCardVar;

end;


{ Функция DecodeTypeCardGPB произволит преобразование номера карты по первым
  6-ти цифрам в тип карты (Газпромбанк) }

function DecodeTypeCardGPB(InCardNumber: ShortString): ShortString;
var
  DecodeTypeCardVar: ShortString;
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


 { Функция PCharToStr производит преобразование PChar в String }

function PCharToStr(P: Pchar): string;
begin
  Result := P;
end;


{ Функция StrDateFormat1 преобразует дату 01.01.2002 в строку формата '01/01/2002' }

function StrDateFormat1(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8  then
    Result := Copy(DateToStr(InValue), 1, 2) + '/'
      + Copy(DateToStr(InValue), 4, 2) + '/' + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + '/'
      + Copy(DateToStr(InValue), 4, 2) + '/' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция StrDateFormat2() преобразует дату 01.01.2002 в строку формата '01-01-2002' }

function StrDateFormat2(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    Result := Copy(DateToStr(InValue), 1, 2) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-' + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + '-'
      + Copy(DateToStr(InValue), 4, 2) + '-' + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция SummaPropis возвращает сумму прописью из типа double, переданного ей
  в качестве аргумента }

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
      StringVar := StringVar + NumbersInWords3[Digit1 - 10] + ' '
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

    Result := StringVar;

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

  I := Round(Frac(InSum) * 100.0);

  Result := AnsiUpperCase(Copy(StringVar, 1, 1)) + Copy(StringVar, 2, (Length(StringVar) - 1));

end;


{ Функция SummaPropis2 возвращает сумму прописью из типа double, переданного ей
  в качестве аргумента

  (второй вариант реализации) }

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
    Result := StringVar;
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


{ Функция StrDateFormat3() преобразует дату, передаваемую в качестве аргумента
  01.02.2002 в строку формата '2002-02-01' }

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


{ Функция YearFromDate возвращает Год из Даты, передаваемой в качестве аргумента }

function YearFromDate(InDate: TDate): Word;
var
  YearVar, MonthVar, DayVar: Word;
begin

  DecodeDate(InDate, YearVar, MonthVar, DayVar);
  Result := YearVar;

end;


{ Функция GenHashMD5 возвращает Хэш-функцию MD5 из строки, передаваемой
  в качестве аргумента }

function GenHashMD5(InString: ShortString): ShortString;
begin

  Result := MD5DigestToStr(MD5String(InString));

end;


{ Функция WindowsCopyFile производит копирование файла, передаваемого в качестве
  аргумента в директорию, указанную в качестве второго аргумента }

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


{ (Delphi 7) Функция GetTempPathSystem возвращает значение переменной "Temp"
  (как C:\Temp\) из параметров операционной системе

function GetTempPathSystem: ShortString;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetTempPath(Sizeof(Buffer)-1,Buffer));
end; }


{ (Delphi 7) Функция GetCurrDir возвращает значение текущего каталога как C:\WORK

function GetCurrDir: ShortString;
var
  Buffer: array[0..1023] of Char;
begin
  SetString(Result, Buffer, GetCurrentDirectory(Sizeof(Buffer)-1, Buffer));
end; }


{ Функция GetShortFileName возвращает имя файла без полного пути
  Пример для GetShortFileName("D:\WORK\read.txt") - результат "read.txt" }

function GetShortFileName(InFileName: ShortString): ShortString;
begin

  Result := ExtractFileName(InFileName);

end;


{ Функция GetFilePath возвращает путь к файлу
  Пример для GetFilePath("D:\WORK\read.txt") - результат "D:\WORK\" }

function GetFilePath(InFileName: ShortString): ShortString;
begin

  Result := ExtractFilePath(InFileName);

end;


{ Функция GetShortFileNameWithoutExt возвращает имя файла без полного пути
  и расширения
  Пример для GetShortFileNameWithoutExt("D:\WORK\read.txt") рузультат "read" }

function GetShortFileNameWithoutExt(InFileName: ShortString): ShortString;
begin

  Result := Copy(ExtractFileName(InFileName), 1,
    Pos('.', ExtractFileName(InFileName)) - 1);

end;


{ Функция StrDateFormat4 преобразует дату, передаваемую в качестве аргумента
  в строку формата ДДММГГГГ
  Пример для StrDateFormat4(01.02.2002) результат '01022002' }

function StrDateFormat4(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8  then
    StrDateFormat4 := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    StrDateFormat4 := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 4);

end;


{ Функция StrDateFormat5 преобразует дату, передаваемую в качестве аргумента
  в строку формата ДДММГГ
  Пример для StrDateFormat5(01.02.2002) результат '010202' }

function StrDateFormat5(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    Result:=Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2) + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 9, 2);

end;


{ Функция StrDateFormat6 преобразует дату и время, передаваемые в качестве аргумента
  в строку формата ДДММГГГГЧЧММСС
  Пример для StrDateFormat6('23.02.2009 12:37:00') результат '23022009123700' }

function StrDateFormat6(InValue: TDateTime): ShortString;
begin

  Result := '';

  if Length(DateToStr(InValue)) = 8 then
    Result := Copy(DateToStr(InValue), 1, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 7, 2) + Copy(TimeToStr(InValue), 1, 2)
      + Copy(TimeToStr(InValue), 4, 2) + Copy(TimeToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 1, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 7, 4) + Copy(TimeToStr(InValue), 1, 2)
      + Copy(TimeToStr(InValue), 4, 2) + Copy(TimeToStr(InValue), 7, 2);

end;


{ Функция StrDateFormat7 преобразует дату и время, передаваемую в качестве
  аргумента в формате 23.02.2009 12:37:00 в строку формата ДДММГГЧЧММСС }

function StrDateFormat7(InValue: TDateTime): ShortString;
var
  StrDateFormat7Var: ShortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    StrDateFormat7Var := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 7, 2);

  if Length(DateToStr(InValue)) = 10 then
    StrDateFormat7Var := Copy(DateToStr(InValue), 1, 2)
      + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 9, 2);

  if Length(TimeToStr(InValue)) = 7 then
    begin
      StrDateFormat7Var := StrDateFormat7Var + '0';
      StrDateFormat7Var := StrDateFormat7Var + Copy(TimeToStr(InValue), 1, 1)
        + Copy(TimeToStr(InValue), 3, 2) + Copy(TimeToStr(InValue), 6, 2);
    end
  else
    begin
      StrDateFormat7Var := StrDateFormat7Var + Copy(TimeToStr(InValue), 1, 2)
        + Copy(TimeToStr(InValue), 4, 2) + Copy(TimeToStr(InValue), 7, 2);
    end;

  Result := StrDateFormat7Var;

end;


{ Функция VariableBetweenChars в передаваемой ей в качестве аргумента строке
  находит и возвращает подстроку, между двумя символами (разделителями) }

function VariableBetweenChars(InString: ShortString; InChar: Char;
  InCharNumberStart: Byte; InCharNumberEnd: Byte): ShortString;
var
  VariableBetweenCharsVar: ShortString;
begin

  VariableBetweenCharsVar := '';

  VariableBetweenCharsVar := Copy(InString, FindChar(InString, InChar,
    InCharNumberStart) + 1, FindChar(InString, InChar, InCharNumberEnd)
    - FindChar(InString, InChar, InCharNumberStart) - 1);

  Result := VariableBetweenCharsVar;

end;


{ Функция VariableBetweenCharsWideString в передаваемой ей в качестве аргумента
  строке находит и возвращает подстроку, между двумя символами (разделителями) }

function VariableBetweenCharsWideString(InString: WideString; InChar:Char;
  InCharNumberStart: Byte; InCharNumberEnd: Byte): ShortString;
begin

  Result := Copy(InString, FindCharWideString(InString, InChar,
    InCharNumberStart) + 1, FindCharWideString(InString, InChar, InCharNumberEnd)
    - FindCharWideString(InString, InChar, InCharNumberStart) - 1);

end;


{ Функция VariableBetweenCharsWideString2 в передаваемой ей в качестве аргумента
  строке находит и возвращает подстроку, между двумя символами (разделителями) }

function VariableBetweenCharsWideString2(InString: WideString; InChar: Char;
  InCharNumberStart: Byte; InCharNumberEnd: Byte): WideString;
begin

  Result := Copy(InString, FindCharWideString(InString, InChar,
    InCharNumberStart) + 1, FindCharWideString(InString, InChar, InCharNumberEnd)
    - FindCharWideString(InString, InChar, InCharNumberStart) - 1);

end;


{ Функция VariableBetweenCharsWideString3 в передаваемой ей в качестве аргумента
  строке находит и возвращает подстроку, между двумя символами (разделителями) }

function VariableBetweenCharsWideString3(InString: WideString; InChar: Char;
  InCharNumberStart: Byte; InCharNumberEnd: Byte): WideString;
begin

  Result := Copy(InString, FindCharWideString2(InString, InChar,
    InCharNumberStart) + 1, FindCharWideString2(InString, InChar, InCharNumberEnd)
    - FindCharWideString2(InString, InChar, InCharNumberStart) - 1);

end;


{ Функция StrFormatDateTimeITDToDateTime преобразует строку, передаваемую
  в качестве аргумента, в формате даты и времени Инфоточки ITD '04-04-07 15:22:11'
  в тип TDateTime }

function StrFormatDateTimeITDToDateTime(InStrFormatDateTimeITD: ShortString): TDateTime;
begin

  Result := StrToDateTime(COPY(InStrFormatDateTimeITD, 1, 2)
    + '.'+Copy(InStrFormatDateTimeITD, 4, 2) + '.20'
    + Copy(InStrFormatDateTimeITD, 7, 2) + Copy(InStrFormatDateTimeITD, 9, 9));

end;


{ Функция StrFormatDateTimeITDToDate преобразует строку, передаваемую
  в качестве аргумента, в формате даты и времени Инфоточки ITD '04-04-07 15:22:11'
  в тип TDateTime }

function StrFormatDateTimeITDToDate(InStrFormatDateTimeITD: ShortString): TDate;
begin

  Result := StrToDate(Copy(InStrFormatDateTimeITD, 1, 2)
    + '.' + Copy(InStrFormatDateTimeITD, 4, 2) + '.20'
    + Copy(InStrFormatDateTimeITD, 7, 2));

end;


{ Функция DateTimeToStrFormatITDDateTime преобразует дату и время, передаваемые
  в качестве аргумента, в формате даты и времени Инфоточки ITD '04-04-07 15:22:11' }

function DateTimeToStrFormatITDDateTime(InDateTime: TDateTime): ShortString;
begin

  Result := Copy(DateTimeToStr(InDateTime), 1, 2) + '-'
    + Copy(DateTimeToStr(InDateTime), 4, 2) + '-'
    + Copy(DateTimeToStr(InDateTime), 9, 11);

end;


{ Функция Sign_RSA_MD5_hex_WideStr для передаваемой строки InStringForSign
  формирует ЭЦП RSA/MD5 с длиной ключа 1024 бит в кодировке hex.
  В InfileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }

function Sign_RSA_MD5_hex_WideStr(InFileRSAPrivateKey: string;
  InStringForSign: WideString ): WideString;
var
   Len: cardinal;
   Mdctx: EVP_MD_CTX;
   InBuf, OutBuf: array of char;
   Key: pEVP_PKEY;
   A: pEVP_PKEY;
   KeyFile: pBIO;
   nTamanho: Integer;
   FileStream: TFileStream;
   OSt: TStringStream;
begin

     if FileExists(InFileRSAPrivateKey) = false
       then
         begin
           raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Файл '
             + InFileRSAPrivateKey + ' не найден!');
         end;


     A := nil;

     OpenSSL_add_all_algorithms;
     OpenSSL_add_all_ciphers;
     OpenSSL_add_all_digests;
     ERR_load_crypto_strings;

     try
        KeyFile := BIO_new(BIO_s_file());
        BIO_read_filename(KeyFile, PChar(InFileRSAPrivateKey));
        Key := PEM_read_bio_PrivateKey(KeyFile, A, nil, nil);
        if Key = nil then
        begin
          raise Exception.Create('Sign_RSA_MD5_hex_WideStr: Ошибка чтения PRIVATE KEY из файла '
           + InFileRSAPrivateKey + '!');
        end;


        OSt := TStringStream.Create('');

        OSt.WriteString(InStringForSign);

        nTamanho := Length(InStringForSign);

        if nTamanho < 1024 then
        begin
             nTamanho := 1024;
        end;

        SetLength(InBuf,nTamanho + 1);
        SetLength(OutBuf,nTamanho + 1);

        StrPCopy(pchar(InBuf), OSt.DataString);
        OSt.Free;

        EVP_SignInit(@Mdctx, EVP_md5());
        EVP_SignUpdate(@Mdctx, pchar(InBuf), StrLen(pchar(InBuf)));
        EVP_SignFinal(@Mdctx, pchar(OutBuf), Len, Key);

        BIO_free(KeyFile);

        BinToHex(pchar(OutBuf),pchar(InBuf),Len);
        InBuf[2 * Len] := #0;

        Result := LowerCase( StrPas(pchar(InBuf)) );

     finally
        EVP_cleanup;
     end;
end;


// --- Wait for Delphi-doc

{ Функция Sign_RSA_MD5_hex_File для файла InStringForSign формирует ЭЦП RSA/MD5
  с длиной ключа 1024 бит в кодировке hex.
  В InfileRSAPrivateKey передается полный путь к файлу, содержащему RSA PRIVATE KEY }

function Sign_RSA_MD5_hex_File(InFileRSAPrivateKey: string; InFileNameForSign:WideString ): WideString;
var
   Len: cardinal;
   Mdctx: EVP_MD_CTX;
   InBuf, OutBuf: array of char;
   Key: pEVP_PKEY;
   A: pEVP_PKEY;
   KeyFile: pBIO;
   NTamanho: integer;
   FileStream: TFileStream;
   OSt: TStringStream;
begin

     if FileExists(InFileRSAPrivateKey) = false then
       begin
         raise Exception.Create('Sign_RSA_MD5_hex_File: Файл '+InFileRSAPrivateKey+' не найден!');
       end;

     if FileExists(InFileNameForSign) = false then
       begin
         raise Exception.Create('Sign_RSA_MD5_hex_File: Не найден файл '+InFileNameForSign+'!');
       end;

     A := nil;

     OpenSSL_add_all_algorithms;
     OpenSSL_add_all_ciphers;
     OpenSSL_add_all_digests;
     ERR_load_crypto_strings;

     try
        KeyFile := BIO_new(BIO_s_file());
        BIO_read_filename(KeyFile, PChar(InFileRSAPrivateKey));
        Key := PEM_read_bio_PrivateKey(KeyFile, A, nil, nil);
        if Key = nil then
        begin
          raise Exception.Create('Sign_RSA_MD5_hex_File: Ошибка чтения PRIVATE KEY из файла '+InFileRSAPrivateKey+' !');
        end;

        FileStream := TFileStream.Create(InFileNameForSign, fmOpenRead);
        NTamanho := FileStream.Size;

        OSt := TStringStream.Create('');
        OSt.CopyFrom(FileStream,NTamanho);

        if NTamanho < 1024 then
        begin
          NTamanho := 1024;
        end;

        SetLength(InBuf,NTamanho + 1);
        SetLength(OutBuf,NTamanho + 1);

        StrPCopy(pchar(InBuf), OSt.DataString);
        OSt.Free;

        EVP_SignInit(@Mdctx, EVP_md5());
        EVP_SignUpdate(@Mdctx, pchar(InBuf), StrLen(pchar(InBuf)));
        EVP_SignFinal(@Mdctx, pchar(OutBuf), Len, Key);

        BIO_free(KeyFile);

        BinToHex(pchar(OutBuf),pchar(InBuf),Len);
        InBuf[2 * Len] := #0;

        Result := LowerCase( StrPas(pchar(InBuf)) );

     finally
        EVP_cleanup;
     end;
end;


{ Функция mixingString производит перемешку между собой случайным образом
  символов передаваемых в качестве параметра (перемешка mixing строки) }

function MixingString(InString: ShortString): ShortString;
var
    MaxLengtInString: Word;
    StringVar: ShortString;
    MyHour, MyMin, MySec, MyMilli, MySecStamp: Word;
    I, PosInStr: Word;
begin

  DecodeTime(Time, MyHour, MyMin, MySecStamp, MyMilli);

  MaxLengtInString := Length(InString);

  if (MaxLengtInString MOD 2) = 0 then
      begin
        InString := InString + Copy(InString, 1, 1);
      end;

  for I := 1 to (MySecStamp + 7) do
    begin

      if (I MOD 2) = 0 then
        begin
          InString := Copy(InString, (Length(InString) DIV 2),
            Length(InString) - (Length(InString) DIV 2) + 1)
            + Copy(InString, 1, (Length(InString) DIV 2) - 1);
        end
      else
        begin
          InString := Copy(Copy(InString, 1, (Length(InString) DIV 2) - 1),
            (Length(Copy(InString, 1, (Length(InString) DIV 2) - 1)) DIV 2),
            Length(COPY(InString, 1, (Length(InString) DIV 2) - 1))
            - (Length(COPY(InString, 1, (Length(InString) DIV 2) - 1)) DIV 2) + 1)
            + Copy(Copy(InString, 1, (Length(InString) DIV 2) - 1), 1,
            (Length(Copy(InString, 1, (Length(InString) DIV 2) - 1)) DIV 2) - 1)
            + Copy(InString, (Length(InString) DIV 2), Length(InString)
            - (Length(InString) DIV 2) + 1);
        end;

      DecodeTime(Time, MyHour, MyMin, MySec, MyMilli);

      if (MyMilli MOD 2) = 0 then
        InString := Copy(InString, (Length(InString) DIV 2),
          Length(InString) - (Length(InString) DIV 2) + 1)
          + Copy(InString, 1, (Length(InString) DIV 2) - 1);

      if (MySec mod 2) = 0 then
        InString := Copy(Copy(InString, 1, (Length(InString) DIV 2) - 1),
          (Length(Copy(InString, 1, (Length(InString) DIV 2) - 1)) DIV 2),
          Length(Copy(InString, 1, (Length(InString) DIV 2) - 1))
          - (Length(Copy(InString, 1, (Length(InString) DIV 2)-1)) DIV 2) + 1)
          + Copy(Copy(InString, 1, (Length(InString) DIV 2) - 1), 1,
          (Length(Copy(InString, 1, (Length(InString) DIV 2) - 1)) DIV 2) - 1)
          + Copy(InString, (Length(InString) DIV 2), Length(InString)
          - (Length(InString) DIV 2) + 1);

      if (MyMin mod 2) = 0 then
        InString := Copy(InString, 1, (Length(InString) DIV 2) - 1)
          + Copy(Copy(InString, (Length(InString) DIV 2), Length(InString)
          - (Length(InString) DIV 2) + 1), (Length(Copy(InString,
          (Length(InString) DIV 2), Length(InString) - (Length(InString) DIV 2) + 1)) DIV 2),
          Length(Copy(InString, (Length(InString) DIV 2), Length(InString)
          - (Length(InString) DIV 2) + 1)) - (Length(Copy(InString,
          (Length(InString) DIV 2), Length(InString)
          - (Length(InString) DIV 2) + 1)) DIV 2) + 1) + Copy(Copy(InString,
          (Length(InString) DIV 2), Length(InString) - (Length(InString) DIV 2) + 1),
          1, (Length(Copy(InString, (Length(InString) DIV 2), Length(InString)
          - (Length(InString) DIV 2) + 1)) DIV 2) - 1);

      StringVar := '';
      PosInStr := 1;

      while (PosInStr < Length(InString)) do
        begin
          DecodeTime(Time, MyHour, MyMin, MySec, MyMilli);
          if (Random(MyMilli) MOD 2) = 0 then
            StringVar := StringVar + InString[PosInStr] + InString[PosInStr + 1]
          else
            StringVar := StringVar + InString[PosInStr + 1] + InString[PosInStr];
          PosInStr := PosInStr + 2;
        end;

      if PosInStr >= Length(InString) then
        StringVar := StringVar + InString[PosInStr];
      InString := StringVar;
    end;

  if MaxLengtInString <> Length(InString) then
    InString := Copy(InString, 2, Length(InString) - 1);

  Result:=InString;

end;


{ Функция StrToFloat2 вызывает StrToFloat с проверкой в InString разделителя,
  соответствующего установленному в системых настройках ОС }

function StrToFloat2(InString: ShortString): Extended;
var
  PcLCA: array [0..20] of Char;
begin

  GetLocaleInfo(LOCALE_SYSTEM_DEFAULT, LOCALE_SDECIMAL, PcLCA, 19);

  if (Pos('.', InString) <> 0 ) and (Pos(',', InString) = 0) and (PcLCA[0] = ',') then
    InString := StringReplace(InString, '.', PcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  if (Pos(',', InString) <> 0) and (Pos('.', InString) = 0) and (PcLCA[0] = '.') then
    InString := StringReplace(InString, ',', PcLCA[0], [rfReplaceAll, rfIgnoreCase]);

  Result:=StrToFloat(InString);

end;


{ Функция SumFormat получает сумму в строковом виде и преобразует разделитель
  к точке, запятой и копейки
    123 -> 123.00
    123 -> 123,00

    SumFormat('123', '.', 2) }

function SumFormat(InSumStr: ShortString; InSeparator: ShortString;
  InDecimal: Word): ShortString;
var
  SumStrVar: ShortString;
  I: Word;
  Minus: Boolean;
begin

  InSumStr := Trim(InSumStr);

  if Copy(InSumStr, 1, 1) = '-' then
    begin
      Minus := True;
      InSumStr := Copy(InSumStr, 2, Length(InSumStr) - 1);
    end
  else Minus := False;

  SumStrVar := '';

  for I := 1 to Length(InSumStr) do
    begin

      if ((InSumStr[I] <> ' ') and ((InSumStr[I] = '0') or (InSumStr[I] = '1')
        or (InSumStr[I] = '2') or (InSumStr[I] = '3') or (InSumStr[I] = '4')
        or (InSumStr[I] = '5') or (InSumStr[I] = '6') or (InSumStr[I] = '7')
        or (InSumStr[I] = '8') or (InSumStr[I] = '9'))) then
          SumStrVar := SumStrVar + InSumStr[I];

      if (InSumStr[I] = '-') or (InSumStr[I] = '.') or (InSumStr[I] = ',')
        or (InSumStr[I] = '=') then
          SumStrVar := SumStrVar + InSeparator;

    end;

  if (Pos(InSeparator, SumStrVar) = 0) and (InDecimal <> 0) then
    SumStrVar := SumStrVar + InSeparator;

  if (InDecimal = 0) then
    begin
      if (Pos('1', Copy(SumStrVar, POS(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('2', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('3', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('4', Copy(SumStrVar, POS(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('5', Copy(SumStrVar, POS(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('6', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and(Pos('7', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (Pos('8', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0)
        and (POS('9', Copy(SumStrVar, Pos(InSeparator, SumStrVar) + 1,
        Length(SumStrVar) - Pos(InSeparator, SumStrVar))) = 0) then
          SumStrVar := Copy(SumStrVar, 1, POS(InSeparator, SumStrVar) - 1);
    end;

  if (Pos(InSeparator, SumStrVar) <> 0) and (( Length(SumStrVar) - Pos(InSeparator, SumStrVar)) < InDecimal) then
    begin
      for I := 1 to (InDecimal - (Length(SumStrVar) - POS(InSeparator, SumStrVar))) do
        begin
          SumStrVar := SumStrVar + '0';
        end;
    end;

  if Minus = True then
    Result := '-' + SumStrVar
  else Result := SumStrVar;

end;


{ Функция DateTimeToStrFormatSirenaDateTime преобразует тип TDateTime
  в строковый формат даты и времени
  для сервера "Сирены" 2009-06-09T01:01:01.123456 }

function DateTimeToStrFormatSirenaDateTime(InDateTime: TDateTime): ShortString;
var
  MyHour, MyMin, MySec, myMilli: Word;
begin

  DecodeTime(InDateTime, MyHour, MyMin, MySec, myMilli);

  Result := Copy(DateTimeToStr(InDateTime), 7, 4) + '-'
    + Copy(DateTimeToStr(InDateTime), 4, 2)
    + '-' + Copy(DateTimeToStr(InDateTime), 1, 2) +'T'
    + beforZero(MyHour, 2) + ':' + beforZero(MyMin, 2)
    + ':' + beforZero(MySec, 2) + '.' + beforZero(myMilli, 6);

end;


{ Функция StrDateFormat8 преобразует дату 01.02.2002 в строку '020201' ГГММДД }

function StrDateFormat8(InValue: TDate): ShortString;
begin

  if Length(DateToStr(InValue)) = 8 then
    Result := Copy(DateToStr(InValue), 7, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 1, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Copy(DateToStr(InValue), 9, 2) + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 1, 2);

end;


{ Функция StrDateFormat9 преобразует дату и время 23.02.2009 12:37:00
  в строку ДДММГГЧЧММССMs }

function StrDateFormat9(InDateTime: TDateTime): ShortString;
var
  StrDateFormat9Var: shortString;
  MyHour, MyMin, MySec, myMilli: Word;
begin

  DecodeTime(InDateTime, MyHour, MyMin, MySec, myMilli);

  if Length(DateToStr(InDateTime)) = 8 then
    StrDateFormat9Var := Copy(DateToStr(InDateTime), 1, 2)
    + Copy(DateToStr(InDateTime), 4, 2) + Copy(DateToStr(InDateTime), 7, 2);

  if Length(DateToStr(InDateTime)) = 10 then
    StrDateFormat9Var := Copy(DateToStr(InDateTime), 1, 2)
    + Copy(DateToStr(InDateTime), 4, 2) + Copy(DateToStr(InDateTime), 9, 2);

  if Length(TimeToStr(InDateTime)) = 7 then
    begin
      StrDateFormat9Var := StrDateFormat9Var + '0';
      StrDateFormat9Var := StrDateFormat9Var + Copy(TimeToStr(InDateTime), 1, 1)
        + Copy(TimeToStr(InDateTime), 3, 2) + Copy(TimeToStr(InDateTime), 6, 2);
    end
  else
    begin
      StrDateFormat9Var := StrDateFormat9Var + Copy(TimeToStr(InDateTime), 1, 2)
        + Copy(TimeToStr(InDateTime), 4, 2) + Copy(TimeToStr(InDateTime), 7, 2);
    end;

  Result := StrDateFormat9Var + IntToStr(myMilli);

end;


{  Функция StrDateFormat10 преобразует дату и время 23.02.2009 12:37:00
  в строку ГГГГММДДЧЧММСС }

function StrDateFormat10(InValue: TDateTime): ShortString;
begin

  Result:='';

  if Length(DateToStr(InValue)) = 8 then
    Result := Result + Copy(DateToStr(InValue), 7, 2)
      + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 1, 2);

  if Length(DateToStr(InValue)) = 10 then
    Result := Result + Copy(DateToStr(InValue), 7, 4)
      + Copy(DateToStr(InValue), 4, 2)
      + Copy(DateToStr(InValue), 1, 2);

  if Length(TimeToStr(InValue)) = 7 then
    Result := Result + '0' + Copy(TimeToStr(InValue), 1, 1)
      + Copy(TimeToStr(InValue), 3, 2) + Copy(TimeToStr(InValue), 6, 2);

  if Length(TimeToStr(InValue)) = 8 then
    Result := Result + Copy(TimeToStr(InValue), 1, 2)
      + Copy(TimeToStr(InValue), 4, 2) + Copy(TimeToStr(InValue), 7, 2);

end;


{ Функция RandomUserName генерирует UserName }

function RandomUserName(PWLen: Word): ShortString;
var
  StrTableUserName: ShortString;
  N, K, X, Y: Integer;
  Flags: TReplaceFlags;
begin

  StrTableUserName:='1234567890';

  StrTableUserName := DateTimeToStrFormat(Now) + StrTableUserName
    + DateTimeToStrFormat(Now);

  StrTableUserName := mixingString(StrTableUserName);

  Flags := [rfReplaceAll, rfIgnoreCase];
  StrTableUserName := StringReplace(StrTableUserName, '0', '', Flags);

  if (PWlen > Length(StrTableUserName)) then
    K := Length(StrTableUserName) - 1
  else K := PWLen;

  SetLength(result, K);
  Y := Length(StrTableUserName);
  N := 0;

  while N < K do
    begin
      X := Random(Y) + 1;

      if (pos(StrTableUserName[X], result) = 0) then
        begin
          inc(N);
          Result[N] := StrTableUserName[X];
        end;
    end;
end;


{ Функция RandomUserPassword генерирует UserPassword }

Function RandomUserPassword(PWLen: Word): ShortString;
var
  N, K, X, Y: integer;
  StrTableUserPassword: ShortString;
  Flags: TReplaceFlags;
begin

  StrTableUserPassword := 'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM123456789';

  StrTableUserPassword := DateTimeToStrFormat(Now)
    + StrTableUserPassword+DateTimeToStrFormat(Now);

  StrTableUserPassword := mixingString(StrTableUserPassword);

  Flags := [rfReplaceAll, rfIgnoreCase];
  StrTableUserPassword := StringReplace(StrTableUserPassword, '0', '', Flags);

  StrTableUserPassword := StringReplace(StrTableUserPassword, 'o', '', Flags);
  StrTableUserPassword := StringReplace(StrTableUserPassword, 'O', '', Flags);

  if (PWlen > Length(StrTableUserPassword)) then
    K := Length(StrTableUserPassword) - 1
  else K := PWLen;

  SetLength(result, K);
  Y := Length(StrTableUserPassword);
  N := 0;

  while N < K do
    begin
      X := Random(Y) + 1;
      if (pos(StrTableUserPassword[X], result) = 0) then
        begin
          inc(N);
          Result[N] := StrTableUserPassword[X];
        end;
    end;

end;


{ Функция RussianDayOfWeek преобразует американский расчет дня недели в российский }

function RussianDayOfWeek(InDayOfWeek: Byte): Byte;
begin
  if InDayOfWeek = 1 then
    Result := 7
  else
    Result := InDayOfWeek - 1;
end;


{ Функция RussianDayOfWeekFromDate преобразует американский расчет дня недели
  в российский из даты }

function RussianDayOfWeekFromDate(InDate: TDate): Byte;
var
  DayOfWeekVar: Byte;
begin

  DayOfWeekVar := DayOfWeek(InDate);

  if DayOfWeekVar = 1 then
    Result := 7
  else Result := DayOfWeekVar - 1;

end;



{ Функция DaysOffBetweenDates возвращает количество выходных дней (субб., вскр.)
  между 2-мя датами, переданными в качестве аргументов }

function DaysOffBetweenDates(InDateBegin: TDate; InDateEnd: TDate): Word;
var
  currDate: TDate;
begin

  Result := 0;
  currDate := InDateBegin;
  while currDate <= InDateEnd do
    begin
      if ((RussianDayOfWeekFromDate(currDate) = 6)
        or (RussianDayOfWeekFromDate(currDate) = 7))
        and (currDate <> InDateBegin) then
          Result := Result + 1;
      currDate := currDate + 1;
    end;

end;


{ Функция paramFromString возвращает параметр (ShortString) из структурированной
  строки вида "параметр_номер_1=100.00; параметр_номер_2=200.00; "
  - Адаптирована к параметр_номер_1 и параметр_номер_11 }

function paramFromString(InStringAnswer: WideString; InParam: ShortString): ShortString;
begin

  if Pos('=', InParam) = 0 then
    InParam := InParam + '=';

  if Pos(InParam, InStringAnswer) <> 0 then
    Result := Copy(Copy(InStringAnswer, Pos(InParam, InStringAnswer) + Length(InParam),
      (Length(InStringAnswer) - Pos(InParam, InStringAnswer) + Length(InParam) + 1)),
      1, Pos(';', Copy(InStringAnswer, Pos(InParam, InStringAnswer) + Length(InParam),
      (Length(InStringAnswer) - Pos(InParam, InStringAnswer) + Length(InParam)+1))) - 1)
  else Result:='';

end;


{ Функция ParamFromString2 возвращает параметр (тип WideString) из структурированной
  строки вида "параметр_номер_1=100.00; параметр_номер_2=200.00; "
  - Адаптирована к параметр_номер_1 и параметр_номер_11 }

function ParamFromString2(InStringAnswer: WideString; InParam: ShortString): WideString;
begin

  if Pos('=', InParam) = 0 then
    InParam := InParam + '=';

  if Pos(InParam, InStringAnswer) <> 0 then
    Result := Copy(Copy(InStringAnswer, Pos(InParam, InStringAnswer)
      + Length(InParam), (Length(InStringAnswer) - Pos(InParam, InStringAnswer)
      + Length(InParam) + 1)), 1, Pos(';', Copy(InStringAnswer,
      POS(InParam, InStringAnswer) + Length(InParam), (Length(InStringAnswer)
      - Pos(InParam, InStringAnswer) + Length(InParam) + 1))) -1)
   else Result := '';

end;


{ Функция ParamFromString3 возвращает параметр (тип WideString) из структурированной
  строки вида "параметр_номер_1=100.00; параметр_номер_2=200.00; "
   - адаптирована к параметр_номер_1 и параметр_номер_11.
   - адаптирована к регистру: "параметр_номер_1" и "пАраметр_номер_1" }

function ParamFromString3(InStringAnswer: WideString; InParam: ShortString): WideString;
var
  StringAnswerVar: WideString;
  ParamVar: ShortString;
begin

  ParamVar := AnsiLowerCase(InParam);
  StringAnswerVar := AnsiLowerCase(InStringAnswer);

  if Pos('=', InParam) = 0 then
    InParam := InParam + '=';

  if Pos('=', ParamVar) = 0 then
    ParamVar := ParamVar + '=';

  if Pos(ParamVar, StringAnswerVar) <> 0 then
    Result := Copy(Copy(InStringAnswer, Pos(ParamVar, StringAnswerVar) + Length(InParam),
      (Length(InStringAnswer)
      - Pos(ParamVar, StringAnswerVar) + Length(InParam) + 1)), 1,
      Pos(';', Copy(InStringAnswer, Pos(ParamVar, StringAnswerVar) + Length(InParam),
      (Length(InStringAnswer) - Pos(ParamVar, StringAnswerVar) + Length(InParam) + 1))) - 1)
  else Result := '';

end;


{ Функция SetParamFromString сохраняет значение параметра в структурированной
  строке вида "параметр_номер_1=100.00; параметр_номер_2=200.00; " }

function SetParamFromString(InStringAnswer: WideString; InParam: ShortString;
  InValue: ShortString): ShortString;
var
  BeforeSubstring, AfterSubstring: ShortString;
begin

  if Pos('=', InParam) = 0 then
    InParam := InParam + '=';

  if Pos(InParam, InStringAnswer) <> 0 then
    begin
      BeforeSubstring := Copy(InStringAnswer, 1, Pos(InParam, InStringAnswer) - 1);
      AfterSubstring := Copy(Copy(InStringAnswer, Pos(InParam, InStringAnswer),
        Length(InStringAnswer) - Pos(InParam, InStringAnswer) + 1),
        Pos(';', Copy(InStringAnswer, Pos(InParam, InStringAnswer),
        Length(InStringAnswer) - Pos(InParam, InStringAnswer) + 1)) + 1,
        Length(Copy(InStringAnswer, Pos(InParam, InStringAnswer), Length(InStringAnswer)
        - Pos(InParam, InStringAnswer) + 1))
        - Pos(';', Copy(InStringAnswer, Pos(InParam, InStringAnswer),
        Length(InStringAnswer) - Pos(InParam, InStringAnswer) + 1)));
      Result:=BeforeSubstring+InParam+InValue+';'+AfterSubstring;
    end
  else Result := InStringAnswer +' ' + InParam + InValue + ';';

end;


{ Функция setParamFromString2 сохраняет значение параметра (WideString)
  в строке вида "параметр_номер_1=100.00; параметр_номер_2=200.00;"
  Версия, адаптированная к регистру! }

function SetParamFromString2(InStringAnswer: WideString; InParam: ShortString;
  InValue: ShortString): WideString;
var
  BeforeSubstring, AfterSubstring: WideString;
  InStringAnswerVar: WideString;
  InParamVar: ShortString;
begin

  InParamVar := AnsiLowerCase(InParam);
  InStringAnswerVar := AnsiLowerCase(InStringAnswer);

  if Pos('=', InParam) = 0
    then InParam := InParam + '=';

  if Pos(InParamVar, InStringAnswerVar) <> 0 then
    begin
        BeforeSubstring := Copy(InStringAnswer, 1, Pos(InParamVar, InStringAnswerVar) - 1);
        AfterSubstring := Copy(Copy(InStringAnswer, Pos(InParamVar,
          InStringAnswerVar), Length(InStringAnswer) - Pos(InParamVar,
          InStringAnswerVar) +1), Pos(';', Copy(InStringAnswer, Pos(InParamVar,
          InStringAnswerVar), Length(InStringAnswer) - Pos(InParamVar,
          InStringAnswerVar) + 1)) + 1, Length(Copy(InStringAnswer,
          Pos(InParamVar, InStringAnswerVar), Length(InStringAnswer)
          - Pos(InParamVar, InStringAnswerVar) + 1))
          - Pos(';', Copy(InStringAnswer, Pos(InParamVar, InStringAnswerVar),
          Length(InStringAnswer) - Pos(InParamVar, InStringAnswerVar) + 1))) ;
        Result := BeforeSubstring + InParam + InValue + ';' + AfterSubstring;
    end
  else
    begin
      Result := InStringAnswer + ' ' + InParam+InValue + ';';
    end;

end;


{ Функция CountParamFromString возвращает число параметров в строке
  вида "параметр_номер_1=100.00; параметр_номер_2=200.00;" }

function CountParamFromString(InStringAnswer: WideString): Word;
var
  СountChar: Word;
  FindChar: Boolean;
  SubStrForFind: WideString;
begin
  СountChar := 0;
  FindChar := True;
  SubStrForFind := InStringAnswer;

  while FindChar = True do
    begin
      if Pos('=', SubStrForFind) = 0 then
        begin
          FindChar := False;
        end
      else
        begin
          СountChar := СountChar + 1;
          SubStrForFind := Copy(SubStrForFind, Pos('=', SubStrForFind) + 1,
            Length(SubStrForFind) - Pos('=', SubStrForFind));
        end;
    end;
  Result := СountChar;

end;


{ Функция ParamNameFromString возвращает наименование параметра по его
  порядковому номеру из строки вида
  "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = параметр_номер_2 }

function ParamNameFromString(InStringAnswer: WideString; InParamNumber: Word): ShortString;
var
  СountChar: Word;
  FindChar: Boolean;
  SubStrForFind: WideString;
  PosRavno, PosCurrent: Word;
begin

  СountChar := 0;
  FindChar := True;
  SubStrForFind := InStringAnswer;
  PosRavno := 0;

  while (FindChar = True) and (СountChar < InParamNumber) do
    begin
      if Pos('=', SubStrForFind) = 0 then
        begin
          FindChar := False;
          PosRavno := 0;
        end
      else
        begin
          СountChar := СountChar + 1;
          PosRavno := PosRavno + Pos('=', SubStrForFind);
          SubStrForFind := Copy(SubStrForFind, Pos('=', SubStrForFind) + 1,
            Length(SubStrForFind) - Pos('=', SubStrForFind));
        end;
    end;

  if PosRavno<>0 then
    begin
      SubStrForFind := Copy(InStringAnswer, 1, PosRavno - 1);
      PosCurrent := PosRavno - 1;
      Result := '';
      while (PosCurrent >= 1) and (Copy(SubStrForFind, PosCurrent, 1) <> ' ')
        and(Copy(SubStrForFind, PosCurrent, 1) <> ';') do
        begin
          Result := Result + Copy(SubStrForFind, PosCurrent, 1);
          PosCurrent := PosCurrent - 1;
        end;

        PosCurrent := Length(Result);
        SubStrForFind := Result;
        Result := '';
        while (PosCurrent >= 1) do
          begin
            Result := Result + Copy(SubStrForFind, PosCurrent, 1);
            PosCurrent := PosCurrent - 1;
          end;
    end
  else Result := '';

end;


{ Функция ParamValueFromString возвращает значение параметра по его порядковому
  номеру: "параметр_номер_1=100.00; параметр_номер_2=200.00; " второй параметр = 200.00 }

function ParamValueFromString(InStringAnswer: WideString; InParamNumber: Word):WideString;
var
  СountChar: Word;
  FindChar: Boolean;
  SubStrForFind: WideString;
  PosRavno, PosCurrent: Word;
begin

  СountChar := 0;
  FindChar := True;
  SubStrForFind := InStringAnswer;
  PosRavno := 0;

  while (FindChar = True) and (СountChar < InParamNumber) do
    begin
      if Pos('=', SubStrForFind) = 0 then
        begin
          FindChar := False;
          PosRavno := 0;
        end
      else
        begin
          СountChar := СountChar + 1;
          PosRavno := PosRavno + Pos('=', SubStrForFind);
          SubStrForFind := Copy(SubStrForFind, Pos('=', SubStrForFind) + 1,
            Length(SubStrForFind) - Pos('=', SubStrForFind));
        end;
    end;

  if PosRavno <> 0 then
    begin
        SubStrForFind := Copy(InStringAnswer, PosRavno + 1,
          Length(InStringAnswer) - PosRavno);
        PosCurrent:=1;
        Result:='';
        while (PosCurrent <= Length(SubStrForFind))
          and (Copy(SubStrForFind, PosCurrent, 1) <> ';') do
          begin
            Result := Result + Copy(SubStrForFind, PosCurrent, 1);
            PosCurrent := PosCurrent + 1;
          end;
    end
  else
    begin
      Result := '';
    end;

end;


{ Функция GetParamFromDoublePayment из строки, содержащей двойной параметр вида
  "1234-9044951501" возвращает первый "1234" (при InParamNumber=1)
  или второй параметр "9044951501" (при InParamNumber=2) }

function GetParamFromDoublePayment(InDoubleAutData: ShortString;
  InParamNumber: Byte): ShortString;
var
  AutData, AutData1, AutData2: ShortString;
begin

  AutData := StringReplace(InDoubleAutData, ' ', '', [rfReplaceAll]);

  if (Pos('-', AutData) <> 0) then
    begin
      AutData2 := Copy(AutData, Pos('-', AutData) + 1, Length(AutData) - Pos('-', AutData));
      AutData1 := Copy(AutData, 1, Pos('-', AutData) - 1);
    end
  else
    begin
      AutData2 := '';
      AutData1 := AutData;
    end;

  if InParamNumber = 1 then
    Result := AutData1
  else Result := AutData2;

end;


{ Функция Ps_paymGate_maskSymbol перед передачей результата
  для PS_PaymGate (PS_PaymGateServer, PS_PaymGate Exchange) маскирует
  и демаскирует спецсимволы " ; = #
  при InMaskDeMask = Mask - производится маскирование,
      InMaskDeMask = DeMask - производится де-маскирование }

function Ps_paymGate_maskSymbol(InString: WideString; InMaskDeMask :ShortString)
  : WideString;
begin

  if InMaskDeMask = 'Mask' then
    begin
      InString := StringReplace(InString, '"', '&quot', [rfReplaceAll]);
      InString := StringReplace(InString, ';', '&quo4', [rfReplaceAll]);
      InString := StringReplace(InString, '=', 'quou', [rfReplaceAll]);
      InString := StringReplace(InString, '#', '&quo3', [rfReplaceAll]);
    end;

  if InMaskDeMask = 'DeMask' then
    begin
      InString := StringReplace(InString, '&quot', '"', [rfReplaceAll]);
      InString := StringReplace(InString, '&quo4', ';', [rfReplaceAll]);
      InString := StringReplace(InString, 'quou', '=', [rfReplaceAll]);
      InString := StringReplace(InString, '&quo3', '#', [rfReplaceAll]);
    end;

  Result := InString;

end;


{ Функция GetLocalIP возвращает локальный Ip-адрес }

function GetLocalIP: ShortString;
  const
    WSVer = $101;
  var
    wsaData: TWSAData;
    P: PHostEnt;
    Buf: array [0..127] of Char;
begin

  Result:= '';

  if WSAStartup(WSVer, wsaData) = 0 then
    begin
      if GetHostName(@Buf, 128) = 0 then
      begin
        P := GetHostByName(@Buf);
        if P <> nil then
          Result := iNet_ntoa(PInAddr(p^.h_addr_list^)^);
      end;
      WSACleanup;
    end;

end;


{ Функция MaskString маскирует середину строки, переданную ей в качестве
  аргумента }

function MaskString(InStringForMask: ShortString): ShortString;
var
  StartPosMask, EndPosMask, I: Word;
begin

  Result := '';
  StartPosMask := ((Length(InStringForMask) Div 2) Div 2) + 2;
  EndPosMask := (Length(InStringForMask) Div 2) + ((Length(InStringForMask) Div 2) Div 2);

  for I := 1 to Length(InStringForMask) do
    begin
      if (I >= StartPosMask) and (I <= EndPosMask) then
          begin
            Result := Result + 'X';
          end
      else
        begin
          Result := Result + InStringForMask[I];
        end;
    end;

end;

    exports

RoundCurrency Name 'RoundCurrency',

DosToWin Name 'DosToWin',

WinToDos Name 'WinToDos',

ChangeSeparator Name 'ChangeSeparator',

ChangeSeparator2 Name 'ChangeSeparator2',

LeftFixString Name 'LeftFixString',

RightFixString Name 'RightFixString',

CentrFixString Name 'CentrFixString',

PrnSum Name 'PrnSum',

TrSum Name 'TrSum',

BnkDay Name 'BnkDay',

DiaStrDate Name 'DiaStrDate',

PropisStrDate Name 'PropisStrDate',

FindSeparator Name 'FindSeparator',

FindChar Name 'FindChar',

FindCharWideString Name 'FindCharWideString',

FindCharWideString2 Name 'FindCharWideString2',

FindSpace Name 'FindSpace',

CountCharInString Name 'CountCharInString',

Upper Name 'Upper',

Proper Name 'Proper',

Lower Name 'Lower',

Divide1000 Name 'Divide1000',

ParamFromIniFile Name 'ParamFromIniFile',

ParamFromIniFileWithOutMessDlg Name 'ParamFromIniFileWithOutMessDlg',

ParamFromIniFileWithOutMessDlg2 Name 'ParamFromIniFileWithOutMessDlg2',

ParamFromIniFileWithFullPath Name 'ParamFromIniFileWithFullPath',

ParamFromIniFileWithFullPathWithOutMessDlg Name 'ParamFromIniFileWithFullPathWithOutMessDlg',

ParamFoundFromIniFile Name 'ParamFoundFromIniFile',

BeforZero Name 'BeforZero',

ID12docFromJournal Name 'ID12docFromJournal',

DateTimeToSec Name 'DateTimeToSec',

StrToPchar Name 'StrToPchar',

ToLogFileWithName Name 'ToLogFileWithName',

ToLogFileWideStringWithName Name 'ToLogFileWideStringWithName',

ToLogFileWithFullName Name 'ToLogFileWithFullName',

ToLogFileWideStringWithFullName Name 'ToLogFileWideStringWithFullName',

TranslitBeeLine Name 'TranslitBeeLine',

FormatMSSqlDate Name 'FormatMSSqlDate',

StrFormatTimeStampToDateTime Name 'StrFormatTimeStampToDateTime',

StrTimeStampToStrDateTime Name 'StrTimeStampToStrDateTime',

DateTimeToStrFormat Name 'DateTimeToStrFormat',

DecodeCurCodeToISO  Name 'DecodeCurCodeToISO',

CardExpDate_To_Date Name 'CardExpDate_To_Date',

DecodeTypeCard Name 'DecodeTypeCard',

DecodeTypeCardGPB Name 'DecodeTypeCardGPB',

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

GetShortFileName Name 'GetShortFileName',

GetFilePath Name 'GetFilePath',

GetShortFileNameWithoutExt Name 'GetShortFileNameWithoutExt',

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

MixingString Name 'MixingString',

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

DaysOffBetweenDates Name 'DaysOffBetweenDates',

ParamFromString Name 'ParamFromString',

CountParamFromString Name 'CountParamFromString',

ParamNameFromString Name 'ParamNameFromString',

ParamValueFromString Name 'ParamValueFromString',

ParamFromString2 Name 'ParamFromString2',

ParamFromString3 Name 'ParamFromString3',

SetParamFromString Name 'SetParamFromString',

SetParamFromString2 Name 'SetParamFromString2',

GetParamFromDoublePayment Name 'GetParamFromDoublePayment',

Ps_paymGate_maskSymbol Name 'Ps_paymGate_maskSymbol',

GetLocalIP Name 'GetLocalIP',

MaskString Name 'MaskString';

begin

end.
