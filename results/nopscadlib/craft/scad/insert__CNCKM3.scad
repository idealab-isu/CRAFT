// Threaded heat-set insert (simplified solid model)
// Target: 3.0mm OD, 4.6mm long, for M3 screws

$fn = 128;

// Parameters
screw_nominal_diameter_mm = 3; //[1.5:6:0.1]
outer_diameter_mm = 3; //[1.5:6:0.1]
length_mm = 4.6; //[2.3:9.2:0.1]
tolerance_mm = 0.1; //[0.05:0.3:0.01]
internal_bore_diameter_mm = 2.6; //[2.2:3:0.05]
end_chamfer_mm = 0.3; //[0.15:0.8:0.05]
knurl_depth_mm = 0.2; //[0.1:0.5:0.05]
knurl_rib_count = 16; //[8:32:1]
knurl_rib_width_mm = 0.35; //[0.2:0.8:0.05]
eps_mm = 0.05; //[0.01:0.5:0.01]

// Threaded Insert - one connected solid (outer body with knurls, internal bore, end chamfers)
module threaded_insert() {
  od = outer_diameter_mm;
  r_body = od/2;

  // Keep chamfer valid and ensure knurl height is positive
  chamfer = min(end_chamfer_mm, r_body*0.9);
  knurl_h = max(0.2, length_mm - 2*chamfer);

  // Ensure ribs are connected by overlapping into the body
  rib_out = max(0.01, knurl_depth_mm);
  overlap_in = min(max(0.05, rib_out*0.6), r_body*0.8);
  rib_len = rib_out + overlap_in;

  // Place rib so its inner face is inside the body by overlap_in
  rib_center_r = r_body + rib_len/2 - overlap_in;

  // Bore radius with tolerance (keep below outer radius)
  r_bore = min(r_body - 0.15, internal_bore_diameter_mm/2 + tolerance_mm/2);

  // Chamfer cut radii (avoid degeneracy)
  r_small = max(0.01, r_body - chamfer);

  difference() {
    union() {
      // Main cylindrical body
      cylinder(h=length_mm, r=r_body, center=true);

      // Knurl ribs (connected via overlap_in)
      for (i = [0:knurl_rib_count-1]) {
        rotate([0, 0, i*360/knurl_rib_count])
          translate([rib_center_r, 0, 0])
            cube([rib_len, knurl_rib_width_mm, knurl_h], center=true);
      }
    }

    // Internal clearance bore (through)
    cylinder(h=length_mm + 2*eps_mm, r=r_bore, center=true);

    // End chamfers (remove material at both ends)
    translate([0, 0,  length_mm/2 - chamfer/2])
      cylinder(h=chamfer + 2*eps_mm, r1=r_body + eps_mm, r2=r_small, center=true);

    translate([0, 0, -length_mm/2 + chamfer/2])
      cylinder(h=chamfer + 2*eps_mm, r1=r_small, r2=r_body + eps_mm, center=true);
  }
}

threaded_insert();