$fn=96;

// Pillow Block Bearing (UCP-style) for 12.0mm shaft, base 71x56mm
// Parametric, renderable, printable approximation.

shaft_d = 12.0;

base_L = 71.0;
base_W = 56.0;
base_H = 10.0;

mount_hole_d = 10.0;
mount_hole_x = 54.0;   // center-to-center along length (typical for 71mm base)
mount_hole_y = 0.0;

housing_total_H = 36.0; // overall height from bottom of base to top
housing_wall = 6.0;

bearing_OD = 32.0;      // typical for 12mm insert (approx)
bearing_width = 18.0;

set_screw_d = 5.0;
set_screw_angle = 25;   // degrees from top, toward shaft

fillet_r = 3.0;

module rounded_box(L, W, H, r){
    r2 = min(r, min(L,W)/2 - 0.01);
    linear_extrude(height=H)
        offset(r=r2)
            square([L-2*r2, W-2*r2], center=true);
}

module slot_hole(d, slot_len, h){
    // slot along X
    hull(){
        translate([-slot_len/2,0,0]) cylinder(d=d, h=h, center=false);
        translate([ slot_len/2,0,0]) cylinder(d=d, h=h, center=false);
    }
}

module pillow_block(){
    difference(){
        union(){
            // Base
            translate([0,0,0])
                rounded_box(base_L, base_W, base_H, fillet_r);

            // Housing pedestal (blended)
            pedestal_H = housing_total_H - base_H;
            pedestal_L = 46.0;
            pedestal_W = 44.0;

            translate([0,0,base_H])
                rounded_box(pedestal_L, pedestal_W, pedestal_H*0.55, fillet_r);

            // Main housing (arched)
            arch_H = pedestal_H;
            arch_L = 46.0;
            arch_W = 44.0;

            translate([0,0,base_H])
            hull(){
                // lower block
                translate([0,0,0])
                    rounded_box(arch_L, arch_W, arch_H*0.55, fillet_r);
                // upper arch cap
                translate([0,0,arch_H*0.55])
                    scale([1.0,1.0,1.0])
                        cylinder(d= bearing_OD + 2*housing_wall, h= arch_H*0.45);
            }

            // Side ribs
            rib_t = 6.0;
            rib_H = housing_total_H - base_H;
            rib_L = 18.0;
            rib_W = 18.0;
            for (sx=[-1,1]){
                translate([sx*(base_L*0.28), 0, base_H])
                    rotate([0,0,0])
                        rounded_box(rib_L, rib_W, rib_H*0.65, 2.0);
            }
        }

        // Mounting holes (slotted slightly along length)
        hole_h = base_H + 0.5;
        slot_len = 4.0;
        for (sx=[-1,1]){
            translate([sx*mount_hole_x/2, mount_hole_y, -0.01])
                slot_hole(mount_hole_d, slot_len, hole_h+0.02);
        }

        // Bearing bore through housing (along X)
        bore_center_z = base_H + (housing_total_H - base_H)*0.62;
        translate([0,0,bore_center_z])
            rotate([0,90,0])
                cylinder(d=bearing_OD, h=base_L+20, center=true);

        // Shaft clearance through insert (slightly larger than shaft)
        translate([0,0,bore_center_z])
            rotate([0,90,0])
                cylinder(d=shaft_d+0.4, h=base_L+30, center=true);

        // Relief pocket around bearing (to suggest insert seat)
        seat_d = bearing_OD + 6.0;
        seat_w = bearing_width + 6.0;
        translate([0,0,bore_center_z])
            rotate([0,90,0])
                cylinder(d=seat_d, h=seat_w, center=true);

        // Top grease port (simple)
        translate([0,0,housing_total_H-6])
            cylinder(d=6.0, h=10.0, center=false);

        // Set screw hole (angled into bore)
        translate([0,0,bore_center_z])
            rotate([0,0,0])
                rotate([0,set_screw_angle,0])
                    translate([0, (bearing_OD/2 + housing_wall*0.6), 0])
                        rotate([90,0,0])
                            cylinder(d=set_screw_d, h=40, center=true);

        // Underside chamfer pockets (lightweight)
        pocket_L = base_L - 14;
        pocket_W = base_W - 14;
        pocket_H = 3.0;
        translate([0,0,0.8])
            rounded_box(pocket_L, pocket_W, pocket_H, 2.0);
    }
}

pillow_block();