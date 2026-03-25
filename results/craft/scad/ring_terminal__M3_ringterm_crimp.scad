// Parameters
ring_outer_diameter = 12; //[6:24:1]
ring_inner_diameter = 6; //[3:12:1]
thickness = 1; //[0.5:2:0.1]
lug_width = 6; //[3:12:1]
overall_length = 25; //[15:50:1]
has_crimp_barrel = 1; //[0:1:1]
crimp_length = 10; //[5:25:1]
crimp_outer_diameter = 6; //[3:12:1]
crimp_inner_diameter = 4; //[2:10:1]
bend_angle_deg = 45; //[0:75:1]
transition_length = 1; //[0.5:3:0.5]
overlap = 1; //[0.5:2:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    difference() {
      // Ring Lug Body
      translate([0, 0, 0])
        cylinder(r=ring_outer_diameter/2, h=thickness, center=true, $fn=64);
      // Fastener Hole
      translate([0, 0, 0])
        cylinder(r=ring_inner_diameter/2, h=thickness + 2*overlap, center=true, $fn=64);
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    union() {
      // Ring Terminal
      ring_terminal();
      // Tongue Extension
      translate([ring_outer_diameter/4 + (overall_length - ring_outer_diameter/2)/2 - overlap, 0, 0])
        cube([overall_length - ring_outer_diameter/2, lug_width, thickness], center=true);
      // Crimp Barrel or Bent Tongue Transition
      if (has_crimp_barrel) {
        translate([ring_outer_diameter/4 + (overall_length - ring_outer_diameter/2) - crimp_length/2 + overlap, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=crimp_outer_diameter/2, h=crimp_length, center=true, $fn=64);
      }
    }
    // Crimp Barrel Inner Void
    if (has_crimp_barrel) {
      translate([ring_outer_diameter/4 + (overall_length - ring_outer_diameter/2) - crimp_length/2 + overlap, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=crimp_inner_diameter/2, h=crimp_length + 2*overlap, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();