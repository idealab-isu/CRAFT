// Ball bearing: 3.0mm bore, 6.0mm OD, 2.5mm width
// STRUCTURAL FIX: ensure ALL parts are physically connected (no floating inner ring/balls)
// Strategy: add 2 thin "web" bridges (top/bottom) that connect inner ring to outer ring,
// and make balls slightly larger so they intersect both rings. All combined with union().

$fn = 128;

// Target dimensions
bore_diameter_mm  = 3.0;
outer_diameter_mm = 6.0;
width_mm          = 2.5;

// Overlaps / fusing (1–2mm overlap required)
eps_mm      = 0.02;
fuse_mm     = 1.20;   // intentional overlap to guarantee connection (radial/axial)
web_thick_z = 0.60;   // axial thickness of each connecting web (kept small vs width)

// Race geometry (within 6x2.5 envelope)
outer_ring_radial_thickness_mm = 0.70;
inner_ring_radial_thickness_mm = 0.55;

// Ball geometry
ball_diameter_mm = 0.80;
ball_count       = 7;

// Derived radii
bore_r  = bore_diameter_mm/2;
od_r    = outer_diameter_mm/2;

outer_inner_r = od_r - outer_ring_radial_thickness_mm;   // inner radius of outer ring
inner_outer_r = bore_r + inner_ring_radial_thickness_mm; // outer radius of inner ring

ball_r = ball_diameter_mm/2;

// Orbit radius centered between raceways
ball_orbit_r = (outer_inner_r + inner_outer_r)/2;

// Clamp orbit so balls remain between rings (but we will enlarge balls to intersect both)
ball_orbit_r_clamped = max(inner_outer_r + ball_r + eps_mm,
                           min(ball_orbit_r, outer_inner_r - ball_r - eps_mm));

// --- Modules ---
module outer_ring() {
    difference() {
        cylinder(r=od_r, h=width_mm, center=true);
        cylinder(r=outer_inner_r, h=width_mm + 2*eps_mm, center=true);
    }
}

module inner_ring() {
    difference() {
        cylinder(r=inner_outer_r, h=width_mm, center=true);
        cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
    }
}

module balls_fused() {
    // Enlarge balls so they *intersect both rings* (not just sit in the gap)
    // Required radius to touch both rings at orbit radius:
    // r >= max(outer_inner_r - orbit, orbit - inner_outer_r) + overlap
    req_r = max(outer_inner_r - ball_orbit_r_clamped,
                ball_orbit_r_clamped - inner_outer_r) + fuse_mm;

    for (i = [0:ball_count-1]) {
        rotate([0,0,i*360/ball_count])
            translate([ball_orbit_r_clamped, 0, 0])
                sphere(r=req_r);
    }
}

module connecting_webs() {
    // Two thin annular "cage/web" rings at top and bottom that bridge the radial gap,
    // guaranteeing the inner ring is physically attached to the outer ring even if
    // balls are edited/removed.
    //
    // Web radial span overlaps into both rings by fuse_mm.
    web_r1 = inner_outer_r - fuse_mm;  // extend slightly into inner ring
    web_r2 = outer_inner_r + fuse_mm;  // extend slightly into outer ring

    // Place webs near the faces, but still inside the bearing width.
    zpos = (width_mm/2) - (web_thick_z/2) - eps_mm;

    for (z = [-zpos, zpos]) {
        translate([0,0,z])
            difference() {
                cylinder(r=web_r2, h=web_thick_z, center=true);
                cylinder(r=web_r1, h=web_thick_z + 2*eps_mm, center=true);
            }
    }
}

module bearing() {
    union() {
        outer_ring();
        inner_ring();
        connecting_webs(); // hard attachment between rings (no clearance gap)
        balls_fused();     // balls intersect both rings (no floating elements)
    }
}

bearing();