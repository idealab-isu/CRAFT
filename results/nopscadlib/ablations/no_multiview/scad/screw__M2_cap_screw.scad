// Parameters
shaft_diameter_mm = 2.0; //[1.0:4.0:0.1]
overall_length_mm = 10.0; //[5.0:20.0:0.5]
head_diameter_mm = 3.8; //[2.0:7.6:0.1]
head_height_mm = 2.0; //[1.0:4.0:0.1]
thread_pitch_mm = 0.4; //[0.2:0.8:0.05]
thread_length_mm = 10.0; //[2.0:20.0:0.5]
socket_across_flats_mm = 1.5; //[0.8:3.0:0.05]
socket_depth_mm = 1.0; //[0.5:2.0:0.05]
overlap_mm = 1.2; //[0.5:2.0:0.1]  // increased to guarantee fusion
thread_radial_add_mm = 0.12; //[0.05:0.3:0.01]
thread_start_offset_mm = 0.0; //[0.0:3.0:0.1]
placeholder_tab_thickness_mm = 0.6; //[0.4:1.5:0.1]
placeholder_tab_width_mm = 1.2; //[0.8:3.0:0.1]
placeholder_tab_height_mm = 1.2; //[0.8:3.0:0.1]

// Derived helpers
shaft_r = shaft_diameter_mm/2;
head_r  = head_diameter_mm/2;

// Place screw so head top is at z=0 and shaft extends downward (simple, stable reference)
z_head_center = -head_height_mm/2;
z_shaft_center = -(head_height_mm + overall_length_mm/2);

// Pin Socket - Custom detailed geometry
module pin_socket() {
  color("Silver")
    cube([placeholder_tab_thickness_mm, placeholder_tab_width_mm, placeholder_tab_height_mm], center=true);
}

// Screw (shaft + head) - single connected solid
module screw() {
  color("DimGray")
    union() {
      // Shaft
      translate([0,0,z_shaft_center])
        cylinder(r=shaft_r, h=overall_length_mm, center=true);

      // Head (overlap into shaft by overlap_mm)
      translate([0,0,z_head_center])
        cylinder(r=head_r, h=head_height_mm + overlap_mm, center=true);
    }
}

// PCB Spacer - Custom detailed geometry
module pcb_spacer() {
  color("Black")
    difference() {
      cylinder(r=placeholder_tab_width_mm/2, h=placeholder_tab_height_mm, center=true);
      // keep inner cut valid (avoid negative radius)
      inner_r = max(0.01, placeholder_tab_width_mm/2 - 0.18);
      translate([0, 0, -placeholder_tab_height_mm/2])
        cylinder(r=inner_r, h=placeholder_tab_height_mm + overlap_mm, center=true);
    }
}

// Buzzer - Custom detailed geometry
module buzzer() {
  color("Copper")
    cylinder(r=placeholder_tab_height_mm/2, h=placeholder_tab_thickness_mm, center=true);
}

// Assembly (all parts physically intersect the head with 1-2mm overlap)
module assembly() {
  union() {
    // Main screw
    screw();

    // Side protrusions: attach to head side with guaranteed overlap
    // X+ (light-gray)
    translate([ head_r + placeholder_tab_thickness_mm/2 - overlap_mm,
                0,
                z_head_center ])
      pin_socket();

    // X- (blue) - create missing symmetric part and attach
    color("SteelBlue")
      translate([ -(head_r + placeholder_tab_thickness_mm/2 - overlap_mm),
                  0,
                  z_head_center ])
        cube([placeholder_tab_thickness_mm, placeholder_tab_width_mm, placeholder_tab_height_mm], center=true);

    // Y- (black small protrusion) - attach to head side with overlap
    translate([ 0,
                -(head_r + placeholder_tab_height_mm/2 - overlap_mm),
                z_head_center ])
      pcb_spacer();

    // Y+ (light-gray side protrusion) - attach to head side with overlap
    color("Gainsboro")
      translate([ 0,
                  (head_r + placeholder_tab_height_mm/2 - overlap_mm),
                  z_head_center ])
        cube([placeholder_tab_height_mm, placeholder_tab_thickness_mm, placeholder_tab_width_mm], center=true);

    // Additional small protrusion (copper) - attach to head side with overlap
    translate([ -(head_r + placeholder_tab_height_mm/2 - overlap_mm),
                0,
                z_head_center ])
      buzzer();
  }
}

assembly();