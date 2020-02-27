with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;
with Ada.Numerics.Float_Random; use Ada.Numerics.Float_Random;
procedure wordscram is

  function getFilename return unbounded_string is
    filename : unbounded_string;
  begin
    Put("Please enter the file name: ");
    Get_Line(filename);
    return filename;
  end getFilename;

  -- function randomInt(a,b : integer) return integer is
  --   num : integer;
  --   G : Generator;
  -- begin
  --   Reset(G);
  --   num := a + (Integer(Float(b) * Random(G)) mod b);
  --   return num;
  -- end randomInt;

  function isNumber(word: unbounded_string) return Boolean is
    flt : float := 0.0;
  begin
    flt := float'value(To_String(word));
    return true;
  exception
      when others =>
        return false;
  end isNumber;

  function isWord(word: unbounded_string) return Boolean is
  begin
    put_line(word);
    for i in 1..Length(word) loop
      if element(word,i) < Character'Val(65) or element(word,i) > Character'Val(173) then
        return False;
      end if;
      if element(word,i) < Character'Val(97) and element(word,i) > Character'Val(90) then
        return False;
      end if;
    end loop;
    return True;
  end isWord;

  function isEndOfWord(c : character) return Boolean is
  begin
    if c = ',' or c = '.' or c = '?' or c = '!' or c = ':' or c = ' ' then
      return True;
    end if;
    return false;
  end isEndOfWord;

  function processText(filename: unbounded_string) return integer is
    infp : file_type;
    line, word : unbounded_string;
    whitespaceIndex : integer;

    totalWords : integer := 0;
  begin
    open(infp, In_File, To_String(filename));

    -- Loop through each line in the file
    while(not End_of_File(infp)) loop
      line := Get_Line(infp);
      -- Loop through each word in the line
      whitespaceIndex := 1;
      for i in 1..Length(line) loop
      -- If we have space or punctuation, it's the end of the word
        if isEndOfWord(element(line,i)) then
          word := To_Unbounded_String(Slice(line, whitespaceIndex, i-1));
          if isWord(word) then
            totalWords := totalWords + 1;
          end if;
        end if;
      end loop;
    end loop;
    put("Total words: ");
    put(totalWords);
    new_line;
    close(infp);

    return -1;
  end processText;

  function checkIfValidFile(filename: unbounded_string) return Boolean is
      infp : file_type;
  begin
    open(infp, In_File, To_String(filename));
    close(infp);
    return True;
    exception
      when Name_Error =>
       Put_Line("Invalid File Name");
       return False;
  end checkIfValidFile;

  filename, word : unbounded_string;
  randInt, count : integer;
  isValidWord, isValidFile : Boolean;
begin

 isValidFile := False;
 while(not isValidFile) loop
   filename := getFilename;
   isValidFile := checkIfValidFile(filename => filename);
 end loop;

 count := processText(filename => filename);
end wordscram;
