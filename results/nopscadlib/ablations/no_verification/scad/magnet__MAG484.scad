// Parameters
magnet_type = 0; //[0:10:1]
outer_diameter_mm = 20; //[10:40:1]
inner_diameter_mm = 0; //[0:30:1]
height_mm = 5; //[2.5:10:0.5]
edge_radius_mm = 0.8; //[0:2:0.1]
overlap_mm = 1; //[0.5:2:0.1]

$fn = 96;

// Magnet - one connected solid with rounded edges (no floating parts)
module magnet() {
    outer_r = outer_diameter_mm/2;
    inner_r = inner_diameter_mm/2;

    // Keep fillet radius valid relative to size
    fillet_r = min(edge_radius_mm, outer_r - 0.01, height_mm/2 - 0.01);
    fillet_r = max(fillet_r, 0);

    // Robust rounded cylinder using minkowski (always produces visible 3D geometry)
    module rounded_cylinder(r, h, fr) {
        if (fr <= 0) {
            cylinder(r=r, h=h, center=true);
        } else {
            minkowski() {
                cylinder(r=r - fr, h=h - 2*fr, center=true);
                sphere(r=fr);
            }
        }
    }

    color([0.72, 0.45, 0.2])
    difference() {
        // Outer body (centered)
        rounded_cylinder(outer_r, height_mm, fillet_r);

        // Optional center bore (through-hole)
        if (inner_diameter_mm > 0)
            cylinder(h=height_mm + 2*overlap_mm, r=inner_r, center=true);
    }
}

// Assembly
module assembly() {
    magnet();
}

assembly();