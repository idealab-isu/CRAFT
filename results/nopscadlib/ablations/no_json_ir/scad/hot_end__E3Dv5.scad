// Fast-rendering hot end model (timeout-safe)
$fn = 32;

// Parameters (mm)
barrel_diameter        = 3.7;   // requested
filament_diameter      = 1.75;  // requested
total_length           = 70.0;  // requested

// Segment lengths (sum to total_length)
nozzle_length          = 12.0;
heater_block_length    = 20.0;
heatbreak_length       = 20.0;
heatsink_length        = total_length - nozzle_length - heater_block_length - heatbreak_length; // 18.0

// Heater block size
heater_block_width     = 16.0;
heater_block_height    = 12.0;

// Heatsink / mount
heatsink_outer_d       = 22.0;
fin_count              = 7;
fin_thickness          = 1.2;
fin_gap                = (heatsink_length - fin_count * fin_thickness) / (fin_count - 1);
mounting_groove_d      = 12.0;
mounting_groove_depth  = 2.0;

// Small overlaps to guarantee connectivity
overlap = 0.15;

// Z layout (bottom at z=0)
z0 = 0;
z_nozzle_top      = z0 + nozzle_length;
z_block_top       = z_nozzle_top + heater_block_length;
z_heatbreak_top   = z_block_top + heatbreak_length;
z_heatsink_top    = z_heatbreak_top + heatsink_length;

// Helpers
module zcyl(z0_, h_, d_, d2_=undef) {
    translate([0,0,z0_])
        (d2_==undef)
            ? cylinder(h=h_, d=d_, center=false)
            : cylinder(h=h_, d1=d_, d2=d2_, center=false);
}

module nozzle() {
    // Simple nozzle: cone + tip
    zcyl(z0, nozzle_length*0.75 + overlap, barrel_diameter + 2.0, barrel_diameter + 0.8);
    zcyl(z0 + nozzle_length*0.75, nozzle_length*0.25, barrel_diameter + 0.8, 0.8);
}

module heater_block() {
    translate([0,0,z_nozzle_top + heater_block_length/2])
        cube([heater_block_width, heater_block_height, heater_block_length], center=true);
}

module heatsink() {
    // Core
    zcyl(z_heatbreak_top - overlap, heatsink_length + 2*overlap, barrel_diameter + 6);

    // Fins (kept simple)
    for (i = [0:fin_count-1]) {
        z_fin = z_heatbreak_top + i * (fin_thickness + fin_gap);
        zcyl(z_fin - overlap, fin_thickness + 2*overlap, heatsink_outer_d);
    }

    // Mounting groove as a shallow ring (difference kept local to avoid heavy global booleans)
    z_groove = z_heatsink_top - mounting_groove_depth;
    difference() {
        zcyl(z_groove - overlap, mounting_groove_depth + 2*overlap, heatsink_outer_d);
        zcyl(z_groove - 2*overlap, mounting_groove_depth + 4*overlap, mounting_groove_d);
    }
}

module filament_path() {
    // Through-hole along entire hotend
    zcyl(z0 - overlap, total_length + 2*overlap, filament_diameter);
}

module heater_block_features() {
    // Heater cartridge hole (cross hole)
    translate([heater_block_width/4, 0, z_nozzle_top + heater_block_length/2])
        rotate([90,0,0])
            cylinder(h=heater_block_height + 2*overlap, d=6.0, center=true);

    // Thermistor hole (cross hole)
    translate([-heater_block_width/4, 0, z_nozzle_top + heater_block_length/2])
        rotate([90,0,0])
            cylinder(h=heater_block_height + 2*overlap, d=3.0, center=true);
}

module hot_end() {
    difference() {
        union() {
            // Main continuous core from nozzle to top
            zcyl(z0, total_length, barrel_diameter);

            // Nozzle
            nozzle();

            // Heater block
            heater_block();

            // Heatsink
            heatsink();
        }

        // Subtractions
        filament_path();
        heater_block_features();
    }
}

hot_end();