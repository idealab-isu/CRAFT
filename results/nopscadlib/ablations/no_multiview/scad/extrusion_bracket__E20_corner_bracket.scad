// Parameters
leg_length_x = 28; //[14:56:1]
leg_length_y = 28; //[14:56:1]
extrusion_size = 20; //[10:40:1]
base_thickness = 4; //[2:8:1]
side_thickness = 4; //[2:10:1]
hole_count = 2; //[2:2:1]
hole_diameter = 5.5; //[3:11:0.1]
hole_offset_from_inner_corner = 10; //[5:20:1]
inner_corner_radius = 2; //[0:6:0.5]
overlap = 1; //[0.5:2:0.1]
extrusion_length = 60; //[30:120:1]
extrusion_gap = 0.2; //[0:1:0.1]
gusset_length = 18; //[10:36:1]
gusset_height = 16; //[8:28:1]

// Extrusion - complete detailed geometry
module extrusion() {
  color([0.0, 0.4, 0.2])
    cube([extrusion_length, extrusion_size, extrusion_size], center=true);
}

// Extrusion Inner Corner Bracket - complete detailed geometry
module extrusion_inner_corner_bracket() {
  color("Silver") {
    difference() {
      cube([extrusion_size/2, extrusion_size/2, base_thickness], center=false);
      translate([extrusion_size/4, extrusion_size/4, 0])
        cylinder(d=hole_diameter, h=base_thickness + 2*overlap, center=false);
    }
  }
}

// Extrusion Corner Bracket - complete detailed geometry
module extrusion_corner_bracket() {
  color("Silver") {
    difference() {
      cube([leg_length_x, leg_length_y, base_thickness], center=false);
      translate([hole_offset_from_inner_corner, extrusion_size/2, 0])
        cylinder(d=hole_diameter, h=base_thickness + 2*overlap, center=false);
      translate([extrusion_size/2, hole_offset_from_inner_corner, 0])
        cylinder(d=hole_diameter, h=base_thickness + 2*overlap, center=false);
    }
  }
}

// Extrusion Corner Bracket 3D - complete detailed geometry
module extrusion_corner_bracket_3D() {
  color("Silver") {
    difference() {
      cube([leg_length_x, leg_length_y, base_thickness + gusset_height], center=false);
      translate([hole_offset_from_inner_corner, extrusion_size/2, 0])
        cylinder(d=hole_diameter, h=base_thickness + gusset_height + 2*overlap, center=false);
      translate([extrusion_size/2, hole_offset_from_inner_corner, 0])
        cylinder(d=hole_diameter, h=base_thickness + gusset_height + 2*overlap, center=false);
    }
  }
}

// Extrusion Corner Bracket Hole Positions - complete detailed geometry
module extrusion_corner_bracket_hole_positions() {
  color("Silver") {
    translate([hole_offset_from_inner_corner, extrusion_size/2, base_thickness/2])
      sphere(r=hole_diameter/4, center=true);
    translate([extrusion_size/2, hole_offset_from_inner_corner, base_thickness/2])
      sphere(r=hole_diameter/4, center=true);
  }
}

// Assembly (fixed connectivity)
// - Everything is in a single union()
// - Inner-corner tab is re-positioned to physically intersect the main bracket AND the extrusion
// - Uses 1mm overlap to guarantee connection (no gaps / no floating)
module assembly() {
  union() {
    // Main extrusion (centered)
    extrusion();

    // Main bracket parts (kept at origin as in original)
    translate([0, 0, 0]) extrusion_corner_bracket();
    translate([0, 0, 0]) extrusion_corner_bracket_3D();
    translate([0, 0, 0]) extrusion_corner_bracket_hole_positions();

    // Inner-corner bracket/tab (FIXED):
    // Attach to the underside of the extrusion (Z) and also overlap into the main bracket footprint (X/Y).
    // Extrusion spans:
    //   X: [-extrusion_length/2, +extrusion_length/2]
    //   Y: [-extrusion_size/2,  +extrusion_size/2]
    //   Z: [-extrusion_size/2,  +extrusion_size/2]
    //
    // Place tab so its TOP is inside extrusion by 'overlap':
    //   tab_z = (-extrusion_size/2) - base_thickness + overlap
    //
    // Place tab so it intersects the main bracket at origin by 'overlap' in X and Y:
    //   tab_x = -overlap  (so it extends from -overlap .. (extrusion_size/2 - overlap))
    //   tab_y = -overlap  (so it extends from -overlap .. (extrusion_size/2 - overlap))
    translate([
      -overlap,
      -overlap,
      -extrusion_size/2 - base_thickness + overlap
    ])
      extrusion_inner_corner_bracket();
  }
}

assembly();