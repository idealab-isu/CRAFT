// Parameters
shank_diameter = 4.2; //[2.1:8.4:0.1]
length = 10; //[5:20:0.5]
head_diameter = 8.2; //[4.1:16.4:0.1]
head_height = 3.05; //[1.5:6.1:0.05]
tip_chamfer_height = 0.6; //[0.2:1.5:0.1]
tip_chamfer_radius_reduction = 0.4; //[0.1:1:0.05]
drive_recess_depth = 1.4; //[0.6:2.5:0.1]
drive_recess_radius = 2.4; //[1.2:4.0:0.1]
drive_slot_width = 0.9; //[0.5:1.8:0.05]
drive_slot_length = 5.0; //[2.5:8.0:0.1]
washer_outer_diameter = 9.5; //[6:19:0.1]
washer_thickness = 1.0; //[0.5:2.5:0.1]
washer_hole_diameter = 4.6; //[3.5:7.5:0.1]
pcb_spacer_height = 6.0; //[3.0:12.0:0.5]
pcb_spacer_wall = 1.8; //[1.0:3.6:0.1]
buzzer_radius = 6.0; //[3.0:12.0:0.5]
buzzer_height = 4.0; //[2.0:8.0:0.5]
overlap = 1; //[0.5:2:0.1]

$fn = 64;

// ---- Derived Z layout (all centered on Z, with guaranteed overlaps) ----
shank_len = length - head_height;                 // length of straight shank portion
z_shank_center = 0;
z_shank_top =  shank_len/2;
z_shank_bot = -shank_len/2;

z_head_center = z_shank_top + head_height/2 - overlap;   // overlap into shank
z_head_top = z_head_center + head_height/2;

z_washer_center = z_head_top + washer_thickness/2 - overlap; // overlap into head
z_washer_top = z_washer_center + washer_thickness/2;

z_spacer_center = z_washer_top + pcb_spacer_height/2 - overlap; // overlap into washer
z_spacer_top = z_spacer_center + pcb_spacer_height/2;

z_buzzer_center = z_spacer_top + buzzer_height/2 - overlap; // overlap into spacer

// ---- Screw (missing part) + washer, all physically connected ----
module screw_and_washer() {
  color("DimGray")
  union() {
    // Main shank
    translate([0,0,z_shank_center])
      cylinder(h=shank_len, r=shank_diameter/2, center=true);

    // Tip chamfer (attached to shank with overlap)
    // Place so its top intersects the shank bottom by 'overlap'
    z_tip_center = z_shank_bot - tip_chamfer_height/2 + overlap;
    translate([0,0,z_tip_center])
      cylinder(h=tip_chamfer_height,
               r1=shank_diameter/2,
               r2=shank_diameter/2 - tip_chamfer_radius_reduction,
               center=true);

    // Pan head (attached to shank with overlap)
    translate([0,0,z_head_center])
      cylinder(h=head_height, r=head_diameter/2, center=true);

    // Washer (attached to head with overlap)
    difference() {
      translate([0,0,z_washer_center])
        cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true);
      translate([0,0,z_washer_center])
        cylinder(h=washer_thickness + 2*overlap, r=washer_hole_diameter/2, center=true);
    }
  }
}

// Drive recess (subtracted from head only; does not create floating solids)
module drive_recess_cut() {
  // Keep the cut fully within the head (slightly extended for robustness)
  z_recess_center = z_head_top - drive_recess_depth/2;
  translate([0,0,z_recess_center])
    union() {
      cylinder(h=drive_recess_depth + 2*overlap, r=drive_recess_radius, center=true);
      // Cross slots
      cube([drive_slot_length, drive_slot_width, drive_recess_depth + 2*overlap], center=true);
      cube([drive_slot_width, drive_slot_length, drive_recess_depth + 2*overlap], center=true);
    }
}

// PCB Spacer - attached to washer with overlap
module pcb_spacer() {
  color("Silver")
  difference() {
    translate([0,0,z_spacer_center])
      cylinder(h=pcb_spacer_height, r=washer_hole_diameter/2 + pcb_spacer_wall, center=true);
    translate([0,0,z_spacer_center])
      cylinder(h=pcb_spacer_height + 2*overlap, r=washer_hole_diameter/2, center=true);
  }
}

// Buzzer - attached to spacer with overlap
module buzzer() {
  color("Black")
  translate([0,0,z_buzzer_center])
    cylinder(h=buzzer_height, r=buzzer_radius, center=true);
}

// Assembly: single connected solid (union), with recess cut applied
module assembly() {
  difference() {
    union() {
      screw_and_washer();
      pcb_spacer();
      buzzer();
    }
    // Subtract recess from the head region
    drive_recess_cut();
  }
}

assembly();