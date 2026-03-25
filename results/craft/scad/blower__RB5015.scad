// Parameters
length_mm = 51.3; //[25.65:102.6:0.1]
width_mm  = 51.0; //[25.5:102.0:0.1]
depth_mm  = 15.0; //[7.5:30.0:0.1]

wall_thk        = 2.0; //[1.0:4.0:0.1]
base_plate_thk  = 2.0; //[1.0:4.0:0.1]
top_cover_thk   = 2.0; //[1.0:4.0:0.1]
internal_height = 11.0; //[6.0:22.0:0.1]

inlet_bore_d      = 22.0; //[11.0:44.0:0.1]
impeller_outer_d  = 34.0; //[17.0:68.0:0.1]
impeller_thk      = 8.0;  //[4.0:16.0:0.1]
hub_d             = 10.0; //[5.0:20.0:0.1]
hub_h             = 10.0; //[5.0:20.0:0.1]

outlet_w   = 14.0; //[7.0:28.0:0.1]
outlet_h   = 8.0;  //[4.0:16.0:0.1]
outlet_len = 12.0; //[6.0:24.0:0.1]

lug_d        = 10.0; //[5.0:20.0:0.1]
lug_thk      = 3.0;  //[1.5:6.0:0.1]
screw_hole_d = 3.2;  //[1.6:6.4:0.1]

// Use 1-2mm overlap to guarantee watertight unions
overlap_mm = 1.0; //[0.5:2.0:0.1]

// ------------------------
// RB5015 Blower (single connected solid)
// Structural fixes:
// - Make the "main body" be ONLY the wall shell height (internal_height + top/bottom plates)
// - Attach top/bottom plates to that shell with 1mm overlap (no gaps)
// - Keep everything in one union(), then subtract holes
// ------------------------
module blower() {

  // Derived heights (ensure the shell height matches the intended stack)
  shell_h = internal_height + base_plate_thk + top_cover_thk; // total housing height
  z_top_plate    =  shell_h/2 - top_cover_thk/2;             // plate sits at top, overlaps into shell
  z_bottom_plate = -shell_h/2 + base_plate_thk/2;            // plate sits at bottom, overlaps into shell

  // Inner cavity height: leave top/bottom plate thickness, and extend slightly to avoid coplanar faces
  cavity_h = internal_height + 0.2;

  color([0.15, 0.15, 0.17])
  difference() {
    union() {

      // Main casing shell (outer minus inner cavity)
      difference() {
        cube([length_mm, width_mm, shell_h], center=true);

        // Inner cavity centered; leaves walls + top/bottom plate thickness
        cube([length_mm - 2*wall_thk,
              width_mm  - 2*wall_thk,
              cavity_h], center=true);
      }

      // TOP COVER (attached: overlaps into shell by overlap_mm)
      translate([0, 0, z_top_plate - overlap_mm/2])
        cube([length_mm, width_mm, top_cover_thk + overlap_mm], center=true);

      // BOTTOM COVER (attached: overlaps into shell by overlap_mm)
      translate([0, 0, z_bottom_plate + overlap_mm/2])
        cube([length_mm, width_mm, base_plate_thk + overlap_mm], center=true);

      // Outlet duct (attached to right side with overlap)
      // Ensure it intersects the outer wall by overlap_mm
      difference() {
        translate([length_mm/2 + outlet_len/2 - overlap_mm, 0, 0])
          cube([outlet_len, outlet_w, outlet_h], center=true);

        // Hollow the duct
        translate([length_mm/2 + outlet_len/2 - overlap_mm, 0, 0])
          cube([outlet_len + 0.2,
                max(0.1, outlet_w - 2*wall_thk),
                max(0.1, outlet_h - 2*wall_thk)], center=true);
      }

      // Mounting lugs (overlap into bottom cover by overlap_mm)
      // Place lugs just below the bottom plate so they intersect it
      lug_z = (-shell_h/2) - lug_thk/2 + overlap_mm; // top of lug penetrates into housing by overlap_mm
      for (sx = [-1, 1]) {
        translate([sx*(length_mm/2 - lug_d/2), 0, lug_z])
          cylinder(r=lug_d/2, h=lug_thk + overlap_mm, center=true, $fn=48);
      }
    }

    // Inlet bore cut through the TOP COVER (and slightly into cavity) to ensure clean opening
    translate([0, 0, z_top_plate - overlap_mm/2])
      cylinder(r=inlet_bore_d/2,
               h=top_cover_thk + 2*overlap_mm, center=true, $fn=64);

    // Screw holes (subtract from lugs/body)
    lug_z = (-shell_h/2) - lug_thk/2 + overlap_mm;
    for (sx = [-1, 1]) {
      translate([sx*(length_mm/2 - lug_d/2), 0, lug_z])
        cylinder(r=screw_hole_d/2,
                 h=shell_h + lug_thk + 6*overlap_mm,
                 center=true, $fn=48);
    }
  }
}

// Fan with blades (kept as-is; not part of blower body connectivity requirements)
module fan() {
  color([0.12, 0.12, 0.14]) {
    difference() {
      cube([40, 40, 10], center=true);
      cylinder(d=36, h=12, center=true, $fn=32);
    }
    cylinder(d=16, h=8, center=true, $fn=24);
    for (i = [0:6]) rotate([0, 0, i * 360 / 7])
      hull() {
        translate([8, 0, -3]) cylinder(r=2, h=6, $fn=8);
        translate([16, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Blower Fan (kept as-is)
module blower_fan() {
  color([0.12, 0.12, 0.14]) {
    difference() {
      cube([40, 40, 10], center=true);
      cylinder(d=36, h=12, center=true, $fn=32);
    }
    cylinder(d=16, h=8, center=true, $fn=24);
    for (i = [0:6]) rotate([0, 0, i * 360 / 7])
      hull() {
        translate([8, 0, -3]) cylinder(r=2, h=6, $fn=8);
        translate([16, 4, 0]) rotate([0, 12, 20]) cylinder(r=2.5, h=5, $fn=8);
      }
  }
}

// Assembly
module assembly() {
  union() {
    blower();

    // Keep these positioned above for visualization; they are separate parts by design.
    shell_h = internal_height + base_plate_thk + top_cover_thk;
    translate([0, 0, shell_h/2 + 5])  fan();
    translate([0, 0, shell_h/2 + 20]) blower_fan();
  }
}

assembly();