$fn = 128;

// A radial: [20.4, 10.8, 5.3, 1]
r_outer = 20.4;
r_mid   = 10.8;
r_inner = 5.3;
n       = 1;

// Heights (Z)
thickness_main = 6;   // outer disc thickness
step_height    = 2;   // mid step thickness
hub_height     = 4;   // inner hub thickness

// Mount hole
mount_hole_radius      = 2.2;
mount_hole_clearance_z = 2;

// Ribs (placed in the annulus between r_mid and r_outer)
rib_count_base = 12;
rib_width      = 2.2;
rib_height     = 1.5;

// Chamfer
chamfer_height = 1.2;
chamfer_radial = 1.2;

// Overlap to guarantee watertight unions
overlap = 0.6;

// Derived
total_h   = thickness_main + step_height + hub_height;
rib_count = max(1, rib_count_base * n);

// Ensure ribs fit within [r_mid, r_outer]
rib_radial_length = max(0.1, (r_outer - r_mid) - 2*overlap);

module radial_stack() {
  // Build a true 4-radius stepped radial profile:
  // r_outer (base), r_mid (top step), r_inner (top hub), plus chamfer on outer edge.
  union() {
    // Base disc centered at origin
    cylinder(r=r_outer, h=thickness_main, center=true);

    // Mid step on top of base
    translate([0, 0, thickness_main/2 + step_height/2 - overlap])
      cylinder(r=r_mid, h=step_height, center=true);

    // Inner hub on top of mid step
    translate([0, 0, thickness_main/2 + step_height + hub_height/2 - overlap])
      cylinder(r=r_inner, h=hub_height, center=true);

    // Outer chamfer on top outer edge of base (kept within r_outer)
    translate([0, 0, thickness_main/2 + chamfer_height/2 - overlap])
      cylinder(r1=r_outer, r2=max(0.01, r_outer - chamfer_radial), h=chamfer_height, center=true);
  }
}

module rib_seed() {
  // Ribs on the top face of the base, spanning from r_mid outward toward r_outer.
  // Inner edge overlaps into the r_mid step to ensure connectivity.
  translate([r_mid + rib_radial_length/2 - overlap, 0,
             thickness_main/2 + rib_height/2 - overlap])
    cube([rib_radial_length, rib_width, rib_height], center=true);
}

module ribs() {
  for (i = [0 : rib_count - 1])
    rotate([0, 0, i * 360 / rib_count])
      rib_seed();
}

module center_hole() {
  // Through-hole across entire stacked height
  cylinder(r=mount_hole_radius, h=total_h + mount_hole_clearance_z, center=true);
}

difference() {
  union() {
    radial_stack();
    ribs();
  }
  center_hole();
}