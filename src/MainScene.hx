package;

import ceramic.AssetId;
import ceramic.Scene;
import ceramic.Tilemap;
import ceramic.TilemapData;
import ceramic.TilemapLayerData;
import ceramic.Tileset;
import ceramic.Timer;
import elements.Im;

using PatternTools;

class MainScene extends Scene {
    static final CELLMAP_WIDTH = 80;
    static final CELLMAP_HEIGHT = 60;

    var patternsById:Map<String, AssetId<String>>;
    var patternId:String;
    var nextPatternId:String;
    var sps:Float;

    var pattern:Pattern;
    var tilemap:Tilemap;
    var generation:Int;

    override function preload() {
        // Add any asset you want to load here

        assets.add(Images.SINGLE_TILE);

        // Load patterns
        // https://conwaylife.com/wiki
        patternsById = [
            'Gosper glider gun' => Texts.PATTERNS__GOSPERGLIDERGUN_CELLS,
            'Pentadecathlon' => Texts.PATTERNS__PENTADECATHLON_CELLS,
            'Pulsar' => Texts.PATTERNS__PULSAR_CELLS,
            'Toad sucker' => Texts.PATTERNS__TOADSUCKER_CELLS,
            'Twin bees shuttle' => Texts.PATTERNS__3BLOCKTWINBEESSHUTTLE_CELLS,
        ];
        for (aid in patternsById) {
            assets.add(aid);
        }
    }

    override function create() {
        // Called when scene has finished preloading

        // Set default values
        nextPatternId = 'Pulsar';
        sps = 4.0;

        // Start simulation
        nextGeneration();
    }

    function loadPattern(aid:AssetId<String>) {
        var text = assets.text(aid);
        pattern = text.convertPlaintextToPattern();

        // Fit pattern to cellmap
        var cells:Array<Int> = [];
        var dx:Int = Std.int((CELLMAP_WIDTH - pattern.w) * 0.5);
        var dy:Int = Std.int((CELLMAP_HEIGHT - pattern.h) * 0.5);
        for (y in 0...CELLMAP_HEIGHT) {
            for (x in 0...CELLMAP_WIDTH) {
                var px = x - dx;
                var py = y - dy;
                var state = 0;
                if (px >= 0 && px < pattern.w && py >= 0 && py < pattern.h) {
                    state = pattern.cells[px + py * pattern.w];
                }
                cells.push(state);
            }
        }
        pattern = {w: CELLMAP_WIDTH, h: CELLMAP_HEIGHT, cells: cells};
        generation = 0;
    }

    function createTilemap(p:Pattern) {
        // Create our very simple one-tile tileset
        var tileset = new Tileset();
        // 0 = no tile
        // 1 = our single tile
        tileset.firstGid = 1;
        tileset.tileSize(8, 8);
        tileset.texture = assets.texture(Images.SINGLE_TILE);
        tileset.columns = 1;

        // Create our tile layer
        var layerData = new TilemapLayerData();
        layerData.name = 'main';
        layerData.grid(p.w, p.h);
        layerData.tileSize(8, 8);
        layerData.tiles = p.cells;

        // Create the tilemap data holding our tile layer
        var tilemapData = new TilemapData();
        tilemapData.size(layerData.columns * tileset.tileWidth, layerData.rows * tileset.tileHeight);
        tilemapData.tilesets = [tileset];
        tilemapData.layers = [layerData];

        // Then create the actual tilemap visual and assign it tilemap data
        if (tilemap != null)
            tilemap.destroy();
        tilemap = new Tilemap();
        tilemap.tilemapData = tilemapData;
        tilemap.pos(8, 8);

        add(tilemap);
    }

    function nextGeneration() {
        if (patternId != nextPatternId) {
            patternId = nextPatternId;
            var aid = patternsById[patternId];
            loadPattern(aid);
        }
        createTilemap(pattern);
        pattern.nextGeneration();
        generation++;

        Timer.delay(null, 1 / sps, nextGeneration);
    }

    override function update(delta:Float) {
        // Here, you can add code that will be executed at every frame

        Im.begin('Options', 300);

        var ids = [for (key in patternsById.keys()) key];
        Im.select('Pattern', Im.string(nextPatternId), ids);

        Im.slideFloat('Steps per second', Im.float(sps), 1, 60, 1);

        Im.end();
    }

    override function resize(width:Float, height:Float) {
        // Called everytime the scene size has changed
    }

    override function destroy() {
        // Perform any cleanup before final destroy

        super.destroy();
    }
}
