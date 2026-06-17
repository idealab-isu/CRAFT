// Parameters
pulley_OD = 60; //[30:120:1]
pulley_width = 20; //[10:40:1]
rim_thickness = 6; //[3:12:1]
hub_OD = 28; //[14:56:1]
hub_length = 24; //[12:48:1]
bore_d = 8; //[4:16:0.5]
groove_top_w = 10; //[5:20:0.5]
groove_depth = 4; //[2:8:0.5]
groove_angle = 40; //[20:60:1]
flange_OD = 34; //[20:68:1]
flange_thickness = 3; //[1.5:6:0.5]
set_screw_d = 3; //[2:6:0.5]
set_screw_offset_z = 0; //[-10:10:0.5]
keyway_w = 3; //[2:6:0.5]
keyway_depth = 1.4; //[0.7:2.8:0.1]
keyway_length = 18; //[9:36:1]
spoke_count = 4; //[3:8:1]
spoke_thickness = 6; //[3:12:1]
spoke_width_z = 10; //[5:20:1]
spoke_overlap = 1; //[0.5:2:0.5]
lightening_hole_d = 8; //[4:16:0.5]
lightening_hole_count = 6; //[3:12:1]
edge_chamfer = 0.8; //[0.4:2:0.1]
clearance = 0.6; //[0.2:1.2:0.1]

// Base Shapes
module pulley_rim_outer() {
  cylinder(r=pulley_OD/2, h=pulley_width, center=true);
}

module pulley_rim_inner_cut() {
  cylinder(r=pulley_OD/2 - rim_thickness, h=pulley_width + 2*clearance, center=true);
}

module pulley_hub() {
  cylinder(r=hub_OD/2, h=hub_length, center=true);
}

module hub_flange() {
  translate([0, 0, hub_length/2 - flange_thickness/2])
    cylinder(r=flange_OD/2, h=flange_thickness, center=true);
}

module center_bore() {
  cylinder(r=bore_d/2, h=hub_length + 2*clearance, center=true);
}

module belt_groove_profile() {
  rotate_extrude() {
    polygon(points=[
      [pulley_OD/2 - clearance, -groove_top_w/2],
      [pulley_OD/2 - clearance, groove_top_w/2],
      [pulley_OD/2 - groove_depth - clearance, 0]
    ]);
  }
}

module set_screw_hole_x() {
  rotate([0, 90, 0])
    translate([0, 0, set_screw_offset_z])
      cylinder(r=set_screw_d/2, h=hub_OD + 2*clearance, center=true);
}

module keyway_slot() {
  translate([bore_d/2 - (keyway_depth + clearance)/2, 0, 0])
    cube([keyway_depth + clearance, keyway_w, keyway_length], center=true);
}

module spoke(angle) {
  rotate([0, 0, angle])
    translate([(hub_OD/2 + (pulley_OD/2 - rim_thickness))/2, 0, 0])
      cube([pulley_OD/2 - rim_thickness - hub_OD/2 + 2*spoke_overlap, spoke_thickness, spoke_width_z], center=true);
}

module lightening_hole(angle) {
  rotate([0, 0, angle])
    translate([(hub_OD/2 + (pulley_OD/2 - rim_thickness))/2, 0, 0])
      cylinder(r=lightening_hole_d/2, h=pulley_width + 2*clearance, center=true);
}

module edge_chamfer_outer_top() {
  translate([0, 0, pulley_width/2 - edge_chamfer])
    cylinder(r1=pulley_OD/2 + edge_chamfer, r2=pulley_OD/2 - edge_chamfer, h=2*edge_chamfer, center=true);
}

module edge_chamfer_outer_bottom() {
  translate([0, 0, -pulley_width/2 + edge_chamfer])
    cylinder(r1=pulley_OD/2 - edge_chamfer, r2=pulley_OD/2 + edge_chamfer, h=2*edge_chamfer, center=true);
}

module fillet_like_hub_to_flange() {
  rotate_extrude()
    translate([hub_OD/2, 0, 0])
      circle(r=edge_chamfer);
}

// Operations
module pulley_rim() {
  difference() {
    pulley_rim_outer();
    pulley_rim_inner_cut();
  }
}

module spokes() {
  union() {
    for (i = [0:spoke_count-1])
      spoke(i * 360/spoke_count);
  }
}

module pulley_body_union() {
  union() {
    pulley_rim();
    pulley_hub();
    hub_flange();
    spokes();
  }
}

module belt_groove() {
  difference() {
    pulley_body_union();
    belt_groove_profile();
  }
}

module lightening_holes() {
  union() {
    for (i = [0:lightening_hole_count-1])
      lightening_hole(i * 360/lightening_hole_count);
  }
}

module with_lightening() {
  difference() {
    belt_groove();
    lightening_holes();
  }
}

module with_bore() {
  difference() {
    with_lightening();
    center_bore();
  }
}

module with_keyway() {
  difference() {
    with_bore();
    keyway_slot();
  }
}

module with_set_screw_hole() {
  difference() {
    with_keyway();
    set_screw_hole_x();
  }
}

module edge_chamfers() {
  union() {
    edge_chamfer_outer_top();
    edge_chamfer_outer_bottom();
  }
}

module with_edge_chamfers() {
  difference() {
    with_set_screw_hole();
    edge_chamfers();
  }
}

module fillets() {
  union() {
    with_edge_chamfers();
    fillet_like_hub_to_flange();
  }
}

// Final Output
fillets();