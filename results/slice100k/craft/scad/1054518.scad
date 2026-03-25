// Parameters
bbox_x = 10.14; //[5.07:20.28:0.01]
bbox_y = 10.16; //[5.08:20.32:0.01]
H_total = 8.01; //[4.0:16.02:0.01]
D_flange = 10.16; //[5.08:20.32:0.01]
D_boss = 8.0; //[4.0:16.0:0.01]
H_flange = 3.0; //[1.5:6.0:0.01]
H_boss = 5.01; //[2.5:10.02:0.01]
D_bore = 4.0; //[2.0:8.0:0.01]
cut_depth = 2.2; //[1.1:4.4:0.01]
cut_width = 10.2; //[5.1:20.4:0.01]
cut_z0 = 3.0; //[0.0:8.01:0.01]
eps_overlap = 0.6; //[0.2:2.0:0.01]
bore_lead_in_h = 0.6; //[0.2:1.2:0.01]
bore_lead_in_deltaD = 0.8; //[0.2:1.6:0.01]
edge_chamfer_h = 0.4; //[0.1:1.0:0.01]
edge_chamfer_deltaD = 0.8; //[0.2:1.6:0.01]
fillet_r = 0.25; //[0.1:0.6:0.01]
cutout_round_r = 0.2; //[0.1:0.6:0.01]

// Base Shapes
module lower_flange_cylinder() {
  translate([0, 0, -H_total/2 + H_flange/2])
    cylinder(r=D_flange/2, h=H_flange, center=true);
}

module upper_boss_cylinder() {
  translate([0, 0, -H_total/2 + H_flange + H_boss/2])
    cylinder(r=D_boss/2, h=H_boss, center=true);
}

module through_bore_cylinder() {
  translate([0, 0, 0])
    cylinder(r=D_bore/2, h=H_total + 2*eps_overlap, center=true);
}

module upper_side_cutout_flat() {
  translate([D_boss/2 - cut_depth/2, 0, -H_total/2 + cut_z0 + H_boss/2])
    cube([cut_depth + eps_overlap, cut_width, H_boss + 2*eps_overlap], center=true);
}

module step_shoulder_interface() {
  translate([0, 0, -H_total/2 + H_flange - eps_overlap/2])
    cylinder(r=D_boss/2, h=eps_overlap, center=true);
}

module small_lead_in_on_bore_top_cone() {
  translate([0, 0, H_total/2 - bore_lead_in_h/2 + eps_overlap/2])
    cylinder(r1=D_bore/2 + bore_lead_in_deltaD/2, r2=D_bore/2, h=bore_lead_in_h, center=true);
}

module small_lead_in_on_bore_bottom_cone() {
  translate([0, 0, -H_total/2 + bore_lead_in_h/2 - eps_overlap/2])
    cylinder(r1=D_bore/2 + bore_lead_in_deltaD/2, r2=D_bore/2, h=bore_lead_in_h, center=true);
}

module edge_chamfers_top_outer_cone() {
  translate([0, 0, H_total/2 - edge_chamfer_h/2 + eps_overlap/2])
    cylinder(r1=D_boss/2 + edge_chamfer_deltaD/2, r2=D_boss/2, h=edge_chamfer_h, center=true);
}

module edge_chamfers_bottom_outer_cone() {
  translate([0, 0, -H_total/2 + edge_chamfer_h/2 - eps_overlap/2])
    cylinder(r1=D_flange/2 + edge_chamfer_deltaD/2, r2=D_flange/2, h=edge_chamfer_h, center=true);
}

module edge_fillets_sphere() {
  translate([0, 0, 0])
    sphere(r=fillet_r, center=true);
}

module cosmetic_rounding_on_cutout_edges_sphere() {
  translate([0, 0, 0])
    sphere(r=cutout_round_r, center=true);
}

// Operations
module union_main_solids() {
  union() {
    lower_flange_cylinder();
    upper_boss_cylinder();
    step_shoulder_interface();
  }
}

module difference_bore_and_cutout() {
  difference() {
    union_main_solids();
    through_bore_cylinder();
    upper_side_cutout_flat();
    small_lead_in_on_bore_top_cone();
    small_lead_in_on_bore_bottom_cone();
    edge_chamfers_top_outer_cone();
    edge_chamfers_bottom_outer_cone();
  }
}

module edge_fillets() {
  minkowski() {
    difference_bore_and_cutout();
    edge_fillets_sphere();
  }
}

module cosmetic_rounding_on_cutout_edges() {
  minkowski() {
    edge_fillets();
    cosmetic_rounding_on_cutout_edges_sphere();
  }
}

// Final Output
cosmetic_rounding_on_cutout_edges();