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

   ----------
   -- Cell --
   ----------

   function Cell (M : Cell_Matrix) return BChar is (raise Program_Error);

   ---------------
   -- Cell_Line --
   ---------------

   function Cell_Line (M : Matrix_Line) return BString is (raise Program_Error);

   --------------
   -- Panorama --
   --------------

   function Panorama (M : Line_Matrix) return BString is (raise Program_Error);

   ------------
   -- Canvas --
   ------------

   function Canvas (M : Full_Matrix) return Line_List is (raise Program_Error);

end Braillart;
