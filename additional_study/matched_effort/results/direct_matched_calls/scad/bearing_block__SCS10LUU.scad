$fn = 96;

// Parameters
shaft_d = 8.0;
block_w = 40.0;   // X
block_l = 68.0;   // Y
block_h = 24.0;   // Z

// Bearing/bore
bore_d = shaft_d + 0.4;     // clearance
bore_z = block_h * 0.55;    // bore center height

// Split clamp
split_w = 1.6;              // slit width
split_x = 0;                // centered

// Mounting holes (4x)
hole_d = 5.2;               // M5 clearance
counterbore_d = 9.5;
counterbore_depth = 4.0;

edge_x = 7.0;               // distance from side edges
edge_y = 10.0;              // distance from end edges

// Relief pockets (optional weight reduction)
pocket_depth = 6.0;
pocket_margin = 6.0;
pocket_corner_r = 3.0;

// Helpers
module rounded_rect_2d(w, l, r){
    r2 = min(r, min(w,l)/2);
    hull(){
        translate([ w/2 - r2,  l/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  l/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -l/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -l/2 + r2]) circle(r=r2);
    }
}

module block_body(){
    // Slightly rounded outer edges
    outer_r = 2.0;
    linear_extrude(height=block_h)
        rounded_rect_2d(block_w, block_l, outer_r);
}

module mounting_holes(){
    xs = [-(block_w/2 - edge_x), (block_w/2 - edge_x)];
    ys = [-(block_l/2 - edge_y), (block_l/2 - edge_y)];
    for(x=xs, y=ys){
        // Through hole
        translate([x,y,0])
            cylinder(d=hole_d, h=block_h+0.2);
        // Counterbore from top
        translate([x,y,block_h-counterbore_depth])
            cylinder(d=counterbore_d, h=counterbore_depth+0.3);
    }
}

module relief_pockets(){
    // Two shallow pockets on the sides (top face), leaving material around holes
    pw = block_w - 2*pocket_margin;
    pl = (block_l/2) - (edge_y + 8.0);
    if(pw > 0 && pl > 0){
        for(s=[-1,1]){
            translate([0, s*(block_l/4), block_h - pocket_depth])
                linear_extrude(height=pocket_depth+0.2)
                    rounded_rect_2d(pw, pl, pocket_corner_r);
        }
    }
}

difference(){
    block_body();

    // Shaft bore along Y
    translate([0,0,bore_z])
        rotate([90,0,0])
            cylinder(d=bore_d, h=block_l+0.6, center=true);

    // Split slit from top down to bore
    translate([split_x, 0, bore_z])
        cube([split_w, block_l+1.0, block_h], center=true);

    // Mounting holes
    mounting_holes();

    // Optional relief pockets
    relief_pockets();
}