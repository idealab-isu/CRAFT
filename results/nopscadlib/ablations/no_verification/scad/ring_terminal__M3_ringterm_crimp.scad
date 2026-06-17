// Parameters
terminal_type = 1; //[1:6:1]
thickness = 2; //[1:4:0.25]
width = 8; //[4:16:0.5]
outer_diameter = 16; //[8:32:0.5]
inner_diameter = 6; //[3:12:0.5]
overall_length = 32; //[16:64:1]
crimp_length = 14; //[0:30:1]
tongue_bend_angle_deg = 45; //[0:90:1]
transition_length = 1; //[0.5:3:0.25]
wire_hole_diameter = 4; //[0:10:0.5]
overlap = 1; //[0.5:2:0.25]
eps = 0.2; //[0.05:0.5:0.05]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring body with bolt hole
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter/2, h=thickness, center=true, $fn=64);
      translate([0, 0, 0])
        cylinder(r=inner_diameter/2, h=thickness + 2*eps, center=true, $fn=64);
    }
    
    // Tongue plate
    translate([0, -(outer_diameter/2 + (overall_length - outer_diameter/2)/2 - overlap), 0])
      cube([width, overall_length - outer_diameter/2, thickness], center=true);
    
    // Transition fillet or hull between ring and tongue
    translate([0, -(outer_diameter/2 - overlap + transition_length/2), 0])
      cube([width, transition_length, thickness], center=true);
    
    // Wire termination section (crimp barrel)
    if (crimp_length > 0) {
      difference() {
        translate([0, -(outer_diameter/2 + (overall_length - outer_diameter/2) - crimp_length/2 - overlap), width/2 - thickness/2])
          rotate([90, 0, 0])
          cylinder(r=width/2, h=crimp_length, center=true, $fn=64);
        translate([0, -(outer_diameter/2 + (overall_length - outer_diameter/2) - crimp_length/2 - overlap), width/2 - thickness/2])
          rotate([90, 0, 0])
          cylinder(r=width/2 - thickness, h=crimp_length + transition_length + 2*eps, center=true, $fn=64);
      }
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    // Base ring terminal
    ring_terminal();
    
    // Optional wire hole in tongue if non-crimp style
    if (crimp_length == 0 && wire_hole_diameter > 0) {
      translate([0, -(outer_diameter/2 + (overall_length - outer_diameter/2) - width/2 - overlap), 0])
        cylinder(r=wire_hole_diameter/2, h=thickness + 2*eps, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();