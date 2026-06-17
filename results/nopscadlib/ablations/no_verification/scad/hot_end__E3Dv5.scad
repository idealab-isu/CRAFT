$fn = 96;

//====================
// Target requirements
//====================
total_length_mm = 70.0;                 // exact overall length
barrel_diameter_mm = 3.7;              // exact heatbreak/barrel OD
filament_diameter_mm = 1.75;           // filament size

//====================
// Tunable details
//====================
filament_clearance_mm = 0.20;
overlap_mm = 1.0;

heatsink_diameter_mm = 22.0;
heatsink_length_mm   = 30.0;

heater_block_size_x_mm = 20.0;
heater_block_size_y_mm = 16.0;
heater_block_size_z_mm = 12.0;

nozzle_tip_length_mm = 10.0;
nozzle_tip_radius_mm = 4.0;

mount_groove_outer_diameter_mm = 16.0;
mount_groove_length_mm = 6.0;
mount_groove_inner_clearance_mm = 0.30;

heater_cartridge_diameter_mm = 6.0;
thermistor_hole_diameter_mm = 3.0;

wiring_strain_relief_radius_mm = 3.5;
wiring_strain_relief_length_mm = 18.0;

//====================
// Derived
//====================
filament_bore_d = max(filament_diameter_mm + 2*filament_clearance_mm, 1.95);
barrel_r   = barrel_diameter_mm/2;
heatsink_r = heatsink_diameter_mm/2;

// Ensure exact total length by solving mid_len from other segments
mid_len = max(total_length_mm - heatsink_length_mm - heater_block_size_z_mm - nozzle_tip_length_mm, 1);

// Z layout (model spans [-total_length/2, +total_length/2])
z_bottom = -total_length_mm/2;
z_nozzle0 = z_bottom;
z_nozzle1 = z_nozzle0 + nozzle_tip_length_mm;

z_block0  = z_nozzle1;
z_block1  = z_block0 + heater_block_size_z_mm;

z_mid0    = z_block1;
z_mid1    = z_mid0 + mid_len;

z_sink0   = z_mid1;
z_sink1   = z_sink0 + heatsink_length_mm;

// Shift to make top exactly +total_length/2 (guards against numeric drift)
z_shift = (total_length_mm/2) - z_sink1;

//====================
// Helpers
//====================
module zcyl(r=1, z0=0, z1=1) {
    translate([0,0,(z0+z1)/2]) cylinder(r=r, h=(z1-z0), center=true);
}

module zcube(sz=[1,1], z0=0, z1=1) {
    translate([0,0,(z0+z1)/2]) cube([sz[0], sz[1], (z1-z0)], center=true);
}

//====================
// Model
//====================
module hot_end_connected() {
    // Place groove near top of heatsink (computed from dimensions)
    groove_z1 = (z_sink1 + z_shift) - overlap_mm;
    groove_z0 = groove_z1 - mount_groove_length_mm;

    difference() {
        union() {
            // Nozzle: cone that meets the heater block at z_nozzle1
            // r2 chosen to be <= block half-min dimension so it visually connects cleanly
            translate([0,0,(z_nozzle0+z_nozzle1)/2 + z_shift])
                cylinder(
                    r1 = nozzle_tip_radius_mm,
                    r2 = min(heater_block_size_x_mm, heater_block_size_y_mm)/2 - 0.5,
                    h  = nozzle_tip_length_mm,
                    center=true
                );

            // Heater block
            zcube([heater_block_size_x_mm, heater_block_size_y_mm],
                  z0=z_block0 + z_shift,
                  z1=z_block1 + z_shift);

            // Heatbreak / barrel: EXACT 3.7mm OD, overlaps into block and heatsink
            zcyl(r=barrel_r,
                 z0=(z_mid0 + z_shift) - overlap_mm,
                 z1=(z_mid1 + z_shift) + overlap_mm);

            // Heatsink core
            zcyl(r=heatsink_r,
                 z0=z_sink0 + z_shift,
                 z1=z_sink1 + z_shift);

            // Heatsink fins: rings that protrude outward, all connected to core
            fin_count = 8;
            fin_gap = heatsink_length_mm/(fin_count*2);
            fin_th  = fin_gap; // equal gap and thickness
            fin_r   = heatsink_r + 2.0;

            for (i=[0:fin_count-1]) {
                fin_z0 = (z_sink0 + z_shift) + (i*2+0.5)*fin_gap;
                fin_z1 = fin_z0 + fin_th;
                zcyl(r=fin_r, z0=fin_z0, z1=fin_z1);
            }

            // Mounting groove collar (outer ring) connected to heatsink
            zcyl(r=mount_groove_outer_diameter_mm/2,
                 z0=groove_z0,
                 z1=groove_z1);

            // Wiring strain relief stub: tangent to block side with overlap
            translate([
                0,
                -(heater_block_size_y_mm/2 + wiring_strain_relief_radius_mm - overlap_mm),
                (z_block0+z_block1)/2 + z_shift
            ])
                rotate([90,0,0])
                    cylinder(r=wiring_strain_relief_radius_mm,
                             h=wiring_strain_relief_length_mm,
                             center=true);
        }

        // Filament path: continuous through-hole for 1.75mm filament
        translate([0,0,z_shift])
            cylinder(r=filament_bore_d/2,
                     h=total_length_mm + 2*overlap_mm,
                     center=true);

        // Heater cartridge hole (X direction)
        translate([0,0,(z_block0+z_block1)/2 + z_shift])
            rotate([0,90,0])
                cylinder(r=heater_cartridge_diameter_mm/2,
                         h=heater_block_size_x_mm + 2*overlap_mm,
                         center=true);

        // Thermistor hole (Y direction)
        translate([0,0,(z_block0+z_block1)/2 + z_shift])
            rotate([90,0,0])
                cylinder(r=thermistor_hole_diameter_mm/2,
                         h=heater_block_size_y_mm + 2*overlap_mm,
                         center=true);

        // Cut the mounting groove inner relief (keeps collar as a ring)
        zcyl(r=heatsink_r + mount_groove_inner_clearance_mm,
             z0=groove_z0 - overlap_mm,
             z1=groove_z1 + overlap_mm);
    }
}

hot_end_connected();