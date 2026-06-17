$fn=128;

// Centrifugal blower fan (approx) 51.3 x 51.0 x 15.0 mm
// Coordinate system: origin at center of outer housing footprint, Z=0 at bottom.

module rounded_rect_2d(w, d, r){
    r2 = min(r, min(w,d)/2);
    hull(){
        translate([ w/2 - r2,  d/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  d/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -d/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -d/2 + r2]) circle(r=r2);
    }
}

module blower_fan(){
    // Overall envelope
    W = 51.3;
    D = 51.0;
    H = 15.0;

    // Housing
    corner_r = 4.0;
    wall = 1.6;
    top_th = 1.6;
    bottom_th = 1.6;

    // Internal cavity height
    cavity_h = H - top_th - bottom_th;

    // Impeller region (inside)
    imp_r = 18.0;
    hub_r = 6.0;
    hub_h = cavity_h * 0.75;
    blade_count = 11;
    blade_th = 1.2;
    blade_h = cavity_h * 0.78;
    blade_r0 = hub_r + 1.0;
    blade_r1 = imp_r - 0.8;
    blade_twist = 28; // degrees

    // Outlet
    outlet_w = 18.0;
    outlet_h = 9.0;
    outlet_len = 10.0;
    outlet_z0 = bottom_th + (cavity_h - outlet_h)/2;

    // Inlet (top)
    inlet_r = 12.0;

    // Mount holes (approx)
    hole_r = 1.7; // ~3.4mm dia
    hole_inset_x = 5.0;
    hole_inset_y = 5.0;

    module housing_solid(){
        // Outer shell
        linear_extrude(height=H)
            rounded_rect_2d(W, D, corner_r);

        // Outlet duct (rectangular) protruding on +X side
        translate([W/2, 0, outlet_z0])
            cube([outlet_len, outlet_w, outlet_h], center=false);
    }

    module housing_void(){
        // Main internal cavity (rounded rectangle inset)
        translate([0,0,bottom_th])
            linear_extrude(height=cavity_h)
                rounded_rect_2d(W-2*wall, D-2*wall, max(0.1, corner_r-wall));

        // Inlet opening through top
        translate([0,0,H-top_th-0.01])
            cylinder(h=top_th+0.02, r=inlet_r);

        // Outlet opening from cavity to duct
        // Cut a window in the side wall into the duct
        translate([W/2 - wall - 0.2, -outlet_w/2, outlet_z0])
            cube([wall+0.6, outlet_w, outlet_h], center=false);

        // Hollow out the outlet duct interior
        translate([W/2 + 0.6, -outlet_w/2 + wall, outlet_z0 + wall])
            cube([outlet_len - 1.2, outlet_w - 2*wall, outlet_h - 2*wall], center=false);

        // Mount holes through body
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(W/2 - hole_inset_x), sy*(D/2 - hole_inset_y), -0.1])
                cylinder(h=H+0.2, r=hole_r);
        }
    }

    module impeller(){
        z0 = bottom_th + (cavity_h - blade_h)/2;

        // Hub
        translate([0,0,z0])
            cylinder(h=hub_h, r=hub_r);

        // Backplate (thin disk)
        translate([0,0,z0])
            cylinder(h=1.2, r=imp_r-0.5);

        // Blades (radial, slightly twisted)
        for(i=[0:blade_count-1]){
            ang = i*360/blade_count;
            rotate([0,0,ang])
                translate([0,0,z0])
                    linear_extrude(height=blade_h, twist=blade_twist, slices=40)
                        translate([blade_r0, -blade_th/2])
                            square([blade_r1-blade_r0, blade_th], center=false);
        }

        // Small center bore (optional visual)
        difference(){
            translate([0,0,z0-0.01])
                cylinder(h=hub_h+0.02, r=hub_r);
            translate([0,0,z0-0.02])
                cylinder(h=hub_h+0.04, r=1.6);
        }
    }

    // Assemble
    difference(){
        housing_solid();
        housing_void();
    }

    // Place impeller inside (as a separate solid)
    color([0.15,0.15,0.15])
        impeller();
}

blower_fan();