with Ada.Wide_Wide_Text_IO;
with Ada.Text_IO;
with Ada.Real_Time;
with Ada.Numerics.Float_Random;
with Ada.Containers.Vectors;
with Braillart;
with AnsiAda;

procedure Sand is
   use Ada.Text_IO;
   use Ada.Real_Time;
   use Braillart;
   use AnsiAda;

   package WWIO renames Ada.Wide_Wide_Text_IO;

   -- Configuration constants
   CANVAS_WIDTH  : constant := 40;  -- Terminal width in characters
   CANVAS_HEIGHT : constant := 24;  -- Terminal height in characters
   ANIMATION_PERIOD : constant := 50; -- Milliseconds between frames
   GRAVITY_STRENGTH : constant := 0.03; -- Downward acceleration
   LATERAL_DRIFT_MAX : constant := 0.1; -- Maximum horizontal drift
   SPAWN_RATE : constant := 3; -- New particles per frame

   -- Convert terminal dimensions to Braillart coordinates
   -- Each Braillart character represents a 4x2 dot matrix
   BRAILLE_WIDTH  : constant := CANVAS_WIDTH * 2;
   BRAILLE_HEIGHT : constant := CANVAS_HEIGHT * 4;

   -- Sand particle representation
   type Sand_Particle is record
      X, Y     : Float;  -- Position (floating point for smooth movement)
      VX, VY   : Float;  -- Velocity components
      Active   : Boolean := True;
   end record;

   -- Container for managing particles
   package Particle_Vectors is new Ada.Containers.Vectors
     (Index_Type   => Natural,
      Element_Type => Sand_Particle);
   use Particle_Vectors;

   -- Global state
   Particles : Vector;
   Canvas_Grid : Full_Matrix (1 .. BRAILLE_HEIGHT, 1 .. BRAILLE_WIDTH * 2);
   Random_Gen : Ada.Numerics.Float_Random.Generator;
   Frame_Count : Natural := 0;

   -- Initialize random number generator
   procedure Initialize is
   begin
      Ada.Numerics.Float_Random.Reset (Random_Gen);
      Canvas_Grid := (others => (others => False));

      -- Hide cursor and clear screen
      Put (Hide & Clear_Screen & Position (1, 1));
   end Initialize;

   -- Spawn new sand particles at the top
   procedure Spawn_Particles is
      use Ada.Numerics.Float_Random;
   begin
      for I in 1 .. SPAWN_RATE loop
         declare
            New_Particle : Sand_Particle;
            Spawn_X : constant Float := Random (Random_Gen) * Float (BRAILLE_WIDTH * 2 - 4) + 2.0;
         begin
            New_Particle.X := Spawn_X;
            New_Particle.Y := 1.0;
            New_Particle.VX := (Random (Random_Gen) - 0.5) * LATERAL_DRIFT_MAX;
            New_Particle.VY := 0.0;
            New_Particle.Active := True;
            Particles.Append (New_Particle);
         end;
      end loop;
   end Spawn_Particles;

   -- Check if a position is occupied or out of bounds
   function Is_Blocked (X, Y : Float) return Boolean is
      Grid_X : constant Integer := Integer (X + 0.5);
      Grid_Y : constant Integer := Integer (Y + 0.5);
   begin
      -- Check bounds
      if Grid_X < Canvas_Grid'First (2) or Grid_X > Canvas_Grid'Last (2) or
         Grid_Y < Canvas_Grid'First (1) or Grid_Y > Canvas_Grid'Last (1)
      then
         return True;
      end if;

      -- Check if position is occupied
      return Canvas_Grid (Grid_Y, Grid_X);
   end Is_Blocked;

   -- Update a single particle's physics
   procedure Update_Particle (P : in out Sand_Particle) is
      use Ada.Numerics.Float_Random;
      New_X, New_Y : Float;
      Settle_Y : Float;
   begin
      if not P.Active then
         return;
      end if;

      -- Apply gravity
      P.VY := P.VY + GRAVITY_STRENGTH;

      -- Add small random lateral movement
      P.VX := P.VX + (Random (Random_Gen) - 0.5) * LATERAL_DRIFT_MAX * 0.1;

      -- Limit lateral velocity
      if abs P.VX > LATERAL_DRIFT_MAX then
         P.VX := (if P.VX > 0.0 then LATERAL_DRIFT_MAX else -LATERAL_DRIFT_MAX);
      end if;

      -- Calculate new position
      New_X := P.X + P.VX;
      New_Y := P.Y + P.VY;

      -- Check for collision downward
      if Is_Blocked (New_X, New_Y) then
         -- Find the settling position by going down until we hit something
         Settle_Y := P.Y;
         while Settle_Y < Float (BRAILLE_HEIGHT) and then not Is_Blocked (New_X, Settle_Y + 1.0) loop
            Settle_Y := Settle_Y + 1.0;
         end loop;

         -- Try to slide left or right if we can't settle straight down
         if Settle_Y = P.Y then
            if not Is_Blocked (P.X - 1.0, Settle_Y + 1.0) and Random (Random_Gen) > 0.5 then
               New_X := P.X - 1.0;
               -- Find settling position for left slide
               while Settle_Y < Float (BRAILLE_HEIGHT) and then not Is_Blocked (New_X, Settle_Y + 1.0) loop
                  Settle_Y := Settle_Y + 1.0;
               end loop;
            elsif not Is_Blocked (P.X + 1.0, Settle_Y + 1.0) then
               New_X := P.X + 1.0;
               -- Find settling position for right slide
               while Settle_Y < Float (BRAILLE_HEIGHT) and then not Is_Blocked (New_X, Settle_Y + 1.0) loop
                  Settle_Y := Settle_Y + 1.0;
               end loop;
            else
               -- Can't move anywhere, settle at current position
               P.Active := False;
               declare
                  Grid_X : constant Integer := Integer (P.X + 0.5);
                  Grid_Y : constant Integer := Integer (P.Y + 0.5);
               begin
                  if Grid_X in Canvas_Grid'Range (2) and Grid_Y in Canvas_Grid'Range (1) then
                     Canvas_Grid (Grid_Y, Grid_X) := True;
                  end if;
               end;
               return;
            end if;
         end if;

         -- If we found a better settling position, move there
         if Settle_Y > P.Y then
            P.X := New_X;
            P.Y := Settle_Y;
         end if;

         -- If we hit the bottom or can't fall further, settle
         if Settle_Y >= Float (BRAILLE_HEIGHT) - 1.0 or Is_Blocked (New_X, Settle_Y + 1.0) then
            P.Active := False;
            declare
               Grid_X : constant Integer := Integer (P.X + 0.5);
               Grid_Y : constant Integer := Integer (P.Y + 0.5);
            begin
               if Grid_X in Canvas_Grid'Range (2) and Grid_Y in Canvas_Grid'Range (1) then
                  Canvas_Grid (Grid_Y, Grid_X) := True;
               end if;
            end;
            return;
         end if;
      else
         -- No collision, update position normally
         P.X := New_X;
         P.Y := New_Y;
      end if;

      -- Remove particles that fall off screen
      if P.Y > Float (BRAILLE_HEIGHT) then
         P.Active := False;
      end if;
   end Update_Particle;

   -- Update all particles
   procedure Update_All_Particles is
   begin
      for I in Particles.First_Index .. Particles.Last_Index loop
         Update_Particle (Particles (I));
      end loop;

      -- Remove inactive particles periodically
      if Frame_Count mod 60 = 0 then
         declare
            I : Natural := Particles.First_Index;
         begin
            while I <= Particles.Last_Index loop
               if not Particles (I).Active then
                  Particles.Delete (I);
               else
                  I := I + 1;
               end if;
            end loop;
         end;
      end if;
   end Update_All_Particles;

   -- Render the current frame
   procedure Render_Frame is
      Temp_Grid : Full_Matrix := Canvas_Grid;
   begin
      -- Add active particles to temporary grid
      for P of Particles loop
         if P.Active then
            declare
               Grid_X : constant Integer := Integer (P.X + 0.5);
               Grid_Y : constant Integer := Integer (P.Y + 0.5);
            begin
               if Grid_X in Temp_Grid'Range (2) and Grid_Y in Temp_Grid'Range (1) then
                  Temp_Grid (Grid_Y, Grid_X) := True;
               end if;
            end;
         end if;
      end loop;

      -- Convert to Braillart and display
      declare
         Canvas_Lines : constant Line_List := Canvas (Temp_Grid);
      begin
         Put (Position (1, 1));
         for Line of Canvas_Lines loop
            WWIO.Put_Line (Line);
         end loop;
      end;
   end Render_Frame;

   -- Main animation loop
   procedure Run_Animation is
      Next_Frame : Time := Clock;
      Period : constant Time_Span := Milliseconds (ANIMATION_PERIOD);
   begin
      loop
         -- Update simulation
         Spawn_Particles;
         Update_All_Particles;
         Render_Frame;

         Frame_Count := Frame_Count + 1;

         -- Wait for next frame
         Next_Frame := Next_Frame + Period;
         delay until Next_Frame;

         -- Exit condition (for now, run indefinitely)
         -- Could add keyboard input handling here
      end loop;
   end Run_Animation;

   -- Cleanup
   procedure Finalize is
   begin
      Put (Show & Clear_Screen & Position (1, 1));
   end Finalize;

begin
   Initialize;
   Run_Animation;
exception
   when others =>
      Finalize;
      raise;
end Sand;
