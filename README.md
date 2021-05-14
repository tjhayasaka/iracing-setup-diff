*

chokidar '**/*.elm' -c 'elm make src/Main.elm --output electron/elm.js'

(cd electron && npm start)
