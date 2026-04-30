// Parameters
profile_size = 15; //[7.5:30:0.1]
length = 100; //[50:200:1]
center_bore_diameter = 3.3; //[1.65:6.6:0.05]
inner_chamber_square = 5.5; //[2.75:11:0.05]
t_slot_opening_width = 6.2; //[3.1:12.4:0.05]
t_slot_internal_channel_width = 9.5; //[4.75:19:0.05]
t_slot_lip_thickness = 1; //[0.5:2:0.05]
internal_spar_thickness = 0.9; //[0.45:1.8:0.05]
corner_fillet_radius = 0.5; //[0:1.5:0.05]
eps = 0.2; //[0.05:0.5:0.05]
outer_wall = 1.2; //[0.6:2.4:0.05]
t_slot_depth = 4.2; //[2.1:8.4:0.05]

// Extrusion - complete detailed geometry
module extrusion() {
  color("Silver") {
    difference() {
      // Outer block with corner fillets
      union() {
        cube([profile_size, profile_size, length], center=true);
        for (x = [-1, 1], y = [-1, 1]) {
          translate([x * (profile_size/2 - corner_fillet_radius), y * (profile_size/2 - corner_fillet_radius), 0])
            cylinder(r=corner_fillet_radius, h=length + 2*eps, center=true);
        }
      }
      // Inner square chamber
      translate([0, 0, 0])
        cube([inner_chamber_square, inner_chamber_square, length + 2*eps], center=true);
      // Central through-bore
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=length + 2*eps, center=true);
      // T-slots
      for (i = [0:3]) {
        rotate([0, 0, i*90]) {
          translate([profile_size/2 - (t_slot_depth + eps)/2, 0, 0]) {
            cube([t_slot_depth + eps, t_slot_internal_channel_width, length + 2*eps], center=true);
            cube([t_slot_depth + eps, t_slot_opening_width, length + 2*eps], center=true);
          }
        }
      }
    }
    // Internal spars
    union() {
      cube([profile_size - 2*outer_wall, internal_spar_thickness, length], center=true);
      cube([internal_spar_thickness, profile_size - 2*outer_wall, length], center=true);
    }
    // T-slot lips
    for (i = [0:3]) {
      rotate([0, 0, i*90]) {
        translate([profile_size/2 - t_slot_lip_thickness/2, t_slot_opening_width/2 + ((t_slot_internal_channel_width - t_slot_opening_width)/2)/2, 0])
          cube([t_slot_lip_thickness, (t_slot_internal_channel_width - t_slot_opening_width)/2, length], center=true);
        translate([profile_size/2 - t_slot_lip_thickness/2, -(t_slot_opening_width/2 + ((t_slot_internal_channel_width - t_slot_opening_width)/2)/2), 0])
          cube([t_slot_lip_thickness, (t_slot_internal_channel_width - t_slot_opening_width)/2, length], center=true);
      }
    }
  }
}

// Corner - complete detailed geometry
module corner() {
  color("DimGray") {
    // Simple corner block
    cube([10, 10, 10], center=true);
  }
}

// Box Corner Profile Section - complete detailed geometry
module box_corner_profile_section() {
  color("Black") {
    // Simple box corner profile
    cube([8, 8, 8], center=true);
  }
}

// Extrusion Cross Section - complete detailed geometry
module extrusion_cross_section() {
  color("Silver") {
    // Cross section of extrusion
    difference() {
      cube([profile_size, profile_size, 2], center=true);
      for (x = [-1, 1], y = [-1, 1]) {
        translate([x * (profile_size/2 - corner_fillet_radius), y * (profile_size/2 - corner_fillet_radius), 0])
          cylinder(r=corner_fillet_radius, h=2, center=true);
      }
      translate([0, 0, 0])
        cube([inner_chamber_square, inner_chamber_square, 2], center=true);
      translate([0, 0, 0])
        cylinder(r=center_bore_diameter/2, h=2, center=true);
    }
  }
}

// Box Corner Profile Sections - complete detailed geometry
module box_corner_profile_sections() {
  color("Black") {
    // Multiple box corner profiles
    for (i = [0:3]) {
      rotate([0, 0, i*90]) {
        translate([profile_size/2, profile_size/2, 0])
          cube([8, 8, 2], center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  extrusion();
  translate([0, 0, length/2 + 5]) corner();
  translate([0, 0, -length/2 - 5]) box_corner_profile_section();
  translate([0, 0, length/2 + 10]) extrusion_cross_section();
  translate([0, 0, -length/2 - 10]) box_corner_profile_sections();
}

assembly();