$fn = 96;

// ===== Target dimensions =====
total_length       = 51.2;   // overall Z length
barrel_diameter    = 4.75;   // heatbreak/barrel OD
filament_diameter  = 1.75;   // through-bore

// ===== Connectivity overlap (1–2mm as required) =====
overlap = 1.2;   // guaranteed physical intersection between segments

// Segment lengths (sum must equal total_length)
heatsink_len   = 22.0;
heatbreak_len  = 12.0;
block_len      = 10.0;
nozzle_len     = total_length - (heatsink_len + heatbreak_len + block_len); // = 7.2

// Outer sizes
heatsink_od    = 16.0;
fin_count      = 7;
fin_th         = 1.2;
fin_gap        = (heatsink_len - fin_count*fin_th) / (fin_count-1);

block_w        = 16.0;
block_d        = 16.0;

nozzle_base_d  = 7.0;
nozzle_tip_d   = 1.0;

// Filament path (slightly larger than filament for clearance)
bore_d = filament_diameter + 0.15;

// Coordinate system: Z runs along hotend axis, centered at 0
z_top    =  total_length/2;
z_bottom = -total_length/2;

// Segment Z extents (nominal, no overlap)
z_heatsink_top = z_top;
z_heatsink_bot = z_heatsink_top - heatsink_len;

z_heatbreak_top = z_heatsink_bot;
z_heatbreak_bot = z_heatbreak_top - heatbreak_len;

z_block_top = z_heatbreak_bot;
z_block_bot = z_block_top - block_len;

z_nozzle_top = z_block_bot;
z_nozzle_bot = z_bottom;

// ===== Modules =====
module heatsink() {
    // Central core to ensure one connected solid
    union() {
        translate([0,0,(z_heatsink_top+z_heatsink_bot)/2])
            cylinder(h=heatsink_len, d=barrel_diameter + 1.2, center=true);

        // Fins (radial discs)
        for (i = [0:fin_count-1]) {
            z_i = z_heatsink_bot + i*(fin_th + fin_gap) + fin_th/2;
            translate([0,0,z_i])
                cylinder(h=fin_th, d=heatsink_od, center=true);
        }

        // Top cap (slight thickening)
        translate([0,0,z_heatsink_top - 2.0/2])
            cylinder(h=2.0, d=heatsink_od*0.85, center=true);
    }
}

module heatbreak() {
    // Extend into heatsink and into block by 'overlap' to guarantee union connectivity
    translate([0,0,(z_heatbreak_top+z_heatbreak_bot)/2])
        cylinder(h=heatbreak_len + 2*overlap, d=barrel_diameter, center=true);
}

module heater_block() {
    // Extend into heatbreak and into nozzle by 'overlap' to guarantee union connectivity
    translate([0,0,(z_block_top+z_block_bot)/2])
        cube([block_w, block_d, block_len + 2*overlap], center=true);
}

module nozzle() {
    // Simple nozzle: base cylinder + cone to tip
    // FIX: ensure base and cone overlap each other AND the base overlaps into the heater block
    union() {
        base_h = nozzle_len*0.35;
        cone_h = nozzle_len - base_h;

        // Base cylinder: push upward into the block by 'overlap'
        // Top of base = z_nozzle_top + overlap (intersects block)
        translate([0,0,(z_nozzle_top + overlap) - (base_h + overlap)/2])
            cylinder(h=base_h + overlap, d=nozzle_base_d, center=true);

        // Cone: start slightly inside the base (overlap) to avoid any internal gap
        // Cone top = (z_nozzle_top - base_h) + overlap
        translate([0,0,((z_nozzle_top - base_h) + overlap + z_nozzle_bot)/2])
            cylinder(h=( (z_nozzle_top - base_h) + overlap - z_nozzle_bot ),
                     d1=nozzle_base_d, d2=nozzle_tip_d, center=true);
    }
}

module filament_bore() {
    // Through-bore for 1.75mm filament
    cylinder(h=total_length + 2, d=bore_d, center=true);
}

module hotend_assembly() {
    difference() {
        union() {
            heatsink();
            heatbreak();
            heater_block();
            nozzle();
        }
        filament_bore();
    }
}

// Render
hotend_assembly();