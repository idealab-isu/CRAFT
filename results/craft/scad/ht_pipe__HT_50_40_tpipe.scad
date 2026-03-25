// Parameters
main_nominal_diameter_mm = 50; //[25:100:1]
branch_nominal_diameter_mm = 40; //[20:80:1]
angle_deg = 90; //[45:90:1]
main_run_length_mm = 140; //[80:280:1]
branch_length_mm = 90; //[50:180:1]
wall_thickness_mm = 3.2; //[1.6:6.4:0.1]
socket_depth_main_mm = 35; //[20:70:1]
socket_depth_branch_mm = 30; //[15:60:1]
socket_wall_extra_mm = 1.8; //[0.8:3.6:0.1]
socket_lead_in_length_mm = 6; //[2:15:1]
socket_lead_in_radial_mm = 1.2; //[0.5:3:0.1]
fillet_radius_mm = 6; //[2:15:1]
overlap_mm = 1; //[0.5:2:0.1]
main_od_mm = 50; //[25:100:1]
branch_od_mm = 40; //[20:80:1]
main_id_mm = 43.6; //[20:95:0.1]
branch_id_mm = 33.6; //[15:75:0.1]
junction_length_main_mm = 40; //[20:80:1]
junction_length_branch_mm = 35; //[15:70:1]

// Ht Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    // Main run outer
    rotate([0, 90, 0])
    translate([0, 0, 0])
    cylinder(r=main_od_mm/2, h=main_run_length_mm, center=true);

    // Branch outer
    rotate([90, 0, 0])
    translate([0, branch_length_mm/2 - overlap_mm, 0])
    cylinder(r=branch_od_mm/2, h=branch_length_mm, center=true);

    // Main socket left outer
    rotate([0, 90, 0])
    translate([-main_run_length_mm/2 + socket_depth_main_mm/2 - overlap_mm, 0, 0])
    cylinder(r=main_od_mm/2 + socket_wall_extra_mm, h=socket_depth_main_mm, center=true);

    // Main socket right outer
    rotate([0, 90, 0])
    translate([main_run_length_mm/2 - socket_depth_main_mm/2 + overlap_mm, 0, 0])
    cylinder(r=main_od_mm/2 + socket_wall_extra_mm, h=socket_depth_main_mm, center=true);

    // Branch socket outer
    rotate([90, 0, 0])
    translate([0, branch_length_mm/2 - socket_depth_branch_mm/2 + overlap_mm, 0])
    cylinder(r=branch_od_mm/2 + socket_wall_extra_mm, h=socket_depth_branch_mm, center=true);

    // Junction blend main
    rotate([0, 90, 0])
    translate([0, 0, 0])
    cylinder(r=main_od_mm/2 + fillet_radius_mm*0.25, h=junction_length_main_mm, center=true);

    // Junction blend branch
    rotate([90, 0, 0])
    translate([0, junction_length_branch_mm/2 - overlap_mm, 0])
    cylinder(r=branch_od_mm/2 + fillet_radius_mm*0.25, h=junction_length_branch_mm, center=true);

    // Internal transition sphere
    translate([0, 0, 0])
    sphere(r=max(main_id_mm, branch_id_mm)/2 + wall_thickness_mm*0.25, center=true);
  }
}

// Assembly
module assembly() {
  difference() {
    ht_pipe();
    // Internal bores
    color("White") {
      rotate([0, 90, 0])
      translate([0, 0, 0])
      cylinder(r=main_id_mm/2, h=main_run_length_mm + 2*overlap_mm, center=true);

      rotate([90, 0, 0])
      translate([0, branch_length_mm/2 - overlap_mm, 0])
      cylinder(r=branch_id_mm/2, h=branch_length_mm + 2*overlap_mm, center=true);

      // Main socket left lead-in cut
      rotate([0, 90, 0])
      translate([-main_run_length_mm/2 + socket_lead_in_length_mm/2 - overlap_mm, 0, 0])
      cylinder(r1=main_id_mm/2 + socket_lead_in_radial_mm, r2=main_id_mm/2, h=socket_lead_in_length_mm, center=true);

      // Main socket right lead-in cut
      rotate([0, -90, 0])
      translate([main_run_length_mm/2 - socket_lead_in_length_mm/2 + overlap_mm, 0, 0])
      cylinder(r1=main_id_mm/2 + socket_lead_in_radial_mm, r2=main_id_mm/2, h=socket_lead_in_length_mm, center=true);

      // Branch socket lead-in cut
      rotate([-90, 0, 0])
      translate([0, branch_length_mm/2 - socket_lead_in_length_mm/2 + overlap_mm, 0])
      cylinder(r1=branch_id_mm/2 + socket_lead_in_radial_mm, r2=branch_id_mm/2, h=socket_lead_in_length_mm, center=true);
    }
  }
}

assembly();