$fn=64;

module smd_body(size=[3.0, 1.8, 0.9], corner_r=0.18) {
    x=size[0]; y=size[1]; z=size[2];
    r=min(corner_r, x/2, y/2);
    translate([0,0,0])
    linear_extrude(height=z, center=true)
        offset(r=r)
            square([x-2*r, y-2*r], center=true);
}

module smd_lead(size=[3.0, 1.8, 0.9], lead_len=0.35, lead_th=0.08, lead_inset=0.12) {
    x=size[0]; y=size[1]; z=size[2];
    lx=lead_len;
    ly=y-2*lead_inset;
    lz=z*0.55;
    translate([0,0,0])
    union() {
        translate([ x/2 - lx/2, 0, -z/2 + lz/2 + lead_th])
            cube([lx, ly, lz], center=true);
        translate([-x/2 + lx/2, 0, -z/2 + lz/2 + lead_th])
            cube([lx, ly, lz], center=true);
    }
}

module smd(size=[3.0, 1.8, 0.9]) {
    union() {
        color([0.15,0.15,0.15]) smd_body(size=size, corner_r=0.18);
        color([0.75,0.75,0.78]) smd_lead(size=size, lead_len=0.35, lead_th=0.06, lead_inset=0.12);
    }
}

smd([3.0, 1.8, 0.9]);