// Parameters
pulley_od = 60; //[30:120:1]
pulley_width = 20; //[10:40:1]
rim_thickness = 6; //[3:12:1]
hub_od = 28; //[14:56:1]
hub_length = 24; //[12:48:1]
bore_d = 8; //[4:20:0.5]
groove_type = 1; //[0:1:1]
groove_angle = 40; //[20:60:1]
groove_depth = 4; //[1:10:0.5]
flange_od = 66; //[33:132:1]
flange_thickness = 2; //[1:6:0.5]
set_screw_d = 3; //[2:6:0.5]
set_screw_offset_z = 0; //[-10:10:0.5]
keyway_w = 3; //[1.5:8:0.5]
keyway_h = 1.5; //[0.75:4:0.25]
keyway_length = 18; //[9:36:1]
spoke_count = 4; //[3:8:1]
spoke_width = 6; //[3:14:0.5]
spoke_thickness = 8; //[4:20:0.5]
lightening_hole_d = 8; //[4:20:0.5]
lightening_hole_count = 6; //[3:12:1]
crown_height = 0.6; //[0:2:0.1]
edge_relief = 0.8; //[0:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module pulley_body() {
  cylinder(r=pulley_od/2, h=pulley_width, center=true);
}

module hub() {
  cylinder(r=hub_od/2, h=hub_length, center=true);
}

module rim_inner_void() {
  cylinder(r=pulley_od/2 - rim_thickness, h=pulley_width + 2*overlap, center=true);
}

module through_bore() {
  cylinder(r=bore_d/2, h=hub_length + 2*overlap, center=true);
}

module flange_left() {
  translate([0, 0, -pulley_width/2 - flange_thickness/2 + overlap])
    cylinder(r=flange_od/2, h=flange_thickness, center=true);
}

module flange_right() {
  translate([0, 0, pulley_width/2 + flange_thickness/2 - overlap])
    cylinder(r=flange_od/2, h=flange_thickness, center=true);
}

module belt_groove_profile() {
  cylinder(r1=pulley_od/2, r2=pulley_od/2 - groove_depth, h=pulley_width + 2*overlap, center=true);
}

module set_screw_hole() {
  rotate([0, 90, 0])
    translate([0, 0, set_screw_offset_z])
      cylinder(r=set_screw_d/2, h=hub_od + 2*overlap, center=true);
}

module keyway() {
  translate([0, bore_d/2 - keyway_h/2 + overlap, 0])
    cube([keyway_w, keyway_h, keyway_length], center=true);
}

module spoke() {
  cube([pulley_od/2 - rim_thickness - hub_od/2 + 2*overlap, spoke_width, spoke_thickness], center=true);
}

module lightening_hole() {
  rotate([90, 0, 0])
    cylinder(r=lightening_hole_d/2, h=pulley_width + 2*overlap, center=true);
}

module crown_profile() {
  cylinder(r=pulley_od/2 + overlap, h=pulley_width + 2*overlap, center=true);
}

module edge_relief_left() {
  translate([0, 0, -pulley_width/2 + edge_relief - overlap])
    cylinder(r1=pulley_od/2 + overlap, r2=pulley_od/2 - edge_relief, h=edge_relief*2, center=true);
}

module edge_relief_right() {
  translate([0, 0, pulley_width/2 - edge_relief + overlap])
    rotate([180, 0, 0])
      cylinder(r1=pulley_od/2 + overlap, r2=pulley_od/2 - edge_relief, h=edge_relief*2, center=true);
}

// Operations
module rim() {
  difference() {
    pulley_body();
    rim_inner_void();
  }
}

module spokes() {
  union() {
    for (i = [0:spoke_count-1]) {
      rotate([0, 0, i*360/spoke_count])
        translate([(hub_od/2 + (pulley_od/2 - rim_thickness))/2, 0, 0])
          spoke();
    }
  }
}

module pulley_solid_pre_cuts() {
  union() {
    rim();
    hub();
    spokes();
    flange_left();
    flange_right();
  }
}

module fillets_chamfers() {
  difference() {
    pulley_solid_pre_cuts();
    edge_relief_left();
    edge_relief_right();
  }
}

module pulley_with_belt_profile() {
  difference() {
    fillets_chamfers();
    belt_groove_profile();
  }
}

module pulley_with_crown() {
  difference() {
    pulley_with_belt_profile();
    crown_profile();
  }
}

module pulley_with_holes() {
  difference() {
    pulley_with_crown();
    through_bore();
    set_screw_hole();
    keyway();
    for (i = [0:lightening_hole_count-1]) {
      rotate([0, 0, i*360/lightening_hole_count])
        translate([(hub_od/2 + (pulley_od/2 - rim_thickness))/2, 0, 0])
          lightening_hole();
    }
  }
}

// Final Output
color("Silver") pulley_with_holes();