// Parameters
thread_nominal_diameter = 3; //[1.5:6:0.1]
thread_pitch = 0.5; //[0.25:1:0.05]
across_flats = 6.4; //[3.2:12.8:0.1]
thickness = 2.4; //[1.2:4.8:0.1]
across_corners = 7.39; //[3.695:14.78:0.01]
hole_diameter_for_tap = 2.5; //[1.25:5:0.05]
hole_diameter_clearance = 3.2; //[1.6:6.4:0.05]
chamfer_size = 0.25; //[0.1:0.6:0.05]
eps = 0.6; //[0.2:1.2:0.1]
washer_outer_diameter = 7; //[3.5:14:0.1]
washer_thickness = 0.8; //[0.4:1.6:0.05]
washer_hole_diameter = 3.4; //[1.7:6.8:0.05]
nut_washer_overlap = 0.8; //[0.3:1.5:0.05]

// Connectivity overlap (1–2mm) to guarantee attachment
attach_overlap = 1.2;

// Derived
nut_r = across_flats/(2*cos(30));

// Hex Nut Module (fixed: chamfers are now SUBTRACTED from the nut, not added as floating fragments)
module hex_nut() {
  color("DimGray")
  difference() {
    // Main hex body
    cylinder(h=thickness, r=nut_r, center=true, $fn=6);

    // Central hole
    cylinder(h=thickness + 2*eps, r=hole_diameter_clearance/2, center=true);

    // Top chamfer (subtract a cone/frustum that intersects the top face)
    translate([0, 0, thickness/2 - chamfer_size/2 + attach_overlap/2])
      cylinder(
        h = chamfer_size + attach_overlap,
        r1 = nut_r + eps,
        r2 = nut_r - chamfer_size,
        center = true,
        $fn = 96
      );

    // Bottom chamfer (subtract a cone/frustum that intersects the bottom face)
    translate([0, 0, -thickness/2 + chamfer_size/2 - attach_overlap/2])
      cylinder(
        h = chamfer_size + attach_overlap,
        r1 = nut_r - chamfer_size,
        r2 = nut_r + eps,
        center = true,
        $fn = 96
      );
  }
}

// Washer Module (kept attached with explicit overlap into nut)
module washer() {
  color("Silver")
  difference() {
    // Place washer so it overlaps into the nut by nut_washer_overlap (and a bit extra for robustness)
    translate([0, 0, -(thickness/2 + washer_thickness/2 - nut_washer_overlap)])
      cylinder(h=washer_thickness, r=washer_outer_diameter/2, center=true, $fn=128);

    translate([0, 0, -(thickness/2 + washer_thickness/2 - nut_washer_overlap)])
      cylinder(h=washer_thickness + 2*eps, r=washer_hole_diameter/2, center=true, $fn=128);
  }
}

// Nut and Washer Assembly (single connected solid)
module nut_and_washer() {
  union() {
    hex_nut();
    washer();
  }
}

// Final Assembly
nut_and_washer();