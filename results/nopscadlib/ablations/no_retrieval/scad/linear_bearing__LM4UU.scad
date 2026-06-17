// Linear bearing sleeve: 4mm bore, 8mm OD, 12mm length
// One connected solid: cylindrical sleeve with through-bore + optional end chamfers

$fn = 128;

// Parameters
bearing_L = 12.0;          //[6.0:24.0:0.1]
bearing_OD = 8.0;          //[4.0:16.0:0.1]
bore_ID = 4.0;             //[2.0:8.0:0.05]
chamfer_len = 0.5;         //[0.0:1.5:0.05]
chamfer_depth = 0.25;      //[0.0:0.8:0.05]
eps = 0.02;

// Derived
Rout = bearing_OD/2;
Rin  = bore_ID/2;

module bearing_sleeve() {
    difference() {
        // Outer body (length along Z)
        cylinder(h=bearing_L, r=Rout, center=true);

        // Through bore (slightly longer to guarantee a clean cut)
        cylinder(h=bearing_L + 2*eps, r=Rin, center=true);

        // Optional internal end chamfers (subtractive, remain connected)
        if (chamfer_len > 0 && chamfer_depth > 0) {
            // +Z end chamfer
            translate([0, 0, bearing_L/2 - chamfer_len/2])
                cylinder(h=chamfer_len + 2*eps,
                         r1=Rin + chamfer_depth, r2=Rin,
                         center=true);

            // -Z end chamfer
            translate([0, 0, -bearing_L/2 + chamfer_len/2])
                cylinder(h=chamfer_len + 2*eps,
                         r1=Rin, r2=Rin + chamfer_depth,
                         center=true);
        }
    }
}

bearing_sleeve();