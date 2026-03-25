// Parameters
L = 97.5; //[48.75:195:0.5]
OD_max = 19; //[9.5:38:0.5]
OD_min = 14; //[7:28:0.5]
ID = 10; //[5:18:0.5]
L_sec1 = 40; //[20:80:0.5]
L_trans = 10; //[5:20:0.5]
L_sec2 = 47.5; //[23.75:95:0.5]
overlap = 1; //[0.5:2:0.1]
csk_depth = 2; //[1:5:0.5]
csk_ID = 12; //[10.5:18:0.5]
chamfer = 0.8; //[0.3:2:0.1]
fillet_r = 0.6; //[0.2:2:0.1]

// Base Shapes
module outer_sec1_cyl() {
  translate([0, 0, -L/2 + L_sec1/2])
    cylinder(h=L_sec1, r=OD_max/2, center=true);
}

module outer_trans_cone() {
  translate([0, 0, -L/2 + L_sec1 + L_trans/2])
    cylinder(h=L_trans, r1=OD_max/2, r2=OD_min/2, center=true);
}

module outer_sec2_cyl() {
  translate([0, 0, -L/2 + L_sec1 + L_trans + L_sec2/2])
    cylinder(h=L_sec2, r=OD_min/2, center=true);
}

module through_bore_cyl() {
  translate([0, 0, 0])
    cylinder(h=L + 2*overlap, r=ID/2, center=true);
}

module csk_top_cone() {
  translate([0, 0, L/2 - csk_depth/2])
    cylinder(h=csk_depth, r1=csk_ID/2, r2=ID/2, center=true);
}

module csk_bot_cone() {
  translate([0, 0, -L/2 + csk_depth/2])
    cylinder(h=csk_depth, r1=ID/2, r2=csk_ID/2, center=true);
}

module outer_chamfer_top_cone() {
  translate([0, 0, -L/2 + chamfer])
    cylinder(h=2*chamfer, r1=OD_max/2 + chamfer, r2=OD_max/2 - chamfer, center=true);
}

module outer_chamfer_bot_cone() {
  translate([0, 0, L/2 - chamfer])
    cylinder(h=2*chamfer, r1=OD_min/2 - chamfer, r2=OD_min/2 + chamfer, center=true);
}

// Operations
module outer_union() {
  union() {
    outer_sec1_cyl();
    outer_trans_cone();
    outer_sec2_cyl();
  }
}

module outer_with_chamfers() {
  difference() {
    outer_union();
    outer_chamfer_top_cone();
    outer_chamfer_bot_cone();
  }
}

module bore_with_countersinks() {
  union() {
    through_bore_cyl();
    csk_top_cone();
    csk_bot_cone();
  }
}

// Final Bushing
module final_bushing() {
  difference() {
    outer_with_chamfers();
    bore_with_countersinks();
  }
}

// Render the final bushing
color("Silver") final_bushing();