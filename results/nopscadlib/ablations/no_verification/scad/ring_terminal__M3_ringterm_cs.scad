// Parameters
outer_diameter_od = 12; //[6:24:0.5]
inner_diameter_id = 6.4; //[3.2:12.8:0.1]
thickness_t = 1.2; //[0.6:2.4:0.1]
width_w = 8; //[4:16:0.5]
overall_length_l = 30; //[15:60:1]
crimp_length = 12; //[6:24:1]
crimp_enabled = 1; //[0:1:1]
aux_hole_diameter = 3; //[0:6:0.1]
bend_angle_deg = 45; //[0:90:1]
transition_length = 2; //[1:6:0.5]
overlap_eps = 1; //[0.5:2:0.1]
ring_to_neck_length = 10; //[5:20:0.5]
barrel_wall = 0.8; //[0.4:1.6:0.1]
strain_relief_length = 4; //[2:10:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring Lug Plate with Hole
    difference() {
      union() {
        translate([0, 0, 0])
          cylinder(r=outer_diameter_od/2, h=thickness_t, center=true);
        translate([0, -(outer_diameter_od/2 + ring_to_neck_length/2 - overlap_eps), 0])
          cube([width_w, ring_to_neck_length, thickness_t], center=true);
      }
      translate([0, 0, 0])
        cylinder(r=inner_diameter_id/2, h=thickness_t + 2*overlap_eps, center=true);
    }
    
    // Crimp Barrel or Bent Tab
    if (crimp_enabled) {
      // Crimp Barrel
      union() {
        difference() {
          translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length - overlap_eps), width_w/2 - thickness_t/2])
            rotate([90, 0, 0])
            cylinder(r=width_w/2, h=crimp_length, center=true);
          translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length - overlap_eps), width_w/2 - thickness_t/2])
            rotate([90, 0, 0])
            cylinder(r=width_w/2 - barrel_wall, h=crimp_length + 2*overlap_eps, center=true);
        }
        difference() {
          translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length + crimp_length/2 + strain_relief_length/2 - overlap_eps), width_w/2 - thickness_t/2])
            rotate([90, 0, 0])
            cylinder(r=width_w/2, h=strain_relief_length, center=true);
          translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length + crimp_length/2 + strain_relief_length/2 - overlap_eps), width_w/2 - thickness_t/2])
            rotate([90, 0, 0])
            cylinder(r=width_w/2 - barrel_wall, h=strain_relief_length + 2*overlap_eps, center=true);
        }
      }
    } else {
      // Bent Tab
      union() {
        translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length + (overall_length_l - outer_diameter_od/2 - ring_to_neck_length - transition_length)/2 - overlap_eps), 0])
          cube([width_w, overall_length_l - outer_diameter_od/2 - ring_to_neck_length - transition_length, thickness_t], center=true);
        translate([0, -(outer_diameter_od/2 + ring_to_neck_length + transition_length/2 - overlap_eps), thickness_t/2 - overlap_eps])
          rotate([bend_angle_deg, 0, 0])
          cube([width_w, transition_length, thickness_t], center=true);
        if (aux_hole_diameter > 0) {
          translate([0, -(overall_length_l - width_w/2), 0])
            cylinder(r=aux_hole_diameter/2, h=thickness_t + 2*overlap_eps, center=true);
        }
      }
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  ring_terminal();
}

// Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();