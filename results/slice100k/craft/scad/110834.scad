// Parameters
bbox_x = 21.25; //[10.6:42.5:0.01]
bbox_y = 21.13; //[10.6:42.3:0.01]
H_total = 10; //[5:20:0.1]
D_flange = 21.13; //[10.6:42.3:0.01]
D_sleeve = 16; //[8:32:0.1]
t_flange = 2; //[1:5:0.1]
D_bore = 8; //[3:14:0.1]
ecc_offset = 2.5; //[0:4:0.1]
chamfer_outer = 0.6; //[0:1.5:0.1]
chamfer_bore = 0.5; //[0:1.5:0.1]
fillet_r = 0.4; //[0:1.2:0.1]
eps_overlap = 0.8; //[0.2:2:0.1]

// Base Shapes
module outer_sleeve_cylinder() {
  translate([0, 0, 0])
    cylinder(h=H_total, r=D_sleeve/2, center=true);
}

module end_flange_lip() {
  translate([0, 0, H_total/2 - t_flange/2])
    cylinder(h=t_flange, r=D_flange/2, center=true);
}

module sleeve_to_flange_step_face() {
  translate([0, 0, H_total/2 - t_flange/2])
    cylinder(h=t_flange, r=D_sleeve/2, center=true);
}

module eccentric_through_bore() {
  translate([ecc_offset, 0, 0])
    cylinder(h=H_total + 2*eps_overlap, r=D_bore/2, center=true);
}

module bore_chamfer_top_cone() {
  translate([ecc_offset, 0, H_total/2 - chamfer_bore/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_bore, r1=D_bore/2 + chamfer_bore, r2=0, center=true);
}

module bore_chamfer_bottom_cone() {
  translate([ecc_offset, 0, -H_total/2 + chamfer_bore/2])
    cylinder(h=chamfer_bore, r1=D_bore/2 + chamfer_bore, r2=0, center=true);
}

module edge_chamfers_flange_top_cone() {
  translate([0, 0, H_total/2 - chamfer_outer/2])
    rotate([180, 0, 0])
    cylinder(h=chamfer_outer, r1=D_flange/2 + chamfer_outer, r2=0, center=true);
}

module edge_chamfers_sleeve_bottom_cone() {
  translate([0, 0, -H_total/2 + chamfer_outer/2])
    cylinder(h=chamfer_outer, r1=D_sleeve/2 + chamfer_outer, r2=0, center=true);
}

module edge_chamfers_flange_underside_cone() {
  translate([0, 0, H_total/2 - t_flange + chamfer_outer/2])
    cylinder(h=chamfer_outer, r1=D_flange/2 + chamfer_outer, r2=0, center=true);
}

module edge_fillets_kernel_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

// Operations
module union_outer_body() {
  union() {
    outer_sleeve_cylinder();
    end_flange_lip();
    sleeve_to_flange_step_face();
  }
}

module difference_outer_chamfers() {
  difference() {
    union_outer_body();
    edge_chamfers_flange_top_cone();
    edge_chamfers_sleeve_bottom_cone();
    edge_chamfers_flange_underside_cone();
  }
}

module difference_bore_and_bore_chamfers() {
  difference() {
    difference_outer_chamfers();
    eccentric_through_bore();
    bore_chamfer_top_cone();
    bore_chamfer_bottom_cone();
  }
}

module edge_fillets() {
  minkowski() {
    difference_bore_and_bore_chamfers();
    edge_fillets_kernel_sphere();
  }
}

// Final Output
edge_fillets();