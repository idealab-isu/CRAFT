// Parameters
inner_hole_diameter = 5; //[2.5:10:0.1]
outer_ring_diameter = 10; //[6:20:0.1]
tab_width = 6; //[3:12:0.1]
overall_length = 25; //[15:50:0.5]
thickness = 1; //[0.5:3:0.1]
tail_style = 0; //[0:1:1]
crimp_length = 10; //[5:25:0.5]
crimp_outer_diameter = 6; //[4:12:0.1]
crimp_wall_thickness = 1; //[0.5:2:0.1]
bend_angle_deg = 45; //[15:90:1]
transition_length = 1; //[0.5:3:0.1]
overlap = 1; //[0.5:2:0.1]
ring_center_y = 0; //[0:0:1]
tab_length = 14; //[8:30:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring terminal body
    difference() {
      cylinder(r=outer_ring_diameter/2, h=thickness, center=true);
      translate([0, ring_center_y, 0])
        cylinder(r=inner_hole_diameter/2, h=thickness + 2*overlap, center=true);
    }
    // Tab tail
    translate([0, -(outer_ring_diameter/2 + tab_length/2 - overlap), 0])
      cube([tab_width, tab_length, thickness], center=true);
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    // Crimp barrel
    difference() {
      translate([0, -(outer_ring_diameter/2 + tab_length - overlap + crimp_length/2), crimp_outer_diameter/2 - thickness/2])
        rotate([90, 0, 0])
        cylinder(r=crimp_outer_diameter/2, h=crimp_length, center=true);
      translate([0, -(outer_ring_diameter/2 + tab_length - overlap + crimp_length/2), crimp_outer_diameter/2 - thickness/2])
        rotate([90, 0, 0])
        cylinder(r=crimp_outer_diameter/2 - crimp_wall_thickness, h=crimp_length + 2*overlap, center=true);
    }
    // Bent tongue
    translate([0, -(outer_ring_diameter/2 + tab_length - overlap + (overall_length - (outer_ring_diameter/2 + tab_length) + transition_length)/2), 0])
      rotate([bend_angle_deg, 0, 0])
      cube([tab_width, overall_length - (outer_ring_diameter/2 + tab_length) + transition_length, thickness], center=true);
  }
}

// Assembly
module assembly() {
  ring_terminal();
  ring_terminal_assembly();
}

assembly();