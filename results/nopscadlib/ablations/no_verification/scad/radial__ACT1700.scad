// Parameters
outer_radius = 10.8; //[5.4:21.6:0.1]
inner_radius = 6.0; //[2.0:10.0:0.1]
height = 5.3; //[2.65:10.6:0.1]
edge_feature_size = 1.0; //[0.5:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
center_mark_radius = 1.2; //[0.6:2.4:0.1]
center_mark_height = 0.8; //[0.4:1.6:0.1]
mount_hole_count = 4; //[3:8:1]
mount_hole_radius = 1.0; //[0.6:2.0:0.1]
mount_hole_circle_radius = 8.0; //[4.0:16.0:0.1]
groove_count = 3; //[1:6:1]
groove_width = 0.8; //[0.4:1.6:0.1]
groove_depth = 0.6; //[0.3:1.2:0.1]

// Base Shapes
module outer_cylinder() {
  cylinder(h=height, r=outer_radius, center=true);
}

module inner_bore() {
  cylinder(h=height + 2*overlap, r=inner_radius, center=true);
}

module edge_chamfer_top() {
  translate([0, 0, height/2 - edge_feature_size/2])
    cylinder(h=edge_feature_size, r1=outer_radius, r2=outer_radius - edge_feature_size, center=true);
}

module edge_chamfer_bottom() {
  translate([0, 0, -height/2 + edge_feature_size/2])
    cylinder(h=edge_feature_size, r1=outer_radius, r2=outer_radius - edge_feature_size, center=true);
}

module center_mark() {
  translate([0, 0, height/2 + center_mark_height/2 - overlap])
    cylinder(h=center_mark_height, r=center_mark_radius, center=true);
}

module mount_hole(angle) {
  translate([mount_hole_circle_radius*cos(angle), mount_hole_circle_radius*sin(angle), 0])
    cylinder(h=height + 2*overlap, r=mount_hole_radius, center=true);
}

module groove_cut(radius_offset) {
  cylinder(h=height - 2*edge_feature_size, r=outer_radius - groove_depth - radius_offset, center=true);
}

// Operations
module main_body() {
  difference() {
    outer_cylinder();
    inner_bore();
  }
}

module edge_round_or_chamfer() {
  difference() {
    main_body();
    edge_chamfer_top();
    edge_chamfer_bottom();
  }
}

module decorative_grooves() {
  difference() {
    edge_round_or_chamfer();
    for (i = [0:groove_count-1]) {
      groove_cut(i * groove_width * 1.5);
    }
  }
}

module mounting_holes() {
  difference() {
    decorative_grooves();
    for (i = [0:mount_hole_count-1]) {
      mount_hole(i * 360/mount_hole_count);
    }
  }
}

// Final Model
module complete_model() {
  union() {
    mounting_holes();
    center_mark();
  }
}

// Render the complete model
complete_model();