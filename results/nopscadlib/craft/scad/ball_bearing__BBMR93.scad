// Ball bearing: 3.0mm bore, 9.0mm OD, 4.0mm width
// STRUCTURAL FIX: force ALL parts to be one connected solid by adding a thin
// "web/bridge" ring that spans the race gap and overlaps both races + balls.

bore_diameter_mm  = 3.0;
outer_diameter_mm = 9.0;
width_mm          = 4.0;

bore_r  = bore_diameter_mm/2;
outer_r = outer_diameter_mm/2;

race_radial_thickness_mm = 1.0;
ball_diameter_mm         = 1.2;
num_balls                = 7;

eps_mm     = 0.05;
overlap_mm = 1.2;   // 1–2mm overlap to guarantee fusion/connection

$fn = 128;

module bearing_solid() {
    // Derived radii
    inner_race_od_r = bore_r + race_radial_thickness_mm;      // outer radius of inner race
    outer_race_id_r = outer_r - race_radial_thickness_mm;     // inner radius of outer race

    // Ball center radius (between raceways)
    ball_center_r = (inner_race_od_r + outer_race_id_r)/2;

    // Balls enlarged slightly so they intersect both races
    ball_r = ball_diameter_mm/2 + overlap_mm;

    // --- Connectivity bridge (web) ---
    // A thin annular ring that spans the gap between inner and outer races.
    // It overlaps into each race by overlap_mm, ensuring the inner ring, outer ring,
    // and balls are all physically connected as one solid.
    web_ir = inner_race_od_r - overlap_mm;   // extend into inner race
    web_or = outer_race_id_r + overlap_mm;   // extend into outer race

    // Safety clamp (avoid negative/invalid radii if parameters change)
    web_ir_safe = max(bore_r + eps_mm, web_ir);
    web_or_safe = min(outer_r - eps_mm, web_or);

    union() {
        // Inner race ring
        difference() {
            cylinder(r=inner_race_od_r, h=width_mm, center=true);
            cylinder(r=bore_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Outer race ring
        difference() {
            cylinder(r=outer_r, h=width_mm, center=true);
            cylinder(r=outer_race_id_r, h=width_mm + 2*eps_mm, center=true);
        }

        // Web/bridge ring (fills the annular gap enough to connect parts)
        // Keep full width so it intersects balls regardless of their Z position.
        difference() {
            cylinder(r=web_or_safe, h=width_mm, center=true);
            cylinder(r=web_ir_safe, h=width_mm + 2*eps_mm, center=true);
        }

        // Balls (radial array) - now guaranteed to intersect races/web
        for (i = [0:num_balls-1]) {
            rotate([0, 0, i*360/num_balls])
                translate([ball_center_r, 0, 0])
                    sphere(r=ball_r);
        }
    }
}

bearing_solid();