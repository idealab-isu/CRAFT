// Parameters
bbox_X = 0.06; //[0.03:0.12:0.001]
bbox_Y = 0.06; //[0.03:0.12:0.001]
bbox_Z = 0.05; //[0.025:0.1:0.001]
body_X = 0.06; //[0.03:0.12:0.001]
body_Y = 0.06; //[0.03:0.12:0.001]
body_Z = 0.05; //[0.025:0.1:0.001]
bore_d = 0.02; //[0.01:0.04:0.001]
boss_d = 0.018; //[0.009:0.036:0.001]
boss_len = 0.01; //[0.005:0.02:0.001]
tab1_w = 0.012; //[0.006:0.024:0.001]
tab1_h = 0.008; //[0.004:0.016:0.001]
tab1_depth = 0.006; //[0.003:0.012:0.001]
tab2_w = 0.01; //[0.005:0.02:0.001]
tab2_h = 0.006; //[0.003:0.012:0.001]
tab2_depth = 0.005; //[0.0025:0.01:0.001]
edge_chamfer = 0.002; //[0.001:0.004:0.0005]
bore_chamfer_h = 0.003; //[0.001:0.006:0.0005]
bore_chamfer_extra_d = 0.006; //[0.002:0.012:0.001]
boss_blend_r = 0.003; //[0.001:0.006:0.0005]
overlap = 0.001; //[0.0005:0.002:0.0005]

// Main Housing Block
module main_housing_block() {
  translate([-boss_len/2, 0, 0])
    cube([body_X - boss_len, body_Y, body_Z], center=true);
}

// Center Through Bore
module center_through_bore() {
  translate([0, 0, 0])
    cylinder(h=body_Z + 2*overlap, r=bore_d/2, center=true);
}

// Side Cylindrical Boss
module side_cylindrical_boss() {
  translate([body_X/2 - boss_len/2, 0, 0])
    rotate([0, 90, 0])
      cylinder(h=boss_len, r=boss_d/2, center=true);
}

// Keyed Tab Positive Face
module keyed_tab_positive_face() {
  translate([-boss_len/2, body_Y/2 - tab1_depth/2, body_Z/2 - tab1_h/2])
    cube([tab1_w, tab1_depth, tab1_h], center=true);
}

// Keyed Tab Opposite Face
module keyed_tab_opposite_face() {
  translate([-boss_len/2, -body_Y/2 + tab2_depth/2, -body_Z/2 + tab2_h/2])
    cube([tab2_w, tab2_depth, tab2_h], center=true);
}

// Edge Chamfers or Fillets
module edge_chamfers_or_fillets() {
  translate([-boss_len/2 - (body_X - boss_len)/2 + edge_chamfer/2, 0, 0])
    cube([edge_chamfer, body_Y + 2*overlap, body_Z + 2*overlap], center=true);
}

// Bore Entry Chamfer Top
module bore_entry_chamfer_top() {
  translate([0, 0, body_Z/2 - bore_chamfer_h/2 + overlap])
    rotate([180, 0, 0])
      cylinder(h=bore_chamfer_h, r1=bore_d/2 + bore_chamfer_extra_d/2, r2=bore_d/2, center=true);
}

// Bore Entry Chamfer Bottom
module bore_entry_chamfer_bottom() {
  translate([0, 0, -body_Z/2 + bore_chamfer_h/2 - overlap])
    cylinder(h=bore_chamfer_h, r1=bore_d/2 + bore_chamfer_extra_d/2, r2=bore_d/2, center=true);
}

// Boss Blend Fillet
module boss_blend_fillet() {
  hull() {
    translate([body_X/2 - boss_len - overlap, 0, 0])
      rotate([0, 90, 0])
        cylinder(h=boss_blend_r*2, r=boss_d/2 + boss_blend_r, center=true);
    translate([body_X/2 - boss_len + overlap, 0, 0])
      rotate([0, 90, 0])
        cylinder(h=boss_blend_r*2, r=boss_d/2 + boss_blend_r, center=true);
  }
}

// Surface Markings
module surface_markings() {
  translate([-boss_len/2, 0, 0])
    cube([overlap, overlap, overlap], center=true);
}

// Final Assembly
difference() {
  union() {
    main_housing_block();
    side_cylindrical_boss();
    keyed_tab_positive_face();
    keyed_tab_opposite_face();
    boss_blend_fillet();
    surface_markings();
  }
  edge_chamfers_or_fillets();
  center_through_bore();
  bore_entry_chamfer_top();
  bore_entry_chamfer_bottom();
}