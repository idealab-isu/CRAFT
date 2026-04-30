// Parameters
seat_width = 22.0; //[11.0:44.0:0.1]
bearing_od_mm = 22.0; //[11.0:44.0:0.1]
bearing_id_mm = 8.0; //[4.0:16.0:0.1]
bearing_width_mm = 7.0; //[3.5:14.0:0.1]
print_clearance_mm = 0.2; //[0.0:0.6:0.05]
interference_fit_mm = 0.2; //[0.0:0.5:0.05]
housing_outer_diameter_mm = 30.0; //[15.0:60.0:0.1]
housing_body_length_mm = 10.0; //[5.0:20.0:0.1]
flange_outer_diameter_mm = 34.0; //[17.0:68.0:0.1]
flange_thickness_mm = 2.5; //[1.25:5.0:0.05]
seat_diameter_mm = 21.8; //[10.9:43.6:0.05]
seat_depth_mm = 7.2; //[3.6:14.4:0.1]
ear_thickness_mm = 5.0; //[2.5:10.0:0.1]
ear_radial_extension_mm = 10.0; //[5.0:20.0:0.1]
ear_width_mm = 14.0; //[7.0:28.0:0.1]
mount_hole_diameter_mm = 4.2; //[2.0:8.0:0.1]
mount_hole_center_distance_mm = 44.0; //[22.0:88.0:0.1]
chamfer_mm = 0.8; //[0.0:2.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
press_fit_feature_w_mm = 5.0; //[2.5:10.0:0.1]
press_fit_feature_h_mm = 6.0; //[3.0:12.0:0.1]

// Base Shapes
module bearing_housing_body_cyl() {
  cylinder(r=housing_outer_diameter_mm/2, h=housing_body_length_mm, center=true);
}

module axial_flange_cyl() {
  translate([0, 0, housing_body_length_mm/2 + flange_thickness_mm/2 - overlap_mm])
    cylinder(r=flange_outer_diameter_mm/2, h=flange_thickness_mm, center=true);
}

module mounting_ear_box() {
  cube([ear_radial_extension_mm + (housing_outer_diameter_mm/2), ear_width_mm, ear_thickness_mm], center=true);
}

module bearing_press_fit_seat_cyl() {
  translate([0, 0, housing_body_length_mm/2 - seat_depth_mm/2])
    cylinder(r=seat_diameter_mm/2, h=seat_depth_mm, center=true);
}

module lead_in_chamfer_cone() {
  translate([0, 0, housing_body_length_mm/2 - chamfer_mm/2])
    cylinder(r1=seat_diameter_mm/2 + chamfer_mm, r2=seat_diameter_mm/2, h=chamfer_mm, center=true);
}

module mount_hole_cyl() {
  cylinder(r=mount_hole_diameter_mm/2, h=ear_thickness_mm + 2*overlap_mm, center=true);
}

module press_fit_peg_box() {
  translate([0, 0, -housing_body_length_mm/2 - press_fit_feature_h_mm/2 + overlap_mm])
    cube([press_fit_feature_w_mm + interference_fit_mm, press_fit_feature_w_mm + interference_fit_mm, press_fit_feature_h_mm], center=true);
}

module press_fit_socket_box() {
  translate([0, 0, -housing_body_length_mm/2 + overlap_mm])
    cube([press_fit_feature_w_mm + print_clearance_mm, press_fit_feature_w_mm + print_clearance_mm, 2*(press_fit_feature_h_mm + overlap_mm)], center=true);
}

module mt3608_carrier_placeholder() {
  translate([0, 0, -housing_body_length_mm/2 + (seat_width*0.15)/2 - overlap_mm])
    cube([seat_width*0.8, seat_width*0.6, seat_width*0.15], center=true);
}

// Operations
module bearing_housing_body_with_flange() {
  union() {
    bearing_housing_body_cyl();
    axial_flange_cyl();
  }
}

module mounting_ears_pair() {
  union() {
    translate([-mount_hole_center_distance_mm/2, 0, housing_body_length_mm/2 - ear_thickness_mm/2])
      mounting_ear_box();
    translate([mount_hole_center_distance_mm/2, 0, housing_body_length_mm/2 - ear_thickness_mm/2])
      mounting_ear_box();
  }
}

module housing_plus_ears() {
  union() {
    bearing_housing_body_with_flange();
    mounting_ears_pair();
    press_fit_peg_box();
  }
}

module housing_with_cuts() {
  difference() {
    housing_plus_ears();
    bearing_press_fit_seat_cyl();
    lead_in_chamfer_cone();
    translate([-mount_hole_center_distance_mm/2, 0, housing_body_length_mm/2 - ear_thickness_mm/2])
      mount_hole_cyl();
    translate([mount_hole_center_distance_mm/2, 0, housing_body_length_mm/2 - ear_thickness_mm/2])
      mount_hole_cyl();
    press_fit_socket_box();
  }
}

// Final Output
union() {
  housing_with_cuts();
  mt3608_carrier_placeholder();
}