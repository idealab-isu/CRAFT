// Parameters
thickness = 3.25; //[1.6:6.5:0.05]
hex_af = 6.0; //[3.0:12.0:0.1]
screw_d = 4.0; //[2.0:8.0:0.1]
hole_clearance_d = 4.3; //[4.0:5.5:0.05]
body_len = 12.0; //[6.0:24.0:0.5]
body_w = 8.0; //[4.0:16.0:0.5]
t_head_w = 8.0; //[4.0:16.0:0.5]
t_neck_w = 5.0; //[2.5:10.0:0.5]
t_head_len = 12.0; //[6.0:24.0:0.5]
t_neck_len = 8.0; //[4.0:16.0:0.5]
chamfer = 0.3; //[0.1:1.0:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
hex_R = 3.464; //[1.732:6.928:0.001]
serration_depth = 0.3; //[0.1:0.8:0.05]
serration_pitch = 1.2; //[0.6:2.4:0.1]
ball_d = 2.0; //[1.0:4.0:0.1]
ball_dimple_depth = 0.6; //[0.2:1.5:0.05]
fillet_r = 0.4; //[0.2:1.2:0.05]

// Hex profile across flats
module hex_profile_across_flats() {
  linear_extrude(height=thickness, center=true) {
    polygon(points=[
      [hex_R, 0],
      [hex_R/2, hex_R*sqrt(3)/2],
      [-hex_R/2, hex_R*sqrt(3)/2],
      [-hex_R, 0],
      [-hex_R/2, -hex_R*sqrt(3)/2],
      [hex_R/2, -hex_R*sqrt(3)/2]
    ]);
  }
}

// T-nut head block
module t_nut_head_block() {
  cube([t_head_len, t_head_w, thickness], center=true);
}

// T-nut neck block
module t_nut_neck_block() {
  cube([t_neck_len, t_neck_w, thickness], center=true);
}

// Central screw hole
module central_screw_hole() {
  cylinder(r=hole_clearance_d/2, h=thickness + 2*overlap, center=true);
}

// Lead-in chamfer cutter
module lead_in_chamfer_cutter_top() {
  translate([0, 0, thickness/2 - chamfer])
    cylinder(r1=hole_clearance_d/2 + chamfer, r2=0, h=2*chamfer, center=true);
}

module lead_in_chamfer_cutter_bottom() {
  translate([0, 0, -thickness/2 + chamfer])
    rotate([180, 0, 0])
    cylinder(r1=hole_clearance_d/2 + chamfer, r2=0, h=2*chamfer, center=true);
}

// Serration notch unit
module serration_notch_unit() {
  cube([serration_pitch/2, serration_depth, thickness + 2*overlap], center=true);
}

// Spring ball dimple cutter
module spring_ball_dimple_cutter() {
  translate([t_head_len/2 - ball_d/2, 0, thickness/2 - ball_dimple_depth])
    sphere(r=ball_d/2, center=true);
}

// Engraved size marking
module engraved_size_marking() {
  translate([0, 0, thickness/2 - chamfer/2])
    cube([hex_af/2, hex_af/4, chamfer], center=true);
}

// Edge fillet sphere
module edge_fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

// Assemble T-nut
module t_nut_main_body() {
  difference() {
    intersection() {
      minkowski() {
        difference() {
          difference() {
            difference() {
              difference() {
                intersection() {
                  union() {
                    t_nut_head_block();
                    t_nut_neck_block();
                  }
                  hex_profile_across_flats();
                }
                spring_ball_dimple_cutter();
              }
              central_screw_hole();
              union() {
                lead_in_chamfer_cutter_top();
                lead_in_chamfer_cutter_bottom();
              }
            }
            union() {
              for (i = [1:5]) {
                translate([-t_head_len/2 + serration_pitch*i, t_head_w/2 - serration_depth/2, 0])
                  serration_notch_unit();
                translate([-t_head_len/2 + serration_pitch*i, -t_head_w/2 + serration_depth/2, 0])
                  serration_notch_unit();
              }
            }
          }
          engraved_size_marking();
        }
        edge_fillet_sphere();
      }
      hex_profile_across_flats();
    }
  }
}

// Final output
t_nut_main_body();