// Parameters
bore_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 8.0; //[4.0:16.0:0.1]
length_mm = 23.0; //[12.0:46.0:0.5]
casing_wall_thickness_mm = 0.4; //[0.2:1.0:0.05]
seal_ring_thickness_mm = 0.5; //[0.2:1.5:0.05]
seal_ring_radial_width_mm = 0.3; //[0.1:1.0:0.05]
overlap_mm = 1.0; //[0.5:2.0:0.1]
seal_enabled = 1; //[0:1:1]
screw_shank_diameter_mm = 3.0; //[2.0:6.0:0.1]
screw_length_mm = 10.0; //[5.0:25.0:0.5]
screw_head_diameter_mm = 6.0; //[4.0:12.0:0.1]
screw_head_height_mm = 2.0; //[1.0:5.0:0.1]
washer_outer_diameter_mm = 8.0; //[5.0:16.0:0.1]
washer_thickness_mm = 1.0; //[0.5:3.0:0.1]

$fn = 96;

// Linear Bearing - complete geometry (single connected solid)
module linear_bearing() {
  color("Silver")
  union() {
    // Outer casing (hollow)
    difference() {
      cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);
      cylinder(h=length_mm + 2*overlap_mm, r=bore_diameter_mm/2, center=true);
    }

    // Seal rings (overlap into casing so they are physically connected)
    if (seal_enabled) {
      for (zpos = [
        ( length_mm/2 - seal_ring_thickness_mm/2 - overlap_mm/2),
        (-length_mm/2 + seal_ring_thickness_mm/2 + overlap_mm/2)
      ]) {
        translate([0,0,zpos])
          difference() {
            cylinder(
              h=seal_ring_thickness_mm + overlap_mm,  // ensures intersection with casing
              r=bore_diameter_mm/2 + seal_ring_radial_width_mm,
              center=true
            );
            cylinder(
              h=seal_ring_thickness_mm + 2*overlap_mm,
              r=bore_diameter_mm/2,
              center=true
            );
          }
      }
    }
  }
}

// Side pin/rod with small flange (screw + washer + head) - ATTACHED to bearing
module screw_and_washer_attached() {
  // Ensure the shank intersects the bearing OD by overlap_mm (guaranteed merge)
  x_attach = outer_diameter_mm/2 + screw_shank_diameter_mm/2 - overlap_mm;

  // Ensure washer also intersects the bearing OD by overlap_mm (prevents "floating flange")
  // Washer is larger than shank, so its center must be closer to the bearing.
  x_attach_washer = outer_diameter_mm/2 + washer_outer_diameter_mm/2 - overlap_mm;

  // Keep washer/head centered on the shank axis (same Y), but shift X so washer actually touches bearing.
  // Add a short "neck" that overlaps both shank and washer to keep the assembly one solid.
  neck_len = max(0, x_attach - x_attach_washer) + overlap_mm; // always >= overlap_mm

  color("DimGray")
  union() {
    // Screw shank (passes through bearing mid-plane)
    translate([x_attach, 0, 0])
      cylinder(h=screw_length_mm, r=screw_shank_diameter_mm/2, center=true);

    // Neck/bridge between shank axis and washer axis (guarantees connectivity even if X differs)
    translate([(x_attach + x_attach_washer)/2, 0, screw_length_mm/2 - washer_thickness_mm/2])
      rotate([0,90,0])
        cylinder(h=neck_len, r=screw_shank_diameter_mm/2, center=true);

    // Washer (flange) near the top end of the shank; positioned to intersect bearing
    translate([x_attach_washer, 0, screw_length_mm/2 - washer_thickness_mm/2])
      difference() {
        cylinder(h=washer_thickness_mm, r=washer_outer_diameter_mm/2, center=true);
        cylinder(h=washer_thickness_mm + 2*overlap_mm, r=screw_shank_diameter_mm/2, center=true);
      }

    // Screw head above washer; overlap slightly so head and washer are connected
    translate([x_attach_washer, 0, screw_length_mm/2 + screw_head_height_mm/2 - overlap_mm])
      cylinder(h=screw_head_height_mm, r=screw_head_diameter_mm/2, center=true);
  }
}

// Assembly - ALL parts connected and combined into a single union()
module assembly() {
  union() {
    linear_bearing();              // linear bearing present (missing part fixed)
    screw_and_washer_attached();   // attached with guaranteed overlap (floating/gap fixed)
  }
}

assembly();