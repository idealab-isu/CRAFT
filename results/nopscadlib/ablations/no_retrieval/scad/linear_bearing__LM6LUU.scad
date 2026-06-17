// Parameters
bearing_L = 35.0; //[17.5:70.0:0.5]
bearing_OD = 12.0; //[6.0:24.0:0.5]
bearing_ID = 6.0; //[3.0:12.0:0.5]
eps_overlap = 1.0; //[0.5:2.0:0.1]
lead_in_len = 1.2; //[0.5:3.0:0.1]
lead_in_rad = 0.6; //[0.2:1.5:0.1]
lube_groove_width = 1.2; //[0.6:3.0:0.1]
lube_groove_depth = 0.4; //[0.2:1.0:0.05]
lube_groove_count = 3.0; //[1.0:6.0:1.0]
ret_groove_width = 1.0; //[0.6:2.5:0.1]
ret_groove_depth = 0.5; //[0.2:1.2:0.05]
ret_groove_offset = 3.0; //[1.5:6.0:0.5]
track_depth = 0.35; //[0.15:0.8:0.05]
track_radius = 0.8; //[0.4:1.6:0.05]
track_count = 4.0; //[3.0:8.0:1.0]
cage_relief_thickness = 0.6; //[0.3:1.5:0.1]

// Base Shapes
module outer_cylinder_body() {
  cylinder(h=bearing_L, r=bearing_OD/2, center=true);
}

module through_bore() {
  cylinder(h=bearing_L + 2*eps_overlap, r=bearing_ID/2, center=true);
}

module chamfer_or_lead_in_top() {
  translate([0, 0, bearing_L/2 - lead_in_len/2 + eps_overlap/2])
    cylinder(h=lead_in_len, r1=bearing_OD/2, r2=bearing_OD/2 - lead_in_rad, center=true);
}

module chamfer_or_lead_in_bottom() {
  translate([0, 0, -bearing_L/2 + lead_in_len/2 - eps_overlap/2])
    cylinder(h=lead_in_len, r1=bearing_OD/2 - lead_in_rad, r2=bearing_OD/2, center=true);
}

module lubrication_groove(position) {
  difference() {
    translate([0, 0, position])
      cylinder(h=lube_groove_width, r=bearing_OD/2, center=true);
    translate([0, 0, position])
      cylinder(h=lube_groove_width + 2*eps_overlap, r=bearing_OD/2 - lube_groove_depth, center=true);
  }
}

module retaining_ring_groove(position) {
  difference() {
    translate([0, 0, position])
      cylinder(h=ret_groove_width, r=bearing_OD/2, center=true);
    translate([0, 0, position])
      cylinder(h=ret_groove_width + 2*eps_overlap, r=bearing_OD/2 - ret_groove_depth, center=true);
  }
}

module ball_track_cutter(angle) {
  rotate([90, 0, angle])
    translate([bearing_ID/2 + track_radius - track_depth, 0, 0])
      cylinder(h=bearing_L + 2*eps_overlap, r=track_radius, center=true);
}

module ball_cage_relief() {
  cylinder(h=bearing_L - 2*lead_in_len, r=bearing_ID/2 + cage_relief_thickness, center=true);
}

// Operations
module complete_bearing_model() {
  difference() {
    difference() {
      difference() {
        difference() {
          difference() {
            difference() {
              outer_cylinder_body();
              chamfer_or_lead_in_top();
              chamfer_or_lead_in_bottom();
            }
            lubrication_groove(-bearing_L/4);
            lubrication_groove(0);
            lubrication_groove(bearing_L/4);
          }
          retaining_ring_groove(bearing_L/2 - ret_groove_offset);
          retaining_ring_groove(-bearing_L/2 + ret_groove_offset);
        }
        through_bore();
      }
      ball_track_cutter(0);
      ball_track_cutter(90);
      ball_track_cutter(180);
      ball_track_cutter(270);
    }
    ball_cage_relief();
  }
}

// Final Output
complete_bearing_model();