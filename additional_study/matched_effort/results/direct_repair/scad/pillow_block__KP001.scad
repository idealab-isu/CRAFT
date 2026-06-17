$fn=96;

// Pillow Block Bearing (UCP-style) for 12.0mm shaft, base 71x56mm
// Parametric, renderable, printable approximation.

shaft_d = 12.0;

base_L = 71.0;
base_W = 56.0;
base_T = 10.0;

mount_hole_d = 10.0;
mount_hole_spacing = 54.0;   // center-to-center along length
mount_hole_edge_margin = (base_L - mount_hole_spacing)/2;

housing_total_H = 34.0;      // overall height from bottom of base
housing_wall = 6.0;

bearing_OD = 32.0;           // typical for 12mm insert (approx)
bearing_seat_clear = 0.4;    // clearance for printed fit
bearing_seat_d = bearing_OD + bearing_seat_clear;

cap_thickness = 10.0;        // thickness of upper cap region
cap_split_z = base_T + (housing_total_H - base_T) * 0.55;

set_screw_d = 5.0;
set_screw_z = base_T + (housing_total_H - base_T) * 0.62;
set_screw_y_offset = 0.0;

fillet_r = 4.0;

module rounded_box_xy(L, W, H, r){
    // Rounded rectangle prism (rounded in XY only)
    r2 = min(r, min(L,W)/2 - 0.01);
    linear_extrude(height=H)
        offset(r=r2)
            square([L-2*r2, W-2*r2], center=true);
}

module base(){
    difference(){
        rounded_box_xy(base_L, base_W, base_T, fillet_r);

        // Mount holes (2)
        for (sx = [-1, 1]){
            translate([sx*mount_hole_spacing/2, 0, -1])
                cylinder(d=mount_hole_d, h=base_T+2);
        }

        // Light underside relief (optional)
        translate([0,0,-0.01])
            linear_extrude(height=base_T*0.55)
                offset(r=2)
                    square([base_L-14, base_W-14], center=true);
    }
}

module housing_outer(){
    // Outer housing as a rounded block + arch
    H = housing_total_H - base_T;
    translate([0,0,base_T]){
        union(){
            // Main block
            rounded_box_xy(52, 40, H, 5);

            // Arch bulge around bearing
            translate([0,0,H*0.35])
                rotate([90,0,0])
                    cylinder(d=bearing_OD + 2*housing_wall + 10, h=40, center=true);
        }
    }
}

module housing_inner_cavity(){
    // Bearing seat + shaft bore + split line relief
    H = housing_total_H - base_T;

    // Shaft bore through
    translate([0,0,-1])
        cylinder(d=shaft_d + 0.6, h=housing_total_H+2);

    // Bearing seat (cylindrical pocket)
    translate([0,0,base_T + H*0.55])
        rotate([90,0,0])
            cylinder(d=bearing_seat_d, h=44, center=true);

    // Slight chamfer/lead-in for seat
    translate([0,0,base_T + H*0.55])
        rotate([90,0,0])
            cylinder(d1=bearing_seat_d+2.0, d2=bearing_seat_d, h=3.0, center=false);

    // Split line groove (visual)
    translate([0,0,cap_split_z-0.6])
        rounded_box_xy(60, 46, 1.2, 3);

    // Clearance pockets near base corners (reduce material)
    translate([0,0,base_T+2])
        rounded_box_xy(44, 30, H-6, 4);
}

module set_screw_holes(){
    // Two opposing set screw holes into the bearing region (approx)
    for (sy = [-1, 1]){
        translate([0, sy*(18/2), set_screw_z])
            rotate([0,90,0])
                cylinder(d=set_screw_d, h=70, center=true);
    }
}

module grease_port(){
    // Simple top grease port boss + hole
    boss_d = 10;
    boss_h = 6;
    hole_d = 3.5;

    translate([0,0,housing_total_H]){
        difference(){
            cylinder(d=boss_d, h=boss_h);
            translate([0,0,-1])
                cylinder(d=hole_d, h=boss_h+2);
        }
    }
}

module pillow_block(){
    difference(){
        union(){
            base();
            housing_outer();
            grease_port();
        }
        housing_inner_cavity();
        set_screw_holes();
    }
}

pillow_block();