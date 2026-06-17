// Parameters
plate_L = 300; //[150:600:1]
plate_W = 200; //[100:400:1]
plate_T = 12; //[6:24:1]
corner_radius = 10; //[5:20:1]
chamfer_leg = 6; //[3:12:1]
hole_d = 10; //[5:20:1]
edge_margin_x = 25; //[12:60:1]
edge_margin_y = 20; //[10:50:1]
hole_pitch_x = 100; //[50:200:1]
hole_pitch_y = 80; //[40:160:1]
hole_cols = 3; //[2:6:1]
hole_rows = 2; //[2:6:1]
overlap = 1; //[0.5:2:0.5]

// Base shapes
module tooling_plate_body() {
  translate([0, 0, 0])
    cube([plate_L, plate_W, plate_T], center=true);
}

module rounded_corner_cyl(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=plate_T + 2*overlap, center=true);
}

module corner_cut_box(x, y) {
  translate([x, y, 0])
    cube([corner_radius*2, corner_radius*2, plate_T + 2*overlap], center=true);
}

module chamfer_cut(x, y) {
  translate([x, y, 0])
    rotate([0, 0, 45])
      cube([chamfer_leg*2, chamfer_leg*2, plate_T + 2*overlap], center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=hole_d/2, h=plate_T + 2*overlap, center=true);
}

// Operations
module rounded_corners() {
  difference() {
    union() {
      corner_cut_box(plate_L/2 - corner_radius, plate_W/2 - corner_radius);
      corner_cut_box(plate_L/2 - corner_radius, -plate_W/2 + corner_radius);
      corner_cut_box(-plate_L/2 + corner_radius, plate_W/2 - corner_radius);
      corner_cut_box(-plate_L/2 + corner_radius, -plate_W/2 + corner_radius);
    }
    union() {
      rounded_corner_cyl(plate_L/2 - corner_radius, plate_W/2 - corner_radius);
      rounded_corner_cyl(plate_L/2 - corner_radius, -plate_W/2 + corner_radius);
      rounded_corner_cyl(-plate_L/2 + corner_radius, plate_W/2 - corner_radius);
      rounded_corner_cyl(-plate_L/2 + corner_radius, -plate_W/2 + corner_radius);
    }
  }
}

module corner_chamfers() {
  union() {
    chamfer_cut(plate_L/2 - chamfer_leg, plate_W/2 - chamfer_leg);
    chamfer_cut(plate_L/2 - chamfer_leg, -plate_W/2 + chamfer_leg);
    chamfer_cut(-plate_L/2 + chamfer_leg, plate_W/2 - chamfer_leg);
    chamfer_cut(-plate_L/2 + chamfer_leg, -plate_W/2 + chamfer_leg);
  }
}

module mounting_holes_pattern() {
  union() {
    for (i = [0:hole_cols-1]) {
      for (j = [0:hole_rows-1]) {
        mount_hole(
          -(edge_margin_x + (hole_cols-1)*hole_pitch_x/2) + i*hole_pitch_x,
          -(edge_margin_y + (hole_rows-1)*hole_pitch_y/2) + j*hole_pitch_y
        );
      }
    }
  }
}

// Final model
module complete_model() {
  difference() {
    difference() {
      difference() {
        tooling_plate_body();
        rounded_corners();
      }
      corner_chamfers();
    }
    mounting_holes_pattern();
  }
}

// Render the complete model
color("Silver") complete_model();