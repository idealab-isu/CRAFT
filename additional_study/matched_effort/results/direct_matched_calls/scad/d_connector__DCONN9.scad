$fn=96;

// D-sub style connector (simplified)
// Units: mm

// ---------- Parameters ----------
body_w = 30;
body_h = 12;
body_d = 12;

flange_w = 40;
flange_h = 16;
flange_t = 2.5;

corner_r = 2.0;

shell_inset = 1.2;     // how much the D-shell is inset from flange outline
shell_t = 1.8;         // thickness of the D-shell wall
shell_depth = 10;      // depth of the D-shell protrusion

pin_rows = 2;
pins_per_row = 5;
pin_pitch_x = 2.77;    // typical D-sub pitch
pin_pitch_y = 2.84;
pin_d = 1.0;
pin_len = 6.0;
pin_offset_z = 0.0;

mount_hole_d = 3.2;
mount_hole_x = 16.5;   // half spacing from center
mount_hole_y = 0;

back_strain_relief_d = 10;
back_strain_relief_len = 10;

// ---------- Helpers ----------
module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2-r2,  h/2-r2]) circle(r=r2);
        translate([-w/2+r2,  h/2-r2]) circle(r=r2);
        translate([ w/2-r2, -h/2+r2]) circle(r=r2);
        translate([-w/2+r2, -h/2+r2]) circle(r=r2);
    }
}

// D-shape 2D: rectangle + semicircle on one side
module dshape_2d(w,h){
    // flat on bottom, rounded on top
    // width w, height h
    union(){
        translate([0, -h/4]) square([w, h/2], center=true);
        translate([0,  h/4]) circle(d=w);
    }
}

// ---------- Main Parts ----------
module flange(){
    difference(){
        linear_extrude(height=flange_t)
            rounded_rect_2d(flange_w, flange_h, corner_r);

        // mounting holes
        translate([ mount_hole_x, mount_hole_y, -0.1])
            cylinder(d=mount_hole_d, h=flange_t+0.2);
        translate([-mount_hole_x, mount_hole_y, -0.1])
            cylinder(d=mount_hole_d, h=flange_t+0.2);

        // opening for D-shell
        translate([0,0,-0.1])
            linear_extrude(height=flange_t+0.2)
                offset(delta=-shell_inset)
                    dshape_2d(body_w*0.9, body_h*0.95);
    }
}

module dshell(){
    // Outer D-shell
    outer_w = body_w*0.9;
    outer_h = body_h*0.95;

    difference(){
        translate([0,0,flange_t])
            linear_extrude(height=shell_depth)
                dshape_2d(outer_w, outer_h);

        // Hollow inside
        translate([0,0,flange_t-0.1])
            linear_extrude(height=shell_depth+0.2)
                offset(delta=-shell_t)
                    dshape_2d(outer_w, outer_h);
    }
}

module body(){
    // Back housing behind flange
    translate([0,0,-body_d])
        linear_extrude(height=body_d)
            rounded_rect_2d(body_w, body_h, corner_r);

    // Strain relief cylinder
    translate([0,0,-body_d-back_strain_relief_len])
        cylinder(d=back_strain_relief_d, h=back_strain_relief_len);
}

module pins(){
    // Pins extend forward from flange (positive Z)
    // Arrange in two staggered rows
    total_w = (pins_per_row-1)*pin_pitch_x;
    for (r=[0:pin_rows-1]){
        y = (r==0) ? pin_pitch_y/2 : -pin_pitch_y/2;
        x_shift = (r==0) ? 0 : pin_pitch_x/2;
        for (i=[0:pins_per_row-1]){
            x = -total_w/2 + i*pin_pitch_x + x_shift;
            translate([x, y, flange_t + 0.5 + pin_offset_z])
                cylinder(d=pin_d, h=pin_len);
        }
    }
}

// ---------- Assembly ----------
union(){
    // Back body
    color([0.15,0.15,0.15]) body();

    // Front flange
    color([0.75,0.75,0.75]) flange();

    // D-shell
    color([0.65,0.65,0.65]) dshell();

    // Pins
    color([0.9,0.8,0.2]) pins();
}