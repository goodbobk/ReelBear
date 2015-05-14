ball_d = 3;
ball_spacing = 4.2;
balls = 15;
hole_w = 4;

axle_d = 5.6;
axle_flat = 0.2;

sprocket_rim_h = 2;
sprocket_rim_w = 2;
sprocket_w = hole_w;
sprocket_d = balls * ball_spacing/PI;

e = 0.002;
e2 = 2*e;

segments = balls * 1;

echo(hole_w);
echo(sprocket_d);
difference() {
    union() {
        cylinder(d=sprocket_d, 
                 h=sprocket_w,
                 center = true,
                 $fn = segments);
        translate([0,0,-sprocket_w/2 - sprocket_rim_w/2])
            cylinder(d1=sprocket_d + sprocket_rim_h, 
                     d2=sprocket_d, 
                     h = sprocket_rim_w,
                     center = true,
                     $fn = segments );
        translate([0,0,sprocket_w/2 + sprocket_rim_w/2])
            cylinder(d1=sprocket_d, 
                     d2=sprocket_d + sprocket_rim_h,  
                     h = sprocket_rim_w,
                     center = true,        
                     $fn = segments);
    }
        
    for( a = [0:360/balls:359] )
        rotate(a) 
            translate([0.96*sprocket_d/2,0,0]) 
                cylinder(d=ball_d + 0.2, 
                         h=hole_w,
                         center=true,
                         $fn=18);
    
    difference() {
        cylinder(d=axle_d, 
                h=2*sprocket_rim_w + sprocket_w + e2,
                center = true,
                $fn = 48);
        translate([-axle_d/2, axle_d/2 - axle_flat,-(2*sprocket_rim_w + sprocket_w + e2)/2])
            cube(size=[axle_d,axle_d,2*sprocket_rim_w + sprocket_w + e2]);
        }

}