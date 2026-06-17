$fn = 96;

// Units: mm
// Simplified 3D printer hot end model (generic), total length 51.2mm
// Barrel diameter 4.75mm, filament path 1.75mm

total_len = 51.2;
barrel_d = 4.75;
filament_d = 1.75;

// Segment lengths (sum to total_len)
len_nozzle = 12.0;
len_heatblock = 10.0;
len_heatsink = 29.2; // 51.2 - 12 - 10

// Diameters
nozzle_tip_d = 1.0;
nozzle_base_d = 7.0;

heatblock_w = 16.0;
heatblock_d = 16.0;

heatsink_base_d = 22.0;
heatsink_top_d  = 16.0;

// Fins
fin_count = 8;
fin_th = 1.2;
fin_gap = (len_heatsink - fin_count*fin_th) / (fin_count - 1);
fin_od = heatsink_base_d;
fin_id = 10.0;

// Small shoulder above heatblock
shoulder_h = 2.0;
shoulder_d = 8.0;

// Filament path (through-hole)
module filament_path(h) {
    cylinder(h=h, d=filament_d, center=false);
}

// Nozzle (conical + small tip)
module nozzle() {
    union() {
        // Main cone
        cylinder(h=len_nozzle-2.0, d1=nozzle_base_d, d2=2.0, center=false);
        // Tip
        translate([0,0,len_nozzle-2.0])
            cylinder(h=2.0, d1=2.0, d2=nozzle_tip_d, center=false);
    }
}

// Heat block (cube with barrel pass-through)
module heatblock() {
    translate([-heatblock_w/2, -heatblock_d/2, 0])
        cube([heatblock_w, heatblock_d, len_heatblock], center=false);
}

// Heatsink body (tapered core + fins)
module heatsink() {
    union() {
        // Core taper
        cylinder(h=len_heatsink, d1=heatsink_base_d-4, d2=heatsink_top_d-4, center=false);

        // Fins
        for (i = [0:fin_count-1]) {
            z = i*(fin_th + fin_gap);
            translate([0,0,z])
                difference() {
                    cylinder(h=fin_th, d=fin_od, center=false);
                    cylinder(h=fin_th+0.2, d=fin_id, center=false);
                }
        }
    }
}

// Barrel (thin tube) running through heatblock and heatsink
module barrel(h) {
    cylinder(h=h, d=barrel_d, center=false);
}

module hotend() {
    difference() {
        union() {
            // Nozzle at bottom
            nozzle();

            // Heatblock above nozzle
            translate([0,0,len_nozzle])
                heatblock();

            // Shoulder above heatblock
            translate([0,0,len_nozzle + len_heatblock])
                cylinder(h=shoulder_h, d=shoulder_d, center=false);

            // Heatsink above shoulder
            translate([0,0,len_nozzle + len_heatblock + shoulder_h])
                heatsink();

            // Barrel through heatblock + shoulder + heatsink (and slightly into nozzle)
            translate([0,0,2.0])
                barrel(total_len - 2.0);
        }

        // Filament path through entire hotend
        filament_path(total_len + 1.0);
    }
}

hotend();