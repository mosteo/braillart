with Braillart; use Braillart;

procedure Braillart_Tests.Canvases is

   -- Test 1: Small 4x2 matrix (single cell, single line)
   Small_Canvas : constant Full_Matrix (1 .. 4, 1 .. 2) :=
      (1 => (1 => X, 2 => O),
       2 => (1 => O, 2 => X),
       3 => (1 => O, 2 => O),
       4 => (1 => O, 2 => O));

   -- Test 2: Wide 4x4 matrix (two cells, single line)
   Wide_Canvas : constant Full_Matrix (1 .. 4, 1 .. 4) :=
      (1 => (1 => X, 2 => O, 3 => O, 4 => X),
       2 => (1 => O, 2 => X, 3 => O, 4 => O),
       3 => (1 => O, 2 => O, 3 => X, 4 => O),
       4 => (1 => O, 2 => O, 3 => X, 4 => X));

   -- Test 3: Tall 8x2 matrix (one cell per line, two lines)
   Tall_Canvas : constant Full_Matrix (1 .. 8, 1 .. 2) :=
      (1 => (1 => X, 2 => O),  -- First line
       2 => (1 => O, 2 => X),
       3 => (1 => O, 2 => O),
       4 => (1 => O, 2 => O),
       5 => (1 => O, 2 => O),  -- Second line
       6 => (1 => O, 2 => O),
       7 => (1 => O, 2 => O),
       8 => (1 => X, 2 => X));

   -- Test 4: Large 8x4 matrix (two cells per line, two lines)
   Large_Canvas : constant Full_Matrix (1 .. 8, 1 .. 4) :=
      (1 => (1 => X, 2 => O, 3 => O, 4 => X),  -- First line
       2 => (1 => O, 2 => X, 3 => O, 4 => O),
       3 => (1 => O, 2 => O, 3 => X, 4 => O),
       4 => (1 => O, 2 => O, 3 => X, 4 => X),
       5 => (1 => O, 2 => O, 3 => O, 4 => O),  -- Second line
       6 => (1 => O, 2 => O, 3 => O, 4 => O),
       7 => (1 => O, 2 => O, 3 => O, 4 => O),
       8 => (1 => X, 2 => X, 3 => X, 4 => X));

   -- Test 5: Odd dimensions 6x3 matrix (partial cells and lines)
   Odd_Canvas : constant Full_Matrix (1 .. 6, 1 .. 3) :=
      (1 => (1 => X, 2 => O, 3 => O),  -- First line (partial)
       2 => (1 => O, 2 => X, 3 => X),
       3 => (1 => O, 2 => O, 3 => O),
       4 => (1 => O, 2 => O, 3 => X),
       5 => (1 => O, 2 => O, 3 => O),  -- Second line (partial)
       6 => (1 => X, 2 => X, 3 => O));

   -- Test 6: 5x5 hollow square
   Hollow_Square : constant Full_Matrix (1 .. 5, 1 .. 5) :=
      (1 => (1 => X, 2 => X, 3 => X, 4 => X, 5 => X),  -- Top edge
       2 => (1 => X, 2 => O, 3 => O, 4 => O, 5 => X),  -- Left and right edges
       3 => (1 => X, 2 => O, 3 => O, 4 => O, 5 => X),  -- Left and right edges
       4 => (1 => X, 2 => O, 3 => O, 4 => O, 5 => X),  -- Left and right edges
       5 => (1 => X, 2 => X, 3 => X, 4 => X, 5 => X)); -- Bottom edge

   Result : Line_List;

begin
   -- Test 1: Small canvas (4x2 = 1 cell, 1 line)
   Result := Canvas (Small_Canvas);
   Assert (Natural (Result.Length) = 1,
           "Small_Canvas should produce 1 line");
   Assert (Result.First_Element = BString'("⠑"),
           "Small_Canvas first line incorrect");

   -- Test 2: Wide canvas (4x4 = 2 cells, 1 line)
   Result := Canvas (Wide_Canvas);
   Assert (Natural (Result.Length) = 1,
           "Wide_Canvas should produce 1 line");
   Assert (Result.First_Element = BString'("⠑⣌"),
           "Wide_Canvas first line incorrect");

   -- Test 3: Tall canvas (8x2 = 1 cell per line, 2 lines)
   Result := Canvas (Tall_Canvas);
   Assert (Natural (Result.Length) = 2,
           "Tall_Canvas should produce 2 lines");
   declare
      Line_Cursor : Line_Lists.Cursor := Result.First;
   begin
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⠑"),
              "Tall_Canvas first line incorrect");
      Line_Lists.Next (Line_Cursor);
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⣀"),
              "Tall_Canvas second line incorrect");
   end;

   -- Test 4: Large canvas (8x4 = 2 cells per line, 2 lines)
   Result := Canvas (Large_Canvas);
   Assert (Natural (Result.Length) = 2,
           "Large_Canvas should produce 2 lines");
   declare
      Line_Cursor : Line_Lists.Cursor := Result.First;
   begin
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⠑⣌"),
              "Large_Canvas first line incorrect");
      Line_Lists.Next (Line_Cursor);
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⣀⣀"),
              "Large_Canvas second line incorrect");
   end;

   -- Test 5: Odd dimensions canvas (6x3 = partial cells and lines)
   Result := Canvas (Odd_Canvas);
   Assert (Natural (Result.Length) = 2,
           "Odd_Canvas should produce 2 lines");
   declare
      Line_Cursor : Line_Lists.Cursor := Result.First;
   begin
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⠑⡂"),
              "Odd_Canvas first line incorrect");
      Line_Lists.Next (Line_Cursor);
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⠒⠀"),
              "Odd_Canvas second line incorrect");
   end;

   -- Test 6: 5x5 hollow square (should produce 2 lines)
   Result := Canvas (Hollow_Square);
   Assert (Natural (Result.Length) = 2,
           "Hollow_Square should produce 2 lines");
   declare
      Line_Cursor : Line_Lists.Cursor := Result.First;
   begin
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⡏⠉⡇"),
              "Hollow_Square first line incorrect");
      Line_Lists.Next (Line_Cursor);
      Assert (Line_Lists.Element (Line_Cursor) = BString'("⠉⠉⠁"),
              "Hollow_Square second line incorrect");
   end;

end Braillart_Tests.Canvases;
