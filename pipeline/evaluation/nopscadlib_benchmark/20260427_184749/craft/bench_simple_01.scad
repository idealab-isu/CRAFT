// Parameters
outer_diameter_mm = 22; //[11:44:0.1]
inner_bore_diameter_mm = 8; //[4:16:0.1]
thickness_mm = 7; //[3.5:14:0.1]
centered = 1; //[0:1:1]
eps_mm = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module outer_cylindrical_surface() {
  cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
}

module inner_bore_surface() {
  cylinder(r=inner_bore_diameter_mm/2, h=thickness_mm + 2*eps_mm, center=true);
}

module flat_end_faces() {
  cylinder(r=outer_diameter_mm/2, h=thickness_mm, center=true);
}

module placeholder_box() {
  cube([eps_mm, eps_mm, eps_mm], center=true);
}

// Operations
module bearing_ring_body() {
  difference() {
    outer_cylindrical_surface();
    inner_bore_surface();
  }
}

module bearing_complete_union() {
  union() {
    bearing_ring_body();
    flat_end_faces();
    placeholder_box(); // MT3608_carrier_stl
    placeholder_box(); // round_grommet_top
    placeholder_box(); // round_grommet_assembly
  }
}

// Final Output
bearing_complete_union();