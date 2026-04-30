// Parameters
total_length = 8.0; //[4.0:16.0:0.1]
scale = 0.2; //[0.1:0.4:0.01]
bearing_od_mm = 3.0; //[1.5:6.0:0.05]
bearing_length_mm = 4.8; //[2.4:9.6:0.05]
rod_diameter_mm = 1.6; //[0.8:3.2:0.05]
print_clearance_mm = 0.04; //[0.0:0.2:0.01]
bore_diameter_mm = 3.08; //[2.8:3.4:0.01]
block_length_mm = 8.0; //[4.0:16.0:0.1]
block_width_mm = 6.0; //[3.0:12.0:0.1]
block_height_mm = 4.0; //[2.0:8.0:0.1]
wall_thickness_mm = 0.6; //[0.3:1.2:0.05]
end_stop_lip_mm = 0.2; //[0.1:0.6:0.05]
use_split_clamp = 1; //[0:1:1]
clamp_slot_width_mm = 0.4; //[0.1:1.0:0.05]
clamp_bolt_hole_diameter_mm = 0.64; //[0.4:1.2:0.02]
clamp_bolt_spacing_mm = 3.6; //[2.0:6.0:0.1]
mount_hole_diameter_mm = 0.86; //[0.5:1.6:0.02]
mount_hole_spacing_mm = 4.8; //[2.0:8.0:0.1]
mount_hole_edge_margin_mm = 1.0; //[0.5:2.0:0.05]
overlap_mm = 0.2; //[0.05:0.6:0.05]

// Base Shapes
module holder_block() {
  cube([block_length_mm, block_width_mm, block_height_mm], center=true);
}

module bearing_bore() {
  rotate([0, 90, 0])
    cylinder(r=bore_diameter_mm/2, h=block_length_mm + 2*overlap_mm, center=true);
}

module split_clamp_slot() {
  translate([0, block_width_mm/2 - clamp_slot_width_mm/2, 0])
    cube([block_length_mm + 2*overlap_mm, clamp_slot_width_mm, block_height_mm + 2*overlap_mm], center=true);
}

module clamp_bolt_hole() {
  rotate([90, 0, 0])
    cylinder(r=clamp_bolt_hole_diameter_mm/2, h=block_width_mm + 2*overlap_mm, center=true);
}

module mounting_hole() {
  cylinder(r=mount_hole_diameter_mm/2, h=block_height_mm + 2*overlap_mm, center=true);
}

module bearing_end_stop_lip() {
  rotate([0, 90, 0])
    cylinder(r=bearing_od_mm/2 + wall_thickness_mm, h=end_stop_lip_mm, center=true);
}

module bearing_end_stop_clear() {
  rotate([0, 90, 0])
    cylinder(r=bearing_od_mm/2 + print_clearance_mm, h=end_stop_lip_mm + 2*overlap_mm, center=true);
}

module linear_bearing() {
  rotate([0, 90, 0])
    cylinder(r=bearing_od_mm/2, h=bearing_length_mm, center=true);
}

// Operations
module bearing_end_stops() {
  difference() {
    union() {
      translate([-block_length_mm/2 + end_stop_lip_mm/2 - overlap_mm, 0, 0])
        bearing_end_stop_lip();
      translate([block_length_mm/2 - end_stop_lip_mm/2 + overlap_mm, 0, 0])
        bearing_end_stop_lip();
    }
    translate([-block_length_mm/2 + end_stop_lip_mm/2 - overlap_mm, 0, 0])
      bearing_end_stop_clear();
    translate([block_length_mm/2 - end_stop_lip_mm/2 + overlap_mm, 0, 0])
      bearing_end_stop_clear();
  }
}

module holder_block_with_stops() {
  union() {
    holder_block();
    bearing_end_stops();
  }
}

module clamp_bolt_holes() {
  union() {
    translate([-clamp_bolt_spacing_mm/2, 0, 0])
      clamp_bolt_hole();
    translate([clamp_bolt_spacing_mm/2, 0, 0])
      clamp_bolt_hole();
  }
}

module mounting_holes() {
  union() {
    translate([-mount_hole_spacing_mm/2, 0, 0])
      mounting_hole();
    translate([mount_hole_spacing_mm/2, 0, 0])
      mounting_hole();
  }
}

module holder_block_cutouts() {
  difference() {
    holder_block_with_stops();
    bearing_bore();
    split_clamp_slot();
    clamp_bolt_holes();
    mounting_holes();
  }
}

// Final Output
holder_block_cutouts();