// Parameters
nominal_diameter_mm = 110; //[55:220:1]
wall_thickness = 3.2; //[1.6:6.4:0.1]
socket_depth = 55; //[30:110:1]
cap_end_thickness = 6; //[3:12:0.5]
socket_clearance = 0.8; //[0.2:2:0.1]
outer_diameter_extra = 8; //[4:16:0.5]
stop_lip_thickness = 3; //[1.5:6:0.5]
stop_lip_radial = 2.5; //[1:6:0.5]
pipe_length = 120; //[60:240:1]
overlap = 1; //[0.5:2:0.1]

// HT Pipe - complete geometry
module ht_pipe() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer pipe
      cylinder(r=nominal_diameter_mm/2, h=pipe_length, center=true);
      // Inner void
      translate([0, 0, -overlap])
        cylinder(r=nominal_diameter_mm/2 - wall_thickness, h=pipe_length + overlap*2, center=true);
    }
  }
}

// End Cap with Socket
module end_cap_with_socket() {
  color([0.85, 0.85, 0.8]) {
    union() {
      // End cap body shell
      difference() {
        cylinder(r=(nominal_diameter_mm + outer_diameter_extra)/2, h=socket_depth + cap_end_thickness, center=true);
        translate([0, 0, cap_end_thickness/2])
          cylinder(r=(nominal_diameter_mm/2 + socket_clearance), h=socket_depth + cap_end_thickness, center=true);
      }
      // Cap end face solid
      translate([0, 0, socket_depth/2])
        cylinder(r=(nominal_diameter_mm + outer_diameter_extra)/2, h=cap_end_thickness, center=true);
      // Pipe interface socket shell
      difference() {
        translate([0, 0, -cap_end_thickness/2])
          cylinder(r=(nominal_diameter_mm + outer_diameter_extra)/2, h=socket_depth, center=true);
        translate([0, 0, -cap_end_thickness/2])
          cylinder(r=(nominal_diameter_mm/2 + socket_clearance), h=socket_depth + overlap*2, center=true);
      }
      // Internal stop lip
      difference() {
        translate([0, 0, -cap_end_thickness/2 - socket_depth/2 + stop_lip_thickness/2])
          cylinder(r=(nominal_diameter_mm/2 + socket_clearance), h=stop_lip_thickness, center=true);
        translate([0, 0, -cap_end_thickness/2 - socket_depth/2 + stop_lip_thickness/2])
          cylinder(r=(nominal_diameter_mm/2 + socket_clearance - stop_lip_radial), h=stop_lip_thickness + overlap*2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  end_cap_with_socket();
  translate([0, 0, -cap_end_thickness/2 - socket_depth/2 - pipe_length/2 + overlap])
    ht_pipe();
}

assembly();