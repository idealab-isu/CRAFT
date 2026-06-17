// Parameters
face_W = 42.3; //[21.15:84.6:0.1]
body_L = 47; //[23.5:94:0.1]
body_W = 42.3; //[21.15:84.6:0.1]
body_H = 42.3; //[21.15:84.6:0.1]
front_face_thk = 3; //[1.5:6:0.1]
shaft_D = 5; //[2.5:10:0.1]
shaft_L = 20; //[10:40:0.1]
pilot_D = 22; //[11:44:0.1]
pilot_H = 2; //[1:4:0.1]
mount_spacing = 31; //[15.5:62:0.1]
mount_hole_D = 3.5; //[2:7:0.1]
mount_counterbore_D = 6.5; //[3.5:13:0.1]
mount_counterbore_depth = 2; //[0.5:4:0.1]
rear_cap_thk = 2.5; //[1:5:0.1]
rear_cap_margin = 1.2; //[0.5:3:0.1]
connector_W = 14; //[7:28:0.1]
connector_H = 8; //[4:16:0.1]
connector_L = 6; //[3:12:0.1]
connector_offset_Y = 0; //[-10:10:0.1]
edge_chamfer = 1; //[0:2.5:0.1]
shaft_flat_depth = 0.6; //[0:1.5:0.05]
shaft_flat_width = 3; //[0:6:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module motor_body() {
  cube([body_W, body_H, body_L], center=true);
}

module front_face() {
  translate([0, 0, body_L/2 + front_face_thk/2 - overlap])
    cube([face_W, face_W, front_face_thk], center=true);
}

module front_pilot_boss() {
  translate([0, 0, body_L/2 + front_face_thk - overlap + pilot_H/2])
    cylinder(r=pilot_D/2, h=pilot_H, center=true);
}

module output_shaft() {
  translate([0, 0, body_L/2 + front_face_thk - overlap + shaft_L/2])
    cylinder(r=shaft_D/2, h=shaft_L, center=true);
}

module rear_cap_detail() {
  translate([0, 0, -body_L/2 - rear_cap_thk/2 + overlap])
    cube([body_W - 2*rear_cap_margin, body_H - 2*rear_cap_margin, rear_cap_thk], center=true);
}

module connector_bump() {
  translate([0, connector_offset_Y, -body_L/2 - connector_L/2 + overlap])
    cube([connector_W, connector_H, connector_L], center=true);
}

module mount_hole(x, y) {
  translate([x, y, body_L/2 + front_face_thk/2 - overlap])
    cylinder(r=mount_hole_D/2, h=front_face_thk + 2*overlap, center=true);
}

module mount_cb(x, y) {
  translate([x, y, body_L/2 + front_face_thk - overlap - mount_counterbore_depth/2])
    cylinder(r=mount_counterbore_D/2, h=mount_counterbore_depth + overlap, center=true);
}

module shaft_flat_cut() {
  translate([shaft_D/2 - shaft_flat_depth + overlap, 0, body_L/2 + front_face_thk - overlap + shaft_L/2])
    cube([shaft_D + 2*overlap, shaft_flat_width, shaft_L + 2*overlap], center=true);
}

module chamfer_cut_corner(x, y) {
  translate([x, y, 0])
    rotate([0, 0, 45])
    cube([edge_chamfer, edge_chamfer, body_L + 2*front_face_thk + 2*pilot_H + 2*shaft_L], center=true);
}

// Operations
module mounting_hole_pattern() {
  union() {
    mount_hole(mount_spacing/2, mount_spacing/2);
    mount_hole(-mount_spacing/2, mount_spacing/2);
    mount_hole(-mount_spacing/2, -mount_spacing/2);
    mount_hole(mount_spacing/2, -mount_spacing/2);
  }
}

module mounting_hole_counterbore() {
  union() {
    mount_cb(mount_spacing/2, mount_spacing/2);
    mount_cb(-mount_spacing/2, mount_spacing/2);
    mount_cb(-mount_spacing/2, -mount_spacing/2);
    mount_cb(mount_spacing/2, -mount_spacing/2);
  }
}

module motor_solid_raw() {
  union() {
    motor_body();
    front_face();
    front_pilot_boss();
    output_shaft();
    rear_cap_detail();
    connector_bump();
  }
}

module motor_with_holes() {
  difference() {
    motor_solid_raw();
    mounting_hole_pattern();
    mounting_hole_counterbore();
  }
}

module shaft_flat_or_key_optional_interface() {
  difference() {
    motor_with_holes();
    shaft_flat_cut();
  }
}

module chamfers_fillets() {
  difference() {
    shaft_flat_or_key_optional_interface();
    chamfer_cut_corner(body_W/2 - edge_chamfer/2, body_H/2 - edge_chamfer/2);
    chamfer_cut_corner(-body_W/2 + edge_chamfer/2, body_H/2 - edge_chamfer/2);
    chamfer_cut_corner(-body_W/2 + edge_chamfer/2, -body_H/2 + edge_chamfer/2);
    chamfer_cut_corner(body_W/2 - edge_chamfer/2, -body_H/2 + edge_chamfer/2);
  }
}

// Final Output
chamfers_fillets();