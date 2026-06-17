// Parameters
outer_width_mm = 38.1; //[19.05:76.2:0.1]
outer_height_mm = 25.4; //[12.7:50.8:0.1]
wall_thickness_mm = 1.6; //[0.8:3.2:0.1]
length_mm = 100; //[50:200:1]
center = 1; //[0:1:1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Connectivity overlap (1-2mm required)
overlap_mm = 1.5;

// Box Section - Primary Component
module box_section() {
  color("Silver") {
    difference() {
      cube([outer_width_mm, outer_height_mm, length_mm], center=true);
      cube([outer_width_mm - 2*wall_thickness_mm,
            outer_height_mm - 2*wall_thickness_mm,
            length_mm + 2*eps_mm], center=true);
    }
  }
}

// Box Shelf Bracket Section - Secondary Component
module box_shelf_bracket_section() {
  color("DimGray") {
    difference() {
      union() {
        // Vertical plate
        translate([-outer_width_mm/2, -outer_height_mm/2, 0])
          cube([4, outer_height_mm, 20], center=false);

        // Horizontal plate
        translate([-outer_width_mm/2, -outer_height_mm/2, 0])
          cube([outer_width_mm, 4, 20], center=false);
      }

      // Mounting holes
      translate([-outer_width_mm/2 + 2, -outer_height_mm/2 + 2, 10])
        cylinder(r=2, h=30, center=true, $fn=16);
      translate([ outer_width_mm/2 - 2, -outer_height_mm/2 + 2, 10])
        cylinder(r=2, h=30, center=true, $fn=16);
    }
  }
}

// Box Bezel Section - Secondary Component
module box_bezel_section() {
  color("Black") {
    difference() {
      cube([outer_width_mm, outer_height_mm, 5], center=true);
      cube([outer_width_mm - 4, outer_height_mm - 4, 6], center=true);
    }
  }
}

// Corner profiles (kept, but ensure they intersect the box with a small overlap)
module box_corner_profile_sections() {
  color("Silver") {
    // Push profiles slightly inward so they definitely intersect the box walls
    inset = overlap_mm; // ensures intersection even if rounding/preview artifacts occur
    for (i = [0:3]) {
      rotate([0, 0, i*90])
        translate([outer_width_mm/2 - inset, outer_height_mm/2 - inset, 0])
          rotate([0, 0, 45])
            cylinder(r=3, h=length_mm + 2*overlap_mm, center=true, $fn=32);
    }
  }
}

// FIX: Four small peg/handle-like protrusions around the box section
// They were floating/offset; now they are explicitly attached with 1-2mm overlap.
module side_pegs() {
  color("DimGray") {
    peg_r = 2.2;
    peg_len = 10;

    // Place pegs at mid-length, centered in Z
    zc = 0;

    // Ensure each peg penetrates into the box by overlap_mm:
    // For X-side pegs: center_x = outer_width/2 + peg_len/2 - overlap
    // For Y-side pegs: center_y = outer_height/2 + peg_len/2 - overlap
    cx = outer_width_mm/2  + peg_len/2 - overlap_mm;
    cy = outer_height_mm/2 + peg_len/2 - overlap_mm;

    // X+ peg
    translate([ cx, 0, zc])
      rotate([0, 90, 0])
        cylinder(r=peg_r, h=peg_len, center=true, $fn=24);

    // X- peg
    translate([-cx, 0, zc])
      rotate([0, 90, 0])
        cylinder(r=peg_r, h=peg_len, center=true, $fn=24);

    // Y+ peg
    translate([0,  cy, zc])
      rotate([90, 0, 0])
        cylinder(r=peg_r, h=peg_len, center=true, $fn=24);

    // Y- peg
    translate([0, -cy, zc])
      rotate([90, 0, 0])
        cylinder(r=peg_r, h=peg_len, center=true, $fn=24);
  }
}

// Assembly (ALL parts unioned and physically overlapping)
module assembly() {
  union() {
    // Main body
    box_section();

    // FIX: attach pegs to the box (overlapping by overlap_mm)
    side_pegs();

    // Bottom end attachment (bracket) - attach to -Z end with overlap
    // Box spans Z: [-length/2, +length/2]
    // Bracket spans local Z: [0, 20] (center=false)
    // Place bracket so its top penetrates into box by overlap_mm:
    // z0 + 20 = -length/2 + overlap_mm  => z0 = -length/2 + overlap_mm - 20
    translate([0, 0, (-length_mm/2) + overlap_mm - 20])
      box_shelf_bracket_section();

    // Top end attachment (bezel) - attach to +Z end with overlap
    // Bezel thickness = 5, centered. Place so it penetrates into box by overlap_mm:
    // bezel_center_z = +length/2 + (5/2) - overlap_mm
    translate([0, 0, (length_mm/2) + (5/2) - overlap_mm])
      box_bezel_section();

    // Corner profiles (unioned and forced to intersect slightly)
    box_corner_profile_sections();
  }
}

assembly();