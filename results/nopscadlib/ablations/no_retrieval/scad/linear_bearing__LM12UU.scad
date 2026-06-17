// Parameters
bore_d = 12.0; //[6.0:24.0:0.1]
outer_d = 21.0; //[10.5:42.0:0.1]
length = 30.0; //[15.0:60.0:0.1]
chamfer_len = 0.8; //[0.4:1.6:0.05]
overlap = 1.0; //[0.5:2.0:0.1]
seal_groove_width = 1.2; //[0.6:2.4:0.05]
seal_groove_depth = 0.4; //[0.2:0.8:0.05]
seal_groove_offset = 2.0; //[1.0:4.0:0.1]
lube_groove_count = 12; //[6:24:1]
lube_groove_width = 0.8; //[0.4:1.6:0.05]
lube_groove_depth = 0.25; //[0.1:0.6:0.05]
lube_groove_length = 26.0; //[10.0:58.0:0.1]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=length, r=outer_d/2, center=true);
}

module through_bore() {
  cylinder(h=length + 2*overlap, r=bore_d/2, center=true);
}

module end_chamfer_top() {
  translate([0, 0, length/2 - (chamfer_len + overlap)/2])
    cylinder(h=chamfer_len + overlap, r1=outer_d/2, r2=0, center=true);
}

module end_chamfer_bottom() {
  translate([0, 0, -length/2 + (chamfer_len + overlap)/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_len + overlap, r1=outer_d/2, r2=0, center=true);
}

module seal_groove_top() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width, r=outer_d/2, center=true);
}

module seal_groove_top_inner() {
  translate([0, 0, length/2 - seal_groove_offset])
    cylinder(h=seal_groove_width + 2*overlap, r=outer_d/2 - seal_groove_depth, center=true);
}

module seal_groove_bottom() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width, r=outer_d/2, center=true);
}

module seal_groove_bottom_inner() {
  translate([0, 0, -length/2 + seal_groove_offset])
    cylinder(h=seal_groove_width + 2*overlap, r=outer_d/2 - seal_groove_depth, center=true);
}

module lube_groove_cutter(angle) {
  rotate([0, 0, angle])
    translate([0, outer_d/2 - lube_groove_depth/2, 0])
    cube([outer_d + 2*overlap, lube_groove_width, lube_groove_length], center=true);
}

// Operations
module end_chamfers() {
  union() {
    end_chamfer_top();
    end_chamfer_bottom();
  }
}

module seal_groove_ring_top() {
  difference() {
    seal_groove_top();
    seal_groove_top_inner();
  }
}

module seal_groove_ring_bottom() {
  difference() {
    seal_groove_bottom();
    seal_groove_bottom_inner();
  }
}

module seal_grooves() {
  union() {
    seal_groove_ring_top();
    seal_groove_ring_bottom();
  }
}

module outer_surface_knurl_or_lubrication_features() {
  union() {
    for (i = [0:lube_groove_count-1]) {
      lube_groove_cutter(i*360/lube_groove_count);
    }
  }
}

module outer_minus_bore() {
  difference() {
    outer_cylinder_body();
    through_bore();
  }
}

module outer_minus_bore_minus_chamfers() {
  difference() {
    outer_minus_bore();
    end_chamfers();
  }
}

module outer_minus_bore_minus_chamfers_minus_seal_grooves() {
  difference() {
    outer_minus_bore_minus_chamfers();
    seal_grooves();
  }
}

module bearing_complete_no_marking() {
  difference() {
    outer_minus_bore_minus_chamfers_minus_seal_grooves();
    outer_surface_knurl_or_lubrication_features();
  }
}

// Final Output
color("Silver") bearing_complete_no_marking();