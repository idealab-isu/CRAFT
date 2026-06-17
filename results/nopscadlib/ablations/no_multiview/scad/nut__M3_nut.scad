// Parameters
thread_nominal_diameter = 3; //[1.5:6:0.1]
across_flats = 6.4; //[3.2:12.8:0.1]
thickness = 2.4; //[1.2:4.8:0.1]
bore_diameter = 3; //[2.5:3.6:0.05]
threaded = 0; //[0:1:1]
thread_representation_scale = 0.9; //[0.75:1:0.01]
chamfer_size = 0.2; //[0.1:0.6:0.05]
overlap = 0.8; //[0.5:2:0.1]
washer_enabled = 1; //[0:1:1]
washer_outer_diameter = 7; //[5:14:0.1]
washer_thickness = 0.6; //[0.3:1.5:0.05]
washer_inner_diameter = 3.2; //[3:4:0.05]

// Connectivity helper (force 1–2mm intersection between parts)
connect_overlap = 1.2; // mm (meets requirement 1–2mm)

// Derived
hex_R = across_flats/(2*cos(30));
bore_R = (bore_diameter*(1-threaded) + bore_diameter*thread_representation_scale*threaded)/2;

// Nut and Washer - complete geometry (single connected solid)
module nut_and_washer() {

  union() {

    // --- Main nut body (with bore + chamfers) ---
    color("DimGray")
    difference() {
      cylinder(r=hex_R, h=thickness, center=true, $fn=6);

      // Central bore
      cylinder(r=bore_R, h=thickness + 2*overlap, center=true);

      // Top chamfer cut
      translate([0, 0, thickness/2 - (chamfer_size + overlap)/2])
        cylinder(r=hex_R + chamfer_size, h=chamfer_size + overlap, center=true);

      // Bottom chamfer cut
      translate([0, 0, -thickness/2 + (chamfer_size + overlap)/2])
        cylinder(r=hex_R + chamfer_size, h=chamfer_size + overlap, center=true);
    }

    // --- Add missing/implicit thin plates (top & bottom) and ATTACH them ---
    // These plates are created and overlapped into the nut by connect_overlap.
    // Keep them thin so the design remains essentially a nut, but ensure no floating parts.
    plate_thickness = 0.6; // thin strip/plate thickness (matches typical "thin plate" look)
    plate_R = hex_R;       // same footprint as nut so it doesn't change silhouette

    // Top plate: intersects nut by connect_overlap
    color("DimGray")
    translate([0, 0, thickness/2 + plate_thickness/2 - connect_overlap])
      difference() {
        cylinder(r=plate_R, h=plate_thickness, center=true, $fn=6);
        cylinder(r=bore_R, h=plate_thickness + 2*overlap, center=true);
      }

    // Bottom plate: intersects nut by connect_overlap
    color("DimGray")
    translate([0, 0, -thickness/2 - plate_thickness/2 + connect_overlap])
      difference() {
        cylinder(r=plate_R, h=plate_thickness, center=true, $fn=6);
        cylinder(r=bore_R, h=plate_thickness + 2*overlap, center=true);
      }

    // --- Washer (attached with guaranteed overlap) ---
    if (washer_enabled) {
      // Place washer under nut and overlap into the nut by connect_overlap
      washer_z = -thickness/2 - washer_thickness/2 + connect_overlap;

      color("Silver")
      difference() {
        translate([0, 0, washer_z])
          cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);

        translate([0, 0, washer_z])
          cylinder(r=washer_inner_diameter/2, h=washer_thickness + 2*overlap, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();