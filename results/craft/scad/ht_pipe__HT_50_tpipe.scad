// Parameters
nominal_diameter_mm = 50; //[25:100:1]
outer_diameter_mm = 50; //[25:100:0.5]
inner_diameter_mm = 45; //[20:95:0.5]
wall_thickness_mm = 2.5; //[1.2:6:0.1]
angle_deg = 90; //[45:90:1]
socket_depth_mm = 40; //[20:80:1]
overall_run_length_mm = 140; //[80:280:1]
branch_length_mm = 90; //[50:180:1]
socket_wall_extra_mm = 1.5; //[0.5:4:0.1]
center_bulge_length_mm = 30; //[15:80:1]
center_bulge_extra_radius_mm = 4; //[1:12:0.5]
chamfer_depth_mm = 2; //[0.5:6:0.1]
chamfer_extra_radius_mm = 1.5; //[0.5:5:0.1]
overlap_mm = 1; //[0.5:2:0.1]
ht_pipe_length_mm = 120; //[60:240:1]
ht_pipe_insert_mm = 25; //[5:60:1]
R_od = 25; //[12.5:50:0.5]
R_id = 22.5; //[10:47.5:0.5]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Outer pipe
    difference() {
      cylinder(r=outer_diameter_mm/2, h=ht_pipe_length_mm, center=true, $fn=64);
      // Inner bore
      translate([0, 0, -overlap_mm])
        cylinder(r=inner_diameter_mm/2, h=ht_pipe_length_mm + 2*overlap_mm, center=true, $fn=64);
    }
  }
}

// Tee Body - complete geometry
module tee_body_with_bores() {
  color([0.75, 0.75, 0.77]) {
    difference() {
      union() {
        // Main run
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=outer_diameter_mm/2, h=overall_run_length_mm, center=true, $fn=64);
        // Branch
        translate([0, 0, branch_length_mm/2 - overlap_mm])
          cylinder(r=outer_diameter_mm/2, h=branch_length_mm, center=true, $fn=64);
        // Center bulge
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=outer_diameter_mm/2 + center_bulge_extra_radius_mm, h=center_bulge_length_mm, center=true, $fn=64);
        // Left socket
        translate([-overall_run_length_mm/2 + socket_depth_mm/2 - overlap_mm, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=outer_diameter_mm/2 + socket_wall_extra_mm, h=socket_depth_mm, center=true, $fn=64);
        // Right socket
        translate([overall_run_length_mm/2 - socket_depth_mm/2 + overlap_mm, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=outer_diameter_mm/2 + socket_wall_extra_mm, h=socket_depth_mm, center=true, $fn=64);
        // Branch socket
        translate([0, 0, branch_length_mm - socket_depth_mm/2 + overlap_mm])
          cylinder(r=outer_diameter_mm/2 + socket_wall_extra_mm, h=socket_depth_mm, center=true, $fn=64);
      }
      // Internal flow channel
      union() {
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=inner_diameter_mm/2, h=overall_run_length_mm + 2*overlap_mm, center=true, $fn=64);
        translate([0, 0, branch_length_mm/2 - overlap_mm])
          cylinder(r=inner_diameter_mm/2, h=branch_length_mm + 2*overlap_mm, center=true, $fn=64);
      }
      // Socket bores
      translate([-overall_run_length_mm/2 + socket_depth_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=outer_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true, $fn=64);
      translate([overall_run_length_mm/2 - socket_depth_mm/2 + overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=outer_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true, $fn=64);
      translate([0, 0, branch_length_mm - socket_depth_mm/2 + overlap_mm])
        cylinder(r=outer_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true, $fn=64);
      // Chamfers
      translate([-overall_run_length_mm/2 + chamfer_depth_mm/2, 0, 0])
        rotate([0, 90, 0])
        cylinder(r1=outer_diameter_mm/2 + chamfer_extra_radius_mm, r2=outer_diameter_mm/2, h=chamfer_depth_mm, center=true, $fn=64);
      translate([overall_run_length_mm/2 - chamfer_depth_mm/2, 0, 0])
        rotate([0, -90, 0])
        cylinder(r1=outer_diameter_mm/2 + chamfer_extra_radius_mm, r2=outer_diameter_mm/2, h=chamfer_depth_mm, center=true, $fn=64);
      translate([0, 0, branch_length_mm - chamfer_depth_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=outer_diameter_mm/2 + chamfer_extra_radius_mm, r2=outer_diameter_mm/2, h=chamfer_depth_mm, center=true, $fn=64);
    }
  }
}

// Assembly
module assembly() {
  tee_body_with_bores();
  translate([-overall_run_length_mm/2 - ht_pipe_length_mm/2 + ht_pipe_insert_mm, 0, 0])
    rotate([0, 90, 0])
    ht_pipe();
  translate([overall_run_length_mm/2 + ht_pipe_length_mm/2 - ht_pipe_insert_mm, 0, 0])
    rotate([0, 90, 0])
    ht_pipe();
  translate([0, 0, branch_length_mm + ht_pipe_length_mm/2 - ht_pipe_insert_mm])
    ht_pipe();
}

assembly();