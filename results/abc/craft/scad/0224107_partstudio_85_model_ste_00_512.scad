// Dimension-calibrated (target: 0.01 x 0.01 x 0.01 mm)
scale([1.041667, 1.051462, 1.188119])
{
// Parameters
bbox_x = 0.01; //[0.005:0.02:0.0001]
bbox_y = 0.01; //[0.005:0.02:0.0001]
bbox_z = 0.01; //[0.005:0.02:0.0001]
body_od = 0.0092; //[0.0046:0.0184:0.0001]
body_len = 0.0096; //[0.0048:0.0192:0.0001]
flange_od = 0.01; //[0.005:0.02:0.0001]
flange_len = 0.0012; //[0.0006:0.0024:0.0001]
hex_af = 0.0048; //[0.0024:0.0096:0.0001]
knurl_band1_len = 0.0016; //[0.0008:0.0032:0.0001]
knurl_band2_len = 0.0016; //[0.0008:0.0032:0.0001]
knurl_depth = 0.00025; //[0.0001:0.0005:0.00001]
knurl_teeth = 18; //[6:48:1]
overlap = 0.0005; //[0.0002:0.001:0.0001]
hex_radius = 0.002771; //[0.001385:0.005542:0.00001]
chamfer_len = 0.0004; //[0.0002:0.0008:0.00005]
chamfer_rad = 0.0004; //[0.0002:0.0008:0.00005]
serration_depth = 0.00018; //[0.00008:0.00036:0.00001]
serration_len = 0.0012; //[0.0006:0.0024:0.0001]
serration_teeth = 12; //[6:36:1]

// Base Shapes
module main_cylindrical_body() {
  translate([0, 0, 0])
    cylinder(r=body_od/2, h=body_len, center=true);
}

module stepped_end_flange() {
  translate([0, 0, body_len/2 - flange_len/2 + overlap])
    cylinder(r=flange_od/2, h=flange_len, center=true);
}

module through_hex_bore() {
  translate([0, 0, 0])
    linear_extrude(height=body_len + flange_len + 2*overlap, center=true)
      polygon(points=[
        [hex_radius, 0],
        [hex_radius/2, hex_radius*0.866025403784],
        [-hex_radius/2, hex_radius*0.866025403784],
        [-hex_radius, 0],
        [-hex_radius/2, -hex_radius*0.866025403784],
        [hex_radius/2, -hex_radius*0.866025403784]
      ]);
}

module upper_knurl_grip_band_base() {
  translate([0, 0, body_len/2 - flange_len - knurl_band1_len/2])
    cylinder(r=body_od/2 + knurl_depth, h=knurl_band1_len, center=true);
}

module lower_knurl_grip_band_base() {
  translate([0, 0, -body_len/2 + knurl_band2_len/2])
    cylinder(r=body_od/2 + knurl_depth, h=knurl_band2_len, center=true);
}

module mid_circumference_facet_serrations_base() {
  translate([0, 0, 0])
    cylinder(r=body_od/2 + serration_depth, h=serration_len, center=true);
}

module lower_circumference_facet_serrations_base() {
  translate([0, 0, -body_len/2 + knurl_band2_len + serration_len/2])
    cylinder(r=body_od/2 + serration_depth, h=serration_len, center=true);
}

module edge_chamfer_top_cone() {
  translate([0, 0, body_len/2 + chamfer_len/2 - overlap])
    cylinder(r1=flange_od/2, r2=flange_od/2 - chamfer_rad, h=chamfer_len, center=true);
}

module edge_chamfer_bottom_cone() {
  translate([0, 0, -body_len/2 - chamfer_len/2 + overlap])
    cylinder(r1=body_od/2, r2=body_od/2 - chamfer_rad, h=chamfer_len, center=true);
}

module knurl_tooth_proto() {
  translate([body_od/2 + knurl_depth - overlap, 0, 0])
    cube([knurl_depth*2, body_od*0.12, knurl_band1_len], center=true);
}

module serration_tooth_proto() {
  translate([body_od/2 + serration_depth - overlap, 0, 0])
    cube([serration_depth*2, body_od*0.14, serration_len], center=true);
}

// Operations
module upper_knurl_grip_band() {
  union() {
    upper_knurl_grip_band_base();
    for (i = [0:knurl_teeth-1]) {
      rotate([0, 0, i*360/knurl_teeth])
        knurl_tooth_proto();
    }
  }
}

module lower_knurl_grip_band() {
  union() {
    lower_knurl_grip_band_base();
    for (i = [0:knurl_teeth-1]) {
      rotate([0, 0, i*360/knurl_teeth])
        translate([0, 0, -body_len/2 + knurl_band2_len/2])
          knurl_tooth_proto();
    }
  }
}

module mid_circumference_facet_serrations() {
  union() {
    mid_circumference_facet_serrations_base();
    for (i = [0:serration_teeth-1]) {
      rotate([0, 0, i*360/serration_teeth])
        serration_tooth_proto();
    }
  }
}

module lower_circumference_facet_serrations() {
  union() {
    lower_circumference_facet_serrations_base();
    for (i = [0:serration_teeth-1]) {
      rotate([0, 0, i*360/serration_teeth])
        translate([0, 0, -body_len/2 + knurl_band2_len + serration_len/2])
          serration_tooth_proto();
    }
  }
}

module body_plus_flange() {
  union() {
    main_cylindrical_body();
    stepped_end_flange();
  }
}

module outer_with_grips() {
  union() {
    body_plus_flange();
    upper_knurl_grip_band();
    lower_knurl_grip_band();
    mid_circumference_facet_serrations();
    lower_circumference_facet_serrations();
  }
}

module edge_chamfers_fillets() {
  union() {
    edge_chamfer_top_cone();
    edge_chamfer_bottom_cone();
  }
}

module outer_with_chamfers() {
  union() {
    outer_with_grips();
    edge_chamfers_fillets();
  }
}

module final_sleeve_solid() {
  difference() {
    outer_with_chamfers();
    through_hex_bore();
  }
}

// Final Output
final_sleeve_solid();
}
