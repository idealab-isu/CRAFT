$fn=64;

L = 200;
W = 100;
T = 4;

end_loop_r = 22;
end_loop_wall = 10;

side_rail_w = 14;

pad_len = 34;
pad_wid = 22;
pad_thk = 4;
pad_angle = 18;

hole_d = 4.2;
hole_spacing = 16;
hole_edge_offset = 9;

rib_h = 2.2;
rib_w = 3.2;
rib_len = 26;

module rounded_frame_2d(L, W, r){
    hull(){
        translate([ L/2 - r, 0]) circle(r=r);
        translate([-L/2 + r, 0]) circle(r=r);
    }
}

module end_loop_2d(L, r_outer, wall){
    difference(){
        hull(){
            translate([ L/2 - r_outer, 0]) circle(r=r_outer);
            translate([-L/2 + r_outer, 0]) circle(r=r_outer);
        }
        hull(){
            translate([ L/2 - (r_outer-wall), 0]) circle(r=r_outer-wall);
            translate([-L/2 + (r_outer-wall), 0]) circle(r=r_outer-wall);
        }
    }
}

module frame_plate(){
    difference(){
        linear_extrude(height=T)
            union(){
                difference(){
                    rounded_frame_2d(L, W, W/2);
                    offset(delta=-side_rail_w) rounded_frame_2d(L, W, W/2);
                }
                end_loop_2d(L, end_loop_r, end_loop_wall);
            }

        translate([0,0,-0.2])
            linear_extrude(height=T+0.4)
                offset(delta=-side_rail_w-2)
                    rounded_frame_2d(L, W, W/2);
    }
}

module pad_body(){
    linear_extrude(height=pad_thk)
        hull(){
            translate([ pad_len/2 - pad_wid/2, 0]) circle(r=pad_wid/2);
            translate([-pad_len/2 + pad_wid/2, 0]) circle(r=pad_wid/2);
        }
}

module pad_ribs(){
    for (s=[-1,1]){
        translate([0, s*(pad_wid*0.22), pad_thk])
            linear_extrude(height=rib_h)
                hull(){
                    translate([ rib_len/2 - rib_w/2, 0]) circle(r=rib_w/2);
                    translate([-rib_len/2 + rib_w/2, 0]) circle(r=rib_w/2);
                }
    }
}

module pad_holes(){
    for (i=[-1,1]){
        translate([i*hole_spacing/2, 0, -0.2])
            cylinder(d=hole_d, h=pad_thk+rib_h+0.4);
    }
}

module mounting_pad_at(x, y, ang){
    translate([x,y,0])
        rotate([0,0,ang])
            difference(){
                union(){
                    pad_body();
                    pad_ribs();
                }
                pad_holes();
            }
}

module all_pads(){
    x0 = L/2 - end_loop_r - 18;
    y0 = W/2 - 18;

    mounting_pad_at( x0,  y0,  180-pad_angle);
    mounting_pad_at( x0, -y0,  180+pad_angle);
    mounting_pad_at(-x0,  y0,    0+pad_angle);
    mounting_pad_at(-x0, -y0,    0-pad_angle);
}

difference(){
    union(){
        frame_plate();
        all_pads();
    }

    translate([0,0,-0.2])
        linear_extrude(height=T+rib_h+0.4)
            offset(delta=-side_rail_w-6)
                rounded_frame_2d(L, W, W/2);
}