// Parameters
nominal_size = 75; //[50:150:1]
pipe_od = 75; //[60:110:0.5]
pipe_wall = 2.7; //[1.5:5.5:0.1]
tolerance_clearance = 0.6; //[0.2:1.5:0.1]
socket_inner_diameter = 76.2; //[70:90:0.1]
socket_depth = 45; //[25:80:1]
end_wall_thickness = 6; //[3:12:0.5]
cap_wall_thickness = 4.5; //[2.5:10:0.5]
cap_outer_diameter = 85.2; //[75:120:0.1]
cap_overall_length = 55; //[35:100:1]
stop_shoulder_thickness = 2.5; //[1:6:0.5]
stop_shoulder_radial = 2.0; //[0.8:5:0.2]
chamfer_lead_in = 1; //[0:1:1]
chamfer_size = 1.5; //[0.5:4:0.1]
rib_count = 12; //[6:24:1]
rib_radial_height = 1.2; //[0.5:3:0.1]
rib_width_tangential = 4; //[2:8:0.5]
rib_length_axial = 35; //[15:70:1]
overlap = 1; //[0.5:2:0.1]
pipe_stub_length = 80; //[40:160:1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(h=pipe_stub_length, r=pipe_od/2, center=true);
      // Inner void
      translate([0, 0, -overlap/2])
        cylinder(h=pipe_stub_length + overlap, r=(pipe_od/2) - pipe_wall, center=true);
    }
  }
}

// Cap with ribs
module cap_with_ribs() {
  color([0.2, 0.2, 0.2]) {
    difference() {
      // Cap body with end wall
      union() {
        // Outer cap body
        cylinder(h=cap_overall_length, r=cap_outer_diameter/2, center=true);
        // End wall
        translate([0, 0, cap_overall_length/2 - end_wall_thickness/2])
          cylinder(h=end_wall_thickness, r=cap_outer_diameter/2, center=true);
      }
      // Internal socket void
      translate([0, 0, -cap_overall_length/2 + (socket_depth + overlap)/2])
        cylinder(h=socket_depth + overlap, r=socket_inner_diameter/2, center=true);
      // Stop shoulder void
      translate([0, 0, -cap_overall_length/2 + socket_depth - stop_shoulder_thickness/2])
        cylinder(h=stop_shoulder_thickness + overlap, r=(socket_inner_diameter/2) - stop_shoulder_radial, center=true);
      // Chamfer relief void
      if (chamfer_lead_in == 1) {
        translate([0, 0, -cap_overall_length/2 + (chamfer_size + overlap)/2])
          rotate([180, 0, 0])
          cylinder(h=chamfer_size + overlap, r1=socket_inner_diameter/2 + chamfer_size, r2=socket_inner_diameter/2, center=true);
      }
    }
    // Outer grip ribs
    for (i = [0:rib_count-1]) {
      rotate([0, 0, i*360/rib_count])
        translate([cap_outer_diameter/2 + (rib_radial_height + overlap)/2 - overlap, 0, -cap_overall_length/2 + rib_length_axial/2 + end_wall_thickness/2])
        cube([rib_radial_height + overlap, rib_width_tangential, rib_length_axial], center=true);
    }
  }
}

// Assembly
module assembly() {
  cap_with_ribs();
  translate([0, 0, -cap_overall_length/2 + socket_depth/2 - overlap])
    ht_pipe();
}

assembly();