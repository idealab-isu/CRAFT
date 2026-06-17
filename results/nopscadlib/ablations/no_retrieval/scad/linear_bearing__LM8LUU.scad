// Parameters
bearing_length = 45.0; //[22.5:90.0:0.5]
outer_diameter = 15.0; //[7.5:30.0:0.1]
inner_diameter = 8.0; //[4.0:16.0:0.1]
chamfer_depth = 1.0; //[0.5:2.0:0.1]
chamfer_radial = 0.8; //[0.4:1.6:0.1]
groove_count = 3; //[1:6:1]
groove_width = 1.2; //[0.6:2.4:0.1]
groove_depth = 0.5; //[0.2:1.2:0.1]
groove_margin = 6.0; //[3.0:12.0:0.5]
bore_extra_length = 2.0; //[1.0:6.0:0.5]

// Base Shapes
module bearing_outer_cylinder() {
  cylinder(h=bearing_length, r=outer_diameter/2, center=true);
}

module bearing_inner_bore() {
  cylinder(h=bearing_length + bore_extra_length, r=inner_diameter/2, center=true);
}

module end_chamfer_top_cutter() {
  translate([0, 0, bearing_length/2 - chamfer_depth/2])
    cylinder(h=chamfer_depth, r1=outer_diameter/2, r2=0, center=true);
}

module end_chamfer_bottom_cutter() {
  translate([0, 0, -bearing_length/2 + chamfer_depth/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_depth, r1=outer_diameter/2, r2=0, center=true);
}

module outer_groove(position_z) {
  translate([0, 0, position_z])
    cylinder(h=groove_width, r=outer_diameter/2 - groove_depth, center=true);
}

// Operations
module end_chamfers() {
  union() {
    end_chamfer_top_cutter();
    end_chamfer_bottom_cutter();
  }
}

module outer_surface_grooves() {
  union() {
    outer_groove(-(bearing_length/2 - groove_margin));
    outer_groove(0);
    outer_groove(bearing_length/2 - groove_margin);
  }
}

module bearing_shell_pre_chamfer() {
  difference() {
    bearing_outer_cylinder();
    bearing_inner_bore();
  }
}

module bearing_shell_with_chamfers() {
  difference() {
    bearing_shell_pre_chamfer();
    end_chamfers();
  }
}

module bearing_complete_model() {
  difference() {
    bearing_shell_with_chamfers();
    outer_surface_grooves();
  }
}

// Final Output
color("Silver") bearing_complete_model();