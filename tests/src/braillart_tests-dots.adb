with Braillart; use Braillart;

procedure Braillart_Tests.Dots is
begin
   -- Test all rows of first column (C=1)
   Assert (Dot (1, 1) = '⠁',
           "Dot(1,1) returned incorrect value");

   Assert (Dot (2, 1) = '⠂',
           "Dot(2,1) returned incorrect value");

   Assert (Dot (3, 1) = '⠄',
           "Dot(3,1) returned incorrect value");

   Assert (Dot (4, 1) = '⡀',
           "Dot(4,1) returned incorrect value");

   -- Test all rows of second column (C=2)
   Assert (Dot (1, 2) = '⠈',
           "Dot(1,2) returned incorrect value");

   Assert (Dot (2, 2) = '⠐',
           "Dot(2,2) returned incorrect value");

   Assert (Dot (3, 2) = '⠠',
           "Dot(3,2) returned incorrect value");

   Assert (Dot (4, 2) = '⢀',
           "Dot(4,2) returned incorrect value");
end Braillart_Tests.Dots;
