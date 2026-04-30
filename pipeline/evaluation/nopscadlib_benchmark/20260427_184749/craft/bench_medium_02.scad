// Parameters
block_length = 40; //[20:80:1]
block_width = 30; //[15:60:1]
block_height = 15; //[8:30:1]
m3_clearance_diameter = 3.4; //[3:4.2:0.1]
hole_depth = 20; //[8:40:1]
use_through_holes = 1; //[0:1:1]
use_counterbore = 1; //[0:1:1]
counterbore_diameter = 6.2; //[5:10:0.1]
counterbore_depth = 3.2; //[1.5:6:0.1]
edge_chamfer = 0.8; //[0:2.5:0.1]
hole_z_fudge = 0.5; //[0.2:2:0.1]
mgn12h_pitch_x = 20; //[10:30:1]
mgn12h_pitch_y = 15; //[8:25:1]

// Base Shapes
module mounting_block_body() {
  translate([0, 0, 0])
    cube([block_length, block_width, block_height], center=true);
}

module edge_chamfer_tool_top_xpos() {
  translate([block_length/2 - edge_chamfer, 0, block_height/2 - edge_chamfer])
    rotate([0, 45, 0])
      cube([edge_chamfer*2, block_width+hole_z_fudge*2, edge_chamfer*2], center=true);
}

module edge_chamfer_tool_top_xneg() {
  translate([-block_length/2 + edge_chamfer, 0, block_height/2 - edge_chamfer])
    rotate([0, 45, 0])
      cube([edge_chamfer*2, block_width+hole_z_fudge*2, edge_chamfer*2], center=true);
}

module edge_chamfer_tool_top_ypos() {
  translate([0, block_width/2 - edge_chamfer, block_height/2 - edge_chamfer])
    rotate([45, 0, 0])
      cube([block_length+hole_z_fudge*2, edge_chamfer*2, edge_chamfer*2], center=true);
}

module edge_chamfer_tool_top_yneg() {
  translate([0, -block_width/2 + edge_chamfer, block_height/2 - edge_chamfer])
    rotate([45, 0, 0])
      cube([block_length+hole_z_fudge*2, edge_chamfer*2, edge_chamfer*2], center=true);
}

module m3_clearance_hole_cyl() {
  translate([0, 0, 0])
    cylinder(r=m3_clearance_diameter/2, h=block_height + hole_z_fudge*2, center=true);
}

module counterbore_cyl() {
  translate([0, 0, block_height/2 - counterbore_depth/2])
    cylinder(r=counterbore_diameter/2, h=counterbore_depth + hole_z_fudge, center=true);
}

// Operations
module m3_clearance_holes() {
  union() {
    translate([mgn12h_pitch_x/2, mgn12h_pitch_y/2, 0]) m3_clearance_hole_cyl();
    translate([mgn12h_pitch_x/2, -mgn12h_pitch_y/2, 0]) m3_clearance_hole_cyl();
    translate([-mgn12h_pitch_x/2, mgn12h_pitch_y/2, 0]) m3_clearance_hole_cyl();
    translate([-mgn12h_pitch_x/2, -mgn12h_pitch_y/2, 0]) m3_clearance_hole_cyl();
  }
}

module bolt_head_recesses() {
  union() {
    translate([mgn12h_pitch_x/2, mgn12h_pitch_y/2, 0]) counterbore_cyl();
    translate([mgn12h_pitch_x/2, -mgn12h_pitch_y/2, 0]) counterbore_cyl();
    translate([-mgn12h_pitch_x/2, mgn12h_pitch_y/2, 0]) counterbore_cyl();
    translate([-mgn12h_pitch_x/2, -mgn12h_pitch_y/2, 0]) counterbore_cyl();
  }
}

module edge_fillets_or_chamfers() {
  union() {
    edge_chamfer_tool_top_xpos();
    edge_chamfer_tool_top_xneg();
    edge_chamfer_tool_top_ypos();
    edge_chamfer_tool_top_yneg();
  }
}

// Final Output
difference() {
  mounting_block_body();
  m3_clearance_holes();
  if (use_counterbore) bolt_head_recesses();
  edge_fillets_or_chamfers();
}