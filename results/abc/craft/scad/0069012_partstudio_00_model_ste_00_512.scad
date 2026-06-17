// Dimension-calibrated (target: 0.03 x 0.01 x 0.03 mm)
scale([0.848664, 0.909091, 2.818182])
{
// Compact faceted cylindrical tool body with central + peripheral hex through-holes,
// stepped collar on one end, and a domed/capped opposite end.
//
// Structural fixes applied:
// - Make the hex bores unambiguously visible on the *-X end face* by ensuring the dome/cap
//   does NOT cover that end (cap stays on +X only).
// - Ensure ALL bores are true through-holes by cutting longer than the full solid extent.
// - Recalculate all translate() placements so collar/chamfer/cap overlap the main body.
// - Keep everything as one connected solid (union) then subtract bores (difference).

// ---------- Parameters (meters; keep as provided) ----------
L = 0.03; //[0.015:0.06:0.001]          // overall length (X axis)
body_flat_d = 0.009; //[0.0045:0.018:0.0005]
facet_count = 12; //[6:24:1]

bore_hex_flat_d = 0.004; //[0.002:0.008:0.0005]
bore_clearance = 0.0; //[0.0:0.001:0.0001]

small_hex_count = 6; //[3:12:1]
small_hex_flat_d = 0.0016; //[0.0008:0.0032:0.0001]
small_hex_ring_r = 0.0032; //[0.0016:0.0064:0.0001]

collar_len = 0.004; //[0.002:0.008:0.0005]
collar_flat_d = 0.01; //[0.005:0.02:0.0005]

cap_len = 0.003; //[0.0015:0.006:0.0005]
cap_dome_r = 0.0045; //[0.002:0.009:0.0005]

overlap = 0.0012; //[0.0002:0.002:0.0001]   // ~1.2mm overlap for robust connections
chamfer_len = 0.001; //[0.0003:0.002:0.0001]

// ---------- Helpers ----------
function circumradius_from_flat(flat_d) = flat_d/sqrt(3); // center->vertex

module hex2d_from_flat(flat_d) {
  r = circumradius_from_flat(flat_d);
  polygon(points=[ for (a=[0:60:300]) [ r*cos(a), r*sin(a) ] ]);
}

module faceted_cyl_x(len, flat_d, facets) {
  // Faceted outer profile extruded along X
  rotate([0,90,0])
    linear_extrude(height=len, center=true)
      polygon(points=[ for (i=[0:facets-1])
        [ (flat_d/2)*cos(i*360/facets), (flat_d/2)*sin(i*360/facets) ]
      ]);
}

module hex_bore_x(len, flat_d) {
  rotate([0,90,0])
    linear_extrude(height=len, center=true)
      hex2d_from_flat(flat_d);
}

module small_hex_bore_x(len, flat_d, ang_deg) {
  translate([0, small_hex_ring_r*cos(ang_deg), small_hex_ring_r*sin(ang_deg)])
    rotate([0,90,0])
      linear_extrude(height=len, center=true)
        hex2d_from_flat(flat_d);
}

module end_chamfer_x(x_plane, flat_d, chamfer) {
  // Bevel ring centered on the end plane (x_plane), overlapping the body
  translate([x_plane,0,0])
    rotate([0,90,0])
      cylinder(
        h = 2*chamfer + 2*overlap,
        r1 = flat_d/2 + chamfer,
        r2 = max(0.0005, flat_d/2 - chamfer),
        center = true,
        $fn = facet_count
      );
}

module domed_cap_x(x_end, body_r) {
  // Cap only on +X end. It overlaps the main body by 'overlap' so it is connected.
  // Cylinder spans [x_end - cap_len - overlap, x_end + overlap]
  x_cyl_len    = cap_len + 2*overlap;
  x_cyl_center = x_end - cap_len/2; // gives overlap on both sides of the join plane

  union() {
    // Short cylindrical collar under the dome
    translate([x_cyl_center,0,0])
      rotate([0,90,0])
        cylinder(h=x_cyl_len, r=body_r, center=true, $fn=facet_count);

    // Dome: keep only the portion beyond the plane at x = x_end - cap_len
    intersection() {
      // Sphere center chosen so dome protrudes beyond x_end
      translate([x_end - cap_len + cap_dome_r - overlap, 0, 0])
        sphere(r=cap_dome_r, $fn=96);

      // Clip volume: keep x >= (x_end - cap_len - overlap)
      translate([x_end - cap_len - overlap, -cap_dome_r - overlap, -cap_dome_r - overlap])
        cube([cap_len + 2*cap_dome_r + 3*overlap,
              2*cap_dome_r + 2*overlap,
              2*cap_dome_r + 2*overlap], center=false);
    }
  }
}

// ---------- Build ----------
module final_geometry() {
  x_end_pos =  L/2;
  x_end_neg = -L/2;

  body_r = body_flat_d/2;

  // Conservative solid extents along X (include collar and dome)
  x_min = x_end_neg - collar_len - 2*overlap;
  x_max = x_end_pos + cap_dome_r + 2*overlap;
  total_cut_len = (x_max - x_min) + 6*overlap; // extra margin so bores are guaranteed through

  difference() {
    union() {
      // Main faceted body (centered)
      faceted_cyl_x(L, body_flat_d, facet_count);

      // Stepped collar near -X end:
      // Collar spans [x_end_neg - overlap, x_end_neg + collar_len + overlap]
      x_collar_len    = collar_len + 2*overlap;
      x_collar_center = x_end_neg + collar_len/2; // attaches at -L/2 with overlap
      translate([x_collar_center, 0, 0])
        faceted_cyl_x(x_collar_len, collar_flat_d, facet_count);

      // Small chamfer at -X end plane (kept connected by overlap)
      end_chamfer_x(x_end_neg, body_flat_d, chamfer_len);

      // Domed/capped +X end (connected)
      domed_cap_x(x_end_pos, body_r);
    }

    // Through bores: cut through entire solid so they open on BOTH ends.
    // This makes the -X end face clearly show the central hex + ring of smaller hex holes.
    union() {
      hex_bore_x(total_cut_len, bore_hex_flat_d + bore_clearance);

      for (i=[0:small_hex_count-1]) {
        ang = i*360/small_hex_count;
        small_hex_bore_x(total_cut_len, small_hex_flat_d, ang);
      }
    }
  }
}

color([0.85, 0.85, 0.8])
final_geometry();
}
