// Parameters
bbox_X = 13.16; //[6.58:26.32:0.01]
bbox_Y = 12; //[6:24:0.01]
bbox_Z = 6.35; //[3.175:12.7:0.01]
hub_X = 6; //[3:12:0.01]
hub_Y = 5.6; //[2.8:11.2:0.01]
hub_Z = 6.35; //[3.175:12.7:0.01]
arm_thk_Z = 6.35; //[3.175:12.7:0.01]
arm_W = 2.2; //[1.1:4.4:0.01]
arm_L_cardinal = 3.58; //[1.79:7.16:0.01]
arm_W_diag = 2; //[1:4:0.01]
arm_L_diag = 2.55; //[1.275:5.1:0.01]
fillet_R_arm_end = 0.6; //[0.3:1.2:0.01]
fillet_R_hub_corner = 0.5; //[0.25:1:0.01]
overlap = 0.8; //[0.2:1.6:0.01]
blend_R = 0.35; //[0.15:0.8:0.01]
asym_trim_X = 0.9; //[0.3:1.8:0.01]
asym_trim_Y = 0.6; //[0.2:1.2:0.01]

// Base shapes
module central_hub_prism() {
  translate([0, 0, 0])
    cube([hub_X, hub_Y, hub_Z], center=true);
}

module radial_arm_east() {
  translate([hub_X/2 + (arm_L_cardinal + overlap)/2 - overlap, 0, 0])
    cube([arm_L_cardinal + overlap, arm_W, arm_thk_Z], center=true);
}

module radial_arm_west() {
  translate([-(hub_X/2 + (arm_L_cardinal + overlap)/2 - overlap), 0, 0])
    cube([arm_L_cardinal + overlap, arm_W, arm_thk_Z], center=true);
}

module radial_arm_north() {
  translate([0, hub_Y/2 + (arm_L_cardinal + overlap)/2 - overlap, 0])
    cube([arm_W, arm_L_cardinal + overlap, arm_thk_Z], center=true);
}

module radial_arm_south() {
  translate([0, -(hub_Y/2 + (arm_L_cardinal + overlap)/2 - overlap), 0])
    cube([arm_W, arm_L_cardinal + overlap, arm_thk_Z], center=true);
}

module radial_arm_ne_raw() {
  translate([hub_X/2 + (arm_L_diag + overlap)/2 - overlap, hub_Y/2 + arm_W_diag/2 - overlap, 0])
    cube([arm_L_diag + overlap, arm_W_diag, arm_thk_Z], center=true);
}

module radial_arm_nw_raw() {
  translate([-(hub_X/2 + (arm_L_diag + overlap)/2 - overlap), hub_Y/2 + arm_W_diag/2 - overlap, 0])
    cube([arm_L_diag + overlap, arm_W_diag, arm_thk_Z], center=true);
}

module radial_arm_se_raw() {
  translate([hub_X/2 + (arm_L_diag + overlap)/2 - overlap, -(hub_Y/2 + arm_W_diag/2 - overlap), 0])
    cube([arm_L_diag + overlap, arm_W_diag, arm_thk_Z], center=true);
}

module radial_arm_sw_raw() {
  translate([-(hub_X/2 + (arm_L_diag + overlap)/2 - overlap), -(hub_Y/2 + arm_W_diag/2 - overlap), 0])
    cube([arm_L_diag + overlap, arm_W_diag, arm_thk_Z], center=true);
}

module arm_end_rounding_sphere_e() {
  translate([hub_X/2 + arm_L_cardinal - fillet_R_arm_end, 0, 0])
    sphere(r=fillet_R_arm_end);
}

module arm_end_rounding_sphere_n() {
  translate([0, hub_Y/2 + arm_L_cardinal - fillet_R_arm_end, 0])
    sphere(r=fillet_R_arm_end);
}

module arm_end_rounding_sphere_ne() {
  translate([hub_X/2 + arm_L_diag - fillet_R_arm_end, hub_Y/2 + arm_W_diag - fillet_R_arm_end, 0])
    sphere(r=fillet_R_arm_end);
}

module hub_corner_rounding_sphere_ne() {
  translate([hub_X/2 - fillet_R_hub_corner, hub_Y/2 - fillet_R_hub_corner, 0])
    sphere(r=fillet_R_hub_corner);
}

module hub_corner_rounding_sphere_nw() {
  translate([-(hub_X/2 - fillet_R_hub_corner), hub_Y/2 - fillet_R_hub_corner, 0])
    sphere(r=fillet_R_hub_corner);
}

module hub_corner_rounding_sphere_se() {
  translate([hub_X/2 - fillet_R_hub_corner, -(hub_Y/2 - fillet_R_hub_corner), 0])
    sphere(r=fillet_R_hub_corner);
}

module hub_corner_rounding_sphere_sw() {
  translate([-(hub_X/2 - fillet_R_hub_corner), -(hub_Y/2 - fillet_R_hub_corner), 0])
    sphere(r=fillet_R_hub_corner);
}

module selective_asymmetric_rounding_variation_trim_box() {
  translate([asym_trim_X/2, asym_trim_Y/2, 0])
    cube([bbox_X, bbox_Y, bbox_Z], center=true);
}

module subtle_molded_blend_transitions_sphere() {
  sphere(r=blend_R);
}

// Operations
module radial_arm_ne_rot() {
  rotate([0, 0, 45]) radial_arm_ne_raw();
}

module radial_arm_nw_rot() {
  rotate([0, 0, 135]) radial_arm_nw_raw();
}

module radial_arm_se_rot() {
  rotate([0, 0, -45]) radial_arm_se_raw();
}

module radial_arm_sw_rot() {
  rotate([0, 0, -135]) radial_arm_sw_raw();
}

module star_core_union() {
  union() {
    central_hub_prism();
    radial_arm_north();
    radial_arm_south();
    radial_arm_east();
    radial_arm_west();
    radial_arm_ne_rot();
    radial_arm_nw_rot();
    radial_arm_se_rot();
    radial_arm_sw_rot();
  }
}

module arm_end_rounding_hull_e() {
  hull() {
    radial_arm_east();
    arm_end_rounding_sphere_e();
  }
}

module arm_end_rounding_hull_n() {
  hull() {
    radial_arm_north();
    arm_end_rounding_sphere_n();
  }
}

module arm_end_rounding_hull_ne() {
  hull() {
    radial_arm_ne_rot();
    arm_end_rounding_sphere_ne();
  }
}

module hub_corner_rounding_hull_ne() {
  hull() {
    central_hub_prism();
    hub_corner_rounding_sphere_ne();
  }
}

module hub_corner_rounding_hull_nw() {
  hull() {
    central_hub_prism();
    hub_corner_rounding_sphere_nw();
  }
}

module hub_corner_rounding_hull_se() {
  hull() {
    central_hub_prism();
    hub_corner_rounding_sphere_se();
  }
}

module hub_corner_rounding_hull_sw() {
  hull() {
    central_hub_prism();
    hub_corner_rounding_sphere_sw();
  }
}

module arm_end_rounding() {
  union() {
    arm_end_rounding_hull_e();
    arm_end_rounding_hull_n();
    arm_end_rounding_hull_ne();
  }
}

module hub_corner_rounding() {
  union() {
    hub_corner_rounding_hull_ne();
    hub_corner_rounding_hull_nw();
    hub_corner_rounding_hull_se();
    hub_corner_rounding_hull_sw();
  }
}

module rounded_star_union() {
  union() {
    star_core_union();
    arm_end_rounding();
    hub_corner_rounding();
  }
}

module selective_asymmetric_rounding_variation() {
  intersection() {
    rounded_star_union();
    selective_asymmetric_rounding_variation_trim_box();
  }
}

module subtle_molded_blend_transitions() {
  minkowski() {
    selective_asymmetric_rounding_variation();
    subtle_molded_blend_transitions_sphere();
  }
}

// Final output
subtle_molded_blend_transitions();