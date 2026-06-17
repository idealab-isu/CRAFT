// Timing pulley: 16 teeth, 12.16mm pitch diameter
// One connected solid, no floating parts, no labels/reference solids.

$fn = 220;

// ---------------- Parameters ----------------
tooth_count = 16;                 //[8:64:1]
pitch_diameter = 12.16;           //[6.08:24.32:0.01]
pulley_width = 10;                //[5:20:0.5]

bore_diameter = 5;                //[2:12:0.1]

flange_thickness = 1.2;           //[0.6:3:0.1]
flange_radial_extra = 2;          //[0.5:6:0.1]

set_screw_diameter = 2.5;         //[1.5:5:0.1]
set_screw_head_clearance = 0.5;   //[0.2:1.5:0.1]

keyway_width = 2;                 //[1:4:0.1]
keyway_depth = 1;                 //[0.5:2.5:0.1]
keyway_length = 8;                //[4:20:0.5]

chamfer_amount = 0.6;             //[0.2:2:0.1]

// Tooth geometry (simple timing-tooth approximation; teeth are distinct and countable)
tooth_height = 1.5;               //[0.8:3:0.1]
tooth_tip_width = 1.2;            //[0.6:2.4:0.05]
tooth_root_width = 2.0;           //[1:4:0.05]
tooth_overlap = 1.0;              //[0.3:2:0.05]

// Rim supports tooth roots and provides a clear cylindrical base
rim_thickness_radial = 1.2;       //[0.6:4:0.1]

// Hub sizing (keep hub inside toothed OD so teeth are visible)
hub_diameter = 10;                //[6:20:0.5]
hub_width = 10;                   //[5:25:0.5]

// Robust boolean overlap to avoid non-manifold seams
overlap = 1.0;                    //[0.2:2:0.1]

// ---------------- Derived ----------------
pitch_r = pitch_diameter/2;

// Place tooth "pitch line" at pitch_r by centering tooth thickness around pitch_r.
tooth_root_r = pitch_r - tooth_height/2;
tooth_tip_r  = pitch_r + tooth_height/2;

// Rim radius (base cylinder under teeth)
rim_r = tooth_root_r + rim_thickness_radial;

// Outer radius at tooth tips
tooth_outer_r = tooth_tip_r;

// Flange radius beyond tooth tips
flange_r = tooth_outer_r + flange_radial_extra;

// Total height including flanges (for cuts)
total_h = pulley_width + 2*flange_thickness;

// ---------------- Geometry ----------------
module tooth_2d() {
    // Trapezoid tooth profile in XY, extruded along Z later.
    // Inner edge overlaps into rim by tooth_overlap to guarantee union connectivity.
    polygon(points=[
        [tooth_root_r - tooth_overlap, -tooth_root_width/2],
        [tooth_root_r - tooth_overlap,  tooth_root_width/2],
        [tooth_tip_r,                   tooth_tip_width/2],
        [tooth_tip_r,                  -tooth_tip_width/2]
    ]);
}

module teeth() {
    for (i = [0:tooth_count-1]) {
        rotate([0,0,i*360/tooth_count])
            linear_extrude(height=pulley_width, center=true, convexity=10)
                tooth_2d();
    }
}

module rim() {
    cylinder(r=rim_r, h=pulley_width, center=true);
}

module hub() {
    // Hub spans the same width as the toothed section to ensure a single connected body.
    cylinder(r=hub_diameter/2, h=hub_width, center=true);
}

module flange(zsign=1) {
    // Flanges touch/overlap the toothed section by 'overlap' to ensure connectivity.
    translate([0,0, zsign*(pulley_width/2 + flange_thickness/2 - overlap)])
        cylinder(r=flange_r, h=flange_thickness, center=true);
}

module chamfer(zsign=1) {
    // Simple conical chamfer on hub ends; overlaps slightly to avoid non-manifold seams.
    translate([0,0, zsign*(hub_width/2 - chamfer_amount/2 + overlap)])
        cylinder(r1=hub_diameter/2, r2=0, h=chamfer_amount, center=true);
}

module center_bore_cut() {
    cylinder(r=bore_diameter/2, h=total_h + 4*overlap, center=true);
}

module set_screw_cut() {
    // Radial hole through hub (X axis), centered at mid-height.
    rotate([0,90,0])
        cylinder(r=set_screw_diameter/2,
                 h=hub_diameter + 2*set_screw_head_clearance + 4*overlap,
                 center=true);
}

module keyway_cut() {
    // Rectangular keyway cut into bore along Z.
    translate([bore_diameter/2 + keyway_depth/2 - overlap, 0, 0])
        cube([keyway_depth + 2*overlap, keyway_width, keyway_length], center=true);
}

module pulley_solid() {
    union() {
        // Core body (single connected solid)
        union() {
            rim();
            teeth();
            hub();
        }

        // Belt guide flanges (connected via overlap)
        flange(+1);
        flange(-1);

        // Hub chamfers (additive; kept connected via overlap)
        chamfer(+1);
        chamfer(-1);
    }
}

module pulley_final() {
    difference() {
        pulley_solid();
        center_bore_cut();
        set_screw_cut();
        keyway_cut();
    }
}

// Output
pulley_final();