// Linear Bearing (Bushing) Parameters
outer_diameter = 12.0;
inner_diameter = 6.0;
length = 35.0;

// Linear Bearing Body
module linear_bearing_body() {
    cylinder(d = outer_diameter, h = length, center = true);
}

// Through Bore
module through_bore() {
    cylinder(d = inner_diameter, h = length + 2, center = true);
}

// Linear Bearing Assembly
module linear_bearing() {
    difference() {
        linear_bearing_body();
        through_bore();
    }
}

// Render the Linear Bearing
linear_bearing();