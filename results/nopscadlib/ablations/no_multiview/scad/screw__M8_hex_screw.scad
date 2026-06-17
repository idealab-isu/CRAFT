// Parameters
shaft_diameter_mm = 8; //[4:16:0.1]
head_across_flats_mm = 15; //[7.5:30:0.1]
head_height_mm = 5.65; //[2.8:11.3:0.05]
length_under_head_mm = 10; //[5:20:0.1]
overlap_mm = 1; //[0.5:2:0.1]
washer_outer_diameter_mm = 16; //[8:32:0.1]
washer_thickness_mm = 1.6; //[0.8:3.2:0.1]
washer_hole_diameter_mm = 8.5; //[4.5:17:0.1]
pcb_spacer_height_mm = 6; //[3:12:0.1]
pcb_spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
buzzer_diameter_mm = 12; //[6:24:0.1]
buzzer_height_mm = 5; //[2.5:10:0.1]
buzzer_offset_x_mm = 10; //[5:20:0.1]
bridge_width_mm = 4; //[2:8:0.1]
bridge_thickness_mm = 2; //[1:4:0.1]

// Derived radii
shaft_r = shaft_diameter_mm/2;
head_r  = (head_across_flats_mm/2)/cos(30);
washer_r = washer_outer_diameter_mm/2;
washer_hole_r = washer_hole_diameter_mm/2;
spacer_outer_r = washer_hole_r + pcb_spacer_wall_mm;
buzzer_r = buzzer_diameter_mm/2;

// Z reference: underside of head at z=0
z_head_center   = head_height_mm/2;

// Shaft overlaps into head by overlap_mm
z_shaft_center  = -length_under_head_mm/2 + overlap_mm/2;

// Washer overlaps into head underside by overlap_mm
z_washer_center = washer_thickness_mm/2 - overlap_mm/2;

// Spacer overlaps into shaft end by overlap_mm
z_spacer_center = -length_under_head_mm - pcb_spacer_height_mm/2 + overlap_mm/2;

// Place buzzer at same Z as spacer for robust bridge contact
z_buzzer_center = z_spacer_center;

// Screw and Washer - connected geometry
module screw_and_washer() {
  color("DimGray")
  union() {
    // Hex Head
    translate([0, 0, z_head_center])
      cylinder(h=head_height_mm, r=head_r, center=true, $fn=6);

    // Shaft (overlaps into head by overlap_mm)
    translate([0, 0, z_shaft_center])
      cylinder(h=length_under_head_mm, r=shaft_r, center=true);

    // Washer (overlaps into head underside by overlap_mm)
    difference() {
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm, r=washer_r, center=true);
      translate([0, 0, z_washer_center])
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=washer_hole_r, center=true);
    }
  }
}

// PCB Spacer - connected to shaft end by overlap
module pcb_spacer() {
  color("Silver")
  difference() {
    translate([0, 0, z_spacer_center])
      cylinder(h=pcb_spacer_height_mm, r=spacer_outer_r, center=true);
    translate([0, 0, z_spacer_center])
      cylinder(h=pcb_spacer_height_mm + 2*overlap_mm, r=washer_hole_r, center=true);
  }
}

// Buzzer - connected to bridge (and bridge connected to spacer)
module buzzer() {
  color("Black")
  translate([buzzer_offset_x_mm, 0, z_buzzer_center])
    cylinder(h=buzzer_height_mm, r=buzzer_r, center=true);
}

// Buzzer Bridge + End Cap
// FIX: ensure the black cylinder subassembly is physically attached to the main body
// by making the bridge overlap into BOTH the spacer and the buzzer by 1-2mm.
module buzzer_bridge_and_cap() {
  // Bridge spans from spacer outer surface to buzzer outer surface, with overlap on both ends.
  // Left end (toward spacer): x = spacer_outer_r - overlap_mm
  // Right end (toward buzzer): x = (buzzer_offset_x_mm - buzzer_r) + overlap_mm
  x_left  = spacer_outer_r - overlap_mm;
  x_right = (buzzer_offset_x_mm - buzzer_r) + overlap_mm;

  bridge_len = x_right - x_left;
  bridge_center_x = (x_left + x_right)/2;

  // Keep bridge centered at same Z as buzzer/spacer so it intersects both
  bridge_center_z = z_buzzer_center;

  // Small rectangular end cap at buzzer far end, overlapped into buzzer by overlap_mm
  cap_len = 4;
  cap_w   = bridge_thickness_mm;
  cap_h   = bridge_width_mm;

  // Cap overlaps into buzzer at its +X face:
  // buzzer +X face is at x = buzzer_offset_x_mm + buzzer_r
  cap_center_x = (buzzer_offset_x_mm + buzzer_r) + cap_len/2 - overlap_mm;
  cap_center_z = bridge_center_z;

  color("Silver")
  union() {
    // Bridge (guaranteed to intersect spacer and buzzer)
    translate([bridge_center_x, 0, bridge_center_z])
      cube([bridge_len, bridge_thickness_mm, bridge_width_mm], center=true);

    // End cap (guaranteed to intersect buzzer and bridge)
    translate([cap_center_x, 0, cap_center_z])
      cube([cap_len, cap_w, cap_h], center=true);
  }
}

// Assembly - single solid union (no floating parts)
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
    buzzer_bridge_and_cap();
  }
}

assembly();