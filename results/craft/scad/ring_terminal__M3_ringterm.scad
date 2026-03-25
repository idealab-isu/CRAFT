// Parameters
ring_outer_diameter_mm = 12; //[6:24:1]
ring_inner_diameter_mm = 6; //[3:12:1]
thickness_mm = 1; //[0.5:2:0.1]
lug_width_mm = 6; //[3:12:1]
overall_length_mm = 25; //[13:50:1]
crimp_length_mm = 10; //[5:20:1]
crimp_enabled = 1; //[0:1:1]
bend_angle_deg = 45; //[0:90:5]
wire_entry_slot_enabled = 1; //[0:1:1]
overlap_mm = 1; //[0.5:2:0.1]
transition_length_mm = 2; //[1:5:0.5]
barrel_wall_mm = 0.8; //[0.4:1.6:0.1]
slot_width_mm = 0.8; //[0.4:2:0.1]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    difference() {
      // Ring Lug Body
      translate([0, 0, 0])
        cylinder(r=ring_outer_diameter_mm/2, h=thickness_mm, center=true);
      // Ring Hole
      translate([0, 0, 0])
        cylinder(r=ring_inner_diameter_mm/2, h=thickness_mm + 2*overlap_mm, center=true);
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    union() {
      // Ring Terminal
      ring_terminal();
      
      // Tongue Neck Transition
      translate([0, -(ring_outer_diameter_mm/2 + transition_length_mm)/2 + overlap_mm/2, 0])
        cube([lug_width_mm, ring_outer_diameter_mm/2 + transition_length_mm, thickness_mm], center=true);
      
      // Crimp Barrel or Bent Tongue
      if (crimp_enabled) {
        difference() {
          // Crimp Barrel Outer
          translate([0, -(ring_outer_diameter_mm/2 + transition_length_mm) - crimp_length_mm/2 + overlap_mm, 0])
            rotate([90, 0, 0])
            cylinder(r=lug_width_mm/2, h=crimp_length_mm, center=true);
          // Crimp Barrel Inner
          translate([0, -(ring_outer_diameter_mm/2 + transition_length_mm) - crimp_length_mm/2 + overlap_mm, 0])
            rotate([90, 0, 0])
            cylinder(r=max(lug_width_mm/2 - barrel_wall_mm, lug_width_mm/4), h=crimp_length_mm + 2*overlap_mm, center=true);
          // Wire Entry Slot Cut
          if (wire_entry_slot_enabled) {
            translate([0, -(ring_outer_diameter_mm/2 + transition_length_mm) - crimp_length_mm/2 + overlap_mm, 0])
              cube([slot_width_mm, crimp_length_mm + 2*overlap_mm, lug_width_mm + 2*overlap_mm], center=true);
          }
        }
      } else {
        // Bent Tongue
        translate([0, -(ring_outer_diameter_mm/2) - (overall_length_mm - ring_outer_diameter_mm/2)/2 + overlap_mm, 0])
          rotate([bend_angle_deg, 0, 0])
          cube([lug_width_mm, overall_length_mm - ring_outer_diameter_mm/2, thickness_mm], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();