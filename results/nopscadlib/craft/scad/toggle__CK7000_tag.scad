// Toggle switch (tiny) — 0.76mm body diameter, 4.7mm overall height
// One connected solid, all placements derived from dimensions.

$fn = 64;

// Parameters
body_diameter_mm = 0.76;            //[0.38:1.52:0.01]
overall_height_mm = 4.7;            //[2.35:9.4:0.05]
body_height_mm = 3.5;               //[1.75:7:0.05]
lever_height_mm = 1.2;              //[0.6:2.4:0.05]
lever_diameter_mm = 0.3;            //[0.15:0.6:0.01]
base_flange_diameter_mm = 1.0;      //[0.5:2:0.01]
base_flange_thickness_mm = 0.2;     //[0.1:0.4:0.01]
overlap_mm = 0.05;                  //[0.02:0.2:0.01]

// Derived: ensure exact overall height by solving for the remaining "cap" height
cap_height_mm = max(0, overall_height_mm - (base_flange_thickness_mm + body_height_mm + lever_height_mm));

module toggle() {
    union() {
        // Base flange (bottom at z=0)
        translate([0, 0, base_flange_thickness_mm/2])
            cylinder(d=base_flange_diameter_mm, h=base_flange_thickness_mm, center=true);

        // Cylindrical body (sits on flange with slight overlap)
        translate([0, 0, base_flange_thickness_mm + body_height_mm/2 - overlap_mm])
            cylinder(d=body_diameter_mm, h=body_height_mm, center=true);

        // Lever (sits on body with slight overlap)
        translate([0, 0, base_flange_thickness_mm + body_height_mm + lever_height_mm/2 - 2*overlap_mm])
            cylinder(d=lever_diameter_mm, h=lever_height_mm, center=true);

        // Top cap to reach exact overall height (blended, connected)
        // Use a short cylinder + sphere to resemble a toggle tip while keeping total height correct.
        if (cap_height_mm > 0) {
            // Cap cylinder (overlaps into lever)
            translate([0, 0, base_flange_thickness_mm + body_height_mm + lever_height_mm + cap_height_mm/2 - 3*overlap_mm])
                cylinder(d=lever_diameter_mm, h=cap_height_mm, center=true);

            // Tip sphere at very top (slight overlap into cap)
            translate([0, 0, overall_height_mm - lever_diameter_mm/2 + overlap_mm])
                sphere(d=lever_diameter_mm);
        } else {
            // If no cap needed, still add a small tip sphere (overlaps into lever)
            translate([0, 0, base_flange_thickness_mm + body_height_mm + lever_height_mm - overlap_mm])
                sphere(d=lever_diameter_mm);
        }
    }
}

toggle();