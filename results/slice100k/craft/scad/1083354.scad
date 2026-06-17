// Parameters
L_total = 97.5; //[48.75:195:0.5]
OD_max = 19; //[9.5:38:0.1]
OD_min = 14; //[7:28:0.1]
L_large = 40; //[20:80:0.5]
L_taper = 10; //[5:20:0.5]
L_small = 47.5; //[23.75:95:0.5]
ID_bore = 10; //[5:18:0.1]
chamfer = 0.5; //[0.2:2:0.1]
overlap = 1; //[0.5:2:0.1]
fillet_r = 0.6; //[0.2:2:0.1]
counterbore_ID = 12; //[10.2:18:0.1]
counterbore_depth = 8; //[2:20:0.5]
knurl_depth = 0.3; //[0.1:1:0.05]
knurl_pitch = 2; //[1:5:0.5]
knurl_count = 10; //[3:30:1]

// Base Shapes
module outer_cylinder_section_large_OD() {
  translate([0, 0, -L_total/2 + L_large/2])
    cylinder(h=L_large, r=OD_max/2, center=true);
}

module outer_cylinder_section_small_OD() {
  translate([0, 0, L_total/2 - L_small/2])
    cylinder(h=L_small, r=OD_min/2, center=true);
}

module outer_conical_frustum_transition() {
  translate([0, 0, -L_total/2 + L_large + L_taper/2 - overlap/2])
    cylinder(h=L_taper, r1=OD_max/2, r2=OD_min/2, center=true);
}

module central_through_bore() {
  cylinder(h=L_total + 2*overlap, r=ID_bore/2, center=true);
}

module end_face_chamfer_minusZ() {
  translate([0, 0, -L_total/2 + chamfer])
    rotate([180, 0, 0])
    cylinder(h=2*chamfer, r1=ID_bore/2 + chamfer, r2=ID_bore/2, center=true);
}

module end_face_chamfer_plusZ() {
  translate([0, 0, L_total/2 - chamfer])
    cylinder(h=2*chamfer, r1=ID_bore/2 + chamfer, r2=ID_bore/2, center=true);
}

module internal_counterbore() {
  translate([0, 0, L_total/2 - (counterbore_depth + overlap)/2])
    cylinder(h=counterbore_depth + overlap, r=counterbore_ID/2, center=true);
}

module fillet_blend_large_side() {
  translate([0, 0, -L_total/2 + L_large - fillet_r])
    cylinder(h=2*fillet_r, r=OD_max/2, center=true);
}

module fillet_blend_small_side() {
  translate([0, 0, -L_total/2 + L_large + L_taper + fillet_r - overlap])
    cylinder(h=2*fillet_r, r=OD_min/2, center=true);
}

module knurl_groove_cutter_proto() {
  rotate_extrude()
    translate([OD_max/2 - knurl_depth, 0, 0])
    circle(r=knurl_depth);
}

// Operations
module outer_union_raw() {
  union() {
    outer_cylinder_section_large_OD();
    outer_conical_frustum_transition();
    outer_cylinder_section_small_OD();
  }
}

module fillet_on_OD_transitions() {
  hull() {
    fillet_blend_large_side();
    fillet_blend_small_side();
  }
}

module outer_union_with_fillet() {
  union() {
    outer_union_raw();
    fillet_on_OD_transitions();
  }
}

module outer_minus_bore() {
  difference() {
    outer_union_with_fillet();
    central_through_bore();
  }
}

module outer_minus_bore_and_counterbore() {
  difference() {
    outer_minus_bore();
    internal_counterbore();
  }
}

module outer_minus_internal_edge_breaks() {
  difference() {
    outer_minus_bore_and_counterbore();
    end_face_chamfer_minusZ();
    end_face_chamfer_plusZ();
  }
}

module knurl_grooves() {
  for (i = [0:knurl_count-1]) {
    translate([0, 0, -(knurl_count-1)*knurl_pitch/2 + i*knurl_pitch])
      knurl_groove_cutter_proto();
  }
}

module surface_text_or_knurl() {
  difference() {
    outer_minus_internal_edge_breaks();
    knurl_grooves();
  }
}

// Final Output
surface_text_or_knurl();