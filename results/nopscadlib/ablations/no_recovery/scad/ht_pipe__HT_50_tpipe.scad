// Parameters
nominal_diameter_mm = 50; //[25:100:1]
bore_inner_diameter_mm = 50; //[25:100:1]
wall_thickness_mm = 2; //[1:4:0.1]
main_run_length_mm = 150; //[75:300:1]
branch_length_mm = 100; //[50:200:1]
socket_depth_mm = 40; //[20:80:1]
socket_outer_diameter_mm = 56; //[50:80:0.5]
branch_angle_deg = 90; //[45:90:1]
fillet_radius_mm = 2; //[0.5:6:0.5]
overlap_mm = 1; //[0.5:2:0.1]
main_outer_diameter_mm = 54; //[50:70:0.5]
branch_outer_diameter_mm = 54; //[50:70:0.5]
socket_inner_diameter_mm = 50.5; //[50:55:0.1]

// Module for HT Pipe
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main outer body
    rotate([0, 90, 0])
      cylinder(r=main_outer_diameter_mm/2, h=main_run_length_mm, center=true);

    // Branch outer body
    rotate([90, 0, 0])
      cylinder(r=branch_outer_diameter_mm/2, h=branch_length_mm, center=true);

    // Socket ends
    translate([-(main_run_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=socket_outer_diameter_mm/2, h=socket_depth_mm, center=true);

    translate([(main_run_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0, 0])
      rotate([0, 90, 0])
      cylinder(r=socket_outer_diameter_mm/2, h=socket_depth_mm, center=true);

    translate([0, (branch_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0])
      rotate([90, 0, 0])
      cylinder(r=socket_outer_diameter_mm/2, h=socket_depth_mm, center=true);

    // Intersection blend
    hull() {
      sphere(r=main_outer_diameter_mm/2 + fillet_radius_mm, center=true);
      sphere(r=branch_outer_diameter_mm/2 + fillet_radius_mm, center=true);
    }

    // Internal bore
    difference() {
      union() {
        rotate([0, 90, 0])
          cylinder(r=bore_inner_diameter_mm/2, h=main_run_length_mm + 2*overlap_mm, center=true);

        rotate([90, 0, 0])
          cylinder(r=bore_inner_diameter_mm/2, h=branch_length_mm + 2*overlap_mm, center=true);
      }

      // Socket voids
      translate([-(main_run_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0, 0])
        rotate([0, 90, 0])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true);

      translate([(main_run_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0, 0])
        rotate([0, 90, 0])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true);

      translate([0, (branch_length_mm/2 - socket_depth_mm/2 + overlap_mm), 0])
        rotate([90, 0, 0])
        cylinder(r=socket_inner_diameter_mm/2, h=socket_depth_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  ht_pipe();
}

assembly();