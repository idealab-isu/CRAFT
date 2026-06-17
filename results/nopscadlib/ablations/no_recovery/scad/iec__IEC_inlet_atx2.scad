// Parameters
iec_type = 0; //[0:0:1]
male = 0; //[0:1:1]
panel_thickness = 2.5; //[1.0:5.0:0.1]
mounting_screw_type = 3; //[2:5:1]
overall_width = 50; //[25:100:1]
overall_height = 40; //[20:80:1]
overall_depth = 28; //[14:56:1]
flange_thickness = 3; //[1.5:6:0.1]
bezel_thickness = 2; //[1:5:0.1]
body_corner_radius = 3; //[1.5:6:0.1]
flange_corner_radius = 4; //[2:8:0.1]
bezel_corner_radius = 3; //[1.5:6:0.1]
screw_hole_pitch = 40; //[20:80:1]
screw_hole_diameter = 3.2; //[2.0:6.0:0.1]
socket_opening_width = 24.5; //[12:40:0.1]
socket_opening_height = 16.3; //[8:30:0.1]
socket_opening_depth = 17; //[8:30:0.1]
body_width = 30; //[15:60:1]
body_height = 22; //[11:44:1]
bezel_width = 34; //[17:68:1]
bezel_height = 26; //[13:52:1]
rear_body_depth = 10; //[5:20:1]
countersink_diameter = 6.5; //[4.0:12.0:0.1]
countersink_depth = 1.5; //[0.5:4.0:0.1]
overlap = 1; //[0.5:2:0.1]

// IEC Connector - complete geometry
module iec() {
  color("Black") {
    // Flange
    translate([0, 0, flange_thickness/2])
      cube([overall_width, overall_height, flange_thickness], center=true);

    // Bezel
    translate([0, 0, flange_thickness + bezel_thickness/2 - overlap])
      cube([bezel_width, bezel_height, bezel_thickness], center=true);

    // Connector Body
    translate([0, 0, flange_thickness + bezel_thickness - overlap + (overall_depth - flange_thickness - bezel_thickness)/2])
      cube([body_width, body_height, overall_depth - flange_thickness - bezel_thickness], center=true);

    // Rear Body
    translate([0, 0, flange_thickness + bezel_thickness - overlap + (overall_depth - flange_thickness - bezel_thickness) - overlap + rear_body_depth/2])
      cube([body_width*0.92, body_height*0.92, rear_body_depth], center=true);

    // Pin or Spade Terminals
    translate([0, 0, flange_thickness + bezel_thickness - overlap + (overall_depth - flange_thickness - bezel_thickness) + rear_body_depth - overlap/2])
      cube([body_width*0.6, body_height*0.4, overlap], center=true);
  }

  // Socket Orifice
  translate([0, 0, flange_thickness + bezel_thickness - overlap + (socket_opening_depth + overlap)/2])
    color("White")
    cube([socket_opening_width, socket_opening_height, socket_opening_depth + overlap], center=true);

  // Screw Mount Holes
  color("Silver") {
    translate([-screw_hole_pitch/2, 0, (flange_thickness + bezel_thickness)/2])
      cylinder(r=screw_hole_diameter/2, h=flange_thickness + bezel_thickness + overlap, center=true);
    translate([screw_hole_pitch/2, 0, (flange_thickness + bezel_thickness)/2])
      cylinder(r=screw_hole_diameter/2, h=flange_thickness + bezel_thickness + overlap, center=true);
  }

  // Screw Countersinks
  color("DimGray") {
    translate([-screw_hole_pitch/2, 0, countersink_depth/2])
      cylinder(r=countersink_diameter/2, h=countersink_depth + overlap, center=true);
    translate([screw_hole_pitch/2, 0, countersink_depth/2])
      cylinder(r=countersink_diameter/2, h=countersink_depth + overlap, center=true);
  }

  // Panel Cutout Reference
  translate([0, 0, -panel_thickness/2])
    color("Gray")
    cube([bezel_width - 2*overlap, bezel_height - 2*overlap, panel_thickness], center=true);
}

// Assembly
module assembly() {
  iec();
}

assembly();