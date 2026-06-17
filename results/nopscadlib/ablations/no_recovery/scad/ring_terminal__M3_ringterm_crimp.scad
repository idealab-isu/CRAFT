// Parameters
type_selector = 0; //[0:2:1]
ring_thickness = 2.0; //[1.0:4.0:0.1]
ring_outer_diameter = 16.0; //[8.0:32.0:0.5]
ring_inner_diameter = 6.0; //[3.0:12.0:0.5]
terminal_width = 8.0; //[4.0:16.0:0.5]
terminal_length = 28.0; //[14.0:56.0:1]
crimp_length = 14.0; //[7.0:28.0:1]
crimp_outer_diameter = 8.0; //[4.0:16.0:0.5]
crimp_inner_diameter = 4.0; //[2.0:12.0:0.5]
tab_bend_angle_deg = 45.0; //[0.0:75.0:1]
secondary_hole_diameter = 3.0; //[1.5:6.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
eps = 0.2; //[0.05:0.5:0.05]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring Terminal Body
    linear_extrude(height=ring_thickness) {
      polygon(points=[
        [-terminal_width/2, -(terminal_length - ring_outer_diameter/2)],
        [terminal_width/2, -(terminal_length - ring_outer_diameter/2)],
        [terminal_width/2, -ring_inner_diameter/2],
        [ring_outer_diameter/2, -ring_inner_diameter/2],
        [ring_outer_diameter/2, ring_inner_diameter/2],
        [terminal_width/2, ring_inner_diameter/2],
        [terminal_width/2, 0],
        [ring_outer_diameter/2, 0],
        [ring_outer_diameter/2, ring_outer_diameter/2],
        [0, ring_outer_diameter/2],
        [-ring_outer_diameter/2, ring_outer_diameter/2],
        [-ring_outer_diameter/2, 0],
        [-ring_outer_diameter/2, -ring_outer_diameter/2],
        [0, -ring_outer_diameter/2],
        [ring_outer_diameter/2, -ring_outer_diameter/2],
        [ring_outer_diameter/2, -ring_inner_diameter/2],
        [-terminal_width/2, -ring_inner_diameter/2],
        [-terminal_width/2, -(terminal_length - ring_outer_diameter/2)]
      ]);
    }
    // Ring Hole
    translate([0, 0, -eps])
      cylinder(r=ring_inner_diameter/2, h=ring_thickness + 2*eps, center=true);
  }
}

// Wire Termination Section - Crimp Barrel
module wire_termination_section_crimp() {
  color("DimGray") {
    difference() {
      // Outer Crimp Barrel
      translate([0, -(ring_outer_diameter/2 + crimp_length/2 - overlap), ring_thickness/2 + crimp_outer_diameter/2 - overlap])
        rotate([90, 0, 0])
        cylinder(r=crimp_outer_diameter/2, h=crimp_length, center=true);
      // Inner Crimp Barrel
      translate([0, -(ring_outer_diameter/2 + crimp_length/2 - overlap), ring_thickness/2 + crimp_outer_diameter/2 - overlap])
        rotate([90, 0, 0])
        cylinder(r=crimp_inner_diameter/2, h=crimp_length + 2*eps, center=true);
    }
  }
}

// Wire Termination Section - Tab
module wire_termination_section_tab() {
  color("DimGray") {
    difference() {
      // Flat Tab Section
      translate([0, -((terminal_length - ring_outer_diameter/2)/2 + ring_outer_diameter/2 - overlap), 0])
        rotate([tab_bend_angle_deg * (type_selector==0 ? 0 : 1), 0, 0])
        cube([terminal_width, (terminal_length - ring_outer_diameter/2), ring_thickness], center=true);
      // Secondary Hole (if applicable)
      if (type_selector == 2) {
        translate([0, -(terminal_length - terminal_width/2), 0])
          cylinder(r=secondary_hole_diameter/2, h=ring_thickness + 2*eps, center=true);
      }
    }
  }
}

// Ring Terminal Assembly
module ring_terminal_assembly() {
  union() {
    ring_terminal();
    if (type_selector == 0) {
      wire_termination_section_crimp();
    } else {
      wire_termination_section_tab();
    }
  }
}

// Final Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();