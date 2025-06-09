pragma Warnings (Off);
with Ada.Assertions; use Ada.Assertions;
--  Make Assert visible to children

with Braillart; use Braillart;
pragma Warnings (On);

package Braillart_Tests is

   -- Common test constants for matrix definitions
   X : constant Boolean := True;   -- Dot present
   O : constant Boolean := False;  -- No dot

end Braillart_Tests;
