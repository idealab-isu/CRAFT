// Parameters
L = 50; //[25:100:1]
ID = 6; //[3:12:0.1]
wall = 0.6; //[0.3:1.2:0.05]
OD = 7.2; //[3.6:14.4:0.1]
shrink_ratio = 2; //[1.2:4:0.1]
ID_recovered = 3; //[1.5:6:0.1]
overlap = 1; //[0.5:2:0.1]
chamfer_L = 1.2; //[0.6:2.4:0.1]
mark_band_w = 6; //[3:12:0.5]
mark_band_t = 0.25; //[0.1:0.6:0.05]
texture_depth = 0.15; //[0.05:0.4:0.05]
texture_pitch = 2.5; //[1.5:6:0.1]

// Base Shapes
module sleeve_body_outer() {
  cylinder(r=OD/2, h=L, center=true);
}

module inner_bore() {
  cylinder(r=ID/2, h=L + 2*overlap, center=true);
}

module end_chamfer_top_cut() {
  translate([0, 0, L/2 - chamfer_L/2 + overlap/2])
    cylinder(r1=OD/2 + overlap, r2=ID/2 - overlap, h=chamfer_L, center=true);
}

module end_chamfer_bottom_cut() {
  translate([0, 0, -L/2 + chamfer_L/2 - overlap/2])
    cylinder(r1=ID/2 - overlap, r2=OD/2 + overlap, h=chamfer_L, center=true);
}

module printed_marking_band() {
  cylinder(r=OD/2 + mark_band_t, h=mark_band_w, center=true);
}

module texture_groove_cutter() {
  rotate([90, 0, 0])
    cylinder(r=OD/2 + overlap, h=texture_depth, center=true);
}

module post_shrink_outer() {
  translate([OD/2 + ((ID_recovered/2) + wall) + 3*overlap, 0, 0])
    cylinder(r=(ID_recovered/2) + wall, h=L, center=true);
}

module post_shrink_inner_bore() {
  translate([OD/2 + ((ID_recovered/2) + wall) + 3*overlap, 0, 0])
    cylinder(r=ID_recovered/2, h=L + 2*overlap, center=true);
}

// Operations
module sleeve_hollow() {
  difference() {
    sleeve_body_outer();
    inner_bore();
  }
}

module sleeve_with_end_chamfers() {
  difference() {
    sleeve_hollow();
    end_chamfer_top_cut();
    end_chamfer_bottom_cut();
  }
}

module sleeve_with_marking_band() {
  union() {
    sleeve_with_end_chamfers();
    printed_marking_band();
  }
}

module surface_texture() {
  difference() {
    sleeve_with_marking_band();
    for (i = [1:5]) {
      translate([0, 0, -L/2 + (i*L/(floor(L/texture_pitch)+1))])
        texture_groove_cutter();
    }
  }
}

module post_shrink_variant() {
  difference() {
    post_shrink_outer();
    post_shrink_inner_bore();
  }
}

// Final Model
module complete_model() {
  union() {
    surface_texture();
    post_shrink_variant();
  }
}

// Render the complete model
color([0.85, 0.85, 0.8]) // Off-white for heatshrink
complete_model();