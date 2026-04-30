$fn=64;

// Parameters (mm)
wall = 2.2;
clearance = 0.6;

inner_len = 60;
inner_wid = 30;
inner_hgt = 18;

outer_len = inner_len + 2*wall;
outer_wid = inner_wid + 2*wall;
outer_hgt = inner_hgt + 2*wall;

lid_th = 2.2;
base_h = outer_hgt - lid_th;

// OLED window (0.96" typical visible area ~21.7 x 11.0)
oled_win_x = 22.0;
oled_win_y = 12.0;
oled_win_r = 1.2;

// OLED module clearance pocket (optional shallow recess)
oled_pocket_x = 27.0;
oled_pocket_y = 15.0;
oled_pocket_d = 1.2;

// ESP32 DevKit approximate board
board_len = 52.0;
board_wid = 28.0;
board_th = 1.6;

// Standoffs
standoff_h = 6.0;
standoff_od = 6.0;
standoff_hole = 2.6;

// USB cutout
usb_w = 12.5;
usb_h = 6.5;
usb_depth = wall + 1.0;

// Side vent holes
vent_r = 1.4;
vent_rows = 2;
vent_cols = 6;
vent_pitch = 6.0;

// Helper: rounded rectangle prism
module rounded_rect_prism(x, y, z, r) {
    hull() {
        translate([ x/2 - r,  y/2 - r, 0]) cylinder(h=z, r=r);
        translate([-x/2 + r,  y/2 - r, 0]) cylinder(h=z, r=r);
        translate([ x/2 - r, -y/2 + r, 0]) cylinder(h=z, r=r);
        translate([-x/2 + r, -y/2 + r, 0]) cylinder(h=z, r=r);
    }
}

// Helper: rounded rectangle cut (centered)
module rounded_rect_cut(x, y, z, r) {
    rounded_rect_prism(x, y, z, r);
}

// Standoff positions (approx for DevKit 30-pin; adjust as needed)
standoff_dx = 44.0;
standoff_dy = 20.0;

module standoff(pos=[0,0,0]) {
    translate(pos)
    difference() {
        cylinder(h=standoff_h, r=standoff_od/2);
        translate([0,0,-0.2]) cylinder(h=standoff_h+0.4, r=standoff_hole/2);
    }
}

module base() {
    difference() {
        // Outer shell
        translate([0,0,0])
            rounded_rect_prism(outer_len, outer_wid, base_h, 4);

        // Inner cavity
        translate([0,0,wall])
            rounded_rect_prism(inner_len + clearance, inner_wid + clearance, base_h - wall + 0.2, 3);

        // USB cutout on +X face
        translate([ outer_len/2 - wall/2, 0, wall + 5.5])
            rotate([0,90,0])
                rounded_rect_cut(usb_w, usb_h, usb_depth + 0.5, 1.2);

        // Side vents on -Y face
        for (r = [0:vent_rows-1])
        for (c = [0:vent_cols-1]) {
            x = - (vent_cols-1)*vent_pitch/2 + c*vent_pitch;
            z = wall + 5 + r*5.0;
            translate([x, -outer_wid/2 + wall/2, z])
                rotate([90,0,0])
                    cylinder(h=wall+0.6, r=vent_r);
        }

        // Side vents on +Y face
        for (r = [0:vent_rows-1])
        for (c = [0:vent_cols-1]) {
            x = - (vent_cols-1)*vent_pitch/2 + c*vent_pitch;
            z = wall + 5 + r*5.0;
            translate([x, outer_wid/2 - wall/2, z])
                rotate([90,0,0])
                    cylinder(h=wall+0.6, r=vent_r);
        }
    }

    // Standoffs inside
    z0 = wall;
    translate([0,0,z0]) {
        standoff([ standoff_dx/2,  standoff_dy/2, 0]);
        standoff([-standoff_dx/2,  standoff_dy/2, 0]);
        standoff([ standoff_dx/2, -standoff_dy/2, 0]);
        standoff([-standoff_dx/2, -standoff_dy/2, 0]);
    }

    // Simple alignment lip (male) for lid
    lip_h = 1.2;
    lip_t = 1.2;
    translate([0,0,base_h - lip_h])
    difference() {
        rounded_rect_prism(inner_len - 0.5, inner_wid - 0.5, lip_h, 2.5);
        translate([0,0,-0.1])
            rounded_rect_prism(inner_len - 0.5 - 2*lip_t, inner_wid - 0.5 - 2*lip_t, lip_h + 0.2, 2.0);
    }
}

module lid() {
    difference() {
        // Lid outer
        translate([0,0,base_h])
            rounded_rect_prism(outer_len, outer_wid, lid_th, 4);

        // Underside recess (female) to fit lip
        recess_h = 1.4;
        recess_clear = 0.4;
        translate([0,0,base_h + (lid_th - recess_h)])
            rounded_rect_prism(inner_len + recess_clear, inner_wid + recess_clear, recess_h + 0.2, 2.6);

        // OLED window cutout (through)
        translate([0,0,base_h - 0.1])
            rounded_rect_cut(oled_win_x, oled_win_y, lid_th + 0.4, oled_win_r);

        // OLED pocket (shallow recess on top surface)
        translate([0,0,base_h + lid_th - oled_pocket_d])
            rounded_rect_cut(oled_pocket_x, oled_pocket_y, oled_pocket_d + 0.2, 1.6);
    }
}

union() {
    // Center overall around origin in X/Y; Z centered by shifting
    z_shift = -(outer_hgt/2);
    translate([0,0,z_shift]) {
        base();
        lid();
    }
}