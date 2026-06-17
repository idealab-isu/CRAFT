// Timing pulley: 16 teeth, 9.75mm pitch diameter
// One connected solid, with visible teeth and dimension-driven placement.

teeth = 16;
pitch_diameter = 9.75;          // pitch circle diameter (mm)
bore_diameter  = 5;             // center bore (mm)

tooth_profile_height = 6;       // toothed section height (mm)

hub_diameter   = 12;            // hub OD (mm)
hub_length     = 10;            // hub length (mm)

flange_thickness = 1;           // flange thickness (mm)
flange_diameter  = 14;          // flange OD (mm)

// Tooth geometry (simple timing-tooth approximation; ensures visible teeth)
tooth_radial_height = 1.2;      // tooth protrusion above pitch radius (mm)
tooth_root_depth    = 0.6;      // tooth valley below pitch radius (mm)
tooth_tip_width     = 0.9;      // tangential width at tooth tip (mm)
tooth_root_width    = 1.6;      // tangential width at tooth root (mm)

// Quality
$fn = max(180, teeth * 24);

eps = 0.05;

pitch_r = pitch_diameter / 2;
root_r  = pitch_r - tooth_root_depth;
tip_r   = pitch_r + tooth_radial_height;

// Ensure teeth are actually visible and not "merged away" by a larger hub.
// The toothed OD must exceed hub OD.
assert(2*tip_r > hub_diameter, "Hub diameter is too large; it hides the teeth. Reduce hub_diameter or increase tooth_radial_height/root geometry.");

module tooth_prism(h) {
    // Build tooth in local coordinates around +X axis, then place radially.
    // Use a trapezoid in the (radial,tangential) plane and extrude along Z.
    linear_extrude(height=h, center=true, convexity=10)
        polygon(points=[
            [0,                 -tooth_root_width/2],
            [0,                  tooth_root_width/2],
            [tooth_radial_height + tooth_root_depth,  tooth_tip_width/2],
            [tooth_radial_height + tooth_root_depth, -tooth_tip_width/2]
        ]);
}

module toothed_ring(h) {
    union() {
        // Root cylinder (valley diameter)
        cylinder(r=root_r, h=h, center=true);

        // Teeth: place each tooth so its inner face starts at root_r (overlap slightly)
        for (i = [0:teeth-1]) {
            rotate([0,0,i*360/teeth])
                translate([root_r - eps, 0, 0])  // connect into root cylinder
                    tooth_prism(h);
        }
    }
}

module pulley_solid() {
    union() {
        // Toothed section centered at Z=0
        toothed_ring(tooth_profile_height);

        // Flanges: overlap slightly into toothed section for connectivity
        translate([0,0, (tooth_profile_height/2) + (flange_thickness/2) - eps])
            cylinder(d=flange_diameter, h=flange_thickness, center=true);

        translate([0,0,-(tooth_profile_height/2) - (flange_thickness/2) + eps])
            cylinder(d=flange_diameter, h=flange_thickness, center=true);

        // Hub: centered, overlaps into toothed section to ensure one connected solid
        cylinder(d=hub_diameter, h=hub_length, center=true);
    }
}

module pulley() {
    difference() {
        pulley_solid();

        // Bore through entire part (with margin)
        bore_h = max(hub_length, tooth_profile_height + 2*flange_thickness) + 2;
        cylinder(d=bore_diameter, h=bore_h, center=true);
    }
}

// Render
pulley();