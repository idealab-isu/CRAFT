// Heatshrink sleeving - single connected hollow tube

$fn = 128;

// Parameters
tube_length = 50; //[25:100:1]
tube_ID = 6; //[3:12:0.1]
wall_thickness = 0.6; //[0.3:1.2:0.05]
end_chamfer = 0.5; //[0.2:1.5:0.05]
rib_count = 18; //[0:60:1]
rib_height = 0.15; //[0:0.5:0.01]
rib_width = 0.6; //[0.2:2:0.05]
mark_band_width = 4; //[1:12:0.5]
mark_band_height = 0.2; //[0:0.6:0.01]
connect_overlap = 0.2; //[0.05:1:0.05]

// Derived
outer_r = tube_ID/2 + wall_thickness;
inner_r = tube_ID/2;

// Helpers
module tube_shell(h, r_out, r_in) {
  difference() {
    cylinder(h=h, r=r_out, center=true);
    cylinder(h=h + 2*connect_overlap, r=r_in, center=true);
  }
}

// Main sleeve with optional chamfered ends (implemented as conical cuts)
module heatshrink_sleeve() {
  difference() {
    // Base hollow tube
    tube_shell(tube_length, outer_r, inner_r);

    // End chamfers: remove small cones from the outer surface only
    if (end_chamfer > 0) {
      // Top
      translate([0, 0, tube_length/2 - end_chamfer/2])
        cylinder(h=end_chamfer + 2*connect_overlap,
                 r1=outer_r + end_chamfer,
                 r2=outer_r - 0.001,
                 center=true);

      // Bottom
      translate([0, 0, -tube_length/2 + end_chamfer/2])
        cylinder(h=end_chamfer + 2*connect_overlap,
                 r1=outer_r - 0.001,
                 r2=outer_r + end_chamfer,
                 center=true);
    }
  }
}

module ribs() {
  if (rib_count > 0 && rib_height > 0 && rib_width > 0) {
    for (i = [0:rib_count-1]) {
      zpos = -tube_length/2 + (i + 0.5) * (tube_length / rib_count);
      translate([0, 0, zpos])
        difference() {
          // Rib ring (outer bump)
          cylinder(h=rib_width, r=outer_r + rib_height, center=true);
          // Keep it as a thin ring on the outside (do not fill the bore)
          cylinder(h=rib_width + 2*connect_overlap, r=outer_r - 0.001, center=true);
        }
    }
  }
}

module marking_band() {
  if (mark_band_height > 0 && mark_band_width > 0) {
    difference() {
      cylinder(h=mark_band_width, r=outer_r + mark_band_height, center=true);
      cylinder(h=mark_band_width + 2*connect_overlap, r=outer_r - 0.001, center=true);
    }
  }
}

// Final Model: ONE connected solid (single sleeve with optional surface features)
union() {
  heatshrink_sleeve();
  ribs();
  marking_band();
}