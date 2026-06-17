// Parameters
bore_d = 6; //[3:12:0.1]
od_d = 12; //[6:24:0.1]
L = 19; //[10:38:0.1]
chamfer = 0.5; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]
groove_w = 1.2; //[0.6:2.4:0.1]
groove_depth = 0.4; //[0.2:1:0.05]
groove_offset = 2.5; //[1.5:5:0.1]
lip_w = 0.8; //[0.4:2:0.1]
lip_radial = 0.25; //[0.1:0.8:0.05]
window_w = 2.2; //[1.2:4:0.1]
window_h = 10; //[6:16:0.1]
window_depth = 2.2; //[1:4:0.1]
window_count = 4; //[2:8:1]
marking_depth = 0.15; //[0.05:0.4:0.05]
marking_w = 1; //[0.5:3:0.1]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=L, r=od_d/2, center=true);
}

module through_bore() {
  cylinder(h=L + 2*overlap, r=bore_d/2, center=true);
}

module end_chamfer_profile() {
  linear_extrude(height=L + 2*overlap, center=true)
    polygon(points=[
      [bore_d/2, 0],
      [od_d/2, 0],
      [od_d/2, chamfer],
      [od_d/2 - chamfer, 0]
    ]);
}

module outer_groove_left() {
  translate([0, 0, -L/2 + groove_offset])
    cylinder(h=groove_w, r=od_d/2 - groove_depth, center=true);
}

module outer_groove_right() {
  translate([0, 0, L/2 - groove_offset])
    cylinder(h=groove_w, r=od_d/2 - groove_depth, center=true);
}

module seal_lip_left() {
  translate([0, 0, -L/2 + lip_w/2 - overlap/2])
    cylinder(h=lip_w, r=od_d/2 + lip_radial, center=true);
}

module seal_lip_right() {
  translate([0, 0, L/2 - lip_w/2 + overlap/2])
    cylinder(h=lip_w, r=od_d/2 + lip_radial, center=true);
}

module ball_window_base() {
  translate([od_d/2 - window_depth/2 + overlap, 0, 0])
    cube([window_depth, window_w, window_h], center=true);
}

module ball_window_rot90() {
  rotate([0, 0, 90])
    ball_window_base();
}

module ball_window_rot180() {
  rotate([0, 0, 180])
    ball_window_base();
}

module ball_window_rot270() {
  rotate([0, 0, 270])
    ball_window_base();
}

module engraved_markings_band() {
  cylinder(h=marking_w, r=od_d/2 - marking_depth, center=true);
}

// Operations
module ball_circuit_windows() {
  union() {
    ball_window_base();
    ball_window_rot90();
    ball_window_rot180();
    ball_window_rot270();
  }
}

module outer_grooves() {
  union() {
    outer_groove_left();
    outer_groove_right();
  }
}

module seal_lips() {
  union() {
    seal_lip_left();
    seal_lip_right();
  }
}

module bearing_with_lips() {
  union() {
    outer_cylinder_body();
    seal_lips();
  }
}

module bearing_minus_bore() {
  difference() {
    bearing_with_lips();
    through_bore();
  }
}

module bearing_minus_chamfers() {
  difference() {
    bearing_minus_bore();
    end_chamfer_profile();
  }
}

module bearing_minus_outer_grooves() {
  difference() {
    bearing_minus_chamfers();
    outer_grooves();
  }
}

module bearing_minus_windows() {
  difference() {
    bearing_minus_outer_grooves();
    ball_circuit_windows();
  }
}

module bearing_minus_markings() {
  difference() {
    bearing_minus_windows();
    engraved_markings_band();
  }
}

// Final Output
bearing_minus_markings();