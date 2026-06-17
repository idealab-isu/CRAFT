// Parameters
bbox_x = 0.06; //[0.03:0.12:0.001]
bbox_y = 0.06; //[0.03:0.12:0.001]
bbox_z = 0.05; //[0.025:0.1:0.001]
body_x = 0.048; //[0.024:0.096:0.001]
body_y = 0.06; //[0.03:0.12:0.001]
body_z = 0.05; //[0.025:0.1:0.001]
bore_d = 0.02; //[0.01:0.04:0.001]
boss_d = 0.018; //[0.009:0.036:0.001]
boss_len = 0.012; //[0.006:0.024:0.001]
tab_depth = 0.006; //[0.003:0.012:0.001]
tab_len = 0.02; //[0.01:0.04:0.001]
tab_z = 0.012; //[0.006:0.024:0.001]
overlap = 0.001; //[0.0005:0.002:0.0001]
lead_in_h = 0.006; //[0.003:0.012:0.001]
lead_in_d = 0.028; //[0.022:0.04:0.001]
edge_relief = 0.004; //[0.002:0.008:0.001]
boss_blend_r = 0.003; //[0.0015:0.006:0.0005]

// Main body
module main_body() {
  cube([body_x, body_y, body_z], center=true);
}

// Center through-bore
module center_through_bore() {
  cylinder(h=body_z + 2*overlap, r=bore_d/2, center=true);
}

// Side boss
module side_boss() {
  rotate([0, 90, 0])
    translate([body_x/2 + boss_len/2 - overlap, 0, 0])
      cylinder(h=boss_len, r=boss_d/2, center=true);
}

// Key tab on positive face
module key_tab_pos_face() {
  translate([body_x/2 + tab_depth/2 - overlap, 0, 0])
    cube([tab_depth, tab_len, tab_z], center=true);
}

// Key tab on negative face
module key_tab_neg_face() {
  translate([-body_x/2 - (tab_depth*0.7)/2 + overlap, body_y*0.15, -body_z*0.1])
    cube([tab_depth*0.7, tab_len*0.8, tab_z*0.9], center=true);
}

// Edge chamfer cuts
module edge_chamfer_cut(x, y) {
  translate([x, y, 0])
    cube([edge_relief, edge_relief, body_z + 2*overlap], center=true);
}

// Bore lead-in chamfers
module bore_lead_in_top() {
  translate([0, 0, body_z/2 - lead_in_h/2 + overlap])
    cylinder(h=lead_in_h, r1=lead_in_d/2, r2=0, center=true);
}

module bore_lead_in_bottom() {
  translate([0, 0, -body_z/2 + lead_in_h/2 - overlap])
    rotate([180, 0, 0])
      cylinder(h=lead_in_h, r1=lead_in_d/2, r2=0, center=true);
}

// Boss blend fillet
module boss_blend_fillet() {
  hull() {
    translate([body_x/2 - overlap, boss_d/2 - boss_blend_r, 0])
      sphere(r=boss_blend_r, center=true);
    translate([body_x/2 - overlap, -boss_d/2 + boss_blend_r, 0])
      sphere(r=boss_blend_r, center=true);
    translate([body_x/2 + boss_len/2 - overlap, boss_d/2 - boss_blend_r, 0])
      sphere(r=boss_blend_r, center=true);
    translate([body_x/2 + boss_len/2 - overlap, -boss_d/2 + boss_blend_r, 0])
      sphere(r=boss_blend_r, center=true);
  }
}

// Final model
difference() {
  union() {
    main_body();
    side_boss();
    key_tab_pos_face();
    key_tab_neg_face();
    boss_blend_fillet();
  }
  edge_chamfer_cut(body_x/2 - edge_relief/2, body_y/2 - edge_relief/2);
  edge_chamfer_cut(body_x/2 - edge_relief/2, -body_y/2 + edge_relief/2);
  edge_chamfer_cut(-body_x/2 + edge_relief/2, body_y/2 - edge_relief/2);
  edge_chamfer_cut(-body_x/2 + edge_relief/2, -body_y/2 + edge_relief/2);
  union() {
    center_through_bore();
    bore_lead_in_top();
    bore_lead_in_bottom();
  }
}