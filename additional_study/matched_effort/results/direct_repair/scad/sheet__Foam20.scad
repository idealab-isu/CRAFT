$fn=64;

// Foam sponge sheet parameters
length = 120;
width  = 80;
thickness = 12;

// Rounded edges
corner_r = 8;

// Pore field
pore_radius_min = 0.6;
pore_radius_max = 2.2;
pore_depth_min  = 2.0;
pore_depth_max  = 8.0;
pore_spacing    = 6.0;

// Surface waviness
wave_amp = 0.6;
wave_freq_x = 2.0;
wave_freq_y = 1.5;

// Random seed
seed = 12345;

// Helpers
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);
function rand01(i) = rands(0, 1, 1, seed + i)[0];
function rand(a,b,i) = a + (b-a)*rand01(i);

module rounded_sheet(L, W, T, R){
    // Rounded rectangle prism via hull of corner cylinders
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(h=T, r=R);
        }
    }
}

module sponge(){
    difference(){
        // Base sheet
        translate([0,0,0])
            rounded_sheet(length, width, thickness, corner_r);

        // Pores (randomized cylinders from top and bottom)
        // Grid over the sheet area, with jitter and varying radii/depths
        idx = 0;
        for (x = [-length/2 + pore_spacing/2 : pore_spacing : length/2 - pore_spacing/2]){
            for (y = [-width/2 + pore_spacing/2 : pore_spacing : width/2 - pore_spacing/2]){
                // Jitter within cell
                jx = (rand(-0.35, 0.35, idx+1)) * pore_spacing;
                jy = (rand(-0.35, 0.35, idx+2)) * pore_spacing;

                // Keep pores away from rounded corners a bit
                px = x + jx;
                py = y + jy;

                // Vary radius and depth
                pr = rand(pore_radius_min, pore_radius_max, idx+3);
                pd = rand(pore_depth_min, pore_depth_max, idx+4);

                // Waviness influences depth slightly
                w = wave_amp * (sin((px/length)*360*wave_freq_x) + sin((py/width)*360*wave_freq_y));
                pd2 = clamp(pd + w, pore_depth_min, pore_depth_max);

                // Alternate drilling from top/bottom for a more sponge-like look
                from_top = (rand01(idx+5) > 0.5);

                if (from_top){
                    translate([px, py, thickness - pd2])
                        cylinder(h=pd2 + 0.2, r=pr);
                } else {
                    translate([px, py, -0.2])
                        cylinder(h=pd2 + 0.2, r=pr);
                }

                idx = idx + 7;
            }
        }

        // A few larger irregular cavities
        for (k=[0:18]){
            px = rand(-length/2 + corner_r, length/2 - corner_r, 1000 + k*11);
            py = rand(-width/2 + corner_r,  width/2 - corner_r, 1001 + k*11);
            pr = rand(2.5, 5.5, 1002 + k*11);
            pd = rand(4.0, thickness*0.9, 1003 + k*11);
            from_top = (rand01(1004 + k*11) > 0.5);

            if (from_top){
                translate([px, py, thickness - pd])
                    cylinder(h=pd + 0.2, r=pr);
            } else {
                translate([px, py, -0.2])
                    cylinder(h=pd + 0.2, r=pr);
            }
        }
    }
}

sponge();