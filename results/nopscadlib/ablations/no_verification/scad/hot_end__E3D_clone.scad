$fn = 128;

// =====================
// Target specs (user)
// =====================
total_length_mm = 66.0;          // overall Z length
barrel_diameter_mm = 6.8;        // heatbreak/barrel OD
filament_diameter_mm = 1.75;
filament_clearance_mm = 0.20;
filament_bore_diameter_mm = filament_diameter_mm + 2*filament_clearance_mm; // 2.15

// =====================
// Modeling controls
// =====================
overlap_mm = 0.6;                // overlap to guarantee watertight unions
eps = 0.01;

// =====================
// Hotend proportions (E3D-like, simplified but recognizable)
// Must sum to total_length_mm
// =====================
heatsink_h = 26.0;
heatbreak_h = 12.0;              // thin 6.8mm barrel section
heater_block_h = 12.0;
nozzle_h = total_length_mm - (heatsink_h + heatbreak_h + heater_block_h); // 16.0

// Heatsink geometry
heatsink_core_d = 12.0;
fin_od = 22.0;
fin_id = heatsink_core_d;
fin_th = 1.2;
fin_gap = 1.2;
num_fins = max(1, floor((heatsink_h - fin_th) / (fin_th + fin_gap)));
fin_stack_h = num_fins*(fin_th+fin_gap) - fin_gap;
top_cap_h = heatsink_h - fin_stack_h;
top_cap_d = 16.0;

// Heater block geometry
heater_block_xy = [16.0, 16.0];
heater_block_corner_r = 1.2;

// Nozzle geometry (simplified cone + hex)
nozzle_hex_h = 4.0;
nozzle_hex_flat = 7.0;           // across flats
nozzle_cone_h = max(eps, nozzle_h - nozzle_hex_h);
nozzle_cone_d_top = 7.0;
nozzle_cone_d_tip = 1.2;

// Heatbreak shoulders
heatbreak_shoulder_h = 1.5;
heatbreak_shoulder_d = 8.0;

// =====================
// Helpers
// =====================
module rounded_cube(size=[10,10,10], r=1, center=false) {
    minkowski() {
        cube([max(eps, size[0]-2*r), max(eps, size[1]-2*r), max(eps, size[2]-2*r)], center=center);
        sphere(r=r);
    }
}

module hex_prism(af=7, h=4, center=false) {
    r = af / (2*cos(30));
    cylinder(r=r, h=h, $fn=6, center=center);
}

// =====================
// Single connected hotend solid with internal filament bore
// Z axis: top at +total_length/2, bottom at -total_length/2
// =====================
module hotend_connected() {

    // Segment Z extents (formulas, no arbitrary offsets)
    z_top = total_length_mm/2;
    z_heatsink_bot = z_top - heatsink_h;
    z_heatbreak_bot = z_heatsink_bot - heatbreak_h;
    z_block_bot = z_heatbreak_bot - heater_block_h;
    z_nozzle_bot = -total_length_mm/2;

    difference() {
        union() {

            // ---- Heatsink core (continuous spine) ----
            translate([0,0, z_heatsink_bot + heatsink_h/2])
                cylinder(d=heatsink_core_d, h=heatsink_h + overlap_mm, center=true);

            // ---- Heatsink fins ----
            // Place fins within heatsink region, below top cap
            z_fin_top = z_top - top_cap_h; // top surface where fins begin
            for (i = [0:num_fins-1]) {
                zc = (z_fin_top - fin_th/2) - i*(fin_th+fin_gap);
                translate([0,0, zc])
                    difference() {
                        cylinder(d=fin_od, h=fin_th + overlap_mm, center=true);
                        cylinder(d=fin_id, h=fin_th + overlap_mm + 2*eps, center=true);
                    }
            }

            // ---- Top cap / mount area ----
            translate([0,0, z_top - top_cap_h/2])
                cylinder(d=top_cap_d, h=top_cap_h + overlap_mm, center=true);

            // ---- Heatbreak (barrel) ----
            translate([0,0, z_heatbreak_bot + heatbreak_h/2])
                cylinder(d=barrel_diameter_mm, h=heatbreak_h + overlap_mm, center=true);

            // Shoulder into heatsink (overlap ensures connection)
            translate([0,0, z_heatsink_bot + heatbreak_shoulder_h/2 - overlap_mm/2])
                cylinder(d=heatbreak_shoulder_d, h=heatbreak_shoulder_h + overlap_mm, center=true);

            // Shoulder into heater block
            translate([0,0, z_heatbreak_bot - heatbreak_shoulder_h/2 + overlap_mm/2])
                cylinder(d=heatbreak_shoulder_d, h=heatbreak_shoulder_h + overlap_mm, center=true);

            // ---- Heater block ----
            translate([0,0, z_block_bot + heater_block_h/2])
                rounded_cube([heater_block_xy[0], heater_block_xy[1], heater_block_h + overlap_mm],
                             r=heater_block_corner_r, center=true);

            // ---- Nozzle (hex + cone) ----
            // Hex section directly under heater block (connected)
            translate([0,0, z_block_bot - nozzle_hex_h/2 + overlap_mm/2])
                hex_prism(af=nozzle_hex_flat, h=nozzle_hex_h + overlap_mm, center=true);

            // Cone to tip: connect to hex by starting at hex bottom plane
            z_hex_bot = z_block_bot - nozzle_hex_h; // bottom face of hex (no overlap)
            translate([0,0, z_hex_bot - nozzle_cone_h/2 + overlap_mm/2])
                cylinder(d1=nozzle_cone_d_top, d2=nozzle_cone_d_tip,
                         h=nozzle_cone_h + overlap_mm, center=true);
        }

        // ---- Filament bore (1.75mm + clearance) through entire hotend ----
        cylinder(d=filament_bore_diameter_mm,
                 h=total_length_mm + 2*overlap_mm + 2, center=true);

        // Tiny nozzle exit (keeps bore continuous and visually nozzle-like)
        translate([0,0, z_nozzle_bot + 0.8])
            cylinder(d=0.6, h=2.0, center=true);
    }
}

hotend_connected();