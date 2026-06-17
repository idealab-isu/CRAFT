$fn=64;

L=38.0;
W=32.0;
H=33.0;

module rounded_box(size=[10,10,10], r=1.5){
    x=size[0]; y=size[1]; z=size[2];
    r2=min(r, min(x,y)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r2), sy*(y/2-r2), 0])
                cylinder(h=z, r=r2, center=true);
    }
}

module lead(d=1.2, len=10, bend=0){
    union(){
        cylinder(h=len, d=d, center=false);
        if (bend > 0)
            translate([0,0,len])
                rotate([0,90,0])
                    cylinder(h=bend, d=d, center=false);
    }
}

module transformer_body(){
    // Main body
    color([0.15,0.15,0.15])
    rounded_box([L,W,H], r=2.0);

    // Top label plate
    color([0.85,0.85,0.85])
    translate([0,0,H/2-0.6])
        rounded_box([L-6, W-6, 1.2], r=1.2);

    // Side mounting ears (small protrusions)
    ear_t=3.0;
    ear_w=10.0;
    ear_h=6.0;
    for (sx=[-1,1]){
        color([0.15,0.15,0.15])
        translate([sx*(L/2 + ear_t/2 - 0.2), 0, -H/2 + ear_h/2 + 3])
            rounded_box([ear_t, ear_w, ear_h], r=1.0);
    }

    // Leads (two on each side)
    lead_d=1.2;
    lead_len=9.0;
    lead_y=8.0;
    lead_z=-H/2;
    for (sx=[-1,1]){
        for (sy=[-1,1]){
            color([0.8,0.7,0.2])
            translate([sx*(L/2-6), sy*lead_y, lead_z])
                lead(d=lead_d, len=lead_len, bend=0);
        }
    }
}

transformer_body();