package;

import ceramic.Entity;
import ceramic.Color;
import ceramic.InitSettings;

class Project extends Entity {
    function new(settings:InitSettings) {
        super();

        settings.antialiasing = 2;
        settings.background = Color.BLACK;
        settings.targetWidth = 640;
        settings.targetHeight = 480;
        settings.scaling = FIT;
        settings.resizable = true;
        // low fps for visibility
        settings.targetFps = 4;

        app.onceReady(this, ready);
    }

    function ready() {
        app.scenes.main = new MainScene();
    }
}
