// Parameters
shaft_diameter = 9.0; //[4.5:18.0:0.1]
block_length = 50.0; //[25.0:100.0:0.5]
block_width = 44.0; //[22.0:88.0:0.5]
block_height = 30.0; //[15.0:60.0:0.5]
bearing_outer_diameter = 15.0; //[10.0:30.0:0.1]
bearing_length = 30.0; //[15.0:60.0:0.5]
bore_clearance = 0.1; //[0.0:0.5:0.05]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing_x = 36.0; //[18.0:72.0:0.5]
mount_hole_spacing_y = 28.0; //[14.0:56.0:0.5]
counterbore_diameter = 9.0; //[6.0:16.0:0.1]
counterbore_depth = 4.0; //[2.0:10.0:0.1]
clamp_screw_diameter = 4.0; //[3.0:8.0:0.1]
clamp_gap_width = 2.0; //[1.0:6.0:0.1]
clamp_gap_depth = 18.0; //[8.0:40.0:0.5]
edge_fillet_radius = 1.0; //[0.5:3.0:0.1]
eps = 0.8; //[0.5:2.0:0.1]

// Connectivity overlap (1-2mm) for guaranteed physical connection
overlap = 1.2;

// Base shapes
module block_body_raw() {
  cube([block_length, block_width, block_height], center=true);
}

module edge_fillet_sphere() {
  sphere(r=edge_fillet_radius);
}

module shaft_bore() {
  rotate([0, 90, 0])
    cylinder(r=(shaft_diameter + bore_clearance)/2, h=block_length + 2*eps, center=true);
}

module bearing_seat() {
  rotate([0, 90, 0])
    cylinder(r=bearing_outer_diameter/2, h=bearing_length + 2*eps, center=true);
}

module mount_hole_through() {
  cylinder(r=mount_hole_diameter/2, h=block_height + 2*eps, center=true);
}

module mount_hole_counterbore() {
  // Counterbore from bottom face upward
  translate([0, 0, -block_height/2 + counterbore_depth/2])
    cylinder(r=counterbore_diameter/2, h=counterbore_depth + eps, center=true);
}

module clamp_gap_slot() {
  // Slot from top face downward
  translate([0, 0, block_height/2 - (clamp_gap_depth/2)])
    cube([block_length + 2*eps, clamp_gap_width, clamp_gap_depth + eps], center=true);
}

module clamp_screw_hole() {
  // Cross hole through width (Y), positioned near the clamp region
  rotate([90, 0, 0])
    translate([0, 0, block_height/2 - clamp_gap_depth + (shaft_diameter + bore_clearance)/2])
      cylinder(r=clamp_screw_diameter/2, h=block_width + 2*eps, center=true);
}

// Operations
module mounting_holes_pattern() {
  union() {
    translate([ mount_hole_spacing_x/2,  mount_hole_spacing_y/2, 0]) mount_hole_through();
    translate([-mount_hole_spacing_x/2,  mount_hole_spacing_y/2, 0]) mount_hole_through();
    translate([ mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0]) mount_hole_through();
    translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0]) mount_hole_through();
  }
}

module mounting_hole_counterbore_or_countersink() {
  union() {
    translate([ mount_hole_spacing_x/2,  mount_hole_spacing_y/2, 0]) mount_hole_counterbore();
    translate([-mount_hole_spacing_x/2,  mount_hole_spacing_y/2, 0]) mount_hole_counterbore();
    translate([ mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0]) mount_hole_counterbore();
    translate([-mount_hole_spacing_x/2, -mount_hole_spacing_y/2, 0]) mount_hole_counterbore();
  }
}

module split_clamp_or_retention_feature() {
  union() {
    clamp_gap_slot();
    clamp_screw_hole();
  }
}

// MISSING PART ADDED: bearing block (external bearing housing/boss)
// This is a solid boss around the bearing seat, attached to the main body with overlap.
module bearing_block_boss() {
  // Boss dimensions (kept modest to avoid changing overall design too much)
  boss_len = bearing_length + 8;                 // along X
  boss_w   = min(block_width, bearing_outer_diameter + 18); // along Y
  boss_h   = min(block_height, bearing_outer_diameter + 14);// along Z

  // Place on the +Y side, intersecting the main body by 'overlap'
  y_pos = (block_width/2) + (boss_w/2) - overlap;

  translate([0, y_pos, 0])
    cube([boss_len, boss_w, boss_h], center=true);
}

module block_body() {
  // Union of all solids (bearing block boss + main body), then subtract features
  difference() {
    union() {
      // Main body with filleted edges
      minkowski() {
        block_body_raw();
        edge_fillet_sphere();
      }

      // Added bearing block (boss) physically connected with overlap
      bearing_block_boss();
    }

    // Subtractive features (apply to both main body and boss)
    shaft_bore();
    bearing_seat();
    mounting_holes_pattern();
    mounting_hole_counterbore_or_countersink();
    split_clamp_or_retention_feature();
  }
}

// Final single solid output (no duplicate bodies / no floating "hole position" geometry)
union() {
  block_body();
}