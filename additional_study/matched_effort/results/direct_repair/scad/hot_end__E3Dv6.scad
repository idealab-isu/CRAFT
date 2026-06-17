$fn = 96;

// Parameters
total_len = 62.0;          // mm
barrel_d = 3.7;            // mm
filament_d = 1.75;         // mm

// Simple stylized hot end geometry (approximate)
// Sections: heatsink, heatbreak/barrel, heater block, nozzle
heatsink_len = 22.0;
heaterblock_len = 12.0;
nozzle_len = 10.0;
barrel_len = total_len - (heatsink_len + heaterblock_len + nozzle_len);

heatsink_d = 16.0;
heaterblock_w = 16.0;
heaterblock_h = 16.0;
nozzle_base_d = 7.0;
nozzle_tip_d = 1.0;

// Filament path (through-hole)
bore_d = filament_d + 0.25; // clearance

module finned_heatsink(len, d, fin_count=9, fin_th=1.0, fin_gap=1.2, core_d=10.0) {
    // Ensure fins fit within length
    pitch = fin_th + fin_gap;
    used = fin_count * pitch - fin_gap;
    scale_z = (used > 0) ? min(1, len / used) : 1;
    union() {
        // Core
        cylinder(h=len, d=core_d);
        // Fins
        for (i = [0:fin_count-1]) {
            z0 = i * pitch * scale_z;
            translate([0,0,z0])
                cylinder(h=fin_th*scale_z, d=d);
        }
    }
}

module heater_block(len, w, h) {
    translate([-w/2, -h/2, 0])
        cube([w, h, len], center=false);
}

module nozzle(len, base_d, tip_d) {
    // Conical nozzle with a short cylindrical base
    base_cyl = 2.0;
    union() {
        cylinder(h=base_cyl, d=base_d);
        translate([0,0,base_cyl])
            cylinder(h=max(0.01, len-base_cyl), d1=base_d, d2=tip_d);
    }
}

module hotend_solid() {
    union() {
        // Heatsink at top
        translate([0,0,0])
            finned_heatsink(heatsink_len, heatsink_d);

        // Barrel / heatbreak
        translate([0,0,heatsink_len])
            cylinder(h=barrel_len, d=barrel_d);

        // Heater block
        translate([0,0,heatsink_len + barrel_len])
            heater_block(heaterblock_len, heaterblock_w, heaterblock_h);

        // Nozzle
        translate([0,0,heatsink_len + barrel_len + heaterblock_len])
            nozzle(nozzle_len, nozzle_base_d, nozzle_tip_d);
    }
}

module filament_bore() {
    // Through-hole along entire length, extended slightly for clean subtraction
    translate([0,0,-1])
        cylinder(h=total_len+2, d=bore_d);
}

difference() {
    hotend_solid();
    filament_bore();
}