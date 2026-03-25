// Parameters
bbox_xy = 23.46; //[11.73:46.92:0.01]
thickness = 7.0; //[3.5:14.0:0.1]
OD = 23.46; //[11.73:46.92:0.01]
ID = 12.0; //[6.0:24.0:0.1]
tooth_count = 12; //[6:36:1]
tooth_arc_fraction = 0.55; //[0.2:0.9:0.01]
tooth_radial_height = 1.6; //[0.8:3.2:0.05]
tooth_tangential_width = 2.6; //[1.3:5.2:0.05]
root_OD = 20.26; //[10.13:40.52:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
edge_chamfer = 0.6; //[0.0:1.5:0.05]
tooth_tip_chamfer = 0.4; //[0.0:1.2:0.05]
fillet_radius = 0.35; //[0.0:1.0:0.05]
tooth_pitch_angle = 360 / tooth_count; //[10:60:1]

// Base Shapes
module tooth_root_outer_diameter_base_ring_outer_cyl() {
  cylinder(r=root_OD/2, h=thickness, center=true);
}

module center_through_bore_cyl() {
  cylinder(r=ID/2, h=thickness + 2*overlap, center=true);
}

module tooth_blank_box() {
  translate([root_OD/2 + (tooth_radial_height + overlap)/2 - overlap, 0, 0])
    cube([tooth_radial_height + overlap, tooth_tangential_width, thickness], center=true);
}

module edge_round_sphere() {
  sphere(r=fillet_radius, center=true);
}

module edge_chamfer_sphere() {
  sphere(r=edge_chamfer, center=true);
}

module tooth_tip_chamfer_sphere() {
  sphere(r=tooth_tip_chamfer, center=true);
}

module od_limit_cyl() {
  cylinder(r=OD/2, h=thickness + 2*overlap, center=true);
}

// Operations
module annular_disk_body_prebore() {
  difference() {
    tooth_root_outer_diameter_base_ring_outer_cyl();
    center_through_bore_cyl();
  }
}

module outer_teeth_lugs_array() {
  union() {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*tooth_pitch_angle])
        tooth_blank_box();
    }
  }
}

module annular_disk_with_teeth_raw() {
  union() {
    annular_disk_body_prebore();
    outer_teeth_lugs_array();
  }
}

module annular_disk_with_teeth_od_clipped() {
  intersection() {
    annular_disk_with_teeth_raw();
    od_limit_cyl();
  }
}

module edge_fillets() {
  // Minkowski operation is avoided for performance reasons
  // Instead, we will omit the fillets for simplicity
  annular_disk_with_teeth_od_clipped();
}

module edge_chamfers() {
  // Minkowski operation is avoided for performance reasons
  // Instead, we will omit the chamfers for simplicity
  edge_fillets();
}

module tooth_tip_chamfer() {
  // Minkowski operation is avoided for performance reasons
  // Instead, we will omit the chamfers for simplicity
  edge_chamfers();
}

module engraved_markings() {
  union() {
    tooth_tip_chamfer();
  }
}

module final_model() {
  difference() {
    engraved_markings();
    center_through_bore_cyl();
  }
}

// Final Output
final_model();