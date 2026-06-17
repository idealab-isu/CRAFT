$fn=96;

plate_x = 81.2;
plate_y = 68.5;
plate_t = 10.0;

corner_r = 6;

ring_outer_d = 28;
ring_inner_d = 18;
ring_center = [plate_x/2 - 16, 0, 0];

tab_w = 14;
tab_h = 10;
tab_t = plate_t;

fast_hole_d = 3.4;

module rounded_rect_2d(w,h,r){
    r2 = min(r, min(w,h)/2);
    hull(){
        translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    }
}

module plate_base(){
    linear_extrude(height=plate_t, center=true)
        rounded_rect_2d(plate_x, plate_y, corner_r);
}

module ring_feature(){
    difference(){
        translate([ring_center[0], ring_center[1], 0])
            cylinder(h=plate_t, d=ring_outer_d, center=true);
        translate([ring_center[0], ring_center[1], 0])
            cylinder(h=plate_t+0.4, d=ring_inner_d, center=true);
    }
}

module tab_at(pos=[0,0,0], rot=0){
    translate([pos[0], pos[1], 0])
    rotate([0,0,rot])
    difference(){
        translate([0,0,0])
            cube([tab_w, tab_h, tab_t], center=true);
        translate([0,0,0])
            cylinder(h=tab_t+0.6, d=fast_hole_d, center=true);
    }
}

module window_cutouts(){
    // Large central rectangular cutout
    translate([-6, 0, 0])
        cube([44, 34, plate_t+0.6], center=true);

    // Row of smaller rectangular windows
    win_w = 8;
    win_h = 18;
    gap = 3.2;
    n = 5;
    start_x = -plate_x/2 + 14;
    y = -plate_y/2 + 16;
    for(i=[0:n-1]){
        x = start_x + i*(win_w+gap);
        translate([x, y, 0])
            cube([win_w, win_h, plate_t+0.6], center=true);
    }
}

module fastener_holes_on_plate(){
    // Additional small holes near corners/edges (not on tabs)
    pts = [
        [-plate_x/2 + 10,  plate_y/2 - 10],
        [ plate_x/2 - 10,  plate_y/2 - 10],
        [-plate_x/2 + 10, -plate_y/2 + 10],
        [ plate_x/2 - 10, -plate_y/2 + 10]
    ];
    for(p=pts)
        translate([p[0], p[1], 0])
            cylinder(h=plate_t+0.6, d=fast_hole_d, center=true);
}

module tabs(){
    // Tabs around perimeter
    tab_at([0,  plate_y/2 + tab_h/2 - 1.0, 0], 0);
    tab_at([0, -plate_y/2 - tab_h/2 + 1.0, 0], 0);

    tab_at([-plate_x/2 - tab_h/2 + 1.0,  0, 0], 90);
    tab_at([ plate_x/2 + tab_h/2 - 1.0,  0, 0], 90);

    // Extra tabs near ring end
    tab_at([plate_x/2 + tab_h/2 - 1.0,  plate_y/2 - 18, 0], 90);
    tab_at([plate_x/2 + tab_h/2 - 1.0, -plate_y/2 + 18, 0], 90);
}

difference(){
    union(){
        plate_base();
        ring_feature();
        tabs();
    }
    window_cutouts();
    fastener_holes_on_plate();
}