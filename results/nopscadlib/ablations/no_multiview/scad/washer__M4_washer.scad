// Parameters
inner_diameter_mm = 4.0; //[2.0:8.0:0.1]
outer_diameter_mm = 9.0; //[5.0:18.0:0.1]
thickness_mm      = 0.8; //[0.4:1.6:0.05]
eps_mm            = 0.2; //[0.05:0.5:0.05]

// Connectivity overlap (requested 1–2mm)
overlap_mm = 1.2;

// Washer - base geometry
module washer(h=thickness_mm, r_out=outer_diameter_mm/2, r_in=inner_diameter_mm/2) {
  difference() {
    cylinder(r=r_out, h=h, center=true, $fn=64);
    cylinder(r=r_in,  h=h + 2*eps_mm, center=true, $fn=64);
  }
}

// Round Grommet Top - detailed geometry (kept, but will be unioned/overlapped)
module round_grommet_top() {
  cylinder(r=outer_diameter_mm/2 + 1, h=thickness_mm/2, center=true, $fn=64);
  translate([0, 0, thickness_mm/4])
    cylinder(r=inner_diameter_mm/2 + 0.5, h=thickness_mm/2, center=true, $fn=64);
}

// Round Grommet Assembly - detailed geometry (kept, but will be unioned/overlapped)
module round_grommet_assembly() {
  cylinder(r=outer_diameter_mm/2 + 2, h=thickness_mm, center=true, $fn=64);
  translate([0, 0, thickness_mm/2])
    cylinder(r=inner_diameter_mm/2 + 1, h=thickness_mm, center=true, $fn=64);
}

// Nut And Washer - detailed geometry (kept, but will be unioned/overlapped)
module nut_and_washer() {
  translate([0, 0, thickness_mm])
    cylinder(r=outer_diameter_mm/2 + 1.5, h=thickness_mm/2, center=true, $fn=6);
  washer();
}

// Screw And Washer - detailed geometry (kept, but will be unioned/overlapped)
module screw_and_washer() {
  translate([0, 0, thickness_mm])
    cylinder(r=inner_diameter_mm/2 + 0.5, h=thickness_mm * 2, center=true, $fn=64);
  washer();
}

// Assembly: FIXED connectivity
// Key fix: clamp overlap so it can never exceed the smallest adjacent half-height.
// This prevents "negative stacking" that can make the blue ring appear as a separate band/layer.
module assembly() {
  // Heights of each stacked component (as defined in modules)
  h0 = thickness_mm;        // washer()
  h1 = thickness_mm/2;      // round_grommet_top() main ring height
  h2 = thickness_mm;        // round_grommet_assembly() main ring height
  h3 = thickness_mm/2;      // nut hex plate height (nut_and_washer overall includes washer too)
  h4 = thickness_mm*2;      // screw central cylinder height (screw_and_washer overall includes washer too)

  // Safe overlap per interface: must be < (hA/2 + hB/2)
  function safe_ov(hA, hB) = min(overlap_mm, (hA + hB)/2 - 0.01);

  z0 = 0;

  ov01 = safe_ov(h0, h1);
  z1   = z0 + (h0/2 + h1/2 - ov01);

  ov12 = safe_ov(h1, h2);
  z2   = z1 + (h1/2 + h2/2 - ov12);

  ov23 = safe_ov(h2, h3);
  z3   = z2 + (h2/2 + h3/2 - ov23);

  ov34 = safe_ov(h3, h4);
  z4   = z3 + (h3/2 + h4/2 - ov34);

  union() {
    // Base washer
    color("DimGray") translate([0,0,z0]) washer();

    // Blue ring layer: now guaranteed to INTERSECT the base washer (no floating/disconnected band)
    color("RoyalBlue") translate([0,0,z1]) round_grommet_top();

    // Thicker gray ring attached via safe overlap
    color("DimGray") translate([0,0,z2]) round_grommet_assembly();

    // Nut plate + washer attached via safe overlap
    color("Black") translate([0,0,z3]) nut_and_washer();

    // Central cylinder + washer attached via safe overlap
    color("Silver") translate([0,0,z4]) screw_and_washer();
  }
}

assembly();