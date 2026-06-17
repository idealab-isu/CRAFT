$fn=64;

module smd_body(size=[11.40,7.50,2.00], corner_r=0.6){
    x=size[0]; y=size[1]; z=size[2];
    r=min(corner_r, min(x,y)/2);
    hull(){
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(x/2 - r), sy*(y/2 - r), 0])
                cylinder(h=z, r=r, center=true);
        }
    }
}

module smd_lead(len=1.2, width=2.2, thick=0.25, body=[11.40,7.50,2.00]){
    translate([0,0,-(body[2]/2 - thick/2)])
        cube([len, width, thick], center=true);
}

module smd_package(size=[11.40,7.50,2.00]){
    union(){
        smd_body(size=size, corner_r=0.6);
        translate([ size[0]/2 + 0.6, 0, 0]) smd_lead(len=1.2, width=2.2, thick=0.25, body=size);
        translate([-size[0]/2 - 0.6, 0, 0]) smd_lead(len=1.2, width=2.2, thick=0.25, body=size);
    }
}

smd_package([11.40,7.50,2.00]);