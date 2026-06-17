$fn=96;

// Centrifugal blower fan (approx) 30 x 30 x 10.1 mm
// Model includes: outer housing, internal scroll cavity, inlet ring, outlet port, and impeller with blades.

size_x = 30.0;
size_y = 30.0;
size_z = 10.1;

wall = 1.2;
base_th = 1.2;
top_th  = 1.0;

inlet_d = 14.0;
inlet_ring_od = 18.0;
inlet_ring_h = 2.2;

outlet_w = 10.0;
outlet_h = 6.0;
outlet_len = 9.0;

impeller_d = 18.0;
impeller_h = 7.2;
hub_d = 6.0;
hub_h = 7.2;
shaft_d = 2.2;

blade_count = 11;
blade_th = 0.9;
blade_radial = (impeller_d/2 - hub_d/2) * 0.95;
blade_height = impeller_h * 0.92;
blade_twist = 22; // degrees

module rounded_box(x,y,z,r){
    // Minkowski rounded edges
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module housing(){
    r = 2.0;
    difference(){
        // Outer body
        translate([0,0,size_z/2])
            rounded_box(size_x, size_y, size_z, r);

        // Internal cavity (scroll-like: offset cylinder + rectangular outlet channel)
        translate([0,0,base_th + (size_z-base_th-top_th)/2])
        union(){
            // Main cavity
            translate([-2.0, -1.0, 0])
                cylinder(d=24.0, h=size_z-base_th-top_th+0.2, center=true);

            // Scroll widening (second offset cylinder)
            translate([3.5, 2.5, 0])
                cylinder(d=22.0, h=size_z-base_th-top_th+0.2, center=true);

            // Outlet channel cavity
            translate([size_x/2 - wall - outlet_len/2 + 0.2, 0, 0])
                cube([outlet_len+0.6, outlet_w, outlet_h], center=true);
        }

        // Inlet hole through top
        translate([0,0,size_z - top_th/2])
            cylinder(d=inlet_d, h=top_th+0.6, center=true);

        // Motor/impeller clearance down to base
        translate([0,0,base_th + (size_z-base_th)/2])
            cylinder(d=impeller_d+2.0, h=size_z-base_th+0.4, center=true);

        // Outlet opening to outside
        translate([size_x/2 + 0.01, 0, base_th + outlet_h/2 + 0.2])
            rotate([0,90,0])
                cube([outlet_h+0.4, outlet_w+0.4, wall+2.0], center=true);
    }

    // Inlet ring on top
    translate([0,0,size_z - top_th + inlet_ring_h/2])
    difference(){
        cylinder(d=inlet_ring_od, h=inlet_ring_h, center=true);
        cylinder(d=inlet_d, h=inlet_ring_h+0.6, center=true);
    }

    // Outlet port (external duct)
    translate([size_x/2 + outlet_len/2 - wall, 0, base_th + outlet_h/2])
    difference(){
        cube([outlet_len, outlet_w+2*wall, outlet_h+2*wall], center=true);
        cube([outlet_len+0.6, outlet_w, outlet_h], center=true);
    }
}

module impeller(){
    // Positioned inside housing, centered under inlet
    z0 = base_th + (impeller_h/2) + 0.2;

    translate([0,0,z0])
    union(){
        // Backplate
        cylinder(d=impeller_d, h=1.0, center=true);

        // Hub
        translate([0,0,(hub_h-1.0)/2])
            cylinder(d=hub_d, h=hub_h, center=true);

        // Shaft hole (visual)
        difference(){
            // Shroud ring (partial top cover)
            translate([0,0,impeller_h/2 - 0.8])
                cylinder(d=impeller_d*0.98, h=1.2, center=true);
            translate([0,0,impeller_h/2 - 0.8])
                cylinder(d=impeller_d*0.70, h=1.6, center=true);
        }

        // Blades
        for(i=[0:blade_count-1]){
            ang = i*360/blade_count;
            rotate([0,0,ang])
            translate([hub_d/2 + blade_radial/2, 0, (blade_height/2 - 0.2)])
            rotate([0,0,12]) // slight forward curve
            linear_extrude(height=blade_height, center=true, twist=blade_twist, slices=24)
                translate([-blade_radial/2, -blade_th/2])
                    square([blade_radial, blade_th]);
        }

        // Central shaft bore (cut)
        difference(){
            // nothing; use a subtractive cylinder by adding negative via render trick:
            // We'll instead model as a visible bore by subtracting from hub using difference wrapper.
        }
    }
}

module impeller_with_bore(){
    z0 = base_th + (impeller_h/2) + 0.2;
    difference(){
        impeller();
        translate([0,0,z0])
            cylinder(d=shaft_d, h=impeller_h+4, center=true);
    }
}

union(){
    color([0.15,0.15,0.15]) housing();
    color([0.25,0.25,0.25]) impeller_with_bore();
}