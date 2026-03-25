$fn=64;

L = 0.2;
W = 0.1;
H = 0.1;

module obround_x(len, dia, h){
    hull(){
        translate([-len/2 + dia/2, 0, 0]) cylinder(d=dia, h=h, center=true);
        translate([ len/2 - dia/2, 0, 0]) cylinder(d=dia, h=h, center=true);
    }
}

module elbow_body(){
    union(){
        // Large end block (along +X)
        translate([0.055, 0, 0])
            cube([0.09, 0.085, 0.085], center=true);

        // Small tongue (along +Y)
        translate([0, 0.055, 0])
            cube([0.06, 0.06, 0.06], center=true);

        // Curved transition (quarter torus-like)
        rotate_extrude(angle=90, convexity=10)
            translate([0.055, 0, 0])
                circle(r=0.03);

        // Obround end-cap near smaller end
        translate([0, 0.085, 0])
            obround_x(0.07, 0.05, 0.06);

        // Two small lugs/steps on top near tip
        translate([-0.018, 0.072, 0.035])
            cube([0.02, 0.02, 0.02], center=true);
        translate([ 0.018, 0.072, 0.035])
            cube([0.02, 0.02, 0.02], center=true);
    }
}

module clip_to_bbox(){
    intersection(){
        elbow_body();
        cube([L, W, H], center=true);
    }
}

clip_to_bbox();