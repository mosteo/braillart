with Braillart; use Braillart;

procedure Braillart_Tests.Lines is
   -- Empty matrix
   Empty_Matrix : constant Cell_Matrix := (others => (others => False));

   -- Matrix with only one dot at position (1,1)
   Matrix_1_1 : constant Cell_Matrix :=
      (1 => (1 => X, 2 => O),
       2 => (1 => O, 2 => O),
       3 => (1 => O, 2 => O),
       4 => (1 => O, 2 => O));

   -- Matrix with dots at positions (1,1) and (2,2)
   Matrix_1_1_2_2 : constant Cell_Matrix :=
      (1 => (1 => X, 2 => O),
       2 => (1 => O, 2 => X),
       3 => (1 => O, 2 => O),
       4 => (1 => O, 2 => O));

   -- Matrix with dots at positions (4,1) and (4,2) - fourth row test
   Matrix_4_1_4_2 : constant Cell_Matrix :=
      (1 => (1 => O, 2 => O),
       2 => (1 => O, 2 => O),
       3 => (1 => O, 2 => O),
       4 => (1 => X, 2 => X));

   -- Matrix with all dots set
   Full_Matrix : constant Cell_Matrix := (others => (others => True));

   -- Test arrays
   Single_Empty_Array : constant Matrix_Array := (1 => Empty_Matrix);
   Single_Dot_Array : constant Matrix_Array := (1 => Matrix_1_1);
   Fourth_Row_Array : constant Matrix_Array := (1 => Matrix_4_1_4_2);
   Multi_Cell_Array : constant Matrix_Array :=
      (1 => Empty_Matrix,
       2 => Matrix_1_1,
       3 => Matrix_1_1_2_2,
       4 => Matrix_4_1_4_2,
       5 => Full_Matrix);
begin
   -- Test with a single empty cell
   Assert(Cell_Line(Single_Empty_Array) = "⠀",
          "Cell_Line(Single_Empty_Array) returned incorrect value");

   -- Test with a single cell with one dot
   Assert(Cell_Line(Single_Dot_Array) = "⠁",
          "Cell_Line(Single_Dot_Array) returned incorrect value");

   -- Test with a single cell with fourth row dots
   Assert(Cell_Line(Fourth_Row_Array) = "⣀",
          "Cell_Line(Fourth_Row_Array) returned incorrect value");

   -- Test with multiple cells
   Assert(Cell_Line(Multi_Cell_Array) = "⠀⠁⠑⣀⣿",
          "Cell_Line(Multi_Cell_Array) returned incorrect value");
end Braillart_Tests.Lines;
