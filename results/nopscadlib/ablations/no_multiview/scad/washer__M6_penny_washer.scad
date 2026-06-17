// Parameters
inner_diameter = 6; //[3:12:0.1]
outer_diameter = 26; //[13:52:0.1]
thickness = 1.5; //[0.75:3:0.05]
eps = 0.5; //[0.2:2:0.1]
grommet_lip_thickness = 0.8; //[0.4:1.6:0.05]
grommet_lip_radial = 1.5; //[0.75:3:0.05]

// Connectivity overlap (1-2mm) to guarantee attachment
overlap = 1.0;

// Penny Washer - complete geometry
module penny_washer() {
  color("Silver")
  difference() {
    cylinder(r=outer_diameter/2, h=thickness, center=true);
    cylinder(r=inner_diameter/2, h=thickness + 2*eps, center=true);
  }
}

// Round Grommet Top - attached to washer with overlap
module round_grommet_top() {
  // Place so it intersects the washer by `overlap`
  // Washer top face (centered) is at +thickness/2
  // Grommet bottom face (centered) is at z - grommet_lip_thickness/2
  // Set bottom = washer_top - overlap
  zc = (thickness/2 - overlap) + grommet_lip_thickness/2;

  color("DimGray")
    translate([0, 0, zc])
      cylinder(r=outer_diameter/2 + grommet_lip_radial,
               h=grommet_lip_thickness,
               center=true);
}

// Single connected washer body (no extra floating rods)
module washer() {
  union() {
    penny_washer();
    round_grommet_top();
  }
}

// Output: washer only (as requested)
washer();