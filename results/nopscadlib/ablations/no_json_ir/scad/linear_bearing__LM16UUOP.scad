$fn = 128;

// Target dimensions (mm)
bore_diameter  = 16.0;   // ID
outer_diameter = 28.0;   // OD
length         = 37.0;   // overall length

// Small epsilon to ensure clean boolean cuts
eps = 0.02;

module linear_bearing_16_28_37() {
    difference() {
        // Outer sleeve
        cylinder(d=outer_diameter, h=length, center=true);

        // Through bore (make slightly longer so it always cuts fully)
        cylinder(d=bore_diameter, h=length + 2*eps, center=true);
    }
}

// ONE connected solid: just the bearing sleeve (no extra shaft/pin/screw/washer)
linear_bearing_16_28_37();