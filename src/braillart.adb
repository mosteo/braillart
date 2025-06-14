with Ada.Unchecked_Conversion;

with Interfaces;

package body Braillart is

   --------------------------
   -- Get_Dot_Offset_Value --
   --------------------------

   function Get_Dot_Offset_Value (R : Rows; C : Cols) return Natural is
      Bit_Offset : Natural;
   begin
      -- Determine Bit_Offset based on R and C
      -- (1,1) -> Bit 0
      -- (2,1) -> Bit 1
      -- (3,1) -> Bit 2
      -- (1,2) -> Bit 3
      -- (2,2) -> Bit 4
      -- (3,2) -> Bit 5
      -- (4,1) -> Bit 6
      -- (4,2) -> Bit 7
      if C = 1 then
         case R is
            when 1 => Bit_Offset := 0;
            when 2 => Bit_Offset := 1;
            when 3 => Bit_Offset := 2;
            when 4 => Bit_Offset := 6;
         end case;
      else -- C = 2
         case R is
            when 1 => Bit_Offset := 3;
            when 2 => Bit_Offset := 4;
            when 3 => Bit_Offset := 5;
            when 4 => Bit_Offset := 7;
         end case;
      end if;
      return 2**Bit_Offset;
   end Get_Dot_Offset_Value;

   ---------
   -- Dot --
   ---------

   function Dot (R : Rows; C : Cols) return BChar is
      Code_Value : Natural;
      Dot_Pattern_Value : Natural;
   begin
      Dot_Pattern_Value := Get_Dot_Offset_Value(R, C);
      Code_Value := BChar'Pos (BChar'First) + Dot_Pattern_Value;

      return Wide_Wide_Character'Val(Code_Value);
   end Dot;

   -------------------
   -- Cell_Computed --
   -------------------

   function Cell_Computed (M : Cell_Matrix) return BChar is
      Result : Natural := BChar'Pos (BChar'First);
   begin
      for R in Rows loop
         for C in Cols loop
            if M (R, C) then
               Result := Result + Get_Dot_Offset_Value (R, C);
            end if;
         end loop;
      end loop;

      return BChar'Val (Result);
   end Cell_Computed;

   Cached_Patterns : array (0 .. 255) of BChar :=
                       (others => Patterns (Patterns'First));
   --  This differs from Patterns in that we don't know the particular
   --  order, which can change depending on whether the compiler uses row-
   --  or column-major order.

   ----------
   -- Cell --
   ----------

   function Cell (M : Cell_Matrix) return BChar is
      --  As BChar is likely larger than one byte, we need first a new type
      type Offset is new Natural range 0 .. 255 with size => 8;
      function Convert is new Ada.Unchecked_Conversion (Cell_Matrix, Offset);
      Pos : constant Natural := Natural (Convert (M));
   begin
      if Pos = 0 then
         return Patterns (Patterns'First);
      elsif Cached_Patterns (Pos) = Patterns (Patterns'First) then
         --  Lazy initialization
         Cached_Patterns (Pos) := Cell_Computed (M);
      end if;

      return Cached_Patterns (Pos);
   end Cell;

   ---------------
   -- Cell_Line --
   ---------------

   function Cell_Line (M : Matrix_Array) return BString is
      Result : BString (1 .. M'Length);
   begin
      for I in M'Range loop
         Result (I) := Cell (M (I));
      end loop;
      return Result;
   end Cell_Line;

   --------------
   -- Panorama --
   --------------

   function Panorama (M : Line_Matrix) return BString is
      -- Calculate how many cells we need (round up for partial cells)
      Num_Cells : constant Natural := (M'Length (2) + 1) / 2;
      Result : BString (1 .. Num_Cells);
      Cell_M : Cell_Matrix;
   begin
      -- Process each cell (including partial ones)
      for Cell_Index in 1 .. Num_Cells loop
         -- Extract a 4x2 cell from the line matrix
         for R in Rows loop
            for C in Cols loop
               declare
                  Matrix_Row : constant Integer := M'First (1) + (R - 1);
                  Matrix_Col : constant Integer := M'First (2) + (Cell_Index - 1) * 2 + (C - 1);
               begin
                  -- Ensure we're within bounds
                  if Matrix_Row in M'Range(1) and Matrix_Col in M'Range(2) then
                     Cell_M (R, C) := M (Matrix_Row, Matrix_Col);
                  else
                     Cell_M (R, C) := False;
                  end if;
               end;
            end loop;
         end loop;

         -- Convert the cell to a Braille character
         Result (Cell_Index) := Cell (Cell_M);
      end loop;

      return Result;
   end Panorama;

   ------------
   -- Canvas --
   ------------

   function Canvas (M : Full_Matrix) return Line_List is
      Result : Line_List;
      Cell_M : Cell_Matrix;
   begin
      -- Iterate over the matrix in 4-row chunks
      for Row_Start in M'First (1) .. M'Last (1) loop
         if (Row_Start - M'First (1)) mod 4 = 0 then
            -- Starting a new line of cells
            declare
               Max_Cells : constant Natural := (M'Length (2) + 1) / 2;
               Current_Line : BString (1 .. Max_Cells);
               Cell_Count : Natural := 0;
            begin
               -- Iterate over columns in 2-column chunks to create cells
               for Col_Start in M'First (2) .. M'Last (2) loop
                  if (Col_Start - M'First (2)) mod 2 = 0 then
                     -- Create a new cell
                     Cell_Count := Cell_Count + 1;

                     -- Extract 4x2 cell data
                     for R in Rows loop
                        for C in Cols loop
                           declare
                              Matrix_Row : constant Integer := Row_Start + (R - 1);
                              Matrix_Col : constant Integer := Col_Start + (C - 1);
                           begin
                              if Matrix_Row in M'Range (1) and Matrix_Col in M'Range (2) then
                                 Cell_M (R, C) := M (Matrix_Row, Matrix_Col);
                              else
                                 Cell_M (R, C) := False;
                              end if;
                           end;
                        end loop;
                     end loop;

                     -- Convert cell to Braille character
                     Current_Line (Cell_Count) := Cell (Cell_M);
                  end if;
               end loop;

               -- Append the completed line to result
               if Cell_Count > 0 then
                  Result.Append (Current_Line (1 .. Cell_Count));
               end if;
            end;
         end if;
      end loop;

      return Result;
   end Canvas;

   -----------
   -- Value --
   -----------

   function Value (Pos : BCount) return BChar is
      use Interfaces;

      -- Mapping from row-first bit position to Unicode bit position
      -- Row-first: 0,1,2,3,4,5,6,7 -> Unicode: 0,1,2,6,3,4,5,7
      Bit_Map : constant array (0 .. 7) of Natural := (0, 1, 2, 6, 3, 4, 5, 7);
      Code_Value : Natural := 0;
      Input_Bits : constant Unsigned_8 := Unsigned_8 (Pos);
   begin
      for I in Bit_Map'Range loop
         if (Input_Bits and 2**I) /= 0 then
            Code_Value := Code_Value + 2**Bit_Map(I);
         end if;
      end loop;

      return BChar'Val (BChar'Pos (BChar'First) + Code_Value);
   end Value;

end Braillart;
