with Braillart; use Braillart;

procedure Braillart_Tests.Values is
begin
   -- Test that the Value function returns the same characters as the Patterns array
   -- This ensures consistency between the two ways of accessing Braille patterns
   for I in Patterns'Range loop
      Assert(Patterns(I) = Value(I),
             "Patterns(" & I'Image & ") /= Value(" & I'Image & ")");
   end loop;
end Braillart_Tests.Values;