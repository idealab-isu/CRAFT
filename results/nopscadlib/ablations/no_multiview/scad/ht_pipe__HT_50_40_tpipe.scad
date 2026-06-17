// Parameters
main_nominal_diameter_mm = 50; //[25:100:1]
branch_nominal_diameter_mm = 40; //[20:80:1]
main_axis_length_mm = 120; //[60:240:1]
branch_axis_length_mm = 80; //[40:160:1]
wall_thickness_mm = 2.5; //[1.25:5:0.1]
socket_insertion_depth_main_mm = 35; //[18:70:1]
socket_insertion_depth_branch_mm = 30; //[15:60:1]
junction_radius_mm = 8; //[4:16:0.5]
end_chamfer_mm = 1; //[0.5:3:0.1]
overlap_mm = 1; //[0.5:2:0.1]
stop_thickness_mm = 2; //[1:4:0.1]
stop_radial_mm = 1.5; //[0.8:3:0.1]
ht_pipe_length_mm = 60; //[30:150:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      translate([main_axis_length_mm/2 + ht_pipe_length_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=main_nominal_diameter_mm/2, h=ht_pipe_length_mm, center=true);
      // Inner bore
      translate([main_axis_length_mm/2 + ht_pipe_length_mm/2 - overlap_mm, 0, 0])
        rotate([0, 90, 0])
        cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm, h=ht_pipe_length_mm + 2*overlap_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      union() {
        // Main run socket
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=main_nominal_diameter_mm/2, h=main_axis_length_mm, center=true);
        // Branch socket
        translate([0, 0, 0])
          rotate([90, 0, 0])
          cylinder(r=branch_nominal_diameter_mm/2, h=branch_axis_length_mm, center=true);
        // Junction blend
        hull() {
          sphere(r=max(main_nominal_diameter_mm, branch_nominal_diameter_mm)/2 + junction_radius_mm, center=true);
          translate([0, 0, 0])
            rotate([0, 90, 0])
            cylinder(r=main_nominal_diameter_mm/2, h=main_axis_length_mm, center=true);
          translate([0, 0, 0])
            rotate([90, 0, 0])
            cylinder(r=branch_nominal_diameter_mm/2, h=branch_axis_length_mm, center=true);
        }
        // Socket stops
        difference() {
          translate([-(main_axis_length_mm/2 - socket_insertion_depth_main_mm + stop_thickness_mm/2), 0, 0])
            rotate([0, 90, 0])
            cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm, h=stop_thickness_mm, center=true);
          translate([-(main_axis_length_mm/2 - socket_insertion_depth_main_mm + stop_thickness_mm/2), 0, 0])
            rotate([0, 90, 0])
            cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm - stop_radial_mm, h=stop_thickness_mm + 2*overlap_mm, center=true);
        }
        difference() {
          translate([(main_axis_length_mm/2 - socket_insertion_depth_main_mm + stop_thickness_mm/2), 0, 0])
            rotate([0, 90, 0])
            cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm, h=stop_thickness_mm, center=true);
          translate([(main_axis_length_mm/2 - socket_insertion_depth_main_mm + stop_thickness_mm/2), 0, 0])
            rotate([0, 90, 0])
            cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm - stop_radial_mm, h=stop_thickness_mm + 2*overlap_mm, center=true);
        }
        difference() {
          translate([0, (branch_axis_length_mm/2 - socket_insertion_depth_branch_mm + stop_thickness_mm/2), 0])
            rotate([90, 0, 0])
            cylinder(r=branch_nominal_diameter_mm/2 - wall_thickness_mm, h=stop_thickness_mm, center=true);
          translate([0, (branch_axis_length_mm/2 - socket_insertion_depth_branch_mm + stop_thickness_mm/2), 0])
            rotate([90, 0, 0])
            cylinder(r=branch_nominal_diameter_mm/2 - wall_thickness_mm - stop_radial_mm, h=stop_thickness_mm + 2*overlap_mm, center=true);
        }
      }
      // Internal flow bore
      union() {
        translate([0, 0, 0])
          rotate([0, 90, 0])
          cylinder(r=main_nominal_diameter_mm/2 - wall_thickness_mm, h=main_axis_length_mm + 2*overlap_mm, center=true);
        translate([0, 0, 0])
          rotate([90, 0, 0])
          cylinder(r=branch_nominal_diameter_mm/2 - wall_thickness_mm, h=branch_axis_length_mm + 2*overlap_mm, center=true);
      }
      // End chamfers
      translate([-(main_axis_length_mm/2 - end_chamfer_mm/2), 0, 0])
        rotate([0, 90, 0])
        cylinder(r1=main_nominal_diameter_mm/2, r2=main_nominal_diameter_mm/2 - end_chamfer_mm, h=end_chamfer_mm, center=true);
      translate([(main_axis_length_mm/2 - end_chamfer_mm/2), 0, 0])
        rotate([0, -90, 0])
        cylinder(r1=main_nominal_diameter_mm/2, r2=main_nominal_diameter_mm/2 - end_chamfer_mm, h=end_chamfer_mm, center=true);
      translate([0, (branch_axis_length_mm/2 - end_chamfer_mm/2), 0])
        rotate([90, 0, 0])
        cylinder(r1=branch_nominal_diameter_mm/2, r2=branch_nominal_diameter_mm/2 - end_chamfer_mm, h=end_chamfer_mm, center=true);
    }
  }
  // HT Pipe
  ht_pipe();
}

assembly();