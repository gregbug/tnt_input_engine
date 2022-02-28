# tnt_input_engine
Godot 3.x Virtual Input Engine

What is it for? Why was it created?
TNT input engine is an addon made for the Godot 3.x game engine.
The main reason why it was created is to simplify and unify the writing of input control code allowing you to write code only once and simultaneously manage keyboard input from virtual touchscreen joystick and real joystick using the standard API of Godot.
It was designed from the outset to not impact performance and in fact the system uses the Godot input engine without adding any overload; the only additional code is for the management of the touchscreen for the virtual joypad and the code is really light and fast, the input management is instead managed by the engine itself.
To make the programmer's life easier, a simplified and automated mapping system has also been added for all those input devices that are not natively recognized by Godot.
