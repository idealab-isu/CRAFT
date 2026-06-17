// Parameters
main_diameter_mm = 50; //[25:100]
branch_diameter_mm = 40; //[20:80]
length_mm = 160; //[80:320]
branch_length_mm = 90; //[45:180]
wall_thickness_mm = 2.2; //[1.1:4.4]
branch_wall_thickness_mm = 2.0; //[1.0:4.0]
fitting_height_mm = 28; //[14:56]
fitting_od_scale = 1.18; //[1.05:1.4]
socket_depth_mm = 18; //[9:36]
socket_clearance_mm = 0.6; //[0.2:1.2]
overlap_mm = 1; //[0.5:2]

// Main HT Pipe Body
module ht_pipe_body() {
  difference() {
    cylinder(r=main_diameter_mm/2, h=length_mm, center=false);
    translate([0, 0, -overlap_mm/2])
      cylinder(r=main_diameter_mm/2 - wall_thickness_mm, h=length_mm + overlap_mm, center=false);
  }
}

// Branch Tube
module branch_tube() {
  difference() {
    translate([-(main_diameter_mm/2 - overlap_mm), 0, length_mm/2])
      rotate([0, 90, 0])
      cylinder(r=branch_diameter_mm/2, h=branch_length_mm + main_diameter_mm/2, center=false);
    translate([-(main_diameter_mm/2 - overlap_mm) - overlap_mm/2, 0, length_mm/2])
      rotate([0, 90, 0])
      cylinder(r=branch_diameter_mm/2 - branch_wall_thickness_mm, h=branch_length_mm + main_diameter_mm/2 + overlap_mm, center=false);
  }
}

// Integrated End Fitting
module integrated_end_fitting() {
  difference() {
    translate([0, 0, length_mm - overlap_mm])
      cylinder(r=(main_diameter_mm/2) * fitting_od_scale, h=fitting_height_mm, center=false);
    translate([0, 0, length_mm + fitting_height_mm - socket_depth_mm - overlap_mm/2])
      cylinder(r=main_diameter_mm/2 + socket_clearance_mm, h=socket_depth_mm + overlap_mm, center=false);
  }
}

// Complete HT Pipe Assembly
module ht_pipe() {
  union() {
    ht_pipe_body();
    branch_tube();
    integrated_end_fitting();
  }
}

// Final Assembly
module assembly() {
  color([0.85, 0.85, 0.8]) // PVC color
    ht_pipe();
}

assembly();