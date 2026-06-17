$fn = 96;

// Parameters
total_len = 66.0;          // overall length (mm)
barrel_d = 6.8;            // main barrel diameter (mm)
filament_d = 1.75;         // filament diameter (mm)

// Simple hotend proportions (approximate, printable representation)
nozzle_len = 12.0;
heater_len = 12.0;
heatsink_len = total_len - nozzle_len - heater_len;

nozzle_tip_d = 1.0;
nozzle_base_d = 7.0;

heater_block_w = 16.0;
heater_block_d = 16.0;
heater_block_h = heater_len;

heatsink_max_d = 22.0;
heatsink_min_d = 12.0;
fin_count = 8;
fin_th = 1.2;
fin_gap = (heatsink_len - fin_count * fin_th) / (fin_count - 1);

// Derived
barrel_r = barrel_d / 2;
filament_r = filament_d / 2;

module nozzle() {
    // Conical nozzle with a short cylindrical base
    union() {
        // Base cylinder (mates to heater block)
        cylinder(h=3.0, d=nozzle_base_d);
        // Cone to tip
        translate([0,0,3.0])
            cylinder(h=nozzle_len-3.0, d1=nozzle_base_d, d2=nozzle_tip_d);
    }
}

module heater_block() {
    // Block centered on axis, with a round bore for the barrel
    difference() {
        translate([-heater_block_w/2, -heater_block_d/2, 0])
            cube([heater_block_w, heater_block_d, heater_block_h], center=false);
        // Barrel pass-through
        translate([0,0,-0.5])
            cylinder(h=heater_block_h+1.0, d=barrel_d + 0.4); // slight clearance
    }
}

module heatsink() {
    // Stack of fins around a central barrel
    union() {
        // Central core (slightly larger than barrel)
        cylinder(h=heatsink_len, d=heatsink_min_d);

        // Fins
        for (i = [0:fin_count-1]) {
            z = i * (fin_th + fin_gap);
            translate([0,0,z])
                cylinder(h=fin_th, d=heatsink_max_d);
        }
    }
}

module barrel() {
    // Main barrel through heatsink and heater block
    cylinder(h=heatsink_len + heater_len, d=barrel_d);
}

module filament_path() {
    // Through-hole for filament across entire hotend
    translate([0,0,-0.5])
        cylinder(h=total_len+1.0, d=filament_d + 0.2);
}

module hotend() {
    difference() {
        union() {
            // Nozzle at bottom
            nozzle();

            // Heater block above nozzle
            translate([0,0,nozzle_len])
                heater_block();

            // Barrel through heater block and heatsink
            translate([0,0,nozzle_len])
                barrel();

            // Heatsink at top
            translate([0,0,nozzle_len + heater_len])
                heatsink();
        }

        // Filament path
        filament_path();
    }
}

hotend();