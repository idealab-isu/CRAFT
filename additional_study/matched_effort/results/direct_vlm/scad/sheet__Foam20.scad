$fn=64;

// Foam sponge sheet parameters
length = 120;
width  = 80;
thickness = 12;

corner_r = 6;

// Pore / texture parameters
pore_count = 260;
pore_r_min = 0.6;
pore_r_max = 2.2;
pore_depth_min = 1.0;
pore_depth_max = 5.0;

surface_wobble_amp = 0.6;
surface_wobble_scale = 0.12;

seed = 12345;

module rounded_sheet(L, W, T, R){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx = [-1, 1], sy = [-1, 1]){
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(h=T, r=R);
        }
    }
}

function hash1(i, s) = let(v = sin((i*127.1 + s*311.7))*43758.5453123) v - floor(v);
function rand_range(i, s, a, b) = a + (b-a)*hash1(i, s);

module pore(i){
    x = rand_range(i, seed+1, -length/2 + corner_r, length/2 - corner_r);
    y = rand_range(i, seed+2, -width/2  + corner_r, width/2  - corner_r);
    r = rand_range(i, seed+3, pore_r_min, pore_r_max);
    d = rand_range(i, seed+4, pore_depth_min, pore_depth_max);

    // Slightly bias pores toward surfaces by choosing top/bottom randomly
    side = (hash1(i, seed+5) < 0.5) ? 0 : 1;

    // Carve from top or bottom
    if (side == 0){
        translate([x, y, thickness - d])
            cylinder(h=d + 0.2, r1=r*1.05, r2=r*0.85);
    } else {
        translate([x, y, -0.2])
            cylinder(h=d + 0.2, r1=r*0.85, r2=r*1.05);
    }
}

module surface_wobble(){
    // Subtle organic waviness using a low-res heightfield
    nx = 26;
    ny = 18;
    translate([-length/2, -width/2, thickness])
        linear_extrude(height=surface_wobble_amp, scale=1)
            surface(file="", center=false, convexity=5);
}

module sponge_sheet(){
    difference(){
        // Base sheet
        translate([0,0,0])
            rounded_sheet(length, width, thickness, corner_r);

        // Pores
        for (i = [0 : pore_count-1]) pore(i);

        // Edge nicks (small random bites along perimeter)
        for (i = [0:34]){
            t = hash1(i, seed+20);
            // pick an edge: 0 left,1 right,2 bottom,3 top
            e = floor(rand_range(i, seed+21, 0, 4));
            rr = rand_range(i, seed+22, 1.2, 3.8);
            dd = rand_range(i, seed+23, 1.0, 4.0);
            px = (e==0) ? (-length/2) :
                 (e==1) ? ( length/2) :
                 rand_range(i, seed+24, -length/2, length/2);
            py = (e==2) ? (-width/2) :
                 (e==3) ? ( width/2) :
                 rand_range(i, seed+25, -width/2, width/2);

            // Move slightly inward so it bites the edge
            ix = (e==0) ? rr*0.6 : (e==1) ? -rr*0.6 : 0;
            iy = (e==2) ? rr*0.6 : (e==3) ? -rr*0.6 : 0;

            translate([px+ix, py+iy, rand_range(i, seed+26, 0, thickness-dd)])
                sphere(r=rr);
        }

        // Slightly soften corners by subtracting tiny spheres near corners
        for (sx=[-1,1], sy=[-1,1], i=[0:2]){
            rr = rand_range(i + (sx+1)*10 + (sy+1)*20, seed+30, 1.0, 2.8);
            translate([sx*(length/2 - corner_r*0.6), sy*(width/2 - corner_r*0.6), rand_range(i, seed+31, 0, thickness)])
                sphere(r=rr);
        }
    }
}

// Color like a foam sponge
color([1.0, 0.95, 0.55])
    sponge_sheet();