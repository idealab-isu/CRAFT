$fn=96;

// Centrifugal blower fan (approx) 51.3mm x 51.0mm x 15.0mm
// Renderable, single-piece model with housing, inlet, outlet, and internal impeller.

W = 51.3;
D = 51.0;
H = 15.0;

wall = 1.6;
base = 1.6;
top  = 1.6;

inlet_d = 26.0;
inlet_lip = 0.8;

outlet_w = 18.0;
outlet_h = 9.0;
outlet_len = 12.0;

corner_r = 6.0;

imp_clear = 0.8;          // clearance between impeller and housing
imp_th = H - base - top - 0.8;
imp_r = (min(W,D)/2) - wall - imp_clear - 1.0;
hub_r = 5.0;
hub_h = imp_th;

blade_count = 11;
blade_th = 1.2;
blade_h = imp_th;
blade_r0 = hub_r + 1.2;
blade_r1 = imp_r - 0.8;
blade_sweep = 28;         // degrees of backward sweep

module rounded_rect_2d(w,d,r){
    r2 = min(r, min(w,d)/2);
    hull(){
        translate([ w/2 - r2,  d/2 - r2]) circle(r=r2);
        translate([-w/2 + r2,  d/2 - r2]) circle(r=r2);
        translate([ w/2 - r2, -d/2 + r2]) circle(r=r2);
        translate([-w/2 + r2, -d/2 + r2]) circle(r=r2);
    }
}

module housing_outer(){
    linear_extrude(height=H)
        rounded_rect_2d(W, D, corner_r);
}

module housing_inner(){
    // Inner cavity (offset inward), leaving base and top thickness
    translate([0,0,base])
        linear_extrude(height=H-base-top)
            offset(delta=-wall)
                rounded_rect_2d(W, D, corner_r);
}

module inlet_hole(){
    // Circular inlet through top (and into cavity)
    translate([0,0,H-top-0.01])
        cylinder(h=top+0.02, d=inlet_d);
}

module inlet_lip_ring(){
    // Small raised ring around inlet on top surface
    translate([0,0,H-top])
        difference(){
            cylinder(h=top, d=inlet_d + 2*inlet_lip);
            translate([0,0,-0.01]) cylinder(h=top+0.02, d=inlet_d);
        }
}

module outlet_cut(){
    // Outlet opening on +X side, centered in Z within cavity
    zc = base + (H-base-top)/2;
    translate([W/2 - wall - 0.2, 0, zc])
        rotate([0,90,0])
            cube([outlet_h, outlet_w, outlet_len+2], center=true);
}

module outlet_duct(){
    // External duct protrusion on +X side
    zc = base + (H-base-top)/2;
    translate([W/2, 0, zc])
        rotate([0,90,0])
            difference(){
                // outer
                cube([outlet_h + 2*wall, outlet_w + 2*wall, outlet_len], center=true);
                // inner
                cube([outlet_h, outlet_w, outlet_len+0.2], center=true);
            }
}

module impeller(){
    // Positioned inside cavity, centered
    z0 = base + 0.4;
    translate([0,0,z0])
    union(){
        // backplate
        cylinder(h=1.2, r=imp_r);
        // hub
        translate([0,0,0]) cylinder(h=hub_h, r=hub_r);
        // blades
        for(i=[0:blade_count-1]){
            ang = i*360/blade_count;
            rotate([0,0,ang])
                translate([0,0,0])
                    blade();
        }
    }
}

module blade(){
    // A backward-swept blade made by hulling two thin radial rectangles at different angles
    // near hub and near rim.
    hull(){
        rotate([0,0,0])
            translate([ (blade_r0+blade_r1)/2, 0, 0])
                cube([blade_r1-blade_r0, blade_th, blade_h], center=true);
        rotate([0,0,-blade_sweep])
            translate([ (blade_r0+blade_r1)/2, 0, 0])
                cube([blade_r1-blade_r0, blade_th, blade_h], center=true);
    }
}

module blower(){
    union(){
        // Main housing with cavity and openings
        difference(){
            union(){
                housing_outer();
                outlet_duct();
                inlet_lip_ring();
            }
            housing_inner();
            inlet_hole();
            outlet_cut();
        }
        // Internal impeller (visible if cutaway; otherwise enclosed)
        impeller();
    }
}

blower();