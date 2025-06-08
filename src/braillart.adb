package body Braillart is

   ---------
   -- Dot --
   ---------

   function Dot (R : Rows; C : Cols) return BChar is
      Bit_Offset : Natural;
      Code_Value : Natural;
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

      Code_Value := BChar'Pos (BChar'First) + (2**Bit_Offset);

      return BChar'Val(Code_Value);
      -- BChar is a subtype of Wide_Wide_Character, so direct return should be fine
      -- as long as the value is within BChar's range, which it will be by construction.
   end Dot;

end Braillart;
