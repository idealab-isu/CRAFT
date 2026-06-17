// Long faceted rod with a single transverse through-hole near one end
// Units: mm

rod_L = 0.15;                    // overall length
rod_D = 0.02;                    // diameter
hole_D = 0.010;                  // cross-hole diameter (visible)
hole_offset_from_end = 0.02;     // distance from one end face to hole center
facet_fn = 12;                   // low-poly facets
eps = 0.002;                     // small robust boolean overlap (mm)

// Derived
rod_r  = rod_D/2;
hole_r = hole_D/2;

// Place hole near the "top" end so it reads clearly in side views
// Rod is centered at Z=0, so top end face is at +rod_L/2
hole_z_raw = rod_L/2 - hole_offset_from_end;

// Keep hole fully inside the rod length (avoid clipping at end faces)
hole_z = min(max(hole_z_raw, -rod_L/2 + hole_r + eps), rod_L/2 - hole_r - eps);

difference() {
    // Featureless faceted rod (upright along Z)
    cylinder(h=rod_L, r=rod_r, center=true, $fn=facet_fn);

    // Single transverse through-hole (along X), extended past OD for a clean cut
    translate([0, 0, hole_z])
        rotate([0, 90, 0])
            cylinder(h=rod_D + 2*eps, r=hole_r, center=true, $fn=facet_fn);
}