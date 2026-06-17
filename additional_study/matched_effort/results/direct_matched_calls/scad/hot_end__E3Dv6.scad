$fn=96;

// Parameters
total_len = 62.0;          // mm
barrel_d = 3.7;            // mm
filament_d = 1.75;         // mm

// Simple hotend proportions (approximate, parametric)
nozzle_len = 12.0;
heater_len = 12.0;
heatbreak_len = 18.0;
heatsink_len = total_len - (nozzle_len + heater_len + heatbreak_len);

nozzle_tip_d = 1.0;
nozzle_base_d = 7.0;

heater_block_w = 16.0;
heater_block_d = 16.0;

heatsink_base_d = 16.0;
heatsink_top_d = 12.0;

module hotend_solid() {
    union() {
        // Nozzle (cone + short base cylinder)
        translate([0,0,0])
            union() {
                cylinder(h=2.0, d=nozzle_base_d);
                translate([0,0,2.0])
                    cylinder(h=nozzle_len-2.0, d1=nozzle_base_d, d2=nozzle_tip_d);
            }

        // Heater block
        translate([-heater_block_w/2, -heater_block_d/2, nozzle_len])
            cube([heater_block_w, heater_block_d, heater_len]);

        // Heatbreak / barrel
        translate([0,0,nozzle_len+heater_len])
            cylinder(h=heatbreak_len, d=barrel_d);

        // Heatsink (tapered cylinder with fins)
        translate([0,0,nozzle_len+heater_len+heatbreak_len])
            union() {
                // Core
                cylinder(h=heatsink_len, d1=heatsink_base_d, d2=heatsink_top_d);

                // Fins
                fin_count = 7;
                fin_th = 1.2;
                fin_gap = (heatsink_len - fin_count*fin_th) / (fin_count+1);
                for (i=[0:fin_count-1]) {
                    z = (i+1)*fin_gap + i*fin_th;
                    translate([0,0,z])
                        cylinder(h=fin_th, d=heatsink_base_d+6);
                }
            }
    }
}

module filament_bore() {
    // Through-hole for filament path
    translate([0,0,-1])
        cylinder(h=total_len+2, d=filament_d);
}

difference() {
    hotend_solid();
    filament_bore();
}