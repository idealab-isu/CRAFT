// Parameters
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_D = 10; //[5:20:1]
shell_corner_r = 6; //[3:12:1]
flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1.25:5:0.5]
mount_hole_d = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing = 33; //[16.5:66:0.5]
rear_W = 28; //[14:56:1]
rear_H = 14; //[7:28:1]
rear_D = 18; //[9:36:1]
front_opening_clearance = 0.5; //[0.25:2:0.25]
overlap = 1; //[0.5:2:0.5]
shell_endcap_r = 6; //[3:12:1]
front_opening_depth = 6; //[3:12:1]

// Base Shapes
module d_shell_center_block() {
  translate([0, 0, 0])
    cube([shell_W - 2*shell_endcap_r, shell_H, shell_D], center=true);
}

module d_shell_endcap_left() {
  translate([-(shell_W/2 - shell_endcap_r), 0, 0])
    rotate([90, 0, 0])
      cylinder(r=shell_endcap_r, h=shell_D, center=true);
}

module d_shell_endcap_right() {
  translate([(shell_W/2 - shell_endcap_r), 0, 0])
    rotate([90, 0, 0])
      cylinder(r=shell_endcap_r, h=shell_D, center=true);
}

module d_shell_flatten_cut() {
  translate([0, -(shell_H/2 + shell_H/4), 0])
    cube([shell_W + 2*overlap, shell_H, shell_D + 2*overlap], center=true);
}

module flange_plate() {
  translate([0, 0, -(shell_D/2 + flange_t/2 - overlap)])
    cube([flange_W, flange_H, flange_t], center=true);
}

module mounting_hole_left() {
  translate([-mount_hole_spacing/2, 0, -(shell_D/2 + flange_t/2 - overlap)])
    cylinder(r=mount_hole_d/2, h=flange_t + 2*overlap, center=true);
}

module mounting_hole_right() {
  translate([mount_hole_spacing/2, 0, -(shell_D/2 + flange_t/2 - overlap)])
    cylinder(r=mount_hole_d/2, h=flange_t + 2*overlap, center=true);
}

module rear_housing_block() {
  translate([0, 0, (shell_D/2 + rear_D/2 - overlap)])
    cube([rear_W, rear_H, rear_D], center=true);
}

module front_opening_cutout() {
  translate([0, 0, -(shell_D/2 - front_opening_depth/2 + overlap)])
    cube([shell_W - 2*front_opening_clearance, shell_H - 2*front_opening_clearance, front_opening_depth], center=true);
}

// Operations
module d_shell_union_raw() {
  union() {
    d_shell_center_block();
    d_shell_endcap_left();
    d_shell_endcap_right();
  }
}

module d_shell_body() {
  difference() {
    d_shell_union_raw();
    d_shell_flatten_cut();
  }
}

module front_shell_with_opening() {
  difference() {
    d_shell_body();
    front_opening_cutout();
  }
}

module front_with_flange() {
  union() {
    front_shell_with_opening();
    flange_plate();
  }
}

module front_with_flange_and_holes() {
  difference() {
    front_with_flange();
    mounting_hole_left();
    mounting_hole_right();
  }
}

module connector_main_solid() {
  union() {
    front_with_flange_and_holes();
    rear_housing_block();
  }
}

module complete_model() {
  union() {
    connector_main_solid();
    // Placeholder components
    translate([0, 0, 0]) cube([overlap, overlap, overlap], center=true); // pins_or_sockets_array
    translate([0, 0, 0]) cube([overlap, overlap, overlap], center=true); // jackscrews
    translate([0, 0, 0]) cube([overlap, overlap, overlap], center=true); // strain_relief
    translate([0, 0, 0]) cube([overlap, overlap, overlap], center=true); // chamfers_fillets
    translate([0, 0, 0]) cube([overlap, overlap, overlap], center=true); // embossed_labels
  }
}

// Final Output
complete_model();