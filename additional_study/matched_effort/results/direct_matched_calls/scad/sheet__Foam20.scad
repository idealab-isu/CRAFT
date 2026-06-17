$fn=64;

// Foam sponge sheet parameters
length = 120;
width  = 80;
thickness = 12;

// Edge rounding
corner_r = 6;

// Foam pore texture
pore_radius_min = 0.6;
pore_radius_max = 2.2;
pore_depth_min  = 0.8;
pore_depth_max  = 3.5;
pore_count = 420;

// Texture placement margins (avoid edges)
margin = 4;

// Deterministic randomness
seed = 12345;

// Performance/robustness
eps = 0.01;

module rounded_sheet(l, w, t, r){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*(l/2 - r), sy*(w/2 - r), 0])
                cylinder(h=t, r=r);
        }
    }
}

module pore(i){
    // Random position within margins
    x = (rands(-length/2 + margin, length/2 - margin, 1, seed + i*17))[0];
    y = (rands(-width/2  + margin, width/2  - margin, 1, seed + i*29))[0];

    // Random pore size/depth
    pr = (rands(pore_radius_min, pore_radius_max, 1, seed + i*31))[0];
    pd = (rands(pore_depth_min,  pore_depth_max,  1, seed + i*37))[0];

    // Random tilt for organic look
    ax = (rands(-18, 18, 1, seed + i*41))[0];
    ay = (rands(-18, 18, 1, seed + i*43))[0];
    az = (rands(0, 360, 1, seed + i*47))[0];

    // Carve from top surface downward
    translate([x, y, thickness - pd + eps])
        rotate([ax, ay, az])
            cylinder(h=pd + 2*eps, r1=pr*1.05, r2=pr*0.75);
}

difference(){
    // Base foam sheet
    translate([0,0,0])
        rounded_sheet(length, width, thickness, corner_r);

    // Pores
    for (i = [0 : pore_count-1])
        pore(i);

    // Slightly roughen bottom too (fewer, shallower pores)
    for (i = [0 : floor(pore_count/5)-1]){
        x = (rands(-length/2 + margin, length/2 - margin, 1, seed + 9000 + i*19))[0];
        y = (rands(-width/2  + margin, width/2  - margin, 1, seed + 9000 + i*23))[0];
        pr = (rands(pore_radius_min*0.7, pore_radius_max*0.9, 1, seed + 9000 + i*27))[0];
        pd = (rands(pore_depth_min*0.4,  pore_depth_max*0.6,  1, seed + 9000 + i*33))[0];
        ax = (rands(-12, 12, 1, seed + 9000 + i*35))[0];
        ay = (rands(-12, 12, 1, seed + 9000 + i*39))[0];
        az = (rands(0, 360, 1, seed + 9000 + i*45))[0];

        translate([x, y, -eps])
            rotate([ax, ay, az])
                cylinder(h=pd + 2*eps, r1=pr*0.75, r2=pr*1.05);
    }
}