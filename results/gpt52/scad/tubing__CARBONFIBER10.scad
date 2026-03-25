$fn=96;

tube_od = 30;
tube_id = 26;
tube_len = 200;

module carbon_fiber_tube(od, id, len){
    difference(){
        cylinder(h=len, d=od, center=true);
        cylinder(h=len+0.2, d=id, center=true);
    }
}

module weave_band(od, len, zpos, band_h, twist_deg){
    translate([0,0,zpos])
    intersection(){
        cylinder(h=band_h, d=od+0.6, center=true);
        rotate([0,0,twist_deg])
        union(){
            for(a=[0:15:165]){
                rotate([0,0,a])
                    translate([0,0,0])
                        cube([od*1.2, 0.9, band_h*1.2], center=true);
            }
            for(a=[7.5:15:172.5]){
                rotate([0,0,a])
                    cube([od*1.2, 0.9, band_h*1.2], center=true);
            }
        }
    }
}

module carbon_fiber_surface(od, len){
    union(){
        for(i=[0:1:19]){
            z = -len/2 + (i+0.5)*(len/20);
            weave_band(od=od, len=len, zpos=z, band_h=len/20, twist_deg=i*9);
        }
    }
}

module tubing_carbon_fiber(){
    union(){
        color([0.08,0.08,0.09])
            carbon_fiber_tube(tube_od, tube_id, tube_len);
        color([0.18,0.18,0.20])
            carbon_fiber_surface(tube_od, tube_len);
    }
}

tubing_carbon_fiber();