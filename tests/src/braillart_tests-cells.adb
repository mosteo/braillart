with Braillart; use Braillart;

procedure Braillart_Tests.Cells is
   -- Test matrices
   Empty_Matrix : constant Cell_Matrix := (others => (others => False));

   T : constant Boolean := True;
   F : constant Boolean := False;

   -- Matrix with only one dot at position (1,1)
   Matrix_1_1 : constant Cell_Matrix :=
      (1 => (1 => T, 2 => F),
       2 => (1 => F, 2 => F),
       3 => (1 => F, 2 => F),
       4 => (1 => F, 2 => F));

   -- Matrix with dots at positions (1,1) and (2,2)
   Matrix_1_1_2_2 : constant Cell_Matrix :=
      (1 => (1 => T, 2 => F),
       2 => (1 => F, 2 => T),
       3 => (1 => F, 2 => F),
       4 => (1 => F, 2 => F));

   -- Matrix with dots at positions (4,1) and (4,2)
   Matrix_4_1_4_2 : constant Cell_Matrix :=
      (1 => (1 => F, 2 => F),
       2 => (1 => F, 2 => F),
       3 => (1 => F, 2 => F),
       4 => (1 => T, 2 => T));

   -- Matrix with all dots set
   Full_Matrix : constant Cell_Matrix := (others => (others => True));
begin
   -- Test empty matrix (should return the base Braille character '⠀')
   Assert(Cell(Empty_Matrix) = '⠀',
          "Cell(Empty_Matrix) returned incorrect value");

   -- Test matrix with only one dot at (1,1) (should return '⠁')
   Assert(Cell(Matrix_1_1) = '⠁',
          "Cell(Matrix_1_1) returned incorrect value");

   -- Test matrix with dots at (1,1) and (2,2) (should return '⠑')
   Assert(Cell(Matrix_1_1_2_2) = '⠑',
          "Cell(Matrix_1_1_2_2) returned incorrect value");

   -- Test matrix with dots at (4,1) and (4,2) (should return '⣀')
   Assert(Cell(Matrix_4_1_4_2) = '⣀',
          "Cell(Matrix_4_1_4_2) returned incorrect value");

   -- Test full matrix (should return '⣿')
   Assert(Cell(Full_Matrix) = '⣿',
          "Cell(Full_Matrix) returned incorrect value");
end Braillart_Tests.Cells;
