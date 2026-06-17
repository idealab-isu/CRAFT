// Parameters
screw_length = 10; //[5:20:0.1]
shank_diameter = 4; //[2:8:0.1]
head_diameter = 7; //[3.5:14:0.1]
head_height = 2.4; //[1.2:4.8:0.1]
tip_chamfer_height = 0.5; //[0.2:1.5:0.05]
tip_chamfer_diameter_reduction = 0.8; //[0.2:2:0.05]
overlap = 0.8; //[0.2:2:0.1]
thread_length = 6; //[3:12:0.1]
thread_diameter = 4.3; //[4.05:5.5:0.05]
recess_width = 1.2; //[0.6:2.5:0.05]
recess_length = 5.5; //[3:7.5:0.1]
recess_depth = 1.0; //[0.4:2.0:0.05]
head_edge_round_radius = 0.4; //[0.1:1.0:0.05]

// Base Shapes
module shank_cyl() {
  translate([0, 0, (screw_length - head_height) / 2])
    cylinder(h = screw_length - head_height, r = shank_diameter / 2, center = true);
}

module head_cyl() {
  translate([0, 0, screw_length - head_height / 2 - overlap / 2])
    cylinder(h = head_height, r = head_diameter / 2, center = true);
}

module tip_cone() {
  translate([0, 0, tip_chamfer_height / 2 - overlap / 2])
    cylinder(h = tip_chamfer_height, r1 = shank_diameter / 2, r2 = (shank_diameter - tip_chamfer_diameter_reduction) / 2, center = true);
}

module thread_cyl() {
  translate([0, 0, tip_chamfer_height + thread_length / 2 - overlap])
    cylinder(h = thread_length, r = thread_diameter / 2, center = true);
}

module drive_recess_box() {
  translate([0, 0, screw_length - recess_depth / 2])
    cube([recess_length, recess_width, recess_depth], center = true);
}

module head_round_sphere() {
  sphere(r = head_edge_round_radius, center = true);
}

// Operations
module screw_union_raw() {
  union() {
    shank_cyl();
    head_cyl();
    tip_cone();
    thread_cyl();
  }
}

module screw_with_recess() {
  difference() {
    screw_union_raw();
    drive_recess_box();
  }
}

module screw_head_rounded() {
  minkowski() {
    screw_with_recess();
    head_round_sphere();
  }
}

// Final Output
screw_head_rounded();