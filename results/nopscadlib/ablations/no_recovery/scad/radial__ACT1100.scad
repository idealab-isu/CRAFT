// Parameters
outer_radius = 20.4; //[10.2:40.8:0.1]
inner_radius = 10.8; //[5.4:21.6:0.1]
height = 5.3; //[2.65:10.6:0.1]
edge_feature_size = 1.0; //[0.5:2.0:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
center_mark_radius = 1.0; //[0.5:2.0:0.1]
center_mark_depth = 0.6; //[0.3:1.2:0.1]
groove_width = 1.2; //[0.6:2.4:0.1]
groove_depth = 0.7; //[0.3:1.4:0.1]
groove_radius = 16.0; //[12.0:19.0:0.1]

// Base Shapes
module radial_main_body() {
  cylinder(h=height, r=outer_radius, center=true);
}

module inner_bore() {
  cylinder(h=height + 2*overlap, r=inner_radius, center=true);
}

module edge_feature() {
  translate([0, 0, height/2 - edge_feature_size/2])
    cylinder(h=edge_feature_size, r=outer_radius - edge_feature_size, center=true);
}

module center_mark() {
  translate([0, 0, height/2 - center_mark_depth/2])
    cylinder(h=center_mark_depth + 2*overlap, r=center_mark_radius, center=true);
}

module decorative_groove() {
  translate([0, 0, height/2 - groove_depth/2])
    cylinder(h=groove_depth + 2*overlap, r=groove_radius + groove_width/2, center=true);
}

module decorative_groove_inner_cut() {
  translate([0, 0, height/2 - groove_depth/2])
    cylinder(h=groove_depth + 2*overlap, r=groove_radius - groove_width/2, center=true);
}

// Operations
module decorative_groove_ring() {
  difference() {
    decorative_groove();
    decorative_groove_inner_cut();
  }
}

module main_ring() {
  difference() {
    radial_main_body();
    inner_bore();
  }
}

module edge_feature_step() {
  difference() {
    main_ring();
    edge_feature();
  }
}

module with_center_mark() {
  difference() {
    edge_feature_step();
    center_mark();
  }
}

// Final Model
module final_model() {
  difference() {
    with_center_mark();
    decorative_groove_ring();
  }
}

// Render the final model
color("Silver") final_model();