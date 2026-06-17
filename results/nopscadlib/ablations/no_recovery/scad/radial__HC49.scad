// Parameters
outer_radius = 10.5; //[5.25:21:0.1]
inner_radius = 3.7; //[1.85:7.4:0.1]
height = 13.5; //[6.75:27:0.1]
overlap = 1; //[0.5:2:0.1]
chamfer_height = 1.2; //[0.6:2.4:0.1]
chamfer_radial = 1.2; //[0.6:2.4:0.1]
mount_hole_count = 4; //[3:8:1]
mount_hole_radius = 1.2; //[0.6:2.4:0.1]
mount_hole_bolt_circle_radius = 7.5; //[3.75:15:0.1]
keyway_width = 2.5; //[1.25:5:0.1]
keyway_depth = 1.2; //[0.6:2.4:0.1]

// Main cylindrical body
module main_cylindrical_body() {
  cylinder(h=height, r=outer_radius, center=true);
}

// Center bore
module center_bore() {
  cylinder(h=height + 2*overlap, r=inner_radius, center=true);
}

// Chamfer cutters
module chamfer_top_cutter() {
  translate([0, 0, height/2 - chamfer_height/2 + overlap/2])
    cylinder(h=chamfer_height, r1=outer_radius + overlap, r2=0, center=true);
}

module chamfer_bottom_cutter() {
  translate([0, 0, -height/2 + chamfer_height/2 - overlap/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_height, r1=outer_radius + overlap, r2=0, center=true);
}

// Mounting holes
module mount_hole_0() {
  translate([mount_hole_bolt_circle_radius, 0, 0])
    cylinder(h=height + 2*overlap, r=mount_hole_radius, center=true);
}

module mount_hole_1() {
  translate([0, mount_hole_bolt_circle_radius, 0])
    cylinder(h=height + 2*overlap, r=mount_hole_radius, center=true);
}

module mount_hole_2() {
  translate([-mount_hole_bolt_circle_radius, 0, 0])
    cylinder(h=height + 2*overlap, r=mount_hole_radius, center=true);
}

module mount_hole_3() {
  translate([0, -mount_hole_bolt_circle_radius, 0])
    cylinder(h=height + 2*overlap, r=mount_hole_radius, center=true);
}

// Keyway slot
module keyway() {
  translate([inner_radius + (keyway_depth + overlap)/2 - overlap, 0, 0])
    cube([keyway_depth + overlap, keyway_width, height + 2*overlap], center=true);
}

// Final model
module final_model() {
  difference() {
    difference() {
      main_cylindrical_body();
      chamfer_top_cutter();
      chamfer_bottom_cutter();
    }
    union() {
      mount_hole_0();
      mount_hole_1();
      mount_hole_2();
      mount_hole_3();
    }
    center_bore();
    keyway();
  }
}

// Render the final model
color("Silver") final_model();