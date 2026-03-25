$fn=96;

size_xy = 40.0;
size_z  = 20.0;

wall = 1.6;
base_th = 2.0;
top_th  = 2.0;

inlet_d = 18.0;
inlet_r = inlet_d/2;

outlet_w = 14.0;
outlet_h = 10.0;

scroll_clear = 1.2;

imp_d = 28.0;
imp_r = imp_d/2;
imp_h = 14.0;

hub_d = 10.0;
hub_r = hub_d/2;
hub_h = imp_h;

shaft_d = 3.0;
shaft_r = shaft_d/2;

blade_count = 11;
blade_th = 1.0;
blade_h  = imp_h - 2.0;
blade_r0 = hub_r + 1.0;
blade_r1 = imp_r - 1.0;
blade_twist = 28;

module rounded_box_xy(x,y,z,r){
    hull(){
        for (sx=[-1,1], sy=[-1,1])
            translate([sx*(x/2-r), sy*(y/2-r), 0])
                cylinder(r=r, h=z, center=true);
    }
}

module housing_shell(){
    difference(){
        rounded_box_xy(size_xy, size_xy, size_z, 3.0);
        translate([0,0,0])
            rounded_box_xy(size_xy-2*wall, size_xy-2*wall, size_z-2*wall, 2.2);
    }
}

module outlet_cut(){
    translate([size_xy/2 - wall/2, 0, 0])
        cube([wall+2.0, outlet_w, outlet_h], center=true);
}

module inlet_cut(){
    translate([0,0, size_z/2 - top_th/2])
        cylinder(r=inlet_r, h=top_th+2.0, center=true);
}

module scroll_cavity(){
    // Create a volute-like cavity by subtracting an offset ring sector and a central clearance
    difference(){
        union(){
            // main cavity volume
            translate([0,0,0])
                cylinder(r=imp_r + scroll_clear + 4.0, h=imp_h+2.0, center=true);
            // bias cavity toward outlet side
            translate([4.0,0,0])
                cylinder(r=imp_r + scroll_clear + 6.0, h=imp_h+2.0, center=true);
        }
        // keep some material near corners by limiting to inner box
        translate([0,0,0])
            rounded_box_xy(size_xy-2*wall, size_xy-2*wall, size_z-2*wall, 2.2);
    }
}

module internal_cavity(){
    // cavity positioned slightly below top to leave top thickness
    translate([0,0, - (top_th-base_th)/2 ])
        intersection(){
            scroll_cavity();
            translate([0,0,0])
                cube([size_xy-2*wall, size_xy-2*wall, size_z-2*wall], center=true);
        }
}

module impeller_blade(){
    // A curved blade made by twisting a thin rectangular prism
    translate([0, (blade_r0+blade_r1)/2, 0])
        linear_extrude(height=blade_h, center=true, twist=blade_twist, slices=24)
            translate([0,0,0])
                square([blade_th, blade_r1-blade_r0], center=true);
}

module impeller(){
    union(){
        // hub
        cylinder(r=hub_r, h=hub_h, center=true);
        // backplate
        translate([0,0,-imp_h/2 + 1.0])
            cylinder(r=imp_r, h=2.0, center=true);
        // blades
        for(i=[0:blade_count-1]){
            rotate([0,0, i*360/blade_count])
                translate([0,0,0])
                    impeller_blade();
        }
        // shaft hole (as negative in assembly)
    }
}

module blower(){
    difference(){
        union(){
            // outer housing
            housing_shell();
            // reinforce around outlet
            translate([size_xy/2 - wall, 0, 0])
                cube([wall*2.2, outlet_w+6.0, outlet_h+6.0], center=true);
            // top and bottom plates (ensure thickness)
            translate([0,0, size_z/2 - top_th/2])
                rounded_box_xy(size_xy, size_xy, top_th, 3.0);
            translate([0,0,-size_z/2 + base_th/2])
                rounded_box_xy(size_xy, size_xy, base_th, 3.0);
        }
        // internal cavity
        internal_cavity();
        // inlet
        inlet_cut();
        // outlet
        outlet_cut();
    }

    // impeller inside
    translate([0,0, - (top_th-base_th)/2 ])
        difference(){
            impeller();
            cylinder(r=shaft_r, h=imp_h+4.0, center=true);
        }
}

blower();