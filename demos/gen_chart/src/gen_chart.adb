with Braillart; use Braillart;

with Ada.Wide_Wide_Text_IO; use Ada.Wide_Wide_Text_IO;

procedure Gen_Chart is
begin
   --  Print, in Ada syntax, all Braille characters in single quotes and
   --  separated by ', '
   for I in 0 .. 255 loop
      Put ("'" & Value (I) & "', ");
      if I mod 16 = 15 then
         New_Line;
      end if;
   end loop;
end Gen_Chart;
