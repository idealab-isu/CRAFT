// Parameters
L = 12.0; //[6.0:24.0:0.1]
OD_max = 27.23; //[13.615:54.46:0.01]
OD_mid = 24.8; //[12.4:49.6:0.1]
OD_end_collar = 26.2; //[13.1:52.4:0.1]
OD_recess = 22.6; //[11.3:45.2:0.1]
bore_D = 14.0; //[7.0:28.0:0.1]
collar_len = 1.2; //[0.6:2.4:0.05]
mid_len = 7.2; //[3.6:14.4:0.1]
recess_band_w = 1.4; //[0.7:2.8:0.05]
recess_band_gap = 1.2; //[0.6:2.4:0.05]
groove_w_small = 0.8; //[0.4:1.6:0.05]
groove_depth_small = 0.6; //[0.3:1.2:0.05]
rib_w_small = 0.7; //[0.35:1.4:0.05]
rib_height_small = 0.5; //[0.25:1.0:0.05]
eps = 0.8; //[0.2:2.0:0.1]
chamfer_z = 0.6; //[0.2:1.2:0.05]
chamfer_rad = 0.6; //[0.2:1.2:0.05]
micro_rib_count = 10; //[4:24:1]
micro_groove_w = 0.25; //[0.1:0.6:0.01]
micro_groove_depth = 0.15; //[0.05:0.4:0.01]

// Base shapes
module outer_mid_cyl() {
  cylinder(r=OD_mid/2, h=mid_len, center=true);
}

module left_collar_cyl() {
  translate([0, 0, -(mid_len/2 + collar_len/2 - eps)])
    cylinder(r=OD_end_collar/2, h=collar_len, center=true);
}

module right_collar_cyl() {
  translate([0, 0, (mid_len/2 + collar_len/2 - eps)])
    cylinder(r=OD_end_collar/2, h=collar_len, center=true);
}

module left_end_cap_max() {
  translate([0, 0, -(L/2 - chamfer_z)])
    cylinder(r=OD_max/2, h=chamfer_z*2, center=true);
}

module right_end_cap_max() {
  translate([0, 0, (L/2 - chamfer_z)])
    cylinder(r=OD_max/2, h=chamfer_z*2, center=true);
}

module recess_band1_cut() {
  translate([0, 0, -(recess_band_gap/2 + recess_band_w/2)])
    cylinder(r=OD_mid/2, h=recess_band_w, center=true);
}

module recess_band2_cut() {
  translate([0, 0, (recess_band_gap/2 + recess_band_w/2)])
    cylinder(r=OD_mid/2, h=recess_band_w, center=true);
}

module small_groove_left_cut() {
  translate([0, 0, -(mid_len/2 - groove_w_small/2)])
    cylinder(r=OD_end_collar/2, h=groove_w_small, center=true);
}

module small_groove_right_cut() {
  translate([0, 0, (mid_len/2 - groove_w_small/2)])
    cylinder(r=OD_end_collar/2, h=groove_w_small, center=true);
}

module rib_left_ring() {
  translate([0, 0, -(mid_len/2 - rib_w_small/2 - groove_w_small - eps)])
    cylinder(r=(OD_mid/2 + rib_height_small), h=rib_w_small, center=true);
}

module rib_right_ring() {
  translate([0, 0, (mid_len/2 - rib_w_small/2 - groove_w_small - eps)])
    cylinder(r=(OD_mid/2 + rib_height_small), h=rib_w_small, center=true);
}

module micro_groove_cut(n) {
  translate([0, 0, -(mid_len/2) + (mid_len/(micro_rib_count+1))*n])
    cylinder(r=OD_mid/2, h=micro_groove_w, center=true);
}

module bore_cyl() {
  cylinder(r=bore_D/2, h=L + 2*eps, center=true);
}

module chamfer_left_cone_cut() {
  translate([0, 0, -(L/2 - chamfer_z/2)])
    rotate([180, 0, 0])
    cylinder(r1=OD_max/2, r2=0, h=chamfer_z, center=true);
}

module chamfer_right_cone_cut() {
  translate([0, 0, (L/2 - chamfer_z/2)])
    cylinder(r1=OD_max/2, r2=0, h=chamfer_z, center=true);
}

// Operations
module outer_stepped_cylindrical_body() {
  union() {
    outer_mid_cyl();
    left_collar_cyl();
    right_collar_cyl();
    left_end_cap_max();
    right_end_cap_max();
  }
}

module additional_circumferential_grooves_ribs() {
  union() {
    rib_left_ring();
    rib_right_ring();
  }
}

module outer_with_ribs() {
  union() {
    outer_stepped_cylindrical_body();
    additional_circumferential_grooves_ribs();
  }
}

module midsection_recessed_band_1() {
  difference() {
    outer_with_ribs();
    recess_band1_cut();
  }
}

module midsection_recessed_band_2() {
  difference() {
    midsection_recessed_band_1();
    recess_band2_cut();
  }
}

module outer_with_small_grooves() {
  difference() {
    midsection_recessed_band_2();
    small_groove_left_cut();
    small_groove_right_cut();
  }
}

module micro_ribbing_texture() {
  difference() {
    outer_with_small_grooves();
    for (i = [1:micro_rib_count])
      micro_groove_cut(i);
  }
}

module small_edge_chamfers_fillets() {
  difference() {
    micro_ribbing_texture();
    chamfer_left_cone_cut();
    chamfer_right_cone_cut();
  }
}

module internal_axial_bore() {
  difference() {
    small_edge_chamfers_fillets();
    bore_cyl();
  }
}

// Final output
internal_axial_bore();