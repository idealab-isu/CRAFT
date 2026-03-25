// Dimension-calibrated (target: 0.02 x 0.02 x 0.15 mm)
scale([1.100079, 1.100079, 0.760005])
{
// Long straight rod with a single transverse through-hole near one end
// Upright along Z, flat circular ends, low-poly faceted surface

// Parameters (mm)
L = 0.20;                    // overall length (Z extent)
D = 0.02;                    // rod diameter
hole_D = 0.006;              // through-hole diameter
hole_offset_from_end = 0.02; // from one end face to hole center along Z
facet_fn = 12;               // low-poly faceting
eps = 0.002;                 // boolean overlap (ensures clean through-cut)

// Derived
rod_r = D/2;
hole_r = hole_D/2;

// Clamp hole position so it stays inside the rod length
hole_z = max(-L/2 + hole_offset_from_end, -L/2 + hole_r + eps);

difference() {
    // Single solid body
    union() {
        cylinder(h = L, r = rod_r, center = true, $fn = facet_fn);
    }

    // Transverse through-hole (axis along Y so it is visible in front/right orthographic views)
    // Make the cutter longer than the diameter to guarantee a clean through-hole.
    translate([0, 0, hole_z])
        rotate([90, 0, 0])
            cylinder(h = D + 2*eps, r = hole_r, center = true, $fn = facet_fn);
}
}
