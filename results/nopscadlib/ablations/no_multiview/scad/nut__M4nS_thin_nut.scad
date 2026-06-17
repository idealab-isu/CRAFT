// Parameters
thread_nominal_diameter = 4.0; //[2.0:8.0:0.1]
thread_pitch = 0.7; //[0.35:1.4:0.05]
across_flats = 7.0; //[3.5:14.0:0.1]
thickness = 2.2; //[1.1:4.4:0.1]
hole_type = 1; //[0:1:1]
tolerance_clearance = 0.0; //[0.0:0.5:0.05]
chamfer_size = 0.2; //[0.1:0.6:0.05]
overlap = 0.6; //[0.2:1.5:0.1]
washer_outer_diameter = 9.0; //[6.0:18.0:0.1]
washer_thickness = 0.8; //[0.4:1.6:0.05]
washer_inner_diameter = 4.3; //[4.0:5.5:0.05]
hex_circumradius = 4.041; //[2.0:8.5:0.001]
threaded_hole_diameter = 3.3; //[2.0:6.5:0.05]

// Connectivity helper: enforce a minimum overlap of 1..2mm for unions
union_overlap = max(1.0, min(2.0, overlap));

module nut_and_washer() {

  // Washer Z placement: ensure washer intersects nut by union_overlap
  // Nut spans: [-thickness/2, +thickness/2]
  // Washer spans: [z_w - washer_thickness/2, z_w + washer_thickness/2]
  // Set washer top inside nut bottom by union_overlap:
  // z_w + washer_thickness/2 = -thickness/2 + union_overlap
  z_washer = -thickness/2 + union_overlap - washer_thickness/2;

  hole_r = (hole_type*threaded_hole_diameter + (1-hole_type)*(thread_nominal_diameter + tolerance_clearance))/2;

  // Make the nut body as a single solid (no internal difference that can create slivers)
  // by intersecting a hex prism with a chamfered "envelope".
  module chamfered_hex_prism(r, h, c) {
    // Clamp chamfer to avoid degeneracy
    c_eff = min(c, h/2 - 0.01);

    intersection() {
      // Hex prism
      cylinder(r=r, h=h, center=true, $fn=6);

      // Chamfer envelope: middle straight section + two frustums
      union() {
        // Middle straight section
        cylinder(r=r, h=max(0.01, h - 2*c_eff), center=true, $fn=6);

        // Top chamfer frustum
        translate([0,0, (h/2 - c_eff/2)])
          cylinder(r1=r, r2=max(0.01, r - c_eff), h=c_eff, center=true, $fn=6);

        // Bottom chamfer frustum
        translate([0,0, -(h/2 - c_eff/2)])
          cylinder(r1=max(0.01, r - c_eff), r2=r, h=c_eff, center=true, $fn=6);
      }
    }
  }

  // Build as one manifold: (nut + washer) minus (through hole)
  difference() {
    union() {
      // Nut (single solid, avoids floating sliver fragments from coplanar/near-coplanar cuts)
      color("DimGray")
        chamfered_hex_prism(hex_circumradius, thickness, chamfer_size);

      // Washer: ensure physical intersection with nut by union_overlap
      color("Silver")
      translate([0, 0, z_washer])
      difference() {
        cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
        cylinder(r=washer_inner_diameter/2, h=washer_thickness + 2*union_overlap, center=true);
      }
    }

    // Central through hole (single subtraction through entire combined part)
    cylinder(r=hole_r, h=thickness + washer_thickness + 4*union_overlap, center=true);
  }
}

// Assembly
module assembly() {
  nut_and_washer();
}

assembly();