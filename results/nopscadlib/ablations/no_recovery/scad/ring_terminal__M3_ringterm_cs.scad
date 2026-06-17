// Parameters
type_selector = 0; //[0:1:1]
thickness_mm = 1.5; //[0.8:3:0.1]
overall_length_mm = 40; //[20:80:1]
tab_width_mm = 10; //[5:20:0.5]
outer_diameter_mm = 16; //[10:32:0.5]
inner_diameter_mm = 8; //[4:20:0.5]
bolt_hole_diameter_mm = 6; //[3:12:0.5]
crimp_length_mm = 18; //[8:40:1]
bend_angle_deg = 45; //[0:90:1]
transition_length_mm = 1; //[0.5:5:0.5]
wire_hole_diameter_mm = 4; //[0:10:0.5]
overlap_mm = 1; //[0.5:2:0.1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring
    difference() {
      translate([0, 0, thickness_mm / 2])
        cylinder(r=outer_diameter_mm / 2, h=thickness_mm, center=true);
      translate([0, 0, thickness_mm / 2])
        cylinder(r=inner_diameter_mm / 2, h=thickness_mm + 2 * eps_mm, center=true);
      translate([0, 0, thickness_mm / 2])
        cylinder(r=bolt_hole_diameter_mm / 2, h=thickness_mm + 2 * eps_mm, center=true);
    }
    // Tab
    translate([0, -(overall_length_mm - outer_diameter_mm / 2) / 2, thickness_mm / 2])
      cube([tab_width_mm, overall_length_mm - outer_diameter_mm / 2, thickness_mm], center=true);
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  if (type_selector == 0) {
    // Crimp Barrel Style
    color("Silver") {
      // Crimp Shell
      difference() {
        translate([0, -(overall_length_mm - outer_diameter_mm / 2) + crimp_length_mm / 2 - overlap_mm, tab_width_mm / 2 - overlap_mm])
          rotate([90, 0, 0])
          cylinder(r=tab_width_mm / 2, h=crimp_length_mm, center=true);
        translate([0, -(overall_length_mm - outer_diameter_mm / 2) + crimp_length_mm / 2 - overlap_mm, tab_width_mm / 2 - overlap_mm])
          rotate([90, 0, 0])
          cylinder(r=tab_width_mm / 2 - thickness_mm, h=crimp_length_mm + 2 * eps_mm, center=true);
      }
      // Transition
      translate([0, -(overall_length_mm - outer_diameter_mm / 2) + transition_length_mm / 2 - overlap_mm, thickness_mm / 2])
        cube([tab_width_mm, transition_length_mm, thickness_mm], center=true);
    }
  } else {
    // Bent Tab Style
    color("Silver") {
      // Bent Tab
      difference() {
        translate([0, -(overall_length_mm - outer_diameter_mm / 2) - (overall_length_mm - outer_diameter_mm / 2 - transition_length_mm) / 2 + overlap_mm, thickness_mm / 2])
          rotate([-bend_angle_deg, 0, 0])
          cube([tab_width_mm, overall_length_mm - outer_diameter_mm / 2 - transition_length_mm, thickness_mm], center=true);
        translate([0, -(overall_length_mm - outer_diameter_mm / 2) + (tab_width_mm / 2), thickness_mm / 2])
          rotate([-bend_angle_deg, 0, 0])
          cylinder(r=wire_hole_diameter_mm / 2, h=thickness_mm + 2 * eps_mm, center=true);
      }
      // Transition
      translate([0, -(overall_length_mm - outer_diameter_mm / 2) + transition_length_mm / 2 - overlap_mm, thickness_mm / 2])
        cube([tab_width_mm, transition_length_mm, thickness_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  ring_terminal();
  ring_terminal_assembly();
}

assembly();