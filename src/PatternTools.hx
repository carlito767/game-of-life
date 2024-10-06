package;

using StringTools;

class PatternTools {
    public static function convertPlaintextToPattern(text:String):Pattern {
        // Plaintext pattern
        // https://conwaylife.com/wiki/Plaintext

        var cells:Array<Int> = [];

        // Set width (w) and height (h)
        var w = 0;
        var h = 0;
        var lines:Array<String> = [];
        var tlines = text.replace('\r\n', '\n').split('\n');
        for (line in tlines) {
            line = line.trim();
            if (line == "" && lines.length == 0)
                continue; // ignore empty lines until pattern starts

            if (line.startsWith('!'))
                continue; // ignore comments

            if (w < line.length)
                w = line.length;
            lines.push(line);
        }

        while (lines.length > 0 && lines[lines.length - 1] == '') {
            lines.pop(); // remove trailing empty lines
        }
        h = lines.length;

        // Convert lines to cells
        for (line in lines) {
            for (i in 0...w) {
                var state = (line.charAt(i) == 'O') ? 1 : 0;
                cells.push(state);
            }
        }

        return {w: w, h: h, cells: cells};
    }

    // Inspired by https://www.jagregory.com/abrash-black-book/#chapter-17-the-game-of-life
    public static function nextGeneration(p:Pattern):Void {
        var next_cells:Array<Int> = [];

        var neighbor_count:Int;
        for (y in 0...p.h) {
            for (x in 0...p.w) {
                // Figure out how many neighbors this cell has
                neighbor_count = 0;
                for (c in [
                    {x: x - 1, y: y - 1},
                    {x: x - 1, y: y},
                    {x: x - 1, y: y + 1},
                    {x: x, y: y - 1},
                    {x: x, y: y + 1},
                    {x: x + 1, y: y - 1},
                    {x: x + 1, y: y},
                    {x: x + 1, y: y + 1},
                ]) {
                    if (c.x >= 0 && c.x < p.w && c.y >= 0 && c.y < p.h) {
                        neighbor_count += p.cells[c.x + c.y * p.w];
                    }
                }

                // Update state
                var state:Int = p.cells[x + y * p.w];
                if (state == 1) {
                    // The cell is on; does it stay on?
                    if ((neighbor_count != 2) && (neighbor_count != 3)) {
                        state = 0; // turn it off
                    }
                } else {
                    // The cell is off; does it turn on?
                    if (neighbor_count == 3) {
                        state = 1; // turn it on
                    }
                }
                next_cells.push(state);
            }
        }

        p.cells = next_cells;
    }
}
