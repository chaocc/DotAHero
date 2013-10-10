Plugin Constants - BGPluginConstants.h





"menu.children.lastObject and menu.children.count" performance is bad


Effect: the sound file in your bundle you want to play.

Pitch: [0.5 to 2.0] think of it as the "note" of the sound. Giving a higher pitch number makes the sound play at a "higher note". A lower value will make the sound lower or "deeper". 1.0 is pitch of original file.

Pan: [-1.0 to 1.0] stereo affect. Below zero plays your sound more on the left side. Above 0 plays to the right. 0.0 is dead-center. (see note below)

Gain: [0.0 and up] volume. 1.0 is the volume of the original file.


// Tell Cocos2D to pass the CCNode's position/scale/rotation matrix to the shader
[shaderProgram_ setUniformForModelViewProjectionMatrix];



const Vertex Vertices2[] = {
    {{0.5, -0.5, 0.01}, {1, 1, 1, 1}, {1, 1}},
    {{0.5, 0.5, 0.01}, {1, 1, 1, 1}, {1, 0}},
    {{-0.5, 0.5, 0.01}, {1, 1, 1, 1}, {0, 0}},
    {{-0.5, -0.5, 0.01}, {1, 1, 1, 1}, {0, 1}},
};
 
const GLubyte Indices2[] = {
    1, 0, 2, 3
};

After the first three vertices, GL_TRIANGLE_STRIP makes new triangles by combining the previous two vertices with the next vertex. This can be nice to use because it
can reduce the index buffer size. I use it here mainly to show you how it works.