$fn = 128;

// =====================
// Parameters (requested)
// =====================
total_len   = 62.0;   // mm
barrel_d    = 3.7;    // mm
filament_d  = 1.75;   // mm

// =====================
// Proportions (sum = total_len)
// =====================
nozzle_len   = 12.0;
heater_len   = 11.0;
heatsink_len = 18.0;
barrel_len   = total_len - (nozzle_len + heater_len + heatsink_len); // 21.0

// =====================
// Feature sizes
// =====================
nozzle_tip_d     = 1.0;
nozzle_base_d    = 7.0;
nozzle_collar_h  = 2.0;

heater_block_w = 16.0;
heater_block_d = 16.0;

heatsink_outer_d = 12.0;
heatsink_core_d  = barrel_d + 1.0;

fin_count = 7;
fin_th    = 1.2;
fin_gap   = (heatsink_len - fin_count*fin_th) / (fin_count-1);

eps = 0.2; // overlap for connectivity / robust booleans

module nozzle(len=nozzle_len, base_d=nozzle_base_d, tip_d=nozzle_tip_d) {
    union() {
        cylinder(h=nozzle_collar_h, d=base_d);
        translate([0,0,nozzle_collar_h])
            cylinder(h=len-nozzle_collar_h, d1=base_d, d2=tip_d);
    }
}

module heater_block(len=heater_len, w=heater_block_w, d=heater_block_d) {
    translate([-w/2, -d/2, 0])
        cube([w, d, len], center=false);
}

module heatsink(len=heatsink_len, outer_d=heatsink_outer_d, core_d=heatsink_core_d) {
    union() {
        // core sleeve
        cylinder(h=len, d=core_d);

        // fins
        for (i = [0:fin_count-1]) {
            z = i*(fin_th + fin_gap);
            translate([0,0,z])
                cylinder(h=fin_th, d=outer_d);
        }
    }
}

module barrel(len=barrel_len, d=barrel_d) {
    cylinder(h=len, d=d);
}

module hotend() {
    // Build from tip (z=0) upward; all placements are formulas from dimensions.
    difference() {
        union() {
            // Nozzle
            nozzle();

            // Heater block directly above nozzle (touching with slight overlap)
            translate([0,0,nozzle_len - eps])
                heater_block();

            // Barrel runs from just above nozzle through heater and up to heatsink
            translate([0,0,nozzle_len - eps])
                barrel(len=heater_len + barrel_len + eps, d=barrel_d);

            // Heatsink at top, connected to barrel with overlap
            translate([0,0,nozzle_len + heater_len + barrel_len - eps])
                heatsink();
        }

        // Filament path (through entire hotend)
        translate([0,0,-eps])
            cylinder(h=total_len + 2*eps, d=filament_d);

        // Slightly larger melt chamber in nozzle
        cylinder(h=6.0, d=2.2);

        // Heater cartridge hole through heater block (X-axis), centered in heater block Z
        // Place it fully inside the block (not tangent to the face) so side views show geometry.
        cart_d = 6.0;
        cart_y = 0; // centered
        cart_z = nozzle_len + heater_len/2;
        translate([0, cart_y, cart_z])
            rotate([90,0,0])
                cylinder(h=heater_block_d + 2*eps, d=cart_d, center=true);

        // Thermistor hole through heater block (Y-axis), centered in heater block Z
        therm_d = 3.0;
        therm_x = 0; // centered
        therm_z = nozzle_len + heater_len/2;
        translate([therm_x, 0, therm_z])
            rotate([0,90,0])
                cylinder(h=heater_block_w + 2*eps, d=therm_d, center=true);
    }
}

// Exact length is enforced by construction (no Z scaling).
hotend();