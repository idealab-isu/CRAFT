// Parameters
outer_diameter_od_mm = 16; //[8:32:1]
inner_diameter_id_mm = 8; //[4:16:1]
hole_diameter_mm = 0; //[0:10:1]
thickness_t_mm = 2; //[1:4:0.5]
width_w_mm = 6; //[3:12:1]
overall_length_l_mm = 30; //[15:60:1]
crimp_length_mm = 12; //[6:24:1]
bend_or_transition_length_mm = 2; //[1:6:0.5]
tab_angle_deg = 45; //[0:60:1]
has_crimp = 1; //[0:1:1]
eps_mm = 1; //[0.5:2:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    difference() {
      // Ring terminal body
      translate([0, 0, 0])
        cylinder(r=outer_diameter_od_mm/2, h=thickness_t_mm, center=true, $fn=64);
      // Ring hole
      translate([0, 0, 0])
        cylinder(r=inner_diameter_id_mm/2, h=thickness_t_mm + 2*eps_mm, center=true, $fn=64);
    }
  }
}

// Tab or Shank - complete geometry
module tab_or_shank() {
  color("Silver") {
    difference() {
      // Tab or shank raw
      translate([0, -(outer_diameter_od_mm/2 + (overall_length_l_mm - outer_diameter_od_mm/2)/2 - eps_mm), 0])
        rotate([tab_angle_deg*(1-has_crimp), 0, 0])
        cube([width_w_mm, overall_length_l_mm - outer_diameter_od_mm/2, thickness_t_mm], center=true);
      // Tab end hole
      if (hole_diameter_mm > 0) {
        translate([0, -(outer_diameter_od_mm/2 + (overall_length_l_mm - outer_diameter_od_mm/2) - width_w_mm/2), 0])
          cylinder(r=hole_diameter_mm/2, h=thickness_t_mm + 2*eps_mm, center=true, $fn=32);
      }
    }
  }
}

// Optional Crimp Barrel - complete geometry
module optional_crimp_barrel() {
  if (has_crimp) {
    color("Silver") {
      difference() {
        // Crimp barrel raw
        translate([0, -(outer_diameter_od_mm/2 + (overall_length_l_mm - outer_diameter_od_mm/2) - eps_mm - bend_or_transition_length_mm), width_w_mm/2 - thickness_t_mm/2])
          rotate([90, 0, 0])
          cylinder(r=width_w_mm/2, h=crimp_length_mm, center=true, $fn=64);
        // Crimp barrel void
        translate([0, -(outer_diameter_od_mm/2 + (overall_length_l_mm - outer_diameter_od_mm/2) - eps_mm - bend_or_transition_length_mm), width_w_mm/2 - thickness_t_mm/2])
          rotate([90, 0, 0])
          cylinder(r=width_w_mm/2 - thickness_t_mm, h=crimp_length_mm + 2*eps_mm, center=true, $fn=64);
      }
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  union() {
    ring_terminal();
    tab_or_shank();
    optional_crimp_barrel();
  }
}

// Final Assembly
module assembly() {
  ring_terminal_assembly();
}

assembly();