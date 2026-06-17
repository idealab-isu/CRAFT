// Ball bearing: 3.0mm bore, 6.0mm OD, 2.5mm width
// One connected solid (races + balls fused with tiny overlap)

$fn = 128;

// Parameters
bore_diameter_mm  = 3.0;
outer_diameter_mm = 6.0;
width_mm          = 2.5;

// Geometry tuning (kept within available radial space)
outer_ring_radial_thickness_mm = 0.70;
inner_ring_radial_thickness_mm = 0.60;

ball_diameter_mm = 0.80;
num_balls        = 7;

// Small overlaps to ensure a single connected manifold
overlap_mm = 0.06;

module ball_bearing_connected() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    inner_outer_r = bore_r + inner_ring_radial_thickness_mm;          // inner ring OD
    outer_inner_r = outer_r - outer_ring_radial_thickness_mm;         // outer ring ID

    // Ball center radius: between inner ring OD and outer ring ID
    ball_center_r = (inner_outer_r + outer_inner_r)/2;

    // Ensure balls touch both rings (slight overlap)
    ball_r = ball_diameter_mm/2 + overlap_mm;

    union() {
        // Outer ring (race)
        difference() {
            cylinder(r=outer_r, h=width_mm, center=true);
            cylinder(r=outer_inner_r, h=width_mm + 2*overlap_mm, center=true);
        }

        // Inner ring (race)
        difference() {
            cylinder(r=inner_outer_r, h=width_mm, center=true);
            cylinder(r=bore_r, h=width_mm + 2*overlap_mm, center=true);
        }

        // Balls (fused into one solid via overlap with rings)
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([ball_center_r, 0, 0])
                    sphere(r=ball_r);
        }
    }
}

ball_bearing_connected();