// Parameters
thread_diameter_mm = 6.0; //[3.0:12.0:0.1]
across_flats_mm = 7.7; //[4.0:16.0:0.1]
thickness_mm = 7.9; //[4.0:16.0:0.1]
hole_diameter_mm = 6.0; //[3.0:12.0:0.1]
chamfer_mm = 0.3; //[0.0:1.5:0.05]
overlap_mm = 1.2; //[0.2:2.0:0.1]  // ensure 1–2mm overlap for robust attachment
washer_outer_diameter_mm = 14.0; //[8.0:28.0:0.1]
washer_thickness_mm = 1.6; //[0.8:4.0:0.1]

// Hex Nut + Washer as ONE connected solid (no floating parts)
module nut_and_washer() {

  // Derived radii
  nut_r   = across_flats_mm/(2*cos(30));   // circumscribed radius for $fn=6
  hole_r  = hole_diameter_mm/2;
  washer_r = washer_outer_diameter_mm/2;

  // Nut spans (centered): z = [-thickness/2, +thickness/2]
  // Washer should be BELOW the nut and overlap into it by overlap_mm.
  // Place washer so its TOP face is at z = (-thickness/2 + overlap_mm)
  // => washer_center_z = (-thickness/2 + overlap_mm) - washer_thickness/2
  washer_center_z = (-thickness_mm/2 + overlap_mm) - (washer_thickness_mm/2);

  difference() {
    union() {
      // Nut body (hex)
      cylinder(r=nut_r, h=thickness_mm, center=true, $fn=6);

      // Washer disc (solid disc; hole is cut later by the global through-hole)
      // This guarantees the washer is physically attached to the nut via overlap.
      translate([0, 0, washer_center_z])
        cylinder(r=washer_r, h=washer_thickness_mm, center=true, $fn=96);

      // Chamfer material around hole edges (will be cut by through-hole)
      // Keep them within the nut thickness; add a tiny overlap to avoid coplanar faces.
      translate([0, 0,  thickness_mm/2 - chamfer_mm/2])
        cylinder(r1=hole_r + chamfer_mm, r2=hole_r, h=chamfer_mm + overlap_mm, center=true, $fn=64);

      translate([0, 0, -thickness_mm/2 + chamfer_mm/2])
        cylinder(r1=hole_r, r2=hole_r + chamfer_mm, h=chamfer_mm + overlap_mm, center=true, $fn=64);
    }

    // Central through hole (cuts nut + washer together; no internal floating pieces)
    // Make it long enough to fully pass through both parts regardless of overlap.
    cylinder(r=hole_r, h=thickness_mm + washer_thickness_mm + 6*overlap_mm, center=true, $fn=96);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();