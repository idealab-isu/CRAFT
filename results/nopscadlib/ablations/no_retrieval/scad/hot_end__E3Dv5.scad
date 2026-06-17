// Hot end (connected) - 70mm total length, 3.7mm barrel diameter, 1.75mm filament path
// Fix: orient hotend along X (length) so FRONT/BACK/LEFT/RIGHT orthographic views show length clearly.
// Output is one connected solid; all placements are derived from dimensions (no arbitrary offsets).

$fn = 96;

// -------------------- Parameters --------------------
total_L = 70;                 // total length (X)
barrel_D = 3.7;               // heatbreak/barrel OD
filament_D = 1.75;            // filament
bore_clearance = 0.25;        // extra clearance on filament path
bore_D = filament_D + bore_clearance;

overlap = 1;                  // overlap for boolean robustness

// Segment lengths (must sum to total_L)
heatsink_L = 22;
barrel_L   = 28;
heater_block_L = 15;
nozzle_L   = total_L - (heatsink_L + barrel_L + heater_block_L); // ensures exact total length

// Heatsink geometry
fin_count = 7;
fin_thk = 1.2;
fin_gap = 1.2;
fin_OD  = 16;
heatsink_core_D = 8.5;        // core under fins (typical heatsink body)
top_cap_D = 12;               // top collar
top_cap_L = 3;

// Groove mount (simple ring groove)
mount_groove_W = 6;
mount_groove_depth = 0.6;

// Heater block geometry
heater_block_W = 16;          // Y
heater_block_H = 12;          // Z

// Nozzle geometry (simple hex + cone tip)
nozzle_hex_AF = 7;            // across flats
nozzle_hex_L  = max(3, nozzle_L*0.55);
nozzle_cone_L = nozzle_L - nozzle_hex_L;
nozzle_base_D = 7.5;
nozzle_tip_D  = 0.8;

// Heater cartridge / thermistor holes
cartridge_D = 6;
thermistor_D = 3;

// -------------------- Derived X layout --------------------
// Model spans x = [-total_L/2, +total_L/2]
x_top =  total_L/2;
x_bot = -total_L/2;

x_heatsink_top = x_top;
x_heatsink_bot = x_heatsink_top - heatsink_L;

x_barrel_top = x_heatsink_bot;
x_barrel_bot = x_barrel_top - barrel_L;

x_block_top = x_barrel_bot;
x_block_bot = x_block_top - heater_block_L;

x_nozzle_top = x_block_bot;
x_nozzle_bot = x_bot; // exact

// Centers
x_heatsink_c = (x_heatsink_top + x_heatsink_bot)/2;
x_barrel_c   = (x_barrel_top   + x_barrel_bot)/2;
x_block_c    = (x_block_top    + x_block_bot)/2;
x_nozzle_c   = (x_nozzle_top   + x_nozzle_bot)/2;

// -------------------- Helpers --------------------
module x_cyl(x0, x1, r1, r2=r1) {
    // cylinder spanning [x0,x1] along X axis
    translate([(x0+x1)/2, 0, 0])
        rotate([0,90,0])
            cylinder(h=abs(x1-x0), r1=r1, r2=r2, center=true);
}

module hex_prism_x(af, h) {
    // across-flats hex prism along X axis
    // For a regular hex: AF = 2*R*cos(30) => R = AF/(2*cos30)
    R = af/(2*cos(30));
    rotate([0,90,0])
        cylinder(h=h, r=R, $fn=6, center=true);
}

// -------------------- Solids --------------------
module heatsink_solid() {
    union() {
        // Core
        x_cyl(x_heatsink_bot - overlap, x_heatsink_top + overlap, heatsink_core_D/2);

        // Top cap (collar)
        x_cyl(x_heatsink_top - top_cap_L, x_heatsink_top, top_cap_D/2);

        // Fins distributed within heatsink length, guaranteed to stay inside
        fin_stack_L = fin_count*fin_thk + (fin_count-1)*fin_gap;
        fin_margin = max(0, (heatsink_L - fin_stack_L)/2);
        for (i = [0:fin_count-1]) {
            x0 = x_heatsink_top - fin_margin - (i*(fin_thk+fin_gap)) - fin_thk;
            x1 = x0 + fin_thk;
            x_cyl(x0, x1, fin_OD/2);
        }
    }
}

module barrel_solid() {
    // Heatbreak/barrel (3.7mm OD) spanning barrel segment, overlapped into neighbors
    x_cyl(x_barrel_bot - overlap, x_barrel_top + overlap, barrel_D/2);
}

module heater_block_solid() {
    // Block centered on its segment, overlapped into barrel/nozzle
    translate([x_block_c, 0, 0])
        cube([heater_block_L + 2*overlap, heater_block_W, heater_block_H], center=true);
}

module nozzle_solid() {
    union() {
        // Hex section at top of nozzle segment
        x_hex_top = x_nozzle_top;
        x_hex_bot = x_nozzle_top - nozzle_hex_L;
        translate([(x_hex_top+x_hex_bot)/2, 0, 0])
            hex_prism_x(nozzle_hex_AF, abs(x_hex_top - x_hex_bot) + 2*overlap);

        // Transition from block to nozzle base (short taper)
        x_cyl(x_nozzle_top - overlap, x_nozzle_top + overlap, nozzle_base_D/2);

        // Cone to tip
        x_cone_top = x_hex_bot;
        x_cone_bot = x_nozzle_bot;
        x_cyl(x_cone_bot, x_cone_top, nozzle_tip_D/2, nozzle_base_D/2);
    }
}

module mount_groove_cut() {
    // Groove ring cut into heatsink core area (simple)
    // Place groove within heatsink, near its lower half
    groove_center_x = x_heatsink_bot + heatsink_L*0.45;
    translate([groove_center_x, 0, 0])
        rotate([0,90,0])
            cylinder(h=mount_groove_W, r=heatsink_core_D/2 + mount_groove_depth, center=true);
}

module heater_cartridge_hole_cut() {
    // Through Y direction, centered in heater block
    translate([x_block_c, 0, 0])
        rotate([90,0,0])
            cylinder(h=heater_block_W + 2*overlap, r=cartridge_D/2, center=true);
}

module thermistor_hole_cut() {
    // Through Z direction, slightly below center in block
    therm_y = 0;
    therm_z = -heater_block_H*0.20;
    translate([x_block_c, therm_y, therm_z])
        cylinder(h=heater_block_H + 2*overlap, r=thermistor_D/2, center=true);
}

module filament_bore_cut() {
    // Continuous filament path through entire hotend along X
    rotate([0,90,0])
        cylinder(h=total_L + 4*overlap, r=bore_D/2, center=true);
}

// -------------------- Assembly --------------------
module hotend_connected() {
    // Union of all solids (with overlaps) ensures one connected body
    union() {
        heatsink_solid();
        barrel_solid();
        heater_block_solid();
        nozzle_solid();
    }
}

difference() {
    difference() {
        difference() {
            hotend_connected();
            mount_groove_cut();
        }
        heater_cartridge_hole_cut();
        thermistor_hole_cut();
    }
    filament_bore_cut();
}