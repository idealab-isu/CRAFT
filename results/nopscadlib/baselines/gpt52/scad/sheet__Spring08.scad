$fn=96;

blade_len = 300;
blade_w   = 20;
blade_t   = 0.9;

bimetal_edge_w = 3.0;

tooth_pitch = 2.5;
tooth_h     = 1.6;
tooth_set   = 0.35;

end_hole_d = 6.0;
end_hole_offset = 12.0;

module rounded_plate(L, W, T, r){
    linear_extrude(height=T, center=true)
        offset(r=r)
            square([L-2*r, W-2*r], center=true);
}

module tooth2d(pitch, h){
    polygon(points=[
        [-pitch/2, 0],
        [ pitch/2, 0],
        [ 0, h]
    ]);
}

module tooth_row(L, pitch, h, T, set=0){
    n = floor(L/pitch);
    for(i=[0:n-1]){
        x = -L/2 + (i+0.5)*pitch;
        translate([x, 0, 0])
            translate([0, set, 0])
                linear_extrude(height=T, center=true)
                    tooth2d(pitch, h);
    }
}

module blade_body(){
    r = blade_w/2;
    rounded_plate(blade_len, blade_w, blade_t, r);
}

module bimetal_edge(){
    translate([0, -blade_w/2 + bimetal_edge_w/2, 0])
        cube([blade_len, bimetal_edge_w, blade_t], center=true);
}

module end_holes(){
    for(s=[-1,1]){
        translate([s*(blade_len/2 - end_hole_offset), 0, 0])
            cylinder(d=end_hole_d, h=blade_t*3, center=true, $fn=96);
    }
}

module teeth(){
    y_base = -blade_w/2;
    for(i=[0:1]){
        set = (i==0) ? tooth_set : -tooth_set;
        translate([0, y_base, 0])
            tooth_row(blade_len, tooth_pitch, tooth_h, blade_t, set);
    }
}

difference(){
    union(){
        blade_body();
        bimetal_edge();
        teeth();
    }
    end_holes();
}