// Parameters
L = 60.4; //[30.2:120.8:0.1]
W = 20.55; //[10.275:41.1:0.05]
T = 8.4; //[4.2:16.8:0.1]
tip_L = 10.0; //[5.0:20.0:0.1]
body_L = 40.4; //[20.2:80.8:0.1]
body_W = 16.55; //[8.275:33.1:0.05]
fin_out = 2.0; //[1.0:4.0:0.1]
fin_L = 6.0; //[3.0:12.0:0.1]
fin_T = 2.8; //[1.4:5.6:0.1]
fin_offset_from_end = 3.0; //[1.5:6.0:0.1]
fin_step_inset = 0.8; //[0.4:1.6:0.05]
overlap = 0.8; //[0.5:2.0:0.1]
chamfer = 0.6; //[0.3:1.2:0.05]
fillet_r = 0.7; //[0.35:1.4:0.05]

// Main Body Prism
module main_body_prism() {
  cube([body_L, body_W, T], center=true);
}

// End Tip Wedge
module end_tip_wedge_left() {
  translate([-(body_L/2 + tip_L/2 - overlap), 0, 0])
    rotate([0, 90, 0])
    cylinder(h=tip_L, r1=body_W/2, r2=0, center=true);
}

module end_tip_wedge_right() {
  translate([body_L/2 + tip_L/2 - overlap, 0, 0])
    rotate([0, -90, 0])
    cylinder(h=tip_L, r1=body_W/2, r2=0, center=true);
}

// Side Fin Steps
module side_fin_step_left_upper() {
  translate([-(L/2 - fin_offset_from_end - fin_L/2), body_W/2 + fin_out/2 - overlap, T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module side_fin_step_left_lower() {
  translate([-(L/2 - fin_offset_from_end - fin_L/2), body_W/2 + (fin_out - fin_step_inset)/2 - overlap, -(T/2 - fin_T/2)])
    cube([fin_L, fin_out - fin_step_inset, fin_T], center=true);
}

module side_fin_step_right_upper() {
  translate([L/2 - fin_offset_from_end - fin_L/2, body_W/2 + fin_out/2 - overlap, T/2 - fin_T/2])
    cube([fin_L, fin_out, fin_T], center=true);
}

module side_fin_step_right_lower() {
  translate([L/2 - fin_offset_from_end - fin_L/2, body_W/2 + (fin_out - fin_step_inset)/2 - overlap, -(T/2 - fin_T/2)])
    cube([fin_L, fin_out - fin_step_inset, fin_T], center=true);
}

// Edge Chamfers
module edge_chamfers() {
  rotate([0, 0, 45])
    cube([L + 2*chamfer, W + 2*chamfer, T + 2*chamfer], center=true);
}

// Surface Markings or Texture
module surface_markings_or_texture() {
  translate([0, 0, T/2 - (T*0.15)/2])
    cube([body_L*0.6, body_W*0.6, T*0.15], center=true);
}

// Small Fillet Rounding
module small_fillet_rounding() {
  sphere(r=fillet_r, center=true);
}

// Union Core
module union_core() {
  union() {
    main_body_prism();
    end_tip_wedge_left();
    end_tip_wedge_right();
    side_fin_step_left_upper();
    side_fin_step_left_lower();
    side_fin_step_right_upper();
    side_fin_step_right_lower();
  }
}

// Difference Chamfered
module difference_chamfered() {
  difference() {
    union_core();
    edge_chamfers();
  }
}

// Union with Texture
module union_with_texture() {
  union() {
    difference_chamfered();
    surface_markings_or_texture();
  }
}

// Minkowski Fillet
module minkowski_fillet() {
  minkowski() {
    union_with_texture();
    small_fillet_rounding();
  }
}

// Final Output
minkowski_fillet();