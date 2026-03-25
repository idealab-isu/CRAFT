// Parameters
bbox_L = 46.19; //[23.1:92.38:0.01]
bbox_W = 40.0; //[20.0:80.0:0.01]
H = 10.0; //[5.0:20.0:0.1]
outer_hex_flat_to_flat = 40.0; //[20.0:80.0:0.01]
outer_hex_point_to_point = 46.19; //[23.1:92.38:0.01]
bore_d = 26.0; //[13.0:52.0:0.1]
lug_count = 10; //[6:24:1]
lug_radial_depth = 2.2; //[1.1:4.4:0.1]
lug_tangential_width = 4.0; //[2.0:8.0:0.1]
lug_height = 10.0; //[5.0:20.0:0.1]
recess_depth = 2.0; //[1.0:4.0:0.1]
recess_ID = 28.0; //[14.0:56.0:0.1]
recess_OD = 36.0; //[18.0:72.0:0.1]
eps_overlap = 0.8; //[0.2:2.0:0.1]
chamfer_size = 0.8; //[0.0:2.0:0.1]
fillet_r = 0.6; //[0.0:2.0:0.1]
lug_relief_r = 0.5; //[0.0:1.5:0.1]

// Base Shapes
module outer_hex_profile() {
  linear_extrude(height=H) {
    polygon(points=[
      [outer_hex_point_to_point/2, 0],
      [outer_hex_point_to_point/4, outer_hex_flat_to_flat/2],
      [-outer_hex_point_to_point/4, outer_hex_flat_to_flat/2],
      [-outer_hex_point_to_point/2, 0],
      [-outer_hex_point_to_point/4, -outer_hex_flat_to_flat/2],
      [outer_hex_point_to_point/4, -outer_hex_flat_to_flat/2]
    ]);
  }
}

module central_bore_cyl() {
  translate([0, 0, 0])
    cylinder(r=bore_d/2, h=H + 2*eps_overlap, center=true);
}

module recess_outer_cyl() {
  translate([0, 0, H/2 - (recess_depth + eps_overlap)/2])
    cylinder(r=recess_OD/2, h=recess_depth + eps_overlap, center=true);
}

module recess_inner_cyl() {
  translate([0, 0, H/2 - (recess_depth + eps_overlap)/2])
    cylinder(r=recess_ID/2, h=recess_depth + 2*eps_overlap, center=true);
}

module lug_tooth_base() {
  translate([bore_d/2 - lug_radial_depth/2 + eps_overlap, 0, 0])
    cube([lug_radial_depth, lug_tangential_width, lug_height + 2*eps_overlap], center=true);
}

module lug_relief_cyl_base() {
  translate([bore_d/2 + eps_overlap, 0, 0])
    cylinder(r=lug_relief_r, h=lug_height + 2*eps_overlap, center=true);
}

module chamfer_top_frustum() {
  translate([0, 0, H/2 - (chamfer_size + eps_overlap)/2])
    cylinder(r1=outer_hex_point_to_point/2 + chamfer_size, r2=outer_hex_point_to_point/2 - chamfer_size, h=chamfer_size + eps_overlap, center=true);
}

module chamfer_bottom_frustum() {
  translate([0, 0, -H/2 + (chamfer_size + eps_overlap)/2])
    cylinder(r1=outer_hex_point_to_point/2 + chamfer_size, r2=outer_hex_point_to_point/2 - chamfer_size, h=chamfer_size + eps_overlap, center=true);
}

module fillet_sphere() {
  sphere(r=fillet_r, center=true);
}

module alignment_mark_dummy() {
  cube([eps_overlap, eps_overlap, eps_overlap], center=true);
}

// Operations
module outer_hex_centered() {
  translate([0, 0, -H/2])
    outer_hex_profile();
}

module recess_annulus_pocket() {
  difference() {
    recess_outer_cyl();
    recess_inner_cyl();
  }
}

module internal_rectangular_lugs_teeth_array() {
  union() {
    for (i = [0:lug_count-1]) {
      rotate([0, 0, i*360/lug_count])
        lug_tooth_base();
    }
  }
}

module small_relief_radii_on_lugs() {
  union() {
    for (i = [0:lug_count-1]) {
      rotate([0, 0, i*360/lug_count])
        lug_relief_cyl_base();
    }
  }
}

module outer_hex_collar_body_raw() {
  difference() {
    outer_hex_centered();
    central_bore_cyl();
    recess_annulus_pocket();
    chamfer_top_frustum();
    chamfer_bottom_frustum();
    small_relief_radii_on_lugs();
  }
}

module outer_hex_collar_body() {
  union() {
    outer_hex_collar_body_raw();
    internal_rectangular_lugs_teeth_array();
    alignment_mark_dummy();
  }
}

module edge_fillets() {
  minkowski() {
    outer_hex_collar_body();
    fillet_sphere();
  }
}

module complete_model() {
  edge_fillets();
}

// Final Output
complete_model();