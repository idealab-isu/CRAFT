// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = true; //[0:1:1]
hs_original_id = 3; //[1.5:6:0.1]
hs_original_od = 5; //[2.5:10:0.1]
hs_id = 3; //[1.5:10:0.1]
hs_od = 5; //[2.5:14:0.1]
eps_overlap = 1; //[0.5:2:0.1]
res_body_d = 6; //[3:12:0.1]
res_body_l = 10; //[5:25:0.1]

$fn = 64;

// Tubing (heatshrink sleeve)
module tubing() {
  color([0.85, 0.85, 0.8])  // Off-white for heatshrink
  difference() {
    cylinder(h=length, r=hs_od/2, center=center);
    cylinder(h=length + 2*eps_overlap, r=hs_id/2, center=center);
  }
}

// Inner tube/liner that MUST be attached to the heatshrink (light gray)
module inner_tube() {
  // Make a thin-walled tube that sits inside the heatshrink and overlaps it axially
  // so it cannot "float" and is clearly united.
  wall = 0.8; // thin liner wall
  r_outer = min(hs_id/2, hs_od/2 - 0.2);          // ensure it fits inside
  r_inner = max(0.1, r_outer - wall);

  // Extend slightly beyond the heatshrink length to guarantee overlap/union
  liner_h = length + 2*eps_overlap;

  color([0.75, 0.75, 0.75])
  difference() {
    cylinder(h=liner_h, r=r_outer, center=center);
    cylinder(h=liner_h + 2*eps_overlap, r=r_inner, center=center);
  }
}

// Resistor body (black) positioned to intersect the heatshrink with overlap
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) {
    // Resistor axis along X; place it so it passes through the heatshrink
    // and overlaps by eps_overlap to ensure a single connected solid.
    rotate([0, 90, 0]) {
      // Center the resistor on the heatshrink axis (no offset that causes "crossing bodies")
      // and ensure it intersects the sleeve volume.
      translate([0, 0, 0])
        cylinder(h=res_body_l + 2*eps_overlap, r=res_body_d/2, center=true);
    }
  }
}

// Assembly: union into a single connected solid
module assembly() {
  union() {
    tubing();
    inner_tube();        // attached by coaxial overlap inside the sleeve
    sleeved_resistor();  // intersects sleeve with overlap for continuous contact
  }
}

assembly();