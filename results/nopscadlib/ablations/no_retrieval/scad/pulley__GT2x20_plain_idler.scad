// Parameters
pulley_od = 60; //[30:120:1]
pulley_width = 20; //[10:40:1]
bore_d = 8; //[4:16:0.5]
groove_depth = 6; //[3:12:0.5]
groove_top_w = 10; //[5:20:0.5]
groove_angle_deg = 60; //[30:120:1]
flange_thk = 2; //[1:5:0.5]
hub_od = 20; //[10:40:1]
hub_width = 20; //[10:40:1]
rim_thk = 4; //[2:10:0.5]
web_thk = 4; //[2:10:0.5]
set_screw_d = 3; //[2:6:0.5]
set_screw_z = 0; //[-8:8:0.5]
keyway_w = 3; //[2:6:0.5]
keyway_h = 1.5; //[0.8:3:0.1]
light_hole_d = 10; //[6:20:1]
light_hole_count = 6; //[3:12:1]
bearing_seat_d = 12; //[8:24:0.5]
bearing_seat_depth = 6; //[2:12:0.5]
ret_ring_groove_w = 1.2; //[0.8:2.5:0.1]
ret_ring_groove_depth = 0.6; //[0.3:1.5:0.1]
ret_ring_groove_z = 7; //[2:15:0.5]
chamfer = 0.8; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module sheave_wheel() {
  cylinder(r= pulley_od/2, h= pulley_width, center=true);
}

module hub() {
  cylinder(r= hub_od/2, h= hub_width, center=true);
}

module side_flange_left() {
  translate([0, 0, -pulley_width/2 + flange_thk/2])
    cylinder(r= pulley_od/2, h= flange_thk, center=true);
}

module side_flange_right() {
  translate([0, 0, pulley_width/2 - flange_thk/2])
    cylinder(r= pulley_od/2, h= flange_thk, center=true);
}

module central_bore() {
  cylinder(r= bore_d/2, h= pulley_width + 2*overlap, center=true);
}

module groove_profile() {
  rotate_extrude() {
    polygon(points=[
      [pulley_od/2 - groove_depth, -groove_top_w/2],
      [pulley_od/2, -groove_top_w/2],
      [pulley_od/2, groove_top_w/2],
      [pulley_od/2 - groove_depth, groove_top_w/2],
      [pulley_od/2 - groove_depth, groove_top_w/2 - groove_depth*tan(groove_angle_deg/2)],
      [pulley_od/2 - groove_depth, -groove_top_w/2 + groove_depth*tan(groove_angle_deg/2)]
    ]);
  }
}

module set_screw_hole() {
  rotate([0, 90, 0])
    translate([0, 0, set_screw_z])
      cylinder(r= set_screw_d/2, h= hub_od + 2*overlap, center=true);
}

module keyway() {
  translate([bore_d/2 - keyway_h/2, 0, 0])
    cube([keyway_h + overlap, keyway_w, hub_width + 2*overlap], center=true);
}

module lightening_hole(angle) {
  translate([(hub_od/2 + (pulley_od/2 - rim_thk))/2 * cos(angle), 
             (hub_od/2 + (pulley_od/2 - rim_thk))/2 * sin(angle), 0])
    cylinder(r= light_hole_d/2, h= pulley_width + 2*overlap, center=true);
}

module bearing_seat() {
  translate([0, 0, -pulley_width/2 + (bearing_seat_depth + overlap)/2])
    cylinder(r= bearing_seat_d/2, h= bearing_seat_depth + overlap, center=true);
}

module retaining_ring_groove() {
  translate([0, 0, ret_ring_groove_z])
    cylinder(r= bore_d/2 + ret_ring_groove_depth, h= ret_ring_groove_w, center=true);
}

module chamfer_cone_front() {
  rotate([180, 0, 0])
    translate([0, 0, pulley_width/2 - (chamfer + overlap)/2])
      cylinder(r1= bore_d/2 + chamfer, r2= 0, h= chamfer + overlap, center=true);
}

module chamfer_cone_back() {
  translate([0, 0, -pulley_width/2 + (chamfer + overlap)/2])
    cylinder(r1= bore_d/2 + chamfer, r2= 0, h= chamfer + overlap, center=true);
}

// Final Assembly
difference() {
  union() {
    sheave_wheel();
    hub();
    side_flange_left();
    side_flange_right();
  }
  groove_profile();
  central_bore();
  keyway();
  set_screw_hole();
  for (i = [0:light_hole_count-1]) {
    lightening_hole(360/light_hole_count * i);
  }
  bearing_seat();
  retaining_ring_groove();
  chamfer_cone_front();
  chamfer_cone_back();
}