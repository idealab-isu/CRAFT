// Thin hex nut for 8.0mm screws, 13.0mm across flats, 4.0mm thick

// Parameters
thread_diameter_mm = 8.0; //[4.0:16.0:0.1]
across_flats_mm = 13.0;   //[6.5:26.0:0.1]
thickness_mm = 4.0;       //[2.0:8.0:0.1]
edge_break_mm = 0.3;      //[0.1:1.0:0.05]
clearance_extra_mm = 0.5; //[0.0:1.5:0.05]
hole_is_clearance = 1;    //[0:1:1]
eps_mm = 0.2;             //[0.05:0.5:0.05]

// Derived
hex_R_mm = across_flats_mm / (2 * cos(30)); // circumradius for $fn=6 cylinder
hole_r_mm = (thread_diameter_mm + hole_is_clearance * clearance_extra_mm) / 2;

// Hex nut body (no washer/flange)
module hex_nut_body() {
  cylinder(r=hex_R_mm, h=thickness_mm, center=true, $fn=6);
}

// Central through hole
module central_through_hole() {
  cylinder(r=hole_r_mm, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
}

// Small edge breaks (chamfers) on top and bottom outer edges
module outer_edge_breaks() {
  // Top chamfer ring
  translate([0, 0, thickness_mm/2 - edge_break_mm/2 + eps_mm])
    cylinder(r1=hex_R_mm + edge_break_mm, r2=hex_R_mm - edge_break_mm,
             h=edge_break_mm, center=true, $fn=6);

  // Bottom chamfer ring
  translate([0, 0, -thickness_mm/2 + edge_break_mm/2 - eps_mm])
    cylinder(r1=hex_R_mm - edge_break_mm, r2=hex_R_mm + edge_break_mm,
             h=edge_break_mm, center=true, $fn=6);
}

// Assembly
difference() {
  hex_nut_body();
  central_through_hole();
  outer_edge_breaks();
}