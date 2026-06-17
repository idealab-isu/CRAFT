// Dimension-calibrated (target: 107.98 x 31.00 x 3.50 mm)
scale([0.990810, 0.964492, 0.535231])
{
// Parameters
L = 107.98; //[53.99:215.96:0.01]
W = 31.0; //[15.5:62.0:0.01]
T = 3.5; //[1.75:7.0:0.01]
corner_r = 6.0; //[3.0:12.0:0.1]
main_L = 88.0; //[44.0:176.0:0.01]
ext_L = 19.98; //[9.99:39.96:0.01]
ext_W = 22.0; //[11.0:31.0:0.01]
step_offset_y = 0.0; //[-4.0:4.0:0.01]
notch_W = 12.0; //[6.0:18.0:0.01]
notch_depth = 10.0; //[5.0:18.0:0.01]
notch_inner_r = 3.0; //[1.5:6.0:0.01]
hole_d = 5.0; //[2.5:10.0:0.01]
hole_pitch_x = 18.0; //[9.0:36.0:0.01]
hole_pitch_y = 12.0; //[6.0:24.0:0.01]
hole_grid_center_x = 50.0; //[20.0:80.0:0.01]
hole_grid_center_y = 0.0; //[-5.0:5.0:0.01]
small_hole_d = 3.0; //[1.5:6.0:0.01]
small_hole_x = 14.0; //[6.0:30.0:0.01]
small_hole_y = 0.0; //[-5.0:5.0:0.01]
overlap = 1.0; //[0.5:2.0:0.1]
chamfer = 0.6; //[0.2:1.5:0.1]
pocket_depth = 1.0; //[0.5:2.0:0.1]
csk_d = 8.5; //[6.0:12.0:0.1]
csk_depth = 1.2; //[0.5:2.5:0.1]

// Base shapes
module main_rect_core() {
  translate([-L/2 + corner_r + (main_L - 2*corner_r)/2, 0, 0])
    cube([main_L - 2*corner_r, W, T], center=true);
}

module main_left_round() {
  translate([-L/2 + corner_r, 0, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module main_right_round() {
  translate([-L/2 + main_L - corner_r, 0, 0])
    cylinder(r=corner_r, h=T, center=true);
}

module extension() {
  translate([-L/2 + main_L + ext_L/2 - overlap/2, step_offset_y, 0])
    cube([ext_L + overlap, ext_W, T], center=true);
}

module step_shoulder() {
  translate([-L/2 + main_L - overlap/2, 0, 0])
    cube([overlap, W, T], center=true);
}

module notch_rect_cut() {
  translate([-L/2 + main_L + ext_L - (notch_depth + overlap)/2, step_offset_y, 0])
    cube([notch_depth + overlap, notch_W, T + 2*overlap], center=true);
}

module notch_round_cut() {
  translate([-L/2 + main_L + ext_L - notch_depth, step_offset_y, 0])
    cylinder(r=notch_inner_r, h=T + 2*overlap, center=true);
}

module hole_pattern() {
  for (x = [-hole_pitch_x/2, hole_pitch_x/2])
    for (y = [-hole_pitch_y/2, 0, hole_pitch_y/2])
      translate([-L/2 + hole_grid_center_x + x, hole_grid_center_y + y, 0])
        cylinder(r=hole_d/2, h=T + 2*overlap, center=true);
}

module small_hole() {
  translate([-L/2 + small_hole_x, small_hole_y, 0])
    cylinder(r=small_hole_d/2, h=T + 2*overlap, center=true);
}

module counterbores() {
  for (x = [-hole_pitch_x/2, hole_pitch_x/2])
    for (y = [-hole_pitch_y/2, 0, hole_pitch_y/2])
      translate([-L/2 + hole_grid_center_x + x, hole_grid_center_y + y, T/2 - (csk_depth + overlap)/2])
        cylinder(r=csk_d/2, h=csk_depth + overlap, center=true);
}

module lightening_pocket() {
  translate([-L/2 + corner_r + (main_L - 2*corner_r)/2, 0, T/2 - (pocket_depth + overlap)/2])
    cube([main_L - 2*corner_r - 2*corner_r, W - 2*corner_r, pocket_depth + overlap], center=true);
}

module chamfer_sphere() {
  sphere(r=chamfer);
}

// Operations
module plate() {
  difference() {
    union() {
      union() {
        union() {
          union() {
            main_rect_core();
            main_left_round();
            main_right_round();
          }
          step_shoulder();
        }
        extension();
      }
      difference() {
        union() {
          notch_rect_cut();
          notch_round_cut();
        }
      }
    }
    hole_pattern();
    small_hole();
    counterbores();
    lightening_pocket();
  }
}

// Final output
minkowski() {
  plate();
  chamfer_sphere();
}
}
