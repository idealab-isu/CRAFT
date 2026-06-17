// Parameters
material_thickness = 1.0; //[0.5:2.0:0.1]
ring_outer_diameter = 10.0; //[5.0:20.0:0.5]
ring_inner_diameter = 5.0; //[2.5:10.0:0.5]
lug_width = 6.0; //[3.0:12.0:0.5]
overall_length = 25.0; //[12.5:50.0:1]
crimp_length = 10.0; //[5.0:20.0:1]
has_crimp_barrel = 1; //[0:1:1]
crimp_barrel_outer_diameter = 6.0; //[3.0:12.0:0.5]
crimp_barrel_wall_thickness = 0.8; //[0.4:1.6:0.1]
bend_angle_deg = 45.0; //[0.0:90.0:5.0]
wire_entry_slot = 1; //[0:1:1]
wire_entry_slot_width = 0.1; //[0.05:1.0:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
neck_length = 12.0; //[6.0:24.0:1]
transition_length = 2.0; //[1.0:4.0:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    difference() {
      // Ring Lug Body
      translate([0, 0, 0])
        cylinder(r=ring_outer_diameter/2, h=material_thickness, center=true);
      // Ring Hole
      translate([0, 0, 0])
        cylinder(r=ring_inner_diameter/2, h=material_thickness + 2*overlap, center=true);
    }
    // Neck Tab
    translate([0, -(ring_outer_diameter/2 + neck_length/2 - overlap), 0])
      cube([lug_width, neck_length, material_thickness], center=true);
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    union() {
      ring_terminal();
      // Transition Block
      translate([0, -(ring_outer_diameter/2 + neck_length - overlap + transition_length/2), 0])
        cube([lug_width, transition_length, material_thickness], center=true);
      
      if (has_crimp_barrel) {
        // Crimp Barrel Outer
        rotate([90, 0, 0])
          translate([0, -(ring_outer_diameter/2 + neck_length - overlap + transition_length - overlap + crimp_length/2), crimp_barrel_outer_diameter/2 - material_thickness/2])
          difference() {
            cylinder(r=crimp_barrel_outer_diameter/2, h=crimp_length, center=true);
            // Crimp Barrel Inner
            cylinder(r=crimp_barrel_outer_diameter/2 - crimp_barrel_wall_thickness, h=crimp_length + 2*overlap, center=true);
            if (wire_entry_slot) {
              // Wire Entry Slot
              translate([0, 0, 0])
                cube([wire_entry_slot_width, crimp_length + 2*overlap, crimp_barrel_outer_diameter + 2*overlap], center=true);
            }
          }
      } else {
        // Bent Tab (if no crimp barrel)
        translate([0, -(ring_outer_diameter/2 + neck_length - overlap + transition_length/2), 0])
          rotate([bend_angle_deg, 0, 0])
          cube([lug_width, transition_length, material_thickness], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();