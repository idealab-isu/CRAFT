// Parameters
dn = 75; //[40:150:1]
pipe_od = 75; //[60:110:1]
cap_od = 82; //[70:120:1]
wall_t = 2.5; //[1.5:5:0.1]
socket_depth = 45; //[25:80:1]
end_wall_t = 3; //[2:6:0.1]
overall_length = 55; //[35:90:1]
chamfer_len = 2; //[1:6:0.1]
chamfer_angle = 30; //[15:60:1]
rim_thickness = 3; //[1.5:6:0.1]
rim_width = 4; //[2:10:0.1]
seal_groove_depth = 1.2; //[0.6:2.5:0.1]
seal_groove_width = 4; //[2:8:0.1]
seal_groove_offset_from_open = 12; //[6:25:1]
socket_clearance = 0.6; //[0.2:1.5:0.1]
overlap = 1; //[0.5:2:0.1]
marking_band_depth = 0.4; //[0.2:1:0.1]
marking_band_width = 6; //[3:12:0.1]
marking_band_offset_from_closed_end = 10; //[5:25:1]
fillet_r = 0.8; //[0.3:2:0.1]

// Base Shapes
module cap_outer_body() {
  translate([0, 0, 0])
    cylinder(r=cap_od/2, h=overall_length, center=true);
}

module internal_socket_bore() {
  translate([0, 0, -overall_length/2 + socket_depth/2])
    cylinder(r=(pipe_od + socket_clearance)/2, h=socket_depth + overlap, center=true);
}

module closed_end_wall() {
  translate([0, 0, (-overall_length/2 + socket_depth) + (overall_length - socket_depth)/2])
    cylinder(r=(cap_od/2) - wall_t, h=overall_length - socket_depth, center=true);
}

module opening_lead_in_chamfer() {
  translate([0, 0, -overall_length/2 + (chamfer_len + overlap)/2])
    cylinder(r1=(pipe_od + socket_clearance)/2 + chamfer_len, r2=(pipe_od + socket_clearance)/2, h=chamfer_len + overlap, center=true);
}

module outer_rim_stop() {
  translate([0, 0, -overall_length/2 + rim_thickness/2])
    cylinder(r=cap_od/2 + rim_width, h=rim_thickness, center=true);
}

module internal_seal_groove() {
  translate([0, 0, -overall_length/2 + seal_groove_offset_from_open])
    cylinder(r=(pipe_od + socket_clearance)/2 + seal_groove_depth, h=seal_groove_width, center=true);
}

module outer_text_markings() {
  translate([0, 0, overall_length/2 - marking_band_offset_from_closed_end])
    cylinder(r=cap_od/2 - marking_band_depth, h=marking_band_width, center=true);
}

module edge_fillets() {
  sphere(r=fillet_r, center=true);
}

// Operations
module cap_shell_with_rim() {
  union() {
    cap_outer_body();
    outer_rim_stop();
  }
}

module cap_hollowed() {
  difference() {
    cap_shell_with_rim();
    internal_socket_bore();
  }
}

module cap_with_chamfer() {
  difference() {
    cap_hollowed();
    opening_lead_in_chamfer();
  }
}

module cap_with_seal_groove() {
  difference() {
    cap_with_chamfer();
    internal_seal_groove();
  }
}

module cap_with_marking_band() {
  difference() {
    cap_with_seal_groove();
    outer_text_markings();
  }
}

// Final Output
minkowski() {
  cap_with_marking_band();
  edge_fillets();
}