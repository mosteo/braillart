with Ada.Wide_Wide_Text_IO;
with Ada.Text_IO;
with Ada.Real_Time;
with Ada.Numerics.Float_Random;
with Ada.Containers.Vectors;
with Braillart;
with AnsiAda;

--  Created with Cline and Claude 4 Sonnet and my mushy brain when the machine
--  got stuck.

procedure Sand is
   use Ada.Text_IO;
   use Ada.Real_Time;
   use Braillart;
   use AnsiAda;

   package WWIO renames Ada.Wide_Wide_Text_IO;

   -- Configuration constants
   CANVAS_WIDTH  : constant := 20;  -- Terminal width in characters
   CANVAS_HEIGHT : constant := 10;  -- Terminal height in characters
   ANIMATION_PERIOD : constant := 50; -- Milliseconds between frames
   GRAVITY_STRENGTH : constant := 0.05; -- Downward acceleration
   LATERAL_DRIFT_MAX : constant := 0.1; -- Maximum horizontal drift
   SPAWN_RATE : constant := 1; -- New particles per frame
   SLIDE_DISTANCE : constant := 1.0; -- How far particles can slide laterally

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
   Canvas_Grid : Full_Matrix (1 .. BRAILLE_HEIGHT, 1 .. BRAILLE_WIDTH);
   Random_Gen : Ada.Numerics.Float_Random.Generator;
   Frame_Count : Natural := 0;

   -- Initialize random number generator
   procedure Initialize is
   begin
      Ada.Numerics.Float_Random.Reset (Random_Gen);
      Canvas_Grid := (others => (others => False));

      -- Create U-shaped container walls
      -- Left wall (first two columns)
      for Row in Canvas_Grid'Range (1) loop
         Canvas_Grid (Row, 1) := True;
         Canvas_Grid (Row, 2) := True;
      end loop;

      -- Right wall (last two columns)
      for Row in Canvas_Grid'Range (1) loop
         Canvas_Grid (Row, BRAILLE_WIDTH - 1) := True;
         Canvas_Grid (Row, BRAILLE_WIDTH) := True;
      end loop;

      -- Bottom wall (last two rows)
      for Col in Canvas_Grid'Range (2) loop
         Canvas_Grid (BRAILLE_HEIGHT - 1, Col) := True;
         Canvas_Grid (BRAILLE_HEIGHT, Col) := True;
      end loop;

      -- Hide cursor and clear screen
      Put (Hide & Clear_Screen & Position (1, 1));
   end Initialize;

   -- Spawn new sand particles at the top center
   procedure Spawn_Particles is
      use Ada.Numerics.Float_Random;
      Center_X : constant Float := Float (BRAILLE_WIDTH) / 2.0;
   begin
      for I in 1 .. SPAWN_RATE loop
         declare
            New_Particle : Sand_Particle;
            -- Spawn near center with small random offset
            Spawn_X : constant Float := Center_X + (Random (Random_Gen) - 0.5) * 4.0;
         begin
            New_Particle.X := Spawn_X;
            New_Particle.Y := 0.5;  -- Start just above the first row
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

   -- Check if the spawn area is blocked (preventing new particles)
   function Is_Spawn_Area_Blocked return Boolean is
      Center_X : constant Float := Float (BRAILLE_WIDTH) / 2.0;
   begin
      -- Check if any position in the spawn area is available
      for Offset in -2 .. 2 loop
         declare
            Check_X : constant Float := Center_X + Float (Offset);
            Check_Y : constant Float := 1.0;
         begin
            if not Is_Blocked (Check_X, Check_Y) then
               return False; -- Found available space
            end if;
         end;
      end loop;
      return True; -- All spawn positions are blocked
   end Is_Spawn_Area_Blocked;

   -- Check if all particles have settled (no active particles)
   function All_Particles_Settled return Boolean is
   begin
      for P of Particles loop
         if P.Active then
            return False;
         end if;
      end loop;
      return True;
   end All_Particles_Settled;

   -- Check if simulation should terminate (all particles blocked)
   function Should_Terminate return Boolean is
   begin
      return Is_Spawn_Area_Blocked and All_Particles_Settled;
   end Should_Terminate;

   -- Find the lowest possible settling position for a particle at given X coordinate
   function Find_Settle_Position (X, Start_Y : Float) return Float is
      Settle_Y : Float := Start_Y;
   begin
      -- Find the lowest available position
      while Settle_Y < Float (BRAILLE_HEIGHT) - 1.0 and then not Is_Blocked (X, Settle_Y + 1.0) loop
         Settle_Y := Settle_Y + 1.0;
      end loop;
      return Settle_Y;
   end Find_Settle_Position;

   -- Settle a particle at its current position
   procedure Settle_Particle (P : in out Sand_Particle) is
      Grid_X : constant Integer := Integer (P.X + 0.5);
      Grid_Y : constant Integer := Integer (P.Y + 0.5);
   begin
      P.Active := False;
      if Grid_X in Canvas_Grid'Range (2) and Grid_Y in Canvas_Grid'Range (1) then
         Canvas_Grid (Grid_Y, Grid_X) := True;
      end if;
   end Settle_Particle;

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

      -- Check if we can move to the new position
      if not Is_Blocked (New_X, New_Y) then
         -- No collision, update position normally
         P.X := New_X;
         P.Y := New_Y;
      else
         -- Collision detected, try to slide laterally
         declare
            Can_Slide_Left  : constant Boolean := not Is_Blocked (P.X - SLIDE_DISTANCE, New_Y);
            Can_Slide_Right : constant Boolean := not Is_Blocked (P.X + SLIDE_DISTANCE, New_Y);
            Slide_Direction : Float := 0.0;
         begin
            -- Determine slide direction based on available space and randomness
            if Can_Slide_Left and Can_Slide_Right then
               -- Both directions available, choose randomly
               Slide_Direction := (if Random (Random_Gen) > 0.5 then -SLIDE_DISTANCE else SLIDE_DISTANCE);
            elsif Can_Slide_Left then
               Slide_Direction := -SLIDE_DISTANCE;
            elsif Can_Slide_Right then
               Slide_Direction := SLIDE_DISTANCE;
            end if;

            -- Apply sliding if possible
            if Slide_Direction /= 0.0 then
               New_X := P.X + Slide_Direction;
               -- Check if we can move to the slid position
               if not Is_Blocked (New_X, New_Y) then
                  P.X := New_X;
                  P.Y := New_Y;
               else
                  -- Can't slide either, find the lowest possible position and settle
                  Settle_Y := Find_Settle_Position (P.X, P.Y);
                  if Settle_Y > P.Y then
                     -- Can fall further
                     P.Y := Settle_Y;
                  else
                     -- Can't fall or slide, settle particle at lowest possible position
                     P.Y := Find_Settle_Position (P.X, P.Y);
                     Settle_Particle (P);
                     return;
                  end if;
               end if;
            else
               -- No sliding possible, settle particle at lowest possible position
               P.Y := Find_Settle_Position (P.X, P.Y);
               Settle_Particle (P);
               return;
            end if;
         end;
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
         -- Check termination condition before spawning new particles
         if Should_Terminate then
            exit;
         end if;

         -- Update simulation
         Spawn_Particles;
         Update_All_Particles;
         Render_Frame;

         Frame_Count := Frame_Count + 1;

         -- Wait for next frame
         Next_Frame := Next_Frame + Period;
         delay until Next_Frame;
      end loop;
   end Run_Animation;

   -- Cleanup
   procedure Finalize is
   begin
      Put (Show & Ansiada.Reset);
   end Finalize;

begin
   Initialize;
   Run_Animation;
   Finalize;
exception
   when others =>
      Finalize;
      raise;
end Sand;
