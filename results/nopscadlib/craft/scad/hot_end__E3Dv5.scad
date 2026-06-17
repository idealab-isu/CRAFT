$fn = 96;

// Parameters
total_length_mm = 70; //[35:140:1]
barrel_diameter_mm = 3.7; //[2:7.4:0.1]
filament_diameter_mm = 1.75; //[1:3:0.01]
filament_clearance_mm = 0.2; //[0.05:0.6:0.01]
filament_channel_diameter_mm = 1.95; //[1.6:3.2:0.01]
overlap_mm = 1; //[0.5:2:0.1]

// Heatsink / cold end
body_diameter_mm = 16; //[8:32:0.5]
body_length_mm = 30; //[15:60:1]
groove_diameter_mm = 12; //[6:24:0.5]
groove_length_mm = 6; //[3:15:0.5]

// Heater block / nozzle
heater_block_x_mm = 20; //[10:40:1]
heater_block_y_mm = 16; //[8:32:1]
heater_block_z_mm = 12; //[6:24:1]
nozzle_base_diameter_mm = 8; //[4:16:0.5]
nozzle_length_mm = 10; //[5:25:0.5]
nozzle_tip_diameter_mm = 2; //[1:6:0.1]

// Extra recognizable features
fin_count = 7;
fin_thickness_mm = 1.2;
fin_gap_mm = 1.6;
fin_diameter_mm = 22;
heatbreak_length_mm = 18; // part of barrel between heatsink and heater block

// Derived / enforced dimensions (ensure exact total length)
cold_end_len = body_length_mm;
heater_len = heater_block_z_mm;
nozzle_len = nozzle_length_mm;
barrel_len = total_length_mm - cold_end_len - heater_len - nozzle_len;
barrel_len_ok = (barrel_len > 0) ? barrel_len : 1;

filament_hole_d = max(filament_channel_diameter_mm, filament_diameter_mm + filament_clearance_mm);

// Coordinate system: Z from -total_length/2 (nozzle tip) to +total_length/2 (top)
z_bottom = -total_length_mm/2;
z_nozzle0 = z_bottom;
z_nozzle1 = z_nozzle0 + nozzle_len;

z_heater0 = z_nozzle1;
z_heater1 = z_heater0 + heater_len;

z_barrel0 = z_heater1;
z_barrel1 = z_barrel0 + barrel_len_ok;

z_cold0 = z_barrel1;
z_cold1 = z_cold0 + cold_end_len;

// Helpers
module zcyl(h, r, z0, center=false) {
    translate([0,0, z0 + (center ? 0 : h/2)]) cylinder(h=h, r=r, center=center);
}

module zcyl_taper(h, r1, r2, z0) {
    translate([0,0, z0 + h/2]) cylinder(h=h, r1=r1, r2=r2, center=true);
}

module zcube(size_xyz, z0) {
    translate([0,0, z0 + size_xyz[2]/2]) cube(size_xyz, center=true);
}

// Main hotend (single connected solid with internal filament path)
module hot_end_connected() {
    difference() {
        union() {
            // Nozzle (tapered)
            zcyl_taper(nozzle_len, nozzle_base_diameter_mm/2, nozzle_tip_diameter_mm/2, z_nozzle0);

            // Heater block (overlaps nozzle and barrel for connectivity)
            translate([0,0, z_heater0 + heater_len/2])
                cube([heater_block_x_mm, heater_block_y_mm, heater_len], center=true);

            // Heatbreak / barrel (3.7mm diameter) - overlaps into heater block and cold end
            translate([0,0, z_barrel0 + barrel_len_ok/2])
                cylinder(h=barrel_len_ok + 2*overlap_mm, r=barrel_diameter_mm/2, center=true);

            // Cold end core cylinder (body)
            translate([0,0, z_cold0 + cold_end_len/2])
                cylinder(h=cold_end_len, r=body_diameter_mm/2, center=true);

            // Groove mount feature near top of cold end (connected by overlap)
            groove_z0 = z_cold1 - groove_length_mm;
            translate([0,0, groove_z0 + groove_length_mm/2 - overlap_mm/2])
                cylinder(h=groove_length_mm + overlap_mm, r=groove_diameter_mm/2, center=true);

            // Heatsink fins (radial discs) around upper cold end for recognizable silhouette
            fins_total_h = fin_count*fin_thickness_mm + (fin_count-1)*fin_gap_mm;
            fins_z0 = z_cold1 - fins_total_h - groove_length_mm - 1; // keep below groove
            for (i = [0:fin_count-1]) {
                fin_z = fins_z0 + i*(fin_thickness_mm + fin_gap_mm);
                translate([0,0, fin_z + fin_thickness_mm/2])
                    cylinder(h=fin_thickness_mm, r=fin_diameter_mm/2, center=true);
            }

            // Small transition collar between barrel and cold end (ensures visible step + connectivity)
            collar_h = 4;
            collar_r = max(body_diameter_mm/2 - 2, barrel_diameter_mm/2 + 1.5);
            collar_z0 = z_cold0 - collar_h + overlap_mm;
            translate([0,0, collar_z0 + collar_h/2])
                cylinder(h=collar_h + overlap_mm, r=collar_r, center=true);
        }

        // Filament path (through entire hotend)
        translate([0,0, 0])
            cylinder(h=total_length_mm + 2, r=filament_hole_d/2, center=true);

        // Optional: small nozzle exit taper (keeps tip looking like an orifice)
        // (still part of the same filament path subtraction)
        translate([0,0, z_nozzle0 + 0.6])
            cylinder(h=1.2, r1=(filament_hole_d/2), r2=(nozzle_tip_diameter_mm/2)*0.55, center=true);
    }
}

hot_end_connected();