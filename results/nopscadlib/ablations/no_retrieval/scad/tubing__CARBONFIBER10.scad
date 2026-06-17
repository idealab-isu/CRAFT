// Parameters
tube_length = 300; //[150:600:1]
outer_diameter = 25; //[12.5:50:0.5]
wall_thickness = 2; //[1:5:0.25]
chamfer_size = 0.5; //[0:2:0.1]
cap_thickness = 0.8; //[0.4:2:0.1]
overlap = 1; //[0.5:2:0.1]

// Base Shapes
module tube_body() {
  cylinder(h=tube_length, r=outer_diameter/2, center=true);
}

module hollow_bore() {
  cylinder(h=tube_length + 2*overlap, r=outer_diameter/2 - wall_thickness, center=true);
}

module end_chamfer_top_cut() {
  translate([0, 0, tube_length/2 - (chamfer_size + overlap)/2])
    cylinder(h=chamfer_size + overlap, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module end_chamfer_bottom_cut() {
  translate([0, 0, -tube_length/2 + (chamfer_size + overlap)/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_size + overlap, r1=outer_diameter/2 + overlap, r2=0, center=true);
}

module end_cap_top() {
  translate([0, 0, tube_length/2 - cap_thickness/2 + overlap/2])
    cylinder(h=cap_thickness, r=outer_diameter/2 - wall_thickness + overlap, center=true);
}

module end_cap_bottom() {
  translate([0, 0, -tube_length/2 + cap_thickness/2 - overlap/2])
    cylinder(h=cap_thickness, r=outer_diameter/2 - wall_thickness + overlap, center=true);
}

module carbon_fiber_surface_texture() {
  cylinder(h=tube_length, r=outer_diameter/2, center=true);
}

// Operations
module tube_shell_prechamfer() {
  difference() {
    tube_body();
    hollow_bore();
  }
}

module tube_shell_with_chamfers() {
  difference() {
    tube_shell_prechamfer();
    end_chamfer_top_cut();
    end_chamfer_bottom_cut();
  }
}

module tube_with_end_caps() {
  union() {
    tube_shell_with_chamfers();
    end_cap_top();
    end_cap_bottom();
  }
}

module complete_model() {
  union() {
    tube_with_end_caps();
    carbon_fiber_surface_texture();
  }
}

// Final Output
color([0.1, 0.1, 0.1]) complete_model();