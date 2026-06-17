$fn=96;

// Pillow block bearing for 8.0mm shaft, 55.0mm x 42.0mm base
// Parametric, printable housing with two mounting holes and a split clamp.

shaft_d = 8.0;

base_L = 55.0;
base_W = 42.0;
base_T = 8.0;

mount_hole_d = 6.5;          // clearance for M6
mount_hole_spacing = 40.0;   // center-to-center along length
mount_hole_edge_margin = (base_L - mount_hole_spacing)/2;

boss_outer_d = 28.0;         // outer diameter of bearing boss
boss_h = 22.0;               // height above base
bore_clearance = 0.35;       // extra clearance on shaft bore

seat_depth = 2.0;            // shallow counterbore at top for bushing/bearing lip (optional)
seat_d = 12.0;

clamp_slot_w = 2.2;          // split clamp slot width
clamp_bolt_d = 3.4;          // clearance for M3
clamp_nut_flat = 5.7;        // M3 nut across flats
clamp_nut_th = 2.6;
clamp_bolt_z = base_T + boss_h*0.62; // height of clamp bolt through boss
clamp_bolt_y = 0;            // centered

fillet_r = 3.0;

module rounded_rect_prism(L,W,H,r){
    // 2D rounded rectangle extruded
    linear_extrude(height=H)
        offset(r=r)
            square([L-2*r, W-2*r], center=true);
}

module hex_prism(af, h){
    // across flats = af
    r = af / (2*cos(30));
    linear_extrude(height=h)
        polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

module pillow_block(){
    difference(){
        union(){
            // Base
            translate([0,0,base_T/2])
                rounded_rect_prism(base_L, base_W, base_T, fillet_r);

            // Boss (bearing housing)
            translate([0,0,base_T])
                cylinder(d=boss_outer_d, h=boss_h);

            // Gussets (front/back)
            gus_w = base_W*0.62;
            gus_t = 6.0;
            gus_h = boss_h*0.75;
            for(s=[-1,1]){
                translate([0, s*(gus_w/2), base_T])
                    rotate([0,90,0])
                        linear_extrude(height=gus_t, center=true)
                            polygon([
                                [0,0],
                                [gus_h,0],
                                [0,gus_h*0.85]
                            ]);
            }
        }

        // Mounting holes
        for(x=[-mount_hole_spacing/2, mount_hole_spacing/2]){
            translate([x,0,-0.5])
                cylinder(d=mount_hole_d, h=base_T+boss_h+2);
            // light counterbore for screw head
            translate([x,0,base_T-2.2])
                cylinder(d=11.5, h=2.4);
        }

        // Shaft bore through boss
        translate([0,0,base_T-0.5])
            cylinder(d=shaft_d + 2*bore_clearance, h=boss_h+base_T+2);

        // Optional shallow seat at top
        translate([0,0,base_T+boss_h-seat_depth])
            cylinder(d=seat_d, h=seat_depth+0.6);

        // Split clamp slot (cuts through boss and slightly into base)
        translate([0,0,base_T-0.5])
            cube([boss_outer_d+2, clamp_slot_w, boss_h+base_T+2], center=true);

        // Clamp bolt through-hole (across Y)
        translate([0,0,clamp_bolt_z])
            rotate([90,0,0])
                cylinder(d=clamp_bolt_d, h=base_W+10, center=true);

        // Nut trap on +Y side
        translate([0, base_W/2 - 6.5, clamp_bolt_z])
            rotate([90,0,0])
                hex_prism(clamp_nut_flat, clamp_nut_th+0.6);

        // Bolt head recess on -Y side
        translate([0, -base_W/2 + 6.5, clamp_bolt_z])
            rotate([90,0,0])
                cylinder(d=6.6, h=3.2, center=false);
    }
}

pillow_block();