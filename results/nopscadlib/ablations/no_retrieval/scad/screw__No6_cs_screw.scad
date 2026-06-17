// Parameters
screw_length = 10.0; //[5.0:20.0:0.5]
shank_diameter = 3.5; //[1.75:7.0:0.1]
head_diameter = 7.0; //[3.5:14.0:0.1]
head_height = 2.5; //[1.25:5.0:0.1]
thread_length = 8.0; //[4.0:16.0:0.5]
transition_height = 0.5; //[0.25:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
drive_recess_diameter = 3.0; //[1.5:5.5:0.1]
drive_recess_depth = 1.5; //[0.5:2.4:0.1]
tip_chamfer_height = 1.0; //[0.5:2.0:0.1]
thread_detail_ridge_height = 0.25; //[0.1:0.6:0.05]
thread_detail_ridge_count = 6.0; //[2.0:16.0:1.0]
thread_detail_ridge_thickness = 0.6; //[0.3:1.2:0.1]
fillet_radius = 0.4; //[0.2:1.0:0.05]

// Base shapes
module head() {
  translate([0, 0, screw_length/2 - head_height/2])
    cylinder(h=head_height, r=head_diameter/2, center=true);
}

module shank() {
  translate([0, 0, -screw_length/2 + (screw_length - head_height)/2])
    cylinder(h=screw_length - head_height, r=shank_diameter/2, center=true);
}

module thread_representation() {
  translate([0, 0, -screw_length/2 + thread_length/2])
    cylinder(h=thread_length, r=shank_diameter/2, center=true);
}

module head_to_shank_transition() {
  translate([0, 0, screw_length/2 - head_height - transition_height/2 + overlap/2])
    cylinder(h=transition_height, r1=head_diameter/2, r2=shank_diameter/2, center=true);
}

module tip_chamfer() {
  translate([0, 0, -screw_length/2 + tip_chamfer_height/2 - overlap/2])
    cylinder(h=tip_chamfer_height, r1=shank_diameter/2, r2=0, center=true);
}

module drive_recess() {
  translate([0, 0, screw_length/2 - (drive_recess_depth + overlap)/2])
    cylinder(h=drive_recess_depth + overlap, r=drive_recess_diameter/2, center=true);
}

module fillets() {
  translate([0, 0, screw_length/2 - head_height - fillet_radius + overlap/2])
    rotate_extrude() translate([shank_diameter/2 + fillet_radius, 0, 0])
      circle(r=fillet_radius);
}

module thread_detail_ridge(pos) {
  translate([0, 0, -screw_length/2 + (thread_length/(thread_detail_ridge_count+1))*pos])
    cylinder(h=thread_detail_ridge_thickness, r=shank_diameter/2 + thread_detail_ridge_height, center=true);
}

// Thread detail
module thread_detail() {
  union() {
    thread_representation();
    for (i = [1:thread_detail_ridge_count])
      thread_detail_ridge(i);
  }
}

// Screw solid pre-recess
module screw_solid_pre_recess() {
  union() {
    shank();
    head();
    head_to_shank_transition();
    tip_chamfer();
    fillets();
    thread_detail();
  }
}

// Final screw model
difference() {
  screw_solid_pre_recess();
  drive_recess();
}