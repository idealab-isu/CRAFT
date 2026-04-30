$fn = 96;

module lead_screw_nut(bore_d=30, shank_od=34, total_h=30, flange_th=20, flange_od=50) {
    difference() {
        union() {
            // Flange (bottom)
            translate([0,0,-total_h/2])
                cylinder(h=flange_th, d=flange_od);

            // Shank (top)
            translate([0,0,-total_h/2 + flange_th])
                cylinder(h=total_h - flange_th, d=shank_od);
        }

        // Lead-screw bore through entire part
        translate([0,0,-total_h/2 - 0.2])
            cylinder(h=total_h + 0.4, d=bore_d);
    }
}

lead_screw_nut();