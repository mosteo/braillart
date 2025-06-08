with Braillart; use Braillart;

procedure Braillart_Tests.Panoramas is
   -- Test constants
   T : constant Boolean := True;
   F : constant Boolean := False;

   -- Test 1: Empty 4x2 matrix (single cell)
   Empty_Line : constant Line_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => F, 2 => F),
       2 => (1 => F, 2 => F),
       3 => (1 => F, 2 => F),
       4 => (1 => F, 2 => F));

   -- Test 2: Single dot at position (1,1) in a 4x2 matrix
   Single_Dot_Line : constant Line_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => T, 2 => F),
       2 => (1 => F, 2 => F),
       3 => (1 => F, 2 => F),
       4 => (1 => F, 2 => F));

   -- Test 3: Two dots at positions (1,1) and (2,2) in a 4x2 matrix
   Two_Dots_Line : constant Line_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => T, 2 => F),
       2 => (1 => F, 2 => T),
       3 => (1 => F, 2 => F),
       4 => (1 => F, 2 => F));

   -- Test 4: Fourth row dots at positions (4,1) and (4,2) in a 4x2 matrix
   Fourth_Row_Line : constant Line_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => F, 2 => F),
       2 => (1 => F, 2 => F),
       3 => (1 => F, 2 => F),
       4 => (1 => T, 2 => T));

   -- Test 5: Full 4x2 matrix (all dots set)
   Full_Line : constant Line_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => T, 2 => T),
       2 => (1 => T, 2 => T),
       3 => (1 => T, 2 => T),
       4 => (1 => T, 2 => T));

   -- Test 6: Wider matrix with multiple cells (4x4 = two 4x2 cells)
   Multi_Cell_Line : constant Line_Matrix (1 .. 4, 1 .. 4) :=
      (1 => (1 => T, 2 => F, 3 => F, 4 => T),
       2 => (1 => F, 2 => T, 3 => F, 4 => F),
       3 => (1 => F, 2 => F, 3 => T, 4 => F),
       4 => (1 => F, 2 => F, 3 => T, 4 => T));

   -- Test 7: Odd width matrix (4x3 = one complete 4x2 cell, last column ignored)
   Odd_Width_Line : constant Line_Matrix (1 .. 4, 1 .. 3) :=
      (1 => (1 => T, 2 => F, 3 => F),  -- Last column should be ignored
       2 => (1 => F, 2 => T, 3 => T),
       3 => (1 => F, 2 => F, 3 => F),
       4 => (1 => F, 2 => F, 3 => T));

begin
   -- Test with empty 4x2 matrix
   Assert(Panorama(Empty_Line) = "⠀",
          "Panorama(Empty_Line) should return empty Braille character");

   -- Test with single dot at (1,1)
   Assert(Panorama(Single_Dot_Line) = "⠁",
          "Panorama(Single_Dot_Line) should return Braille character with dot at (1,1)");

   -- Test with two dots at (1,1) and (2,2)
   Assert(Panorama(Two_Dots_Line) = "⠑",
          "Panorama(Two_Dots_Line) should return Braille character with dots at (1,1) and (2,2)");

   -- Test with fourth row dots
   Assert(Panorama(Fourth_Row_Line) = "⣀",
          "Panorama(Fourth_Row_Line) should return Braille character with dots at (4,1) and (4,2)");

   -- Test with full matrix
   Assert(Panorama(Full_Line) = "⣿",
          "Panorama(Full_Line) should return full Braille character");

   -- Test with multiple cells (4x4 matrix = two cells)
   Assert(Panorama(Multi_Cell_Line) = "⠑⣌",
          "Panorama(Multi_Cell_Line) should return two Braille characters");

   -- Test with odd width (should ignore last column)
   Assert(Panorama(Odd_Width_Line) = "⠑⡂",
          "Panorama(Odd_Width_Line) failed on odd-width matrix");

end Braillart_Tests.Panoramas;