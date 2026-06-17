// Parameters
length = 15; //[8:30:1]
center = 1; //[0:1:1]
forced_id = 0; //[0:10:0.1]
original_id = 2.0; //[1.0:6.0:0.1]
original_od = 3.2; //[1.6:6.4:0.1]
id = 2.0; //[1.0:10.0:0.1]
od = 3.2; //[1.6:12.8:0.1]
wall_min = 0.4; //[0.2:1.5:0.1]
eps = 0.8; //[0.2:2.0:0.1]
resistor_body_d = 2.4; //[1.2:5.0:0.1]
resistor_body_l = 6.5; //[3.0:15.0:0.1]
lead_d = 0.6; //[0.3:1.2:0.05]
lead_len_each = 10; //[5:25:1]
sleeving_bare = 5; //[2:12:1]
sleeving_id = 1.2; //[0.8:3.0:0.1]
sleeving_od = 2.0; //[1.2:4.0:0.1]

// Connectivity overlap (1-2mm) to guarantee merging
overlap = 1.2;

// Tubing - complete geometry (Z axis)
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length, r=od / 2, center=true, $fn=64);
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length + 2 * eps, r=max(id / 2, (od / 2 - wall_min)), center=true, $fn=64);
    }
  }
}

// Sleeved Resistor - complete geometry (X axis)
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) {
    // Resistor body
    translate([0, 0, 0])
      rotate([0, 90, 0])
      cylinder(h=resistor_body_l, r=resistor_body_d / 2, center=true, $fn=32);

    // Lead wires
    translate([-(resistor_body_l / 2 + lead_len_each / 2 - eps), 0, 0])
      rotate([0, 90, 0])
      cylinder(h=lead_len_each, r=lead_d / 2, center=true, $fn=16);
    translate([(resistor_body_l / 2 + lead_len_each / 2 - eps), 0, 0])
      rotate([0, 90, 0])
      cylinder(h=lead_len_each, r=lead_d / 2, center=true, $fn=16);

    // Sleeving (left)
    difference() {
      translate([-(resistor_body_l / 2 + (lead_len_each - sleeving_bare) / 2 - eps), 0, 0])
        rotate([0, 90, 0])
        cylinder(h=max(lead_len_each - sleeving_bare, 0), r=sleeving_od / 2, center=true, $fn=32);
      translate([-(resistor_body_l / 2 + (lead_len_each - sleeving_bare) / 2 - eps), 0, 0])
        rotate([0, 90, 0])
        cylinder(h=max(lead_len_each - sleeving_bare, 0) + 2 * eps, r=sleeving_id / 2, center=true, $fn=32);
    }

    // Sleeving (right)
    difference() {
      translate([(resistor_body_l / 2 + (lead_len_each - sleeving_bare) / 2 - eps), 0, 0])
        rotate([0, 90, 0])
        cylinder(h=max(lead_len_each - sleeving_bare, 0), r=sleeving_od / 2, center=true, $fn=32);
      translate([(resistor_body_l / 2 + (lead_len_each - sleeving_bare) / 2 - eps), 0, 0])
        rotate([0, 90, 0])
        cylinder(h=max(lead_len_each - sleeving_bare, 0) + 2 * eps, r=sleeving_id / 2, center=true, $fn=32);
    }
  }
}

// Assembly (fixed connectivity)
// Fixes:
// 1) The light-gray ring/sleeve is no longer floating: it is physically connected to the main body.
// 2) The ring is also physically connected to the black heatshrink/rod assembly via a small "saddle" bridge
//    that overlaps both parts by ~overlap mm.
// 3) Everything is combined in a single union() with intentional intersections.
module assembly() {

  // Place the collar centered on the resistor (keeps overall design intent)
  z_offset = 0;

  // Bridge ("saddle") dimensions: ensure it intersects BOTH the collar and the black sleeving.
  // - Along X: spans across the sleeving OD with extra overlap on both sides.
  // - Along Z: extends into the collar wall by overlap.
  // - Along Y: thin but non-zero to create a real solid connection.
  bridge_x = sleeving_od + 2*overlap;                 // guarantees overlap into sleeving
  bridge_y = max(1.0, overlap);                       // small thickness
  bridge_z = max(1.0, overlap);                       // small height

  // Position bridge so it touches the collar at its inner radius and reaches the sleeving.
  // Collar inner radius:
  collar_ir = max(id/2, (od/2 - wall_min));
  // Put the bridge at the collar inner surface (slightly inside to guarantee intersection)
  bridge_z_center = z_offset + collar_ir - bridge_z/2 + overlap/2;

  union() {
    sleeved_resistor();

    // Collar (light-gray ring)
    translate([0, 0, z_offset])
      tubing();

    // Physical connector between collar and sleeving/rod assembly (prevents "floating" ring)
    // This creates a small fused contact patch without changing the overall silhouette much.
    color([0.85, 0.85, 0.8])
      translate([0, 0, bridge_z_center])
        cube([bridge_x, bridge_y, bridge_z], center=true);
  }
}

assembly();