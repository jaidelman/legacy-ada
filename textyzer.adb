-- Joshua Aidelman, 1000139, jaidelma@uoguelph.ca

-- This program reads in a text file and analyzes it, counting the total
-- characters, words, numbers, sentences, lines and punctuation marks. It also
-- calculates the average characters per word, and average words per sentence.
-- The program then prints a histogram of the word length for all the words in
-- the file.
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Float_Text_IO; use Ada.Float_Text_IO;
with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.unbounded.Text_IO; use ada.strings.unbounded.Text_IO;
procedure textyzer is
  -- Get's filename from user
  function getFilename return unbounded_string is
    filename : unbounded_string;
  begin
    Put("Please enter the file name: ");
    Get_Line(filename);
    return filename;
  end getFilename;

  -- Check if string is a number
  function isNumber(word: unbounded_string) return Boolean is
  begin
    -- Loop through string and check each character
    for i in 1..Length(word) loop
      -- If any character is not a number, return false
      if element(word,i) < Character'Val(48) or element(word,i) > Character'Val(57) then
        return False;
      end if;
    end loop;
    -- Otherwise return true
    return True;
  end isNumber;

  -- Check if string is a vlid word
  function isWord(word: unbounded_string) return Boolean is
  begin
    -- Loop through string and check each character
    for i in 1..Length(word) loop
      -- Check if below upper case or above lower case
      if element(word,i) < Character'Val(65) or element(word,i) > Character'Val(173) then
        return False;
      end if;
      -- Check between the cases
      if element(word,i) < Character'Val(97) and element(word,i) > Character'Val(90) then
        return False;
      end if;
    end loop;
    -- If all characters are good, return true
    return True;
  end isWord;

  -- Check if a character is punctuation
  function isPunctuation(c : character) return Boolean is
  begin
    -- If it is any punctuation character return true
    if c = ',' or c = '.' or c = '?' or c = '!' or c = ':' then
      return True;
    end if;
    return false; -- If it's not a punctuation return false
  end isPunctuation;

  -- Check if a character is an end of sentence character
  function isEndOfSentence(c : character) return Boolean is
  begin
    if c = '.' or c = '?' or c = '!' then
      return True;
    end if;
    return false;
  end isEndOfSentence;

  -- This function reads in a file and analyzes it
  function analyzeText(filename: unbounded_string) return integer is
    infp : file_type; --The file pointer
    line, word : unbounded_string; -- To store each line/word
    whitespaceIndex : integer; -- The latest character index
    punctuationIndex : integer := 1; -- Stores what index the last punctuation was

    -- To store totals and averages
    totalWords, totalNumbers, totalPunctuation, totalChar, totalSentences, totalLines : integer := 0;
    avgCharPerWord, avgWordsPerSentence : float;
  begin
    open(infp, In_File, To_String(filename)); -- Open file

    -- Print header
    put_line("The Text");
    put_line("________");
    new_line;

    -- Loop through each line in the file
    while(not End_of_File(infp)) loop
      line := Get_Line(infp);
      put_line(line);
      -- Loop through each word in the line
      whitespaceIndex := 0; -- Reset whitespace index
      for i in 1..Length(line) loop
        totalChar := totalChar + 1;
      -- Check for if it's the end of the word (when we hit a space or new line)
        if element(line, i) = ' ' or i = Length(line) then

          -- We know the word will be between the character after the previous whitespace
          -- and the current whitespace.
          word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));

          -- If we're at the end of the line and the line ends in punctuation:
          if i = Length(line) and isPunctuation(element(line,i)) then
            totalPunctuation := totalPunctuation + 1; -- Increment punctuation count
            punctuationIndex := i; -- Set new punctuation index
          -- Else if the word ends in punctuation:
          elsif isPunctuation(element(line, i-1)) then
            totalPunctuation := totalPunctuation + 1; -- Increment punctuation count
            -- Move the word to cut out the punctuation
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-2));
            punctuationIndex := i-1; -- Save index of punctuation
          -- Else if we're at the end of the line:
          elsif i = Length(line) then
              -- Move the word to include the last character (normally we truncate the space)
              word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i));
          end if;

          -- Check if it's the end of the sentence
          if isEndOfSentence(element(line, punctuationIndex)) then
            totalSentences := totalSentences + 1;
            punctuationIndex := 1; -- Reset punctuation index
          end if;

          -- Check if it's a number
          if isNumber(word) then
            totalNumbers := totalNumbers + 1;
          -- Check if it's a word
          elsif isWord(word) then
            totalWords:= totalWords + 1;
          end if;
          whitespaceIndex := i; -- Set index of whitespace
        end if;
      end loop;
      totalLines := totalLines + 1; -- Increment total lines
    end loop;

    -- Calculate averages
    -- * Avg characters instead of letters, as discussed in the forum https://courselink.uoguelph.ca/d2l/le/590330/discussions/threads/2928413/View *
    avgCharPerWord := Float(totalChar)/Float(totalWords);
    avgWordsPerSentence := Float(totalWords)/Float(totalSentences);

    -- Print header
    new_line;
    put_line("Text Statistics");
    put_line("_______________");
    new_line;

    -- Print all statistics
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

    put("Average characters per word: ");
    put(avgCharPerWord, 2, 2, 0);
    new_line;

    put("Average words per sentence: ");
    put(avgWordsPerSentence, 2, 2, 0);
    new_line;

    close(infp);

    return -1;
  end analyzeText;

  -- Print the histogram
  function printHist(filename: unbounded_string) return integer is
    infp : file_type; -- File pointer
    line, word : unbounded_string; -- To store the word and lines
    whitespaceIndex, wordLength : integer; -- To store whitespace index and word length
    punctuationIndex : integer := 1; -- To store punctuation index
    wordLengthArr : array(1..20) of integer; -- To store how many of each word length
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
          -- We know the word will be between the character after the previous whitespace
          -- and the current whitespace.
          word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-1));

          -- If we're at the end of the line and the line ends in punctuation:
          if i = Length(line) and isPunctuation(element(line,i)) then
            punctuationIndex := i; -- Set new punctuation index
          -- Else if the word ends in punctuation:
          elsif isPunctuation(element(line, i-1)) then
            -- Move the word to cut out the punctuation
            word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i-2));
            punctuationIndex := i-1; -- Save index of punctuation
          -- Else if we're at the end of the line:
          elsif i = Length(line) then
              -- Move the word to include the last character (normally we truncate the space)
              word := To_Unbounded_String(Slice(line, whitespaceIndex+1, i));
          end if;

          -- Check if it's the end of the sentence
          if isEndOfSentence(element(line, punctuationIndex)) then
            punctuationIndex := 1; -- Reset punctuation index
          end if;

          -- Calculate word length and add it to the array
          wordLength := Length(word);
          wordLengthArr(wordLength) := wordLengthArr(wordLength) + 1;

          whitespaceIndex := i; -- Set index of whitespace
        end if;
      end loop;
    end loop;
    close(infp);

    -- Print the histogram
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

  -- Check if a filename is valid
  function checkIfValidFile(filename: unbounded_string) return Boolean is
      infp : file_type;
  begin
    -- If the file opens and closes without an issue, it is falid
    open(infp, In_File, To_String(filename));
    close(infp);
    return True;
    exception
      -- If there's an exception, the file must not exist
      when Name_Error =>
       Put_Line("Invalid File Name");
       return False;
  end checkIfValidFile;

  -- Main function
  filename : unbounded_string; -- To store the filename
  count : integer; -- To store the return value from analyzeText and printHist
  isValidFile : Boolean; -- To store the return value of isValidFile
begin

 isValidFile := False;
 -- Loop until user enter's a valid file
 while(not isValidFile) loop
   filename := getFilename;
   isValidFile := checkIfValidFile(filename => filename);
 end loop;

 -- Analize the text
 count := analyzeText(filename => filename);
 -- This was done to use count, since there is a warning if I don't
 if count = 0 then
   new_line;
 end if;
 -- Print the histogram
 count := printHist(filename => filename);
 -- This was done to use count, since there is a warning if I don't
 if count = 0 then
   new_line;
 end if;

end textyzer;
