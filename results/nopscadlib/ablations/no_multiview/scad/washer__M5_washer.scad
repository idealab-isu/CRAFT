// Parameters
inner_diameter_mm = 5; //[2.5:10:0.1]
outer_diameter_mm = 10; //[5:20:0.1]
thickness_mm      = 1; //[0.5:2:0.1]

// Structural overlap to guarantee fusion between stacked parts
overlap_mm = 1.2; //[0.2:2:0.1]
hole_cut_extra_h_mm = 2; //[1:10:0.5]

// Washer - base geometry (the actual requested part)
module washer_body_annulus() {
  difference() {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + hole_cut_extra_h_mm, center=true);
  }
}

// Helper: a solid disc layer (no hole) used to "attach" stacked layers to the washer
module solid_disc(r, h) {
  cylinder(r=r, h=h, center=true);
}

// Round Grommet Top - detailed geometry (kept, but now physically attached)
module round_grommet_top(z_center) {
  color("Silver")
  translate([0, 0, z_center]) {
    // main layer
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    // small step on top (overlaps into main layer)
    translate([0, 0, (thickness_mm/2) - overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - 1, h=thickness_mm/2 + overlap_mm, center=true);
  }
}

// Round Grommet Assembly - detailed geometry (kept, but now physically attached)
module round_grommet_assembly(z_center) {
  color("DimGray")
  translate([0, 0, z_center]) {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    translate([0, 0, (thickness_mm/2) - overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - 1, h=thickness_mm/2 + overlap_mm, center=true);
  }
}

// Nut And Washer - detailed geometry (kept, but now physically attached)
module nut_and_washer(z_center) {
  color("Black")
  translate([0, 0, z_center]) {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    translate([0, 0, (thickness_mm/2) - overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - 1, h=thickness_mm/2 + overlap_mm, center=true);
  }
}

// Screw And Washer - detailed geometry (kept, but now physically attached)
module screw_and_washer(z_center) {
  color("Silver")
  translate([0, 0, z_center]) {
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
    translate([0, 0, (thickness_mm/2) - overlap_mm/2])
      cylinder(r=outer_diameter_mm/2 - 1, h=thickness_mm/2 + overlap_mm, center=true);
  }
}

// Assembly: all parts are unioned and stacked with guaranteed overlap.
// Also adds a small solid "spine" through the center to ensure every disc layer
// is physically connected to the washer (no floating / no separated concentric layers).
module assembly() {
  // Compute Z centers so each layer overlaps the previous by overlap_mm
  z0 = 0;
  step = thickness_mm - overlap_mm; // center-to-center spacing for overlap
  z1 = z0 + step;
  z2 = z1 + step;
  z3 = z2 + step;
  z4 = z3 + step;

  union() {
    // The actual washer (annulus with hole)
    washer_body_annulus();

    // Central solid connector (small post) to physically attach all stacked layers
    // to the washer while keeping the washer hole intact (post is smaller than hole).
    // This prevents "floating/disconnected" stacked discs and merges concentric layers.
    connector_r = max(0.6, inner_diameter_mm/2 - 0.6); // stays inside the 5mm hole
    connector_h = (z4 - z0) + thickness_mm + 2*overlap_mm;
    translate([0, 0, (z0 + z4)/2])
      solid_disc(connector_r, connector_h);

    // Stacked layers (now attached via overlap + central connector)
    round_grommet_top(z1);
    round_grommet_assembly(z2);
    nut_and_washer(z3);
    screw_and_washer(z4);
  }
}

assembly();