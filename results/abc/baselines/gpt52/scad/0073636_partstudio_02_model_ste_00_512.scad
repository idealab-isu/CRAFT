$fn=64;

sx=0.4;
sy=0.8;
sz=0.5;

t=0.12;          // member thickness (x)
w=0.18;          // member width (z)
h=sz;            // overall height (z)

Lh=sy;           // horizontal arm length along +Y
Lv=0.55;         // vertical arm length along +Z

thick_len=0.22;  // local thickening length at far end of horizontal arm
thick_add=0.08;  // added thickness in X for thickened region

gus_y=0.22;      // gusset extent along Y
gus_z=0.22;      // gusset extent along Z
gus_x=t+0.02;    // gusset thickness in X

module arm_y(len, xth=t, zth=w){
    translate([-xth/2, 0, 0])
        cube([xth, len, zth], center=false);
}

module arm_z(len, xth=t, zth=w){
    translate([-xth/2, 0, 0])
        cube([xth, zth, len], center=false);
}

module gusset(){
    translate([-gus_x/2, 0, 0])
    linear_extrude(height=gus_x, center=false, convexity=10)
        polygon(points=[[0,0],[gus_y,0],[0,gus_z]]);
}

module bracket(){
    union(){
        arm_y(Lh, t, w);
        arm_z(Lv, t, w);

        translate([0, Lh-thick_len, 0])
            arm_y(thick_len, t+thick_add, w);

        gusset();
    }
}

translate([0, -sy/2, -sz/2])
    bracket();