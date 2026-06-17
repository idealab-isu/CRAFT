// Parameters
shaft_diameter_mm = 3.5; //[1.75:7:0.05]
length_mm = 10; //[5:20:0.1]
head_diameter_mm = 6.9; //[3.45:13.8:0.05]
head_height_mm = 2.5; //[1.25:5:0.05]

// Use 1-2mm overlap to guarantee watertight connections
overlap_mm = 1.2; //[0.2:2:0.1]

head_rounding_mm = 1.2; //[0.4:2.5:0.1]
washer_thickness_mm = 0.8; //[0.4:2:0.1]
washer_outer_diameter_mm = 8.5; //[5:17:0.1]
washer_inner_diameter_mm = 3.9; //[2.5:6:0.05]
spacer_height_mm = 6; //[3:12:0.1]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 5; //[2.5:10:0.1]

// --- Derived Z layout (all parts stacked and overlapping) ---
// Coordinate convention: screw head on top, shaft goes downward.
// z=0 is the top surface of the head.
head_top_z      = 0;
head_bottom_z   = head_top_z - head_height_mm;

// Washer overlaps into head/shaft region
washer_top_z    = head_bottom_z + overlap_mm;
washer_bottom_z = washer_top_z - washer_thickness_mm;

// Shaft overlaps into head
shaft_top_z     = head_bottom_z + overlap_mm;
shaft_bottom_z  = shaft_top_z - length_mm;

// Spacer MUST overlap into shaft end (fix: ensure spacer top is ABOVE shaft bottom by overlap)
spacer_top_z    = shaft_bottom_z + overlap_mm;
spacer_bottom_z = spacer_top_z - spacer_height_mm;

// Buzzer MUST overlap into spacer (fix: ensure buzzer top is ABOVE spacer bottom by overlap)
buzzer_top_z    = spacer_bottom_z + overlap_mm;
buzzer_bottom_z = buzzer_top_z - buzzer_height_mm;

// Screw + washer (single connected solid)
module screw_and_washer() {
  union() {
    color("DimGray") union() {
      // Shaft
      translate([0, 0, (shaft_top_z + shaft_bottom_z)/2])
        cylinder(h=length_mm, r=shaft_diameter_mm/2, center=true);

      // Head
      translate([0, 0, (head_top_z + head_bottom_z)/2])
        cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true);

      // Head dome (sunk slightly to ensure intersection with head)
      translate([0, 0, head_top_z - head_rounding_mm + overlap_mm])
        sphere(r=head_rounding_mm);

      // Washer (overlaps into head/shaft region)
      difference() {
        translate([0, 0, (washer_top_z + washer_bottom_z)/2])
          cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        translate([0, 0, (washer_top_z + washer_bottom_z)/2])
          cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_inner_diameter_mm/2, center=true);
      }
    }
  }
}

// Light gray hex/cylindrical collar (PCB spacer) - attached to shaft end with overlap
module pcb_spacer() {
  color("Silver")
  difference() {
    translate([0, 0, (spacer_top_z + spacer_bottom_z)/2])
      cylinder(h=spacer_height_mm, r=washer_inner_diameter_mm/2 + spacer_wall_mm, center=true);
    translate([0, 0, (spacer_top_z + spacer_bottom_z)/2])
      cylinder(h=spacer_height_mm + 2*overlap_mm, r=washer_inner_diameter_mm/2, center=true);
  }
}

// Large black cylindrical piece (buzzer) - attached to spacer with overlap
module buzzer() {
  color("Black")
  translate([0, 0, (buzzer_top_z + buzzer_bottom_z)/2])
    cylinder(h=buzzer_height_mm, r=buzzer_diameter_mm/2, center=true);
}

// Assembly: ensure EVERYTHING is one connected solid via union()
// (Fix: add small "fuse" cylinders to guarantee physical connection even if
// boolean differences create coincident/near-coincident surfaces.)
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();

    // Fuse shaft <-> spacer (solid core overlap)
    color("Silver")
    translate([0, 0, shaft_bottom_z + overlap_mm/2])
      cylinder(h=overlap_mm, r=shaft_diameter_mm/2, center=true);

    // Fuse spacer <-> buzzer (solid core overlap)
    color("Black")
    translate([0, 0, spacer_bottom_z + overlap_mm/2])
      cylinder(h=overlap_mm, r=washer_inner_diameter_mm/2, center=true);
  }
}

assembly();