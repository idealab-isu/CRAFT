// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 20.0; //[10.0:40.0:0.5]
rail_H = 17.5; //[8.75:35.0:0.5]
profile_top_flat_W = 12.0; //[6.0:24.0:0.5]
profile_side_step_W = 4.0; //[2.0:8.0:0.5]
profile_step_H = 3.0; //[1.5:6.0:0.5]
hole_d = 4.2; //[2.0:8.0:0.1]
hole_csk_d = 8.0; //[4.0:16.0:0.1]
hole_csk_H = 2.5; //[1.0:6.0:0.1]
hole_pitch = 25.0; //[10.0:50.0:1]
hole_edge_offset = 12.5; //[6.0:25.0:0.5]
end_chamfer_L = 2.0; //[0.5:6.0:0.5]
edge_round_r = 0.6; //[0.2:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Rail Main Body
module rail_main_body() {
  translate([0, 0, -profile_step_H/2])
    cube([rail_L, rail_W, rail_H - profile_step_H], center=true);
}

// Rail Running Profile
module rail_running_profile() {
  rotate([0, 90, 0])
    linear_extrude(height=rail_L, center=true)
      polygon(points=[
        [-rail_W/2, -rail_H/2],
        [rail_W/2, -rail_H/2],
        [rail_W/2, rail_H/2 - profile_step_H],
        [profile_top_flat_W/2 + profile_side_step_W, rail_H/2 - profile_step_H],
        [profile_top_flat_W/2, rail_H/2],
        [-profile_top_flat_W/2, rail_H/2],
        [-profile_top_flat_W/2 - profile_side_step_W, rail_H/2 - profile_step_H],
        [-rail_W/2, rail_H/2 - profile_step_H]
      ]);
}

// Mounting Holes
module mounting_hole_through(x_offset) {
  translate([x_offset, 0, 0])
    cylinder(r=hole_d/2, h=rail_H + 2*overlap, center=true);
}

module mounting_hole_csk(x_offset) {
  translate([x_offset, 0, rail_H/2 - hole_csk_H/2])
    cylinder(r=hole_csk_d/2, h=hole_csk_H + overlap, center=true);
}

// End Chamfers
module end_chamfer(pos) {
  translate([pos * (rail_L/2 - end_chamfer_L/2), 0, 0])
    rotate([0, 0, 45])
      cube([end_chamfer_L, rail_W + 2*overlap, rail_H + 2*overlap], center=true);
}

// Edge Fillet Rounding
module edge_fillet_rounding_sphere() {
  sphere(r=edge_round_r, center=true);
}

// Rail with Features
module rail_with_features() {
  difference() {
    union() {
      rail_main_body();
      rail_running_profile();
    }
    union() {
      for (i = [0:3]) {
        mounting_hole_through(-rail_L/2 + hole_edge_offset + i*hole_pitch);
        mounting_hole_csk(-rail_L/2 + hole_edge_offset + i*hole_pitch);
      }
    }
    union() {
      end_chamfer(1);
      end_chamfer(-1);
    }
  }
}

// Final Output with Edge Rounding
minkowski() {
  rail_with_features();
  edge_fillet_rounding_sphere();
}