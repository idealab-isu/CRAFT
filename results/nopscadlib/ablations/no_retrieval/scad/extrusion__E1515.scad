// Parameters
profile_W = 15.0; //[7.5:30.0:0.1]
profile_H = 15.0; //[7.5:30.0:0.1]
length_L = 100.0; //[50.0:200.0:1]
chamfer_C = 0.8; //[0.4:1.6:0.1]
fillet_R = 1.0; //[0.5:2.0:0.1]
slot_W = 3.0; //[1.5:6.0:0.1]
slot_depth = 4.0; //[2.0:8.0:0.1]
center_bore_R = 2.0; //[1.0:4.0:0.1]
mark_depth = 0.3; //[0.1:0.8:0.05]
mark_R = 4.0; //[2.0:7.0:0.1]
overlap_eps = 1.0; //[0.5:2.0:0.1]

// Base Shapes
module extrusion_body() {
  cube([profile_W, profile_H, length_L], center=true);
}

module edge_chamfer_wedge_xpos() {
  translate([profile_W/2 - chamfer_C/2, 0, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, profile_H + 2*overlap_eps, length_L + 2*overlap_eps], center=true);
}

module edge_chamfer_wedge_xneg() {
  translate([-profile_W/2 + chamfer_C/2, 0, 0])
    rotate([0, 0, 45])
      cube([chamfer_C, profile_H + 2*overlap_eps, length_L + 2*overlap_eps], center=true);
}

module edge_chamfer_wedge_ypos() {
  translate([0, profile_H/2 - chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([profile_W + 2*overlap_eps, chamfer_C, length_L + 2*overlap_eps], center=true);
}

module edge_chamfer_wedge_yneg() {
  translate([0, -profile_H/2 + chamfer_C/2, 0])
    rotate([0, 0, 45])
      cube([profile_W + 2*overlap_eps, chamfer_C, length_L + 2*overlap_eps], center=true);
}

module corner_fillet_cyl_pp() {
  translate([profile_W/2 - fillet_R, profile_H/2 - fillet_R, 0])
    cylinder(r=fillet_R, h=length_L + 2*overlap_eps, center=true);
}

module corner_fillet_cyl_pn() {
  translate([profile_W/2 - fillet_R, -profile_H/2 + fillet_R, 0])
    cylinder(r=fillet_R, h=length_L + 2*overlap_eps, center=true);
}

module corner_fillet_cyl_np() {
  translate([-profile_W/2 + fillet_R, profile_H/2 - fillet_R, 0])
    cylinder(r=fillet_R, h=length_L + 2*overlap_eps, center=true);
}

module corner_fillet_cyl_nn() {
  translate([-profile_W/2 + fillet_R, -profile_H/2 + fillet_R, 0])
    cylinder(r=fillet_R, h=length_L + 2*overlap_eps, center=true);
}

module internal_slot_xpos() {
  translate([profile_W/2 - (slot_depth + overlap_eps)/2, 0, 0])
    cube([slot_depth + overlap_eps, slot_W, length_L + 2*overlap_eps], center=true);
}

module internal_slot_xneg() {
  translate([-profile_W/2 + (slot_depth + overlap_eps)/2, 0, 0])
    cube([slot_depth + overlap_eps, slot_W, length_L + 2*overlap_eps], center=true);
}

module internal_slot_ypos() {
  translate([0, profile_H/2 - (slot_depth + overlap_eps)/2, 0])
    cube([slot_W, slot_depth + overlap_eps, length_L + 2*overlap_eps], center=true);
}

module internal_slot_yneg() {
  translate([0, -profile_H/2 + (slot_depth + overlap_eps)/2, 0])
    cube([slot_W, slot_depth + overlap_eps, length_L + 2*overlap_eps], center=true);
}

module internal_center_bore() {
  cylinder(r=center_bore_R, h=length_L + 2*overlap_eps, center=true);
}

module end_face_marking_pos() {
  translate([0, 0, length_L/2 - (mark_depth + overlap_eps)/2])
    cylinder(r=mark_R, h=mark_depth + overlap_eps, center=true);
}

module end_face_marking_neg() {
  translate([0, 0, -length_L/2 + (mark_depth + overlap_eps)/2])
    cylinder(r=mark_R, h=mark_depth + overlap_eps, center=true);
}

// Operations
module edge_chamfers() {
  union() {
    edge_chamfer_wedge_xpos();
    edge_chamfer_wedge_xneg();
    edge_chamfer_wedge_ypos();
    edge_chamfer_wedge_yneg();
  }
}

module corner_fillets() {
  union() {
    corner_fillet_cyl_pp();
    corner_fillet_cyl_pn();
    corner_fillet_cyl_np();
    corner_fillet_cyl_nn();
  }
}

module internal_profile_details() {
  union() {
    internal_slot_xpos();
    internal_slot_xneg();
    internal_slot_ypos();
    internal_slot_yneg();
    internal_center_bore();
  }
}

module end_face_markings() {
  union() {
    end_face_marking_pos();
    end_face_marking_neg();
  }
}

// Complete Model
difference() {
  difference() {
    difference() {
      difference() {
        extrusion_body();
        edge_chamfers();
      }
      corner_fillets();
    }
    internal_profile_details();
  }
  end_face_markings();
}