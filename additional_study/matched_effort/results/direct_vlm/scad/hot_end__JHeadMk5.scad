$fn=128;

// Units: mm
// Hot end model: heatsink + heatbreak barrel + heater block + nozzle
// Total length: 51.2 mm
// Barrel (heatbreak) diameter: 4.75 mm
// Filament path: 1.75 mm

total_len = 51.2;

filament_d = 1.75;
barrel_d   = 4.75;

// Segment lengths (sum to total_len)
L_heatsink = 18.0;
L_barrel   = 22.0;
L_block    = 8.0;
L_nozzle   = total_len - (L_heatsink + L_barrel + L_block); // 3.2

// Heatsink geometry
heatsink_od      = 16.0;
heatsink_bore_d  = 6.0;   // clearance bore around heatbreak
fin_count        = 7;
fin_th           = 1.2;
fin_gap          = (L_heatsink - fin_count*fin_th) / (fin_count-1);

// Heater block geometry
block_x = 16.0;
block_y = 16.0;
block_z = L_block;

// Nozzle geometry
nozzle_len      = L_nozzle;
nozzle_hex_h    = min(4.0, nozzle_len);
nozzle_cone_h   = max(0, nozzle_len - nozzle_hex_h);
nozzle_hex_flat = 7.0;
nozzle_tip_d    = 1.0;
nozzle_base_d   = 6.0;

// Small overlap to guarantee connectivity in unions
ov = 0.25;

// Helper: hex prism by across-flats
module hex_prism(af=7, h=5){
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module hotend(){
    // Build along +Z with bottom at z=0 (nozzle tip end)
    // Order: nozzle -> heater block -> barrel -> heatsink
    difference(){
        union(){
            // --- Nozzle (bottom at z=0) ---
            // Conical tip first, then hex above it
            if(nozzle_cone_h > 0)
                translate([0,0,0])
                    cylinder(h=nozzle_cone_h, d1=nozzle_tip_d, d2=nozzle_base_d);

            translate([0,0,nozzle_cone_h-ov])
                hex_prism(af=nozzle_hex_flat, h=nozzle_hex_h+ov);

            // --- Heater block (sits above nozzle) ---
            z_block0 = nozzle_len - ov;
            translate([-block_x/2, -block_y/2, z_block0])
                cube([block_x, block_y, block_z+ov]);

            // --- Heatbreak barrel (above heater block) ---
            z_barrel0 = nozzle_len + L_block - ov;
            translate([0,0,z_barrel0])
                cylinder(h=L_barrel+ov, d=barrel_d);

            // --- Heatsink with fins (above barrel) ---
            z_sink0 = nozzle_len + L_block + L_barrel - ov;

            // Fins
            for(i=[0:fin_count-1]){
                zf = z_sink0 + i*(fin_th+fin_gap);
                translate([0,0,zf])
                    cylinder(h=fin_th, d=heatsink_od);
            }

            // Top cap ring
            translate([0,0,z_sink0 + L_heatsink - 2.0])
                cylinder(h=2.0, d=heatsink_od*0.95);
        }

        // --- Filament path through entire assembly ---
        translate([0,0,-1])
            cylinder(h=total_len+2, d=filament_d);

        // --- Heatsink bore (clearance around barrel) ---
        z_sink0 = nozzle_len + L_block + L_barrel - ov;
        translate([0,0,z_sink0-1])
            cylinder(h=L_heatsink+2, d=heatsink_bore_d);

        // --- Heater block cartridge hole (through Y) ---
        cart_d   = 6.0;
        cart_y   = block_y + 2;
        cart_off = block_y/2 - cart_d/2 - 1.0; // derived from block_y and cart_d
        z_block0 = nozzle_len - ov;
        translate([0, cart_off, z_block0 + block_z/2])
            rotate([90,0,0])
                cylinder(h=cart_y, d=cart_d, center=true);

        // --- Heater block thermistor hole (through X) ---
        therm_d   = 3.0;
        therm_x   = block_x + 2;
        therm_off = block_x/2 - therm_d/2 - 1.0; // derived from block_x and therm_d
        translate([therm_off, 0, z_block0 + block_z/2])
            rotate([0,90,0])
                cylinder(h=therm_x, d=therm_d, center=true);
    }
}

hotend();