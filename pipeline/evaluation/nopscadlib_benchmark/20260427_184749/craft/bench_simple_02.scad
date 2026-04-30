// Parameters
outer_diameter_mm = 16; //[8:32:0.1]
inner_diameter_mm = 8.4; //[4.2:16.8:0.05]
thickness_mm = 1.6; //[0.8:3.2:0.05]
centered = 1; //[0:1:1]
eps_mm = 0.2; //[0.05:0.5:0.05]

// Washer geometry
module washer_body() {
  difference() {
    // Outer cylinder
    cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=centered);
    // Inner hole
    cylinder(r=inner_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=centered);
  }
}

// Render the washer
washer_body();