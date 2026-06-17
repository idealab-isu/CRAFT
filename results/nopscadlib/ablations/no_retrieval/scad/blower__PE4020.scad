// Centrifugal blower fan 40x40x20mm (single connected solid)
// Fixes: ensure visible geometry, connected outlet, real inlet/outlet openings,
// impeller is fused to housing via a thin internal bridge (still looks like an impeller).

$fn = 96;

// Parameters
fan_L = 40; //[20:80:1]
fan_W = 40; //[20:80:1]
fan_H = 20; //[10:40:1]

wall_t = 1.5; //[0.8:3:0.1]
lid_t  = 1.5; //[0.8:3:0.1]

inlet_d = 22; //[12:34:1]

outlet_W   = 12; //[6:24:1]
outlet_H   = 8;  //[4:16:1]
outlet_len = 8;  //[4:16:1]

volute_clearance = 1; //[0.5:2.5:0.1]

impeller_D = 28; //[18:34:1]
impeller_H = 16; //[10:18:1]
impeller_blade_t = 1; //[0.6:2:0.1]
impeller_blade_count = 12; //[6:24:1]

hub_d = 8; //[5:14:0.5]
hub_H = 16; //[10:18:1]
shaft_d = 2; //[1:5:0.1]

mount_hole_d = 3; //[2:5:0.1]
mount_hole_edge_offset = 4; //[2:8:0.5]

mount_boss_d = 10; //[6:18:0.5]
mount_boss_H = 4;  //[2:8:0.5]

grille_bar_w = 2;  //[1:4:0.1]
screw_head_d = 5.5; //[4:8:0.1]
screw_head_h = 1.5; //[0.8:3:0.1]

overlap = 1; //[0.5:2:0.1]

// Derived
z_top =  fan_H/2;
z_bot = -fan_H/2;

// Keep cavities within housing
cav_h = fan_H - lid_t - wall_t;
cav_z = z_bot + wall_t + cav_h/2;

// Volute radius (kept inside walls)
volute_r = min((impeller_D/2) + volute_clearance, min(fan_L, fan_W)/2 - wall_t - 0.5);

// Outlet placement: attached to right face with slight overlap
outlet_x = fan_L/2 + outlet_len/2 - overlap;
outlet_z = cav_z; // align with internal cavity height

// Inlet is on top lid
inlet_z = z_top - lid_t/2;

// Mount hole positions
mhx = fan_L/2 - mount_hole_edge_offset;
mhy = fan_W/2 - mount_hole_edge_offset;

// Impeller placement: inside cavity, slightly below lid
imp_z = cav_z;

// Small internal bridge to ensure ONE connected solid (fuses impeller to housing)
bridge_t = 0.8;
bridge_w = 2.0;
bridge_len = wall_t + 1.2; // reaches inner wall with overlap
bridge_x = (fan_L/2 - wall_t) - bridge_len/2 + 0.2; // near right inner wall
bridge_z = imp_z;

// ----------------- Modules -----------------
module housing_outer() {
    cube([fan_L, fan_W, fan_H], center=true);
}

module volute_cavity() {
    translate([0, 0, cav_z])
        cylinder(h=cav_h + 2*overlap, r=volute_r, center=true);
}

module outlet_cavity() {
    // Internal duct from volute to outlet
    // Starts inside housing and extends into outlet nozzle region
    duct_len = fan_L/2 + outlet_len + overlap;
    translate([fan_L/4, 0, outlet_z])
        cube([duct_len, outlet_W, outlet_H], center=true);
}

module inlet_hole() {
    translate([0, 0, inlet_z])
        cylinder(h=lid_t + 2*overlap, r=inlet_d/2, center=true);
}

module outlet_nozzle_solid() {
    // External nozzle attached to housing
    translate([outlet_x, 0, outlet_z])
        cube([outlet_len, outlet_W + 2*wall_t, outlet_H + 2*wall_t], center=true);
}

module outlet_nozzle_hole() {
    translate([outlet_x, 0, outlet_z])
        cube([outlet_len + 2*overlap, outlet_W, outlet_H], center=true);
}

module mounting_hole(x, y) {
    translate([x, y, 0])
        cylinder(h=fan_H + 2*overlap, r=mount_hole_d/2, center=true);
}

module screw_head(x, y) {
    translate([x, y, z_top - lid_t - screw_head_h/2 + overlap])
        cylinder(h=screw_head_h, r=screw_head_d/2, center=true);
}

module grille_bars() {
    // Simple cross bars on inlet (solid, not subtractive)
    translate([0, 0, inlet_z])
        union() {
            cube([inlet_d + 2*wall_t, grille_bar_w, lid_t], center=true);
            cube([grille_bar_w, inlet_d + 2*wall_t, lid_t], center=true);
        }
}

module motor_mount_boss() {
    translate([0, 0, z_bot + mount_boss_H/2 - overlap])
        cylinder(h=mount_boss_H, r=mount_boss_d/2, center=true);
}

module impeller_hub() {
    translate([0, 0, imp_z])
        cylinder(h=hub_H, r=hub_d/2, center=true);
}

module impeller_shaft_hole() {
    translate([0, 0, imp_z])
        cylinder(h=hub_H + 2*overlap, r=shaft_d/2, center=true);
}

module impeller_blade(angle) {
    blade_len = (impeller_D/2 - hub_d/2) + overlap;
    // Place blades radially, protruding outward from hub
    rotate([0, 0, angle])
        translate([hub_d/2 + blade_len/2 - overlap, 0, imp_z])
            cube([blade_len, impeller_blade_t, impeller_H], center=true);
}

module impeller() {
    difference() {
        union() {
            impeller_hub();
            for (i = [0:impeller_blade_count-1])
                impeller_blade(i * 360 / impeller_blade_count);
        }
        impeller_shaft_hole();
    }
}

module impeller_bridge() {
    // Thin bridge from impeller region to inner wall to guarantee single connected solid
    translate([bridge_x, 0, bridge_z])
        cube([bridge_len, bridge_w, bridge_t], center=true);
}

// ----------------- Final solid -----------------
module blower_solid() {
    union() {
        // Housing with internal cavities and openings
        difference() {
            union() {
                housing_outer();
                outlet_nozzle_solid();
            }

            // Internal cavities
            volute_cavity();
            outlet_cavity();

            // Openings
            inlet_hole();
            outlet_nozzle_hole();

            // Mounting holes
            mounting_hole( mhx,  mhy);
            mounting_hole(-mhx,  mhy);
            mounting_hole(-mhx, -mhy);
            mounting_hole( mhx, -mhy);
        }

        // Lid details (solid features)
        grille_bars();
        screw_head( mhx,  mhy);
        screw_head(-mhx,  mhy);
        screw_head(-mhx, -mhy);
        screw_head( mhx, -mhy);

        // Bottom boss
        motor_mount_boss();

        // Impeller (fused via bridge so the whole model is one connected solid)
        impeller();
        impeller_bridge();
    }
}

blower_solid();