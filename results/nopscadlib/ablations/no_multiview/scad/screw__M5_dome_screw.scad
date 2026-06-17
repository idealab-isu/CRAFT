// Parameters
thread_diameter_mm = 5.0; //[2.5:10.0:0.1]
length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 9.5; //[6.0:19.0:0.1]
head_height_mm = 2.75; //[1.5:5.5:0.05]
washer_outer_diameter_mm = 10.0; //[6.0:20.0:0.1]
washer_thickness_mm = 1.0; //[0.5:2.0:0.05]
washer_hole_clearance_mm = 0.4; //[0.1:1.0:0.05]
spacer_height_mm = 6.0; //[3.0:12.0:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_mm = 0.3; //[0.1:0.8:0.05]
buzzer_diameter_mm = 12.0; //[8.0:24.0:0.5]
buzzer_height_mm = 7.0; //[4.0:14.0:0.5]

// Use 1–2mm overlap to guarantee watertight connections
overlap_mm = 1.5; //[0.5:2.0:0.1]

// --------------------
// Z layout (all solids are center=true)
// Convention: head above z=0, shank extends downward from z=0.
// Ensure every interface overlaps by overlap_mm.
// --------------------
z_shank_center  = -length_mm/2;                 // shank top at z=0
z_head_center   =  head_height_mm/2;            // head base at z=0

// Washer sits just below z=0 and overlaps into shank by overlap_mm
z_washer_center = -(washer_thickness_mm/2) + overlap_mm;

// Spacer sits below washer and overlaps into washer by overlap_mm
z_spacer_center = -(washer_thickness_mm + spacer_height_mm/2) + overlap_mm;

// Buzzer sits below spacer and overlaps into spacer by overlap_mm
z_buzzer_center = -(washer_thickness_mm + spacer_height_mm + buzzer_height_mm/2) + overlap_mm;

// --------------------
// Screw (missing part) + washer, all connected
// --------------------
module screw_and_washer() {
  union() {
    // Screw shank (threaded shaft proxy)
    translate([0, 0, z_shank_center])
      cylinder(h=length_mm, r=thread_diameter_mm/2, center=true, $fn=96);

    // Dome head (spherical cap clipped to head height above z=0)
    // This is positioned so its base plane is at z=0 and overlaps the shank at z=0.
    intersection() {
      // Spherical cap math
      head_R = ((head_diameter_mm/2)*(head_diameter_mm/2) + head_height_mm*head_height_mm) / (2*head_height_mm);
      // Sphere center relative to cap base plane (z=0)
      sphere_center_z = head_height_mm - head_R;

      translate([0, 0, sphere_center_z])
        sphere(r=head_R, $fn=128);

      // Clip to only the cap volume from z=0..head_height_mm
      translate([0, 0, z_head_center])
        cube([head_diameter_mm*2, head_diameter_mm*2, head_height_mm], center=true);
    }

    // Washer (ring) - overlaps into shank by overlap_mm
    difference() {
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true, $fn=96);

      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm + 2*overlap_mm,
                 r=thread_diameter_mm/2 + washer_hole_clearance_mm,
                 center=true, $fn=96);
    }
  }
}

// --------------------
// PCB Spacer - connected to washer (overlap)
// --------------------
module pcb_spacer() {
  difference() {
    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height_mm,
               r=thread_diameter_mm/2 + spacer_clearance_mm + spacer_wall_mm,
               center=true, $fn=96);

    translate([0, 0, z_spacer_center])
      cylinder(h=spacer_height_mm + 2*overlap_mm,
               r=thread_diameter_mm/2 + spacer_clearance_mm,
               center=true, $fn=96);
  }
}

// --------------------
// Buzzer - MUST be physically attached to spacer (overlap)
// --------------------
module buzzer() {
  translate([0, 0, z_buzzer_center])
    cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true, $fn=96);
}

// --------------------
// Assembly: single connected solid via union() with intentional overlaps
// --------------------
module assembly() {
  union() {
    // Keep colors for preview; union ensures one connected solid
    color("DimGray") screw_and_washer(); // includes the missing screw
    color("Silver")  pcb_spacer();
    color("Black")   buzzer();           // now overlaps spacer by overlap_mm
  }
}

assembly();