$fn = 96;

// D-sub style connector body (simplified)
module d_connector(
    body_w = 30,
    body_h = 12,
    body_d = 14,
    flange_w = 38,
    flange_h = 16,
    flange_t = 2.5,
    corner_r = 2.0,
    shell_inset = 1.2,
    shell_depth = 8,
    shell_r = 5.2,
    pin_rows = 2,
    pins_per_row = 5,
    pin_pitch = 2.77,
    row_pitch = 2.84,
    pin_d = 1.0,
    pin_len = 6,
    screw_hole_d = 3.2,
    screw_boss_d = 7.0,
    screw_boss_h = 3.0,
    screw_offset_x = 15.5
){
    module rounded_box(sz=[10,10,10], r=1){
        x=sz[0]; y=sz[1]; z=sz[2];
        hull(){
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(x/2-r), sy*(y/2-r), 0])
                    cylinder(r=r, h=z, center=false);
        }
    }

    module d_profile(w, h, r){
        // 2D D-shape: rectangle + semicircle
        // width w, height h, semicircle radius r (typically h/2)
        rr = min(r, h/2);
        union(){
            translate([-w/2, -h/2]) square([w-rr, h], center=false);
            translate([w/2-rr, 0]) circle(r=rr);
        }
    }

    // Main body
    color([0.15,0.15,0.15])
    difference(){
        union(){
            // flange
            translate([0,0,0])
                linear_extrude(height=flange_t)
                    offset(r=corner_r)
                        square([flange_w-2*corner_r, flange_h-2*corner_r], center=true);

            // body behind flange
            translate([0,0,flange_t])
                rounded_box([body_w, body_h, body_d], r=corner_r);

            // screw bosses
            for (sx=[-1,1])
                translate([sx*screw_offset_x, 0, 0])
                    cylinder(d=screw_boss_d, h=flange_t + screw_boss_h, center=false);
        }

        // screw holes
        for (sx=[-1,1])
            translate([sx*screw_offset_x, 0, -0.5])
                cylinder(d=screw_hole_d, h=flange_t + screw_boss_h + 1, center=false);

        // front shell recess (D-shaped)
        translate([0,0,flange_t + shell_inset])
            linear_extrude(height=shell_depth)
                d_profile(w=body_w-4, h=body_h-2, r=shell_r);
    }

    // Metal shell lip (front)
    color([0.75,0.75,0.78])
    translate([0,0,flange_t + shell_inset])
    difference(){
        linear_extrude(height=1.2)
            d_profile(w=body_w-3.2, h=body_h-1.2, r=shell_r+0.2);
        translate([0,0,-0.2])
            linear_extrude(height=1.6)
                d_profile(w=body_w-5.2, h=body_h-3.2, r=shell_r-0.6);
    }

    // Pins
    color([0.9,0.75,0.2])
    translate([0,0,flange_t + shell_inset + 1.2])
    {
        total_w = (pins_per_row-1)*pin_pitch;
        row_y = (pin_rows-1)*row_pitch/2;

        for (ridx=[0:pin_rows-1]){
            y = (ridx==0) ? row_y : -row_y;
            // stagger second row slightly
            xoff = (ridx%2==0) ? 0 : pin_pitch/2;
            for (i=[0:pins_per_row-1]){
                x = -total_w/2 + i*pin_pitch + xoff;
                translate([x, y, 0])
                    cylinder(d=pin_d, h=pin_len, center=false);
            }
        }
    }
}

// Render
d_connector();