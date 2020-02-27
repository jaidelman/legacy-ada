with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;
procedure textyzer is

  function getFilename return unbounded_string is
    filename : unbounded_string;
  begin
    Put("Please enter the file name: ");
    Get_Line(filename);
    return filename;
  end getFilename;

  function isNumber(word: unbounded_string) return Boolean is
  begin
    for i in 1..Length(word) loop
      if element(word,i) < Character'Val(48) or element(word,i) > Character'Val(57) then
        return False;
      end if;
    end loop;
    return True;
  end isNumber;

  function isWord(word: unbounded_string) return Boolean is
  begin
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

  function isPunctuation(c : character) return Boolean is
  begin
    if c = ',' or c = '.' or c = '?' or c = '!' or c = ':' then
      return True;
    end if;
    return false;
  end isPunctuation;

  function isEndOfSentence(c : character) return Boolean is
  begin
    if c = '.' or c = '?' or c = '!' then
      return True;
    end if;
    return false;
  end isEndOfSentence;

  function analyzeText(filename: unbounded_string) return integer is
    infp : file_type;
    line, word : unbounded_string;
    whitespaceIndex : integer;
    punctuationIndex : integer := 1;

    totalWords, totalNumbers, totalPunctuation, totalChar, totalSentences, totalLines : integer := 0;
    avgLettersPerWord, avgWordsPerSentence : float;
  begin
    open(infp, In_File, To_String(filename));

    -- Loop through each line in the file
    while(not End_of_File(infp)) loop
      line := Get_Line(infp);
      -- Loop through each word in the line
      whitespaceIndex := 0;
      for i in 1..Length(line) loop
        totalChar := totalChar + 1;
      -- Check for if it's the end of the word (when we hit a space or new line)
        if element(line, i) = ' ' or i = Length(line) then
          word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));

          -- Check if char before whitespace is punctuation
          if i = Length(line) and isPunctuation(element(line,i)) then
            totalPunctuation := totalPunctuation + 1;
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));
            punctuationIndex := i;
          elsif isPunctuation(element(line, i-1)) then
            totalPunctuation := totalPunctuation + 1;
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-2));
            punctuationIndex := i-1;
          elsif i = Length(line) then
              word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i));
          end if;

          -- Check if it's the end of the sentence
          if isEndOfSentence(element(line, punctuationIndex)) then
            totalSentences := totalSentences + 1;
            punctuationIndex := 1;
          end if;

          -- Check if it's a number
          if isNumber(word) then
            totalNumbers := totalNumbers + 1;
          elsif isWord(word) then
            totalWords:= totalWords + 1;
          end if;
          whitespaceIndex := i; -- Set index of whitespace
        end if;
      end loop;
      totalLines := totalLines + 1;
    end loop;

    avgLettersPerWord := Float(totalChar)/Float(totalWords);
    avgWordsPerSentence := Float(totalWords)/Float(totalSentences);

    put("Number of characters: ");
    put(totalChar);
    new_line;

    put("Number of words: ");
    put(totalWords);
    new_line;

    put("Number of numbers: ");
    put(totalNumbers);
    new_line;

    put("Number of sentences: ");
    put(totalSentences);
    new_line;

    put("Number of lines: ");
    put(totalLines);
    new_line;

    put("Number of punctuation: ");
    put(totalPunctuation);
    new_line;

    -- Avg characters instead of letters, as discussed in the forum https://courselink.uoguelph.ca/d2l/le/590330/discussions/threads/2928413/View
    put("Average characters per word: ");
    put(avgLettersPerWord, 2, 2, 0);
    new_line;

    put("Average words per sentence: ");
    put(avgWordsPerSentence, 2, 2, 0);
    new_line;

    close(infp);

    return -1;
  end analyzeText;

  function printHist(filename: unbounded_string) return integer is
    infp : file_type;
    line, word : unbounded_string;
    whitespaceIndex, wordLength : integer;
    punctuationIndex : integer := 1;
    wordLengthArr : array(1..20) of integer;
  begin

    -- Set all word lengths to 0
    for i in 1..20 loop
      wordLengthArr(i) := 0;
    end loop;

    open(infp, In_File, To_String(filename));

    -- Loop through each line in the file
    while(not End_of_File(infp)) loop
      line := Get_Line(infp);
      -- Loop through each word in the line
      whitespaceIndex := 0;
      for i in 1..Length(line) loop
      -- Check for if it's the end of the word (when we hit a space or new line)
        if element(line, i) = ' ' or i = Length(line) then
          word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));

          -- Check if char before whitespace is punctuation
          if i = Length(line) and isPunctuation(element(line,i)) then
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));
            punctuationIndex := i;
          elsif isPunctuation(element(line, i-1)) then
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-2));
            punctuationIndex := i-1;
          elsif i = Length(line) then
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i));
          end if;

        -- Check if it's the end of the sentence to reset punctuationIndex
          if isEndOfSentence(element(line, punctuationIndex)) then
            punctuationIndex := 1;
          end if;

          wordLength := Length(word);
          wordLengthArr(wordLength) := wordLengthArr(wordLength) + 1;

          whitespaceIndex := i; -- Set index of whitespace
        end if;
      end loop;
    end loop;
    close(infp);

    new_line;
    for i in 1..20 loop
      put(i);
      put("    ");
      for j in 1..wordLengthArr(i) loop
        put('*');
      end loop;
      new_line;
    end loop;

    return -1;
  end printHist;

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

  filename : unbounded_string;
  count : integer;
  isValidFile : Boolean;
begin

 isValidFile := False;
 while(not isValidFile) loop
   filename := getFilename;
   isValidFile := checkIfValidFile(filename => filename);
 end loop;

 count := analyzeText(filename => filename);
 if count = 0 then
   new_line;
 end if;
 count := printHist(filename => filename);
 if count = 0 then
   new_line;
 end if;

end textyzer;
