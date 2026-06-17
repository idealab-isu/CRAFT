// Parameters
bbox_xy = 23.46; //[11.73:46.92:0.01]
thickness = 7.0; //[3.5:14.0:0.1]
bore_d = 10.0; //[5.0:20.0:0.1]
root_od = 19.5; //[9.75:39.0:0.1]
tip_od = 23.46; //[11.73:46.92:0.01]
tooth_count = 12; //[6:48:1]
tooth_arc_width = 4.0; //[2.0:8.0:0.1]
tooth_radial_height = 1.98; //[0.99:3.96:0.01]
overlap = 0.8; //[0.5:2.0:0.1]
chamfer_z = 0.6; //[0.3:1.2:0.05]
chamfer_r = 0.6; //[0.3:1.2:0.05]
fillet_r = 0.5; //[0.25:1.0:0.05]
notch_w = 2.0; //[1.0:4.0:0.1]
notch_depth = 1.2; //[0.6:2.4:0.1]

// Base shapes
module tooth_root_outer_diameter_reference() {
  cylinder(r=root_od/2, h=thickness, center=true);
}

module tooth_tip_outer_diameter_reference() {
  cylinder(r=tip_od/2, h=thickness, center=true);
}

module center_through_bore() {
  cylinder(r=bore_d/2, h=thickness + 2*overlap, center=true);
}

module tooth_base_rect() {
  translate([(root_od/2) + ((((tip_od - root_od)/2) + overlap)/2) - overlap, 0, 0])
    cube([((tip_od - root_od)/2) + overlap, tooth_arc_width, thickness], center=true);
}

module edge_chamfer_outer_top() {
  translate([0, 0, (thickness/2) - (chamfer_z/2) + overlap])
    cylinder(r1=tip_od/2 + chamfer_r, r2=tip_od/2, h=chamfer_z, center=true);
}

module edge_chamfer_outer_bottom() {
  translate([0, 0, (-thickness/2) + (chamfer_z/2) - overlap])
    cylinder(r1=tip_od/2 + chamfer_r, r2=tip_od/2, h=chamfer_z, center=true);
}

module tooth_tip_chamfer_top() {
  translate([0, 0, (thickness/2) - (chamfer_z/2) + overlap])
    cylinder(r1=tip_od/2 + chamfer_r, r2=tip_od/2, h=chamfer_z, center=true);
}

module tooth_tip_chamfer_bottom() {
  translate([0, 0, (-thickness/2) + (chamfer_z/2) - overlap])
    cylinder(r1=tip_od/2 + chamfer_r, r2=tip_od/2, h=chamfer_z, center=true);
}

module marking_notch() {
  translate([(tip_od/2) - ((notch_depth + 2*overlap)/2) + overlap, 0, 0])
    cube([notch_depth + 2*overlap, notch_w, thickness + 2*overlap], center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r);
}

// Operations
module annular_body() {
  difference() {
    tooth_root_outer_diameter_reference();
    center_through_bore();
  }
}

module outer_teeth_array() {
  union() {
    for (i = [0:tooth_count-1]) {
      rotate([0, 0, i*(360/tooth_count)])
        tooth_base_rect();
    }
  }
}

module edge_chamfers() {
  union() {
    edge_chamfer_outer_top();
    edge_chamfer_outer_bottom();
  }
}

module tooth_tip_chamfers() {
  union() {
    tooth_tip_chamfer_top();
    tooth_tip_chamfer_bottom();
  }
}

module ring_with_teeth() {
  union() {
    annular_body();
    outer_teeth_array();
  }
}

module ring_chamfered() {
  difference() {
    ring_with_teeth();
    edge_chamfers();
    tooth_tip_chamfers();
  }
}

module ring_with_notch() {
  difference() {
    ring_chamfered();
    marking_notch();
  }
}

module edge_fillets() {
  minkowski() {
    ring_with_notch();
    fillet_sphere();
  }
}

// Final model
intersection() {
  edge_fillets();
  tooth_tip_outer_diameter_reference();
}