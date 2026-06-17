$fn=64;

length = 120;
width  = 60;
thickness = 0.08;

corner_r = 2;

wrinkle_amp = 0.35;
wrinkle_freq = 0.18;
wrinkle_phase = 0;

module rounded_sheet_2d(l, w, r){
    r2 = min(r, min(l,w)/2);
    hull(){
        translate([ r2, r2]) circle(r=r2);
        translate([l-r2, r2]) circle(r=r2);
        translate([ r2, w-r2]) circle(r=r2);
        translate([l-r2, w-r2]) circle(r=r2);
    }
}

module foil_tape(){
    // Base foil
    color([0.78,0.80,0.83])
    linear_extrude(height=thickness, convexity=10)
        rounded_sheet_2d(length, width, corner_r);

    // Subtle wrinkle ridges on top surface
    color([0.86,0.88,0.90], 0.85)
    translate([0,0,thickness])
    intersection(){
        linear_extrude(height=0.03, convexity=10)
            rounded_sheet_2d(length, width, corner_r);

        // Create a field of thin raised bands with slight waviness
        union(){
            for (y = [2 : 2.2 : width-2]){
                xoff = wrinkle_amp * sin((y*wrinkle_freq + wrinkle_phase) * 360);
                translate([xoff, y, 0])
                    rotate([0,0, 2*sin(y*0.12*360)])
                        cube([length, 0.35, 0.03], center=false);
            }
        }
    }

    // Slightly darker edge band to suggest cut edge
    color([0.65,0.67,0.70], 0.9)
    difference(){
        linear_extrude(height=thickness*0.6, convexity=10)
            rounded_sheet_2d(length, width, corner_r);
        translate([1.2,1.2,-0.1])
            linear_extrude(height=thickness, convexity=10)
                rounded_sheet_2d(length-2.4, width-2.4, max(0,corner_r-1));
    }
}

foil_tape();