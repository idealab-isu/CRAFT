// Parameters
bbox_X = 60.0; //[30.0:120.0:0.01]
bbox_Y = 59.56; //[29.78:119.12:0.01]
thickness_Z = 11.8; //[5.9:23.6:0.01]
outer_Rx = 30.0; //[15.0:60.0:0.01]
outer_Ry = 29.78; //[14.89:59.56:0.01]
bore_d = 40.0; //[20.0:80.0:0.01]
notch_count = 8; //[2:24:1]
notch_width_tangential = 6.0; //[3.0:12.0:0.01]
notch_depth_radial = 4.0; //[2.0:8.0:0.01]
notch_overlap = 1.0; //[0.5:2.0:0.01]
outer_scale_x = 1.0; //[0.8:1.2:0.0001]
outer_scale_y = 1.0; //[0.8:1.2:0.0001]
edge_chamfer = 0.8; //[0.0:2.0:0.01]
edge_fillet = 0.6; //[0.0:2.0:0.01]
engrave_depth = 0.4; //[0.0:1.5:0.01]

// Base Shapes
module outer_annulus_body_raw() {
  cylinder(r=outer_Rx, h=thickness_Z, center=true);
}

module central_through_bore() {
  cylinder(r=bore_d/2, h=thickness_Z + 2*notch_overlap, center=true);
}

module notch_cutter_base() {
  translate([bore_d/2 + (notch_depth_radial + notch_overlap)/2 - notch_overlap, 0, 0])
    cube([notch_depth_radial + notch_overlap, notch_width_tangential, thickness_Z + 2*notch_overlap], center=true);
}

module edge_round_sphere() {
  sphere(r=edge_fillet, center=true);
}

// Operations
module outer_profile_xy_scaling_to_match_60_00x59_56() {
  scale([outer_scale_x*(bbox_X/(2*outer_Rx)), outer_scale_y*(bbox_Y/(2*outer_Ry)), 1])
    outer_annulus_body_raw();
}

module outer_annulus_body() {
  difference() {
    outer_profile_xy_scaling_to_match_60_00x59_56();
    central_through_bore();
  }
}

module inner_circumference_rectangular_notches() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, i*(360/notch_count)])
        notch_cutter_base();
    }
  }
}

module even_angular_patterning_of_notches() {
  difference() {
    outer_annulus_body();
    inner_circumference_rectangular_notches();
  }
}

module edge_fillets() {
  minkowski() {
    even_angular_patterning_of_notches();
    edge_round_sphere();
  }
}

module edge_chamfers() {
  union() {
    edge_fillets();
  }
}

// Final Output
edge_chamfers();