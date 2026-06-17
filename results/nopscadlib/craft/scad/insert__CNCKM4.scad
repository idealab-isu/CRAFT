// Parameters
outer_diameter_mm = 4; //[2:8:0.1]
length_mm = 6.3; //[3.15:12.6:0.1]
screw_nominal_diameter_mm = 4; //[2:8:0.1]
internal_clearance_diameter_mm = 3.4; //[2.8:4.2:0.05]
chamfer_mm = 0.3; //[0.15:0.8:0.05]
lead_in_taper_mm = 0.5; //[0.25:1.5:0.05]
rib_count = 12; //[6:24:1]
rib_radial_height_mm = 0.25; //[0.1:0.6:0.05]
rib_width_mm = 0.5; //[0.25:1.2:0.05]
rib_length_mm = 4.8; //[2.4:9.6:0.1]
rib_end_margin_mm = 0.6; //[0.3:1.5:0.05]
overlap_mm = 0.8; //[0.3:2:0.1]

$fn = 96;

module threaded_insert() {
  outer_r = outer_diameter_mm/2;
  inner_r = internal_clearance_diameter_mm/2;

  // Clamp to avoid degenerate/inside-out geometry
  eps = 0.01;
  overlap = max(eps, overlap_mm);

  // Keep chamfers/tapers valid and within length
  lead_h = max(eps, chamfer_mm + lead_in_taper_mm);
  end_h  = max(eps, chamfer_mm);

  // Ensure taper doesn't invert (r2 must stay > 0)
  taper_r2 = max(eps, outer_r - lead_in_taper_mm);
  chamf_r1 = max(eps, outer_r - chamfer_mm);

  // Ribs: keep within length and ensure they overlap into the body
  rib_len = min(rib_length_mm, max(eps, length_mm - 2*rib_end_margin_mm));
  rib_radial_total = rib_radial_height_mm + overlap; // includes overlap into body
  rib_center_r = outer_r + rib_radial_total/2 - overlap; // inner face at outer_r - overlap

  difference() {
    union() {
      // Main body
      cylinder(h=length_mm, r=outer_r, center=true);

      // Lead-in taper (bottom) - overlaps into body
      translate([0, 0, -length_mm/2 + lead_h/2 - overlap/2])
        cylinder(h=lead_h + overlap, r1=outer_r, r2=taper_r2, center=true);

      // Installation end chamfer (top) - overlaps into body
      translate([0, 0,  length_mm/2 - end_h/2 + overlap/2])
        cylinder(h=end_h + overlap, r1=chamf_r1, r2=outer_r, center=true);

      // Ribs (knurls) - connected by overlap into the body
      for (i = [0:rib_count-1])
        rotate([0, 0, i*360/rib_count])
          translate([rib_center_r, 0, 0])
            cube([rib_radial_total, rib_width_mm, rib_len], center=true);
    }

    // Internal clearance hole (through)
    cylinder(h=length_mm + 2*overlap, r=inner_r, center=true);
  }
}

threaded_insert();