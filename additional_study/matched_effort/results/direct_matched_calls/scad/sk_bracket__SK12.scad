$fn=96;

// Parameters
rod_d = 12.0;
rod_r = rod_d/2;

bracket_height = 23.0;      // overall height (Z)
base_len = 42.0;            // X
base_wid = 28.0;            // Y
base_thk = 6.0;             // Z thickness of base

wall_thk = 6.0;             // thickness around bore (radial)
outer_d = rod_d + 2*wall_thk;

center_x = base_len/2;
center_y = base_wid/2;

// Clamp slit and screw
slit_w = 1.2;               // width of clamp slit
screw_d = 5.2;              // clearance for M5
nut_flat = 8.2;             // across flats for M5 nut (approx)
nut_thk = 4.2;              // nut thickness
nut_trap_depth = 6.5;       // how far nut pocket goes in from side

// Mounting holes
mount_hole_d = 5.2;         // clearance for M5
mount_x_off = 10.0;         // from ends
mount_y_off = 7.0;          // from sides
mount_csk_d = 9.5;          // simple counterbore diameter
mount_csk_depth = 2.5;      // counterbore depth

module hex_prism(af=8, h=4){
    // across flats af
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module bracket(){
    difference(){
        union(){
            // Base
            translate([0,0,0])
                cube([base_len, base_wid, base_thk], center=false);

            // Upright boss (cylindrical) sitting on base
            translate([center_x, center_y, base_thk])
                cylinder(h=bracket_height-base_thk, d=outer_d);

            // Small fillet-like ribs (simple triangular prisms) front/back
            rib_len = outer_d*0.55;
            rib_h = bracket_height-base_thk;
            rib_thk = 6;
            // front rib
            translate([center_x - rib_len/2, 0, base_thk])
                linear_extrude(height=rib_h)
                    polygon(points=[
                        [0,0],
                        [rib_len,0],
                        [rib_len/2, rib_thk]
                    ]);
            // back rib
            translate([center_x - rib_len/2, base_wid, base_thk])
                rotate([0,0,180])
                linear_extrude(height=rib_h)
                    polygon(points=[
                        [0,0],
                        [rib_len,0],
                        [rib_len/2, rib_thk]
                    ]);
        }

        // Rod bore (through boss)
        translate([center_x, center_y, base_thk])
            cylinder(h=bracket_height-base_thk+0.2, d=rod_d);

        // Clamp slit (from top down through boss)
        translate([center_x - slit_w/2, center_y - outer_d/2 - 1, base_thk])
            cube([slit_w, outer_d + 2, bracket_height-base_thk+0.2], center=false);

        // Clamp screw hole (cross through boss, perpendicular to slit)
        screw_z = base_thk + (bracket_height-base_thk)*0.55;
        translate([center_x, center_y, screw_z])
            rotate([0,90,0])
                cylinder(h=base_len+2, d=screw_d, center=true);

        // Nut trap on left side
        translate([0 - 0.01, center_y, screw_z])
            rotate([0,90,0])
                translate([0,0,0])
                    hex_prism(af=nut_flat, h=nut_trap_depth);

        // Simple counterbore for screw head on right side
        head_d = 9.5;
        head_depth = 3.0;
        translate([base_len - head_depth + 0.01, center_y, screw_z])
            rotate([0,90,0])
                cylinder(h=head_depth+0.5, d=head_d);

        // Mounting holes (2x) with counterbores from bottom
        for(xp = [mount_x_off, base_len - mount_x_off]){
            for(yp = [mount_y_off, base_wid - mount_y_off]){
                // through hole
                translate([xp, yp, -0.1])
                    cylinder(h=base_thk+0.2, d=mount_hole_d);
                // counterbore
                translate([xp, yp, base_thk - mount_csk_depth])
                    cylinder(h=mount_csk_depth+0.2, d=mount_csk_d);
            }
        }
    }
}

bracket();