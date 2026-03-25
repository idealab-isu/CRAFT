// Parameters
H = 115; //[60:230:1]
OD_x = 45; //[22.5:90:0.01]
OD_y = 44.62; //[22.31:89.24:0.01]
OD = 44.62; //[22.31:89.24:0.01]
bore_D = 24; //[12:48:0.01]
wall_min = 3; //[1.5:6:0.1]
notch_count = 6; //[2:24:1]
notch_w = 8; //[3:16:0.1]
notch_h = 20; //[5:60:0.1]
notch_depth = 6; //[1:12:0.1]
notch_z0 = 10; //[0:40:0.1]
notch_z1 = 105; //[60:115:0.1]
notch_angle_offset = 0; //[0:359:1]
split_gap = 1; //[0.2:3:0.1]
keyway_w = 6; //[2:12:0.1]
keyway_depth = 2.5; //[0.5:6:0.1]
edge_fillet_r = 0.8; //[0.2:2:0.1]
relief_r = 0.8; //[0.3:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module outer_sleeve_body() {
  cylinder(h=H, r=OD/2, center=true);
}

module central_through_bore() {
  cylinder(h=H + 2*overlap, r=bore_D/2, center=true);
}

module notch_cutter_base() {
  translate([OD/2 - wall_min + (notch_depth + OD/2)/2 - overlap, 0, -H/2 + notch_z0 + (notch_z1 - notch_z0)/2])
    cube([notch_depth + OD/2, notch_w, notch_h], center=true);
}

module notch_relief_sphere() {
  sphere(r=relief_r, center=true);
}

module split_line_gap() {
  cube([OD + 2*overlap, split_gap, H + 2*overlap], center=true);
}

module keyway_slot_variant() {
  translate([bore_D/2 - keyway_depth/2 + overlap/2, 0, 0])
    cube([keyway_depth + overlap, keyway_w, H + 2*overlap], center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

module overall_height_constraint() {
  cube([OD, OD, H], center=true);
}

// Operations
module notch_cutter_relief() {
  minkowski() {
    notch_cutter_base();
    notch_relief_sphere();
  }
}

module circumferential_rectangular_notches_array() {
  union() {
    for (i = [0:notch_count-1]) {
      rotate([0, 0, notch_angle_offset + i*(360/notch_count)])
        notch_cutter_relief();
    }
  }
}

module notch_depth_control_to_preserve_wall_thickness() {
  difference() {
    outer_sleeve_body();
    central_through_bore();
    circumferential_rectangular_notches_array();
    split_line_gap();
    keyway_slot_variant();
  }
}

module chamfers_or_fillets_on_edges() {
  minkowski() {
    notch_depth_control_to_preserve_wall_thickness();
    edge_fillet_sphere();
  }
}

module final_model() {
  intersection() {
    chamfers_or_fillets_on_edges();
    overall_height_constraint();
  }
}

// Final Output
final_model();