with Ada.Containers.Indefinite_Doubly_Linked_Lists;

package Braillart with Preelaborate is

   --  Facilities to use Braille characters as a kind of dot-matrix

   subtype UChar is Wide_Wide_Character;
   subtype UString is Wide_Wide_String;

   --  Braille Character:
   subtype BChar is UChar range UChar'Val (16#2800#) .. UChar'Val (16#28FF#);
   --  Braille patterns are like a binary counter, growing in row-first order,
   --  from the top-left. There is a catch in that a full 3x2 matrix is filled
   --  first, and the last row for a 4x2 matrix is filled next. Hence, values
   --  1, 2, 4 grow with the Char values but then the sequence changes:
   --  16#2800# = '⠀', 16#2801# = '⠁', 16#2802# = '⠂', 16#2803# = '⠃',
   --  16#2804# = '⠄', but 16#2848# = '⡀', whereas 16#2808# = '⠈'.

   subtype BString is UString with
     Predicate => (for all C of BString => C in BChar);

   --  Straight counting, using Braille dots from top-left in row-first order

   subtype BCount is Natural range 0 .. 255;

   function Value (Pos : BCount) return BChar;
   --  Note that this is not the Unicode code-point order! This returns the
   --  patterns in the order of Patterns at the end of this package. (What
   --  would be the "natural" order for a 4x2 matrix.)

   --  A single cell given as a matrix

   subtype Rows is Positive range 1 .. 4;
   subtype Cols is Positive range 1 .. 2;

   type Cell_Matrix is array (Rows, Cols) of Boolean;

   function Dot (R : Rows; C : Cols) return BChar;

   function Cell (M : Cell_Matrix) return BChar;

   --  Lines as a sequences of cells

   type Matrix_Array is array (Positive range <>) of Cell_Matrix;

   function Cell_Line (M : Matrix_Array) return BString;

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
