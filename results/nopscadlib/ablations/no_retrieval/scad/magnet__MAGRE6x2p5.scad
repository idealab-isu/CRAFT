// Parameters
outer_diameter = 12; //[6:24:0.5]
thickness = 2; //[1:4:0.1]
bore_diameter = 6; //[3:12:0.5]
pole_count = 8; //[2:24:1]
marker_depth = 0.2; //[0.05:0.6:0.05]
marker_gap = 0.1; //[0.05:0.5:0.05]
overlap = 0.8; //[0.2:2:0.1]
chamfer_size = 0.3; //[0.1:1:0.05]
hub_outer_diameter = 8; //[4:16:0.5]
hub_height = 1.2; //[0.5:3:0.1]
orientation_mark_width = 0.6; //[0.3:1.5:0.1]
orientation_mark_depth = 0.3; //[0.1:1:0.05]

// Base Shapes
module magnet_outer_cyl() {
  translate([0, 0, 0])
    cylinder(r=outer_diameter/2, h=thickness, center=true);
}

module center_bore_cyl() {
  translate([0, 0, 0])
    cylinder(r=bore_diameter/2, h=thickness + 2*overlap, center=true);
}

module mounting_hub_cyl() {
  translate([0, 0, thickness/2 + hub_height/2 - overlap])
    cylinder(r=hub_outer_diameter/2, h=hub_height, center=true);
}

module chamfer_top_cone_cut() {
  translate([0, 0, thickness/2 - chamfer_size/2 + overlap/2])
    cylinder(r1=outer_diameter/2, r2=0, h=chamfer_size, center=true);
}

module chamfer_bottom_cone_cut() {
  translate([0, 0, -thickness/2 + chamfer_size/2 - overlap/2])
    cylinder(r1=outer_diameter/2, r2=0, h=chamfer_size, center=true);
}

module pole_marker_groove_base() {
  translate([(bore_diameter/2 + (outer_diameter/2 - bore_diameter/2)/2) - overlap, 0, thickness/2 - marker_depth/2 + overlap/2])
    cube([outer_diameter/2 - bore_diameter/2 + 2*overlap, marker_gap, marker_depth + 2*overlap], center=true);
}

module orientation_mark_cut() {
  translate([outer_diameter/2 - orientation_mark_depth/2 + overlap/2, 0, 0])
    cube([orientation_mark_depth + 2*overlap, orientation_mark_width, thickness + 2*overlap], center=true);
}

// Operations
module magnet_body_with_hub_union() {
  union() {
    magnet_outer_cyl();
    mounting_hub_cyl();
  }
}

module magnet_body_minus_bore() {
  difference() {
    magnet_body_with_hub_union();
    center_bore_cyl();
  }
}

module magnet_body_minus_chamfers() {
  difference() {
    magnet_body_minus_bore();
    chamfer_top_cone_cut();
    chamfer_bottom_cone_cut();
  }
}

module pole_segmentation_markers_union() {
  union() {
    for (i = [0:pole_count-1]) {
      rotate([0, 0, i*(360/pole_count)])
        pole_marker_groove_base();
    }
  }
}

module magnet_minus_pole_markers() {
  difference() {
    magnet_body_minus_chamfers();
    pole_segmentation_markers_union();
  }
}

module magnet_complete_with_orientation_mark() {
  difference() {
    magnet_minus_pole_markers();
    orientation_mark_cut();
  }
}

// Final Output
magnet_complete_with_orientation_mark();