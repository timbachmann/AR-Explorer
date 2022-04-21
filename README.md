# AR-Explorer
Capture images and visualize them in AR at their real world location

# Context
With GoFind! researchers of the Databases and Information Systems group have created a prototype to relive historic views with Augmented Reality. Historic photography of cityscapes are searchable using multimedia retrieval tech- niques and are presented as accurately as possible in AR - acting as a “window into the past”. The system’s foundation form three naive parameters: longitude and latitude (a.k.a. GPS location) and the bearing (deviation of the image from north, in degrees). For historic photography, all three of the parameters are rough estimates.
GoFind! does exist as a Unity based application powered by Google’s ARCore for Android and as a native Android app. It has been shown, that while there are advantages for cross-platform applications such as the Unity based GoFind!, the benefits of native apps outweigh the former. In addition, recently, Apple’s ARKit - and in addition to this, additional sensors - have made improvements such that AR presentation is as accessible as it can be.
Thus, a native iOS app gathering as much (sensor) data as possible upon snapping a picture, in order to then present the captured photo in AR – as accurately as possible will bring insights on which parameters are essential for AR perspective reproduction.

# Goals
