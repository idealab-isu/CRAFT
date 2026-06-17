$fn = 180;

// Requested
teeth = 12;
pitch_diameter = 7.15;          // pitch circle diameter (PCD)
belt_width = 6;                 // toothed section height (Z)

// Tooth shape (simple timing-tooth-like trapezoid, not rectangular ribs)
tooth_radial_height = 1.2;      // radial height above pitch radius
tooth_tip_frac = 0.35;          // fraction of circular pitch at tooth tip
tooth_root_frac = 0.65;         // fraction of circular pitch at tooth root (at pitch circle)

// Other parameters
center_bore_diameter = 5;
hub_diameter = 10;
hub_height = 5;
flange_thickness = 1;
flange_overhang = 2.0;          // flange extends beyond tooth OD by this radial amount
overlap = 0.25;                 // overlap for watertight unions

// Derived
pitch_r = pitch_diameter/2;
circular_pitch = PI * pitch_diameter / teeth;

tooth_tip_w  = circular_pitch * tooth_tip_frac;
tooth_root_w = circular_pitch * tooth_root_frac;

tooth_od = pitch_diameter + 2*tooth_radial_height;
tooth_or = tooth_od/2;

flange_diameter = tooth_od + 2*flange_overhang;
flange_r = flange_diameter/2;

total_h = belt_width + 2*flange_thickness + hub_height;

// 2D trapezoid tooth (in XY), extruded along Z
module tooth2d() {
    // Inner face starts slightly inside pitch radius for guaranteed connection
    r_in  = pitch_r - overlap;
    r_out = pitch_r + tooth_radial_height;

    polygon(points=[
        [r_in,  -tooth_root_w/2],
        [r_in,   tooth_root_w/2],
        [r_out,  tooth_tip_w/2],
        [r_out, -tooth_tip_w/2]
    ]);
}

module toothed_section() {
    z0 = flange_thickness;
    union() {
        // Core cylinder slightly under pitch radius so teeth are distinct and connected
        translate([0,0,z0])
            cylinder(h=belt_width, r=pitch_r - overlap);

        // 12 teeth around pitch circle
        translate([0,0,z0])
            for (i = [0:teeth-1])
                rotate([0,0,i*360/teeth])
                    linear_extrude(height=belt_width)
                        tooth2d();
    }
}

module flanges() {
    // Bottom flange
    cylinder(h=flange_thickness, r=flange_r);

    // Top flange
    translate([0,0,flange_thickness + belt_width])
        cylinder(h=flange_thickness, r=flange_r);
}

module hub() {
    // Hub sits on top flange and overlaps slightly into it
    translate([0,0,flange_thickness + belt_width + flange_thickness - overlap])
        cylinder(h=hub_height + overlap, r=hub_diameter/2);
}

module pulley_solid() {
    union() {
        flanges();
        toothed_section();
        hub();
    }
}

module pulley() {
    difference() {
        pulley_solid();

        // Center bore through entire part (extra for guaranteed cut)
        translate([0,0,-overlap])
            cylinder(h=total_h + 2*overlap, r=center_bore_diameter/2);
    }
}

pulley();