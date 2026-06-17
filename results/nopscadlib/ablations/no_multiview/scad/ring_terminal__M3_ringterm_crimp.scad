// Parameters
type_selector = 1; //[0:1:1]
thickness = 1.5; //[0.8:3:0.1]
width = 8; //[4:16:0.5]
outer_diameter = 14; //[8:28:0.5]
inner_diameter = 6; //[3:14:0.5]
overall_length = 32; //[18:64:1]
crimp_length = 14; //[0:30:1]
aux_hole_diameter = 4; //[0:10:0.5]
bend_angle_deg = 45; //[0:90:1]
transition_length = 1; //[0.5:3:0.1]
overlap = 1; //[0.5:2:0.1]
eps = 0.2; //[0.05:0.5:0.05]
barrel_wall = 0.8; //[0.4:2:0.1]
barrel_outer_diameter = 8; //[5:16:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring end with bolt hole
    difference() {
      translate([0, 0, 0])
        cylinder(r=outer_diameter/2, h=thickness, center=true);
      translate([0, 0, 0])
        cylinder(r=inner_diameter/2, h=thickness + 2*eps, center=true);
    }
    
    // Tab shank
    translate([0, -(overall_length - outer_diameter/2)/2, 0])
      cube([width, overall_length - outer_diameter/2, thickness], center=true);
    
    // Transition
    translate([0, -(overall_length - outer_diameter/2) + transition_length/2 - overlap/2, 0])
      cube([width, transition_length, thickness], center=true);
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  if (type_selector == 1) {
    // Crimp barrel style
    color("Silver") {
      union() {
        ring_terminal();
        difference() {
          translate([0, -(overall_length - outer_diameter/2) - crimp_length/2 + overlap, barrel_outer_diameter/2 - thickness/2])
            rotate([90, 0, 0])
            cylinder(r=barrel_outer_diameter/2, h=crimp_length, center=true);
          translate([0, -(overall_length - outer_diameter/2) - crimp_length/2 + overlap, barrel_outer_diameter/2 - thickness/2])
            rotate([90, 0, 0])
            cylinder(r=(barrel_outer_diameter - 2*barrel_wall)/2, h=crimp_length + 2*eps, center=true);
        }
      }
    }
  } else {
    // Bent-tab style
    color("Silver") {
      union() {
        ring_terminal();
        rotate([bend_angle_deg, 0, 0])
          difference() {
            translate([0, -(overall_length - outer_diameter/2) - width/2 + overlap, 0])
              cylinder(r=width/2, h=thickness, center=true);
            translate([0, -(overall_length - outer_diameter/2) - width/2 + overlap, 0])
              cylinder(r=aux_hole_diameter/2, h=thickness + 2*eps, center=true);
          }
      }
    }
  }
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();