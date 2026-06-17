$fn=160;

// Flexible shaft coupling: 6mm to 8mm bore, 19mm OD, 25mm long
// Typical helical-beam style with clamp slits and set-screw holes.

od = 19.0;
len = 25.0;

bore1_d = 6.0;   // one end
bore2_d = 8.0;   // other end

center_split = len/2;

wall_min = 2.0;  // ensure enough wall around bores
hub_chamfer = 0.6;

slit_w = 1.2;
slit_depth = od*0.62;     // radial depth of helical cuts
slit_turns = 1.35;        // number of turns along length
slit_count = 3;           // number of helical slots around circumference

clamp_slit_w = 1.2;
clamp_slit_depth = od*0.55;
clamp_slit_len = 7.0;     // axial length of clamp slit region at each end

setscrew_d = 3.0;         // M3 clearance-ish
setscrew_head_d = 6.0;    // counterbore for socket head
setscrew_head_depth = 2.2;
setscrew_offset_from_end = 5.0;

module chamfered_cylinder(d, h, c=0.6){
    // simple chamfer by subtracting cones at ends
    difference(){
        cylinder(d=d, h=h);
        if(c > 0){
            translate([0,0,-0.01]) cylinder(d1=d+2*c, d2=d, h=c+0.02);
            translate([0,0,h-c-0.01]) cylinder(d1=d, d2=d+2*c, h=c+0.02);
        }
    }
}

module bore_transition(){
    // Two bores meeting at center with a small relief cone
    union(){
        translate([0,0,0]) cylinder(d=bore1_d, h=center_split+0.2);
        translate([0,0,center_split-0.2]) cylinder(d=bore2_d, h=len-center_split+0.2);
        // small conical relief at the interface
        translate([0,0,center_split-0.6]) cylinder(d1=bore1_d, d2=bore2_d, h=1.2);
    }
}

module helical_slot(angle0=0){
    // Create a helical slot by hulling thin rectangular cutters along a helix
    steps = 70;
    dz = len/steps;
    twist_total = 360*slit_turns;
    for(i=[0:steps-1]){
        z1 = i*dz;
        z2 = (i+1)*dz;
        a1 = angle0 + (twist_total)*(z1/len);
        a2 = angle0 + (twist_total)*(z2/len);

        hull(){
            translate([0,0,z1])
                rotate([0,0,a1])
                    translate([od/2 - slit_depth/2, 0, 0])
                        cube([slit_depth, slit_w, dz*0.6], center=true);

            translate([0,0,z2])
                rotate([0,0,a2])
                    translate([od/2 - slit_depth/2, 0, 0])
                        cube([slit_depth, slit_w, dz*0.6], center=true);
        }
    }
}

module clamp_slits(){
    // Straight radial slits at each end for clamping
    for(end=[0,1]){
        z0 = (end==0) ? 0 : (len-clamp_slit_len);
        translate([0,0,z0])
        for(a=[0,180]){
            rotate([0,0,a])
                translate([od/2 - clamp_slit_depth/2, 0, clamp_slit_len/2])
                    cube([clamp_slit_depth, clamp_slit_w, clamp_slit_len+0.2], center=true);
        }
    }
}

module setscrew_holes(){
    // Two set-screw holes, one per side, oriented radially
    // Place one near each end, rotated 90 degrees apart
    for(end=[0,1]){
        zc = (end==0) ? setscrew_offset_from_end : (len-setscrew_offset_from_end);
        rot = (end==0) ? 0 : 90;

        rotate([0,0,rot]){
            // through hole
            translate([0, od/2 - wall_min, zc])
                rotate([0,90,0])
                    cylinder(d=setscrew_d, h=od, center=true);

            // counterbore from outside
            translate([0, od/2 + 0.01, zc])
                rotate([0,90,0])
                    cylinder(d=setscrew_head_d, h=setscrew_head_depth+0.5, center=false);
        }
    }
}

module coupling(){
    difference(){
        chamfered_cylinder(od, len, hub_chamfer);

        // bores
        bore_transition();

        // helical slots
        for(k=[0:slit_count-1]){
            helical_slot(360*k/slit_count);
        }

        // clamp slits
        clamp_slits();

        // set-screw holes
        setscrew_holes();
    }
}

coupling();