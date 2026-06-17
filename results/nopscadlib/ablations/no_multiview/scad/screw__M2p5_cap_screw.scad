// Parameters
shaft_diameter_mm = 2.5; //[1.25:5:0.05]
overall_length_mm = 10; //[5:20:0.5]
head_diameter_mm = 4.5; //[3:9:0.1]
head_height_mm = 2.5; //[1.5:5:0.1]
socket_across_flats_mm = 2; //[1.2:3.5:0.05]
socket_depth_mm = 1.5; //[0.8:2.3:0.05]
threaded = 1; //[0:1:1]
thread_pitch_mm = 0.45; //[0.25:0.8:0.01]
thread_depth_mm = 0.12; //[0.05:0.25:0.01]
tip_chamfer_height_mm = 0.4; //[0.1:1:0.05]
overlap_mm = 1.2; //[0.2:2:0.1]   // ensure 1-2mm overlap for connectivity
thread_ridge_count = 12; //[6:30:1]
aux_scale_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 6; //[4:12:0.1]
washer_thickness_mm = 0.8; //[0.4:2:0.05]

// Derived
shaft_len_mm = overall_length_mm - head_height_mm;
eps = 0.01;

// Pin Socket - Detailed Geometry
module pin_socket() {
  color("DimGray")
    cube([aux_scale_mm*6, aux_scale_mm*4, aux_scale_mm*3], center=true);
}

// Screw and Washer - Detailed Geometry
module screw_and_washer() {
  // Place head so its bottom is at z=0, shaft extends downward (negative z)
  head_center_z = head_height_mm/2;
  shaft_center_z = -(shaft_len_mm/2) + overlap_mm/2; // overlaps into head by overlap_mm/2
  shaft_bottom_z = -shaft_len_mm + overlap_mm/2;

  // Tip chamfer: ensure it overlaps into the shaft by ~overlap_mm
  chamfer_center_z = shaft_bottom_z - tip_chamfer_height_mm/2 + overlap_mm;

  // Small "diamond/triangular" tip piece and FORCE it to intersect the chamfer/shaft
  diamond_h = max(0.6, overlap_mm);
  diamond_r = shaft_diameter_mm/2 * 0.55;
  diamond_center_z = (chamfer_center_z - tip_chamfer_height_mm/2) - diamond_h/2 + overlap_mm;

  union() {
    // Screw (black)
    color("Black") union() {
      // Screw Head
      translate([0, 0, head_center_z])
        cylinder(h=head_height_mm, r=head_diameter_mm/2, center=true, $fn=32);

      // Shaft (overlaps into head)
      translate([0, 0, shaft_center_z])
        cylinder(h=shaft_len_mm + overlap_mm, r=shaft_diameter_mm/2, center=true, $fn=32);

      // Tip Chamfer (overlaps into shaft)
      translate([0, 0, chamfer_center_z])
        cylinder(h=tip_chamfer_height_mm + overlap_mm, r1=shaft_diameter_mm/2, r2=0, center=true, $fn=32);

      // Small diamond/triangular piece below tip (physically attached)
      translate([0, 0, diamond_center_z])
        cylinder(h=diamond_h, r1=diamond_r, r2=0, center=true, $fn=4);
    }

    // Washer (silver) - overlaps into head slightly
    color("Silver")
      difference() {
        translate([0, 0, head_height_mm + washer_thickness_mm/2 - overlap_mm/2])
          cylinder(h=washer_thickness_mm + overlap_mm, r=washer_outer_diameter_mm/2, center=true, $fn=32);
        translate([0, 0, head_height_mm + washer_thickness_mm/2 - overlap_mm/2])
          cylinder(h=washer_thickness_mm + overlap_mm + eps, r=shaft_diameter_mm/2 + overlap_mm/4, center=true, $fn=32);
      }

    // Hex Socket (visual solid as provided)
    color("Black")
      translate([0, 0, head_height_mm - socket_depth_mm/2 - overlap_mm/2])
        cylinder(h=socket_depth_mm + overlap_mm, r=(socket_across_flats_mm/2)/cos(30), center=true, $fn=6);
  }
}

// PCB Spacer - Detailed Geometry (FIXED: attach to washer/head with 1-2mm overlap)
module pcb_spacer() {
  spacer_h = aux_scale_mm*6;
  spacer_r = aux_scale_mm*2;

  // Attach radially to washer OD (or head if washer smaller), with overlap
  attach_r = max(washer_outer_diameter_mm/2, head_diameter_mm/2);
  spacer_center_x = attach_r + spacer_r - overlap_mm; // ensures intersection by overlap_mm

  // Vertically align to washer band so it intersects (not floating)
  washer_center_z = head_height_mm + washer_thickness_mm/2 - overlap_mm/2;
  spacer_center_z = washer_center_z; // guaranteed overlap through full height

  color("Silver")
    translate([spacer_center_x, 0, spacer_center_z])
      cylinder(h=spacer_h, r=spacer_r, center=true, $fn=32);
}

// Buzzer - Detailed Geometry (FIXED: attach to washer/head with 1-2mm overlap)
module buzzer() {
  buzzer_h = aux_scale_mm*4;
  buzzer_r = aux_scale_mm*3;

  // Attach radially to washer OD (or head), with overlap
  attach_r = max(washer_outer_diameter_mm/2, head_diameter_mm/2);
  buzzer_center_y = attach_r + buzzer_r - overlap_mm; // ensures intersection by overlap_mm

  // Vertically align to washer band so it intersects (not floating)
  washer_center_z = head_height_mm + washer_thickness_mm/2 - overlap_mm/2;
  buzzer_center_z = washer_center_z; // guaranteed overlap through full height

  color("Black")
    translate([0, buzzer_center_y, buzzer_center_z])
      cylinder(h=buzzer_h, r=buzzer_r, center=true, $fn=32);
}

// Assembly (single connected union)
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();

    // Pin socket kept, but positioned to intersect the washer/head region (no floating)
    // Attach to +X side of washer with overlap and align Z to washer center.
    pin_x = max(washer_outer_diameter_mm/2, head_diameter_mm/2) + (aux_scale_mm*6)/2 - overlap_mm;
    pin_z = head_height_mm + washer_thickness_mm/2 - overlap_mm/2;
    color("DimGray")
      translate([pin_x, 0, pin_z])
        cube([aux_scale_mm*6, aux_scale_mm*4, aux_scale_mm*3], center=true);
  }
}

assembly();