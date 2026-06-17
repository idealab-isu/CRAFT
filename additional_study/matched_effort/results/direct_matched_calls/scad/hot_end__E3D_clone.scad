$fn=96;

// Units: mm
// Simple parametric 3D printer hot end (stylized) for 1.75mm filament
// Total length: 66.0mm
// Barrel diameter: 6.8mm

total_len = 66.0;
barrel_d  = 6.8;
filament_d = 1.75;

// Segment lengths (sum to total_len)
nozzle_len   = 12.0;
heater_len   = 20.0;
heatsink_len = 34.0; // 12 + 20 + 34 = 66

// Diameters
nozzle_tip_d   = 1.0;
nozzle_base_d  = 7.0;

heater_block_w = 16.0;
heater_block_d = 16.0;
heater_block_h = heater_len;

heatsink_base_d = 14.0;
heatsink_top_d  = 10.0;

// Fins
fin_count = 7;
fin_th    = 1.2;
fin_gap   = (heatsink_len - fin_count*fin_th) / (fin_count-1);
fin_od    = heatsink_base_d;
fin_id    = barrel_d + 0.6;

// Small chamfers/reliefs
neck_d = barrel_d;
neck_len = 2.0;

// Helper: centered cube at given z range
module zcube(size=[10,10,10], z0=0, z1=10) {
    translate([0,0,(z0+z1)/2]) cube([size[0], size[1], z1-z0], center=true);
}

module hotend() {
    difference() {
        union() {
            // Nozzle (conical)
            translate([0,0,0])
                cylinder(h=nozzle_len, d1=nozzle_tip_d, d2=nozzle_base_d);

            // Neck / barrel section between nozzle and heater
            translate([0,0,nozzle_len])
                cylinder(h=neck_len, d=neck_d);

            // Heater block (cube) around barrel
            translate([0,0,nozzle_len + neck_len])
                cube([heater_block_w, heater_block_d, heater_block_h], center=false);

            // Barrel through heater block (outer)
            translate([heater_block_w/2, heater_block_d/2, nozzle_len + neck_len])
                cylinder(h=heater_len, d=barrel_d);

            // Transition from heater to heatsink (short taper)
            trans_len = 3.0;
            translate([0,0,nozzle_len + neck_len + heater_len])
                cylinder(h=trans_len, d1=barrel_d, d2=heatsink_top_d);

            // Heatsink core (tapered)
            translate([0,0,nozzle_len + neck_len + heater_len + trans_len])
                cylinder(h=heatsink_len - trans_len, d1=heatsink_top_d, d2=heatsink_base_d);

            // Fins (rings)
            for (i=[0:fin_count-1]) {
                z = nozzle_len + neck_len + heater_len + trans_len + i*(fin_th + fin_gap);
                translate([0,0,z])
                    difference() {
                        cylinder(h=fin_th, d=fin_od);
                        translate([0,0,-0.1]) cylinder(h=fin_th+0.2, d=fin_id);
                    }
            }
        }

        // Filament path (through entire hotend)
        translate([0,0,-0.5])
            cylinder(h=total_len+1.0, d=filament_d);

        // Bore through heater block aligned with barrel center
        translate([heater_block_w/2, heater_block_d/2, nozzle_len + neck_len - 0.5])
            cylinder(h=heater_len+1.0, d=barrel_d + 0.2);

        // Simple heater cartridge hole (side)
        cart_d = 6.0;
        cart_z = nozzle_len + neck_len + heater_len*0.55;
        translate([heater_block_w/2, heater_block_d/2, cart_z])
            rotate([0,90,0])
                cylinder(h=heater_block_w+1.0, d=cart_d, center=true);

        // Thermistor hole (smaller, perpendicular)
        therm_d = 3.0;
        therm_z = nozzle_len + neck_len + heater_len*0.25;
        translate([heater_block_w/2, heater_block_d/2, therm_z])
            rotate([90,0,0])
                cylinder(h=heater_block_d+1.0, d=therm_d, center=true);
    }
}

// Place so overall length is exactly total_len along +Z
// Current model starts at z=0 and ends at z=total_len by construction.
hotend();