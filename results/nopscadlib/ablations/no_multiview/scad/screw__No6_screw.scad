// Parameters
shank_diameter_mm = 3.5; //[1.75:7:0.1]
length_mm = 10; //[5:20:0.5]
head_diameter_mm = 6.7; //[3.35:13.4:0.1]
head_height_mm = 2.2; //[1.1:4.4:0.1]
overlap_mm = 1.2; //[0.5:2:0.1]  // ensure 1-2mm overlap for solid connections

washer_outer_diameter_mm = 8.5; //[4.25:17:0.1]
washer_thickness_mm = 1; //[0.5:2:0.1]
spacer_height_mm = 6; //[3:12:0.5]
spacer_wall_mm = 1.8; //[0.9:3.6:0.1]
spacer_clearance_mm = 0.3; //[0.1:0.8:0.05]

buzzer_diameter_mm = 12; //[6:24:0.5]
buzzer_height_mm = 5; //[2.5:10:0.5]
buzzer_offset_x_mm = 10; //[5:20:0.5]

bridge_thickness_mm = 2; //[1:4:0.1]
bridge_width_mm = 4; //[2:8:0.1]

// Derived radii
shank_r  = shank_diameter_mm/2;
head_r   = head_diameter_mm/2;
washer_r = washer_outer_diameter_mm/2;

spacer_outer_r = shank_r + spacer_clearance_mm + spacer_wall_mm;
spacer_inner_r = shank_r + spacer_clearance_mm;

buzzer_r = buzzer_diameter_mm/2;

// -------------------------
// Z stack (guaranteed overlap contacts)
// Reference: washer top at z=0
// -------------------------
z_washer_top    = 0;
z_washer_center = z_washer_top - washer_thickness_mm/2;
z_washer_bottom = z_washer_top - washer_thickness_mm;

// Head overlaps washer by overlap_mm
z_head_bottom = z_washer_top - overlap_mm;
z_head_center = z_head_bottom + head_height_mm/2;
z_head_top    = z_head_bottom + head_height_mm;

// Shank overlaps head by overlap_mm (shank top slightly inside head)
z_shank_top    = z_head_bottom + overlap_mm;
z_shank_center = z_shank_top - length_mm/2;
z_shank_bottom = z_shank_top - length_mm;

// Spacer overlaps washer by overlap_mm
z_spacer_top    = z_washer_bottom + overlap_mm;
z_spacer_center = z_spacer_top - spacer_height_mm/2;
z_spacer_bottom = z_spacer_top - spacer_height_mm;

// Buzzer overlaps spacer/bridge region by overlap_mm
z_buzzer_top    = z_spacer_bottom + overlap_mm;
z_buzzer_center = z_buzzer_top - buzzer_height_mm/2;
z_buzzer_bottom = z_buzzer_top - buzzer_height_mm;

// -------------------------
// Modules
// -------------------------

// Screw and Washer - unioned so screw is one connected solid with washer
module screw_and_washer() {
  color("DimGray")
  union() {
    // Shank
    translate([0, 0, z_shank_center])
      cylinder(r=shank_r, h=length_mm, center=true);

    // Pan Head
    translate([0, 0, z_head_center])
      cylinder(r=head_r, h=head_height_mm, center=true);

    // Washer (ring)
    difference() {
      translate([0, 0, z_washer_center])
        cylinder(r=washer_r, h=washer_thickness_mm, center=true);
      translate([0, 0, z_washer_center])
        cylinder(r=spacer_inner_r, h=washer_thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// PCB Spacer - ring
module pcb_spacer() {
  color("Silver")
  difference() {
    translate([0, 0, z_spacer_center])
      cylinder(r=spacer_outer_r, h=spacer_height_mm, center=true);
    translate([0, 0, z_spacer_center])
      cylinder(r=spacer_inner_r, h=spacer_height_mm + 2*overlap_mm, center=true);
  }
}

// Buzzer - positioned to overlap bridge in X and Z
module buzzer() {
  color("Black")
  translate([buzzer_offset_x_mm, 0, z_buzzer_center])
    cylinder(r=buzzer_r, h=buzzer_height_mm, center=true);
}

// Bridge - guaranteed to intersect BOTH spacer and buzzer (and also overlap in Z)
module buzzer_bridge() {
  color("Silver")
  union() {
    // X: extend slightly INTO spacer and INTO buzzer
    x_left_face  =  spacer_outer_r - overlap_mm;                 // inside spacer
    x_right_face =  buzzer_offset_x_mm - buzzer_r + overlap_mm;   // inside buzzer
    bridge_len   =  x_right_face - x_left_face;
    bridge_cx    = (x_left_face + x_right_face)/2;

    // Z: place bridge so it intersects buzzer bottom and spacer bottom region
    // Make bridge span across the interface: top slightly inside buzzer, bottom slightly inside spacer
    z_bridge_top    = z_buzzer_bottom + overlap_mm;              // inside buzzer
    z_bridge_bottom = z_spacer_bottom - overlap_mm;              // inside spacer
    bridge_h        = max(bridge_thickness_mm, z_bridge_top - z_bridge_bottom);
    z_bridge_c      = (z_bridge_top + z_bridge_bottom)/2;

    translate([bridge_cx, 0, z_bridge_c])
      cube([bridge_len, bridge_width_mm, bridge_h], center=true);
  }
}

// -------------------------
// Assembly (single connected solid)
// -------------------------
module assembly() {
  union() {
    screw_and_washer();
    pcb_spacer();
    buzzer();
    buzzer_bridge();
  }
}

assembly();