// Thin hex nut for 6.0mm screw, 10.0mm across flats, 3.2mm thick
thread_diameter = 6.0;          // screw major diameter
across_flats    = 10.0;         // hex AF
thickness       = 3.2;          // nut thickness
hole_clearance  = 0.2;          // clearance on diameter
edge_chamfer    = 0.2;          // small lead-in on hole (both sides)
eps             = 0.05;

$fn = 96;

// Derived
hex_R = across_flats / sqrt(3);                 // circumradius for AF hex
hole_r = (thread_diameter + hole_clearance)/2;  // clearance hole radius

module thin_hex_nut() {
  difference() {
    // Outer hex prism
    cylinder(r=hex_R, h=thickness, center=true, $fn=6);

    // Through hole
    cylinder(r=hole_r, h=thickness + 2*eps, center=true, $fn=96);

    // Lead-in chamfers on the hole (remove material only near faces)
    translate([0,0, thickness/2 - edge_chamfer/2])
      cylinder(r1=hole_r + edge_chamfer, r2=hole_r, h=edge_chamfer + eps, center=true, $fn=96);

    translate([0,0,-thickness/2 + edge_chamfer/2])
      cylinder(r1=hole_r + edge_chamfer, r2=hole_r, h=edge_chamfer + eps, center=true, $fn=96);
  }
}

thin_hex_nut();