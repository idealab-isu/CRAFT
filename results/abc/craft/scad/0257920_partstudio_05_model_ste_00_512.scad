// Parameters
bbox_L = 0.04; //[0.02:0.08:0.001]
bbox_W = 0.02; //[0.01:0.04:0.001]
bbox_H = 0.01; //[0.005:0.02:0.001]
plate_L = 0.04; //[0.02:0.08:0.001]
plate_W = 0.02; //[0.01:0.04:0.001]
plate_T = 0.006; //[0.003:0.01:0.001]
ear_chamfer = 0.002; //[0.001:0.004:0.0005]
boss_d_flat = 0.008; //[0.004:0.016:0.001]
boss_h = 0.004; //[0.002:0.008:0.001]
boss_facets = 8; //[6:16:1]
boss_top_chamfer = 0.0008; //[0.0004:0.0016:0.0002]
tab_L = 0.004; //[0.002:0.008:0.001]
tab_W = 0.003; //[0.0015:0.006:0.0005]
tab_T = 0.003; //[0.0015:0.006:0.0005]
hole_d_small = 0.002; //[0.001:0.004:0.0005]
hole_pitch_L = 0.012; //[0.006:0.024:0.001]
hole_pitch_W = 0.008; //[0.004:0.016:0.001]
diamond_across_flats = 0.004; //[0.002:0.008:0.0005]
diamond_rotation_deg = 45; //[0:90:1]
teardrop_r = 0.0012; //[0.0006:0.0024:0.0002]
teardrop_len = 0.0035; //[0.0018:0.007:0.0005]
edge_fillet_r = 0.0006; //[0.0003:0.0012:0.0001]
countersink_d = 0.0032; //[0.0016:0.0064:0.0002]
countersink_h = 0.001; //[0.0005:0.002:0.0001]
overlap = 0.0008; //[0.0004:0.0016:0.0001]
cut_extra = 0.002; //[0.001:0.004:0.0005]

// Base Shapes
module main_plate_body() {
  cube([plate_L, plate_W, plate_T], center=true);
}

module end_tab_right() {
  translate([plate_L/2 + tab_L/2 - overlap, 0, 0])
    cube([tab_L, tab_W, tab_T], center=true);
}

module end_tab_left() {
  translate([-(plate_L/2 + tab_L/2 - overlap), 0, 0])
    cube([tab_L, tab_W, tab_T], center=true);
}

module ear_chamfer_cut_tr() {
  translate([plate_L/2 - ear_chamfer/2, plate_W/2 - ear_chamfer/2, 0])
    rotate([0, 0, 45])
    cube([ear_chamfer, ear_chamfer, plate_T + cut_extra], center=true);
}

module ear_chamfer_cut_tl() {
  translate([-(plate_L/2 - ear_chamfer/2), plate_W/2 - ear_chamfer/2, 0])
    rotate([0, 0, 45])
    cube([ear_chamfer, ear_chamfer, plate_T + cut_extra], center=true);
}

module ear_chamfer_cut_br() {
  translate([plate_L/2 - ear_chamfer/2, -(plate_W/2 - ear_chamfer/2), 0])
    rotate([0, 0, 45])
    cube([ear_chamfer, ear_chamfer, plate_T + cut_extra], center=true);
}

module ear_chamfer_cut_bl() {
  translate([-(plate_L/2 - ear_chamfer/2), -(plate_W/2 - ear_chamfer/2), 0])
    rotate([0, 0, 45])
    cube([ear_chamfer, ear_chamfer, plate_T + cut_extra], center=true);
}

module boss_faceted_prism() {
  translate([0, 0, plate_T/2 + boss_h/2 - overlap])
    linear_extrude(height=boss_h)
    polygon(points=[
      [boss_d_flat/2, 0],
      [boss_d_flat*0.3536, boss_d_flat*0.3536],
      [0, boss_d_flat/2],
      [-boss_d_flat*0.3536, boss_d_flat*0.3536],
      [-boss_d_flat/2, 0],
      [-boss_d_flat*0.3536, -boss_d_flat*0.3536],
      [0, -boss_d_flat/2],
      [boss_d_flat*0.3536, -boss_d_flat*0.3536]
    ]);
}

module boss_top_chamfer_cone() {
  translate([0, 0, plate_T/2 + boss_h - boss_top_chamfer/2 - overlap])
    cylinder(h=boss_top_chamfer, r1=boss_d_flat/2, r2=boss_d_flat/2 - boss_top_chamfer, center=true);
}

module diamond_aperture_1() {
  translate([hole_pitch_L/2, 0, 0])
    rotate([0, 0, diamond_rotation_deg])
    cube([diamond_across_flats, diamond_across_flats, plate_T + cut_extra], center=true);
}

module diamond_aperture_2() {
  translate([-hole_pitch_L/2, 0, 0])
    rotate([0, 0, diamond_rotation_deg])
    cube([diamond_across_flats, diamond_across_flats, plate_T + cut_extra], center=true);
}

module small_round_hole_tr() {
  translate([hole_pitch_L/2, hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=hole_d_small/2, center=true);
}

module small_round_hole_tl() {
  translate([-hole_pitch_L/2, hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=hole_d_small/2, center=true);
}

module small_round_hole_br() {
  translate([hole_pitch_L/2, -hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=hole_d_small/2, center=true);
}

module small_round_hole_bl() {
  translate([-hole_pitch_L/2, -hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=hole_d_small/2, center=true);
}

module counterbore_tr() {
  translate([hole_pitch_L/2, hole_pitch_W/2, plate_T/2 - countersink_h/2])
    cylinder(h=countersink_h + cut_extra/2, r=countersink_d/2, center=true);
}

module counterbore_tl() {
  translate([-hole_pitch_L/2, hole_pitch_W/2, plate_T/2 - countersink_h/2])
    cylinder(h=countersink_h + cut_extra/2, r=countersink_d/2, center=true);
}

module teardrop_circle_top() {
  translate([0, hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=teardrop_r, center=true);
}

module teardrop_circle_bottom() {
  translate([0, -hole_pitch_W/2, 0])
    cylinder(h=plate_T + cut_extra, r=teardrop_r, center=true);
}

module teardrop_tip_top() {
  translate([teardrop_len/2, hole_pitch_W/2, 0])
    sphere(r=teardrop_r, center=true);
}

module teardrop_tip_bottom() {
  translate([teardrop_len/2, -hole_pitch_W/2, 0])
    sphere(r=teardrop_r, center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_r, center=true);
}

// Operations
module end_tab_extensions() {
  union() {
    end_tab_right();
    end_tab_left();
  }
}

module plate_with_tabs() {
  union() {
    main_plate_body();
    end_tab_extensions();
  }
}

module corner_ears_chamfers() {
  difference() {
    plate_with_tabs();
    ear_chamfer_cut_tr();
    ear_chamfer_cut_tl();
    ear_chamfer_cut_br();
    ear_chamfer_cut_bl();
  }
}

module central_faceted_boss() {
  union() {
    boss_faceted_prism();
    boss_top_chamfer_cone();
  }
}

module diamond_apertures() {
  union() {
    diamond_aperture_1();
    diamond_aperture_2();
  }
}

module small_round_holes() {
  union() {
    small_round_hole_tr();
    small_round_hole_tl();
    small_round_hole_br();
    small_round_hole_bl();
  }
}

module countersinks_or_counterbores() {
  union() {
    counterbore_tr();
    counterbore_tl();
  }
}

module teardrop_like_holes() {
  hull() {
    teardrop_circle_top();
    teardrop_tip_top();
  }
}

module teardrop_like_holes_mirror() {
  hull() {
    teardrop_circle_bottom();
    teardrop_tip_bottom();
  }
}

module teardrop_like_holes_pair() {
  union() {
    teardrop_like_holes();
    teardrop_like_holes_mirror();
  }
}

module through_hole_pattern_primary() {
  union() {
    diamond_apertures();
    small_round_holes();
    teardrop_like_holes_pair();
    countersinks_or_counterbores();
  }
}

module plate_tabs_boss_union() {
  union() {
    corner_ears_chamfers();
    central_faceted_boss();
  }
}

module plate_with_holes() {
  difference() {
    plate_tabs_boss_union();
    through_hole_pattern_primary();
  }
}

module edge_fillets() {
  minkowski() {
    plate_with_holes();
    edge_fillet_sphere();
  }
}

module symmetric_layout_constraints() {
  union() {
    edge_fillets();
    edge_fillets();
  }
}

// Final Output
symmetric_layout_constraints();