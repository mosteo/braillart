with Ada.Containers.Indefinite_Doubly_Linked_Lists;

package Braillart with Preelaborate is

   --  Facilities to use Braille characters as a kind of dot-matrix

   subtype UChar is Wide_Wide_Character;
   subtype UString is Wide_Wide_String;

   --  Braille Character:
   subtype BChar is UChar range UChar'Val (16#2800#) .. UChar'Val (16#28FF#);
   --  Braille patterns are like a binary counter, growing in row-first order,
   --  from the top-left. There are four rows and two columns in a cell. For
   --  example, 16#2800# is empty '⠀', 16#2801# is one '⠁', 16#2802# is 2 '⠂',
   --  16#2803# is 3 '⠃', 16#2848# is 9 '⡈'. there are, obviously, 2**8 values,
   --  hence the range.

   subtype BString is UString with
     Predicate => (for all C of BString => C in BChar);

   subtype Rows is Positive range 1 .. 4;
   subtype Cols is Positive range 1 .. 2;

   type Cell_Matrix is array (Rows, Cols) of Boolean;

   function Get_Dot_Offset_Value (R : Rows; C : Cols) return Natural; -- New function

   function Dot (R : Rows; C : Cols) return BChar;

   function Cell (M : Cell_Matrix) return BChar;

   --  Lines as a sequences of cells

   type Matrix_Line is array (Positive range <>) of Cell_Matrix;

   function Cell_Line (M : Matrix_Line) return BString;

   --  Lines as whole matrices

   type Line_Matrix is array (Rows range <>, Cols'Base range <>) of Boolean;
   --  A whole line given as a continuous matrix

   function Panorama (M : Line_Matrix) return BString;

   --  A whole canvas of any size

   type Full_Matrix is array (Rows'Base range <>, Cols'Base range <>) of Boolean;

   package Line_Lists is new
     Ada.Containers.Indefinite_Doubly_Linked_Lists (BString);

   subtype Line_List is Line_Lists.List;

   function Canvas (M : Full_Matrix) return Line_List;

end Braillart;
