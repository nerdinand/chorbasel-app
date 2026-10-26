import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "audioTag", "score" ]
  static values = {
    url: String,
    delayInMilliseconds: Number,
    metadata: Object,
    measureList: Array,
    secondsToMeasureNumberList: Array,
  }

  initializeVerovio() {
    // Check if WebAssembly is supported
    if (typeof WebAssembly === 'undefined') {
      return;
    }

    // Check if verovio object exists at all
    if (typeof verovio === 'undefined') {
      return;
    }

    // If toolkit already exists, we're already initialized
    if (document.toolkit) {
      this.setupToolkit();
      return;
    }

    // If module exists, check if it's already initialized
    if (verovio?.module) {
      // In Emscripten, check if runtime is already initialized
      // Different Verovio versions may use different properties
      const isInitialized = verovio.module.calledRun || 
                           verovio.module._initialized ||
                           (typeof verovio.module._main === 'function' && verovio.module._main.length === 0) ||
                           // Check if HEAP is available (WASM memory is initialized)
                           (verovio.module.HEAPU8 && verovio.module.HEAPU8.length > 0) ||
                           // Check if toolkit constructor exists (module is ready)
                           (typeof verovio.module._vrvToolkit_constructor === 'function');
      
      if (isInitialized) {
        this.setupToolkit();
        return;
      }
      
      // If module has a then() method (promise), use it
      if (typeof verovio.module.then === 'function') {
        verovio.module.then(() => {
          this.setupToolkit();
        });
        return;
      }
      
      // Set callback for when module initializes
      const existingCallback = verovio.module.onRuntimeInitialized;
      verovio.module.onRuntimeInitialized = () => {
        if (existingCallback) {
          try {
            existingCallback();
          } catch (e) {
            // Ignore errors from existing callback
          }
        }
        this.setupToolkit();
      };
      
      // Safari/Chrome/Edge fix: Also try after a short delay in case module is already initialized
      // but the callback doesn't fire when set after initialization
      setTimeout(() => {
        if (!document.toolkit) {
          this.setupToolkit();
        }
      }, 100);
      
      return;
    }

    // Module not loaded yet, wait for it to appear
    const interval = setInterval(() => {
      if (verovio?.module) {
        clearInterval(interval);
        
        // Check if already initialized
        const isInitialized = verovio.module.calledRun || 
                           verovio.module._initialized ||
                           (verovio.module.HEAPU8 && verovio.module.HEAPU8.length > 0) ||
                           (typeof verovio.module._vrvToolkit_constructor === 'function');
        if (isInitialized) {
          this.setupToolkit();
          return;
        }
        
        const existingCallback = verovio.module.onRuntimeInitialized;
        verovio.module.onRuntimeInitialized = () => {
          if (existingCallback) existingCallback();
          this.setupToolkit();
        };
        if (document.toolkit) {
          this.setupToolkit();
        }
      }
    }, 50);
    
    // Prevent infinite waiting
    setTimeout(() => {
      clearInterval(interval);
    }, 5000);
  }

  setupToolkit() {
    try {
      document.toolkit = new verovio.toolkit();
      
      document.toolkit.setOptions({
        pageWidth: document.body.clientWidth,
        pageHeight: 100,
        scale: 50,
        svgViewBox: true,
        scaleToPageSize: true,
        header: 'none',
        footer: 'none',
        lyricSize: 3,
        lyricWordSpace: 2,
        adjustPageHeight: true,
        adjustPageWidth: true,
        expandNever: true
      });

      this.secondsToMeasureNumberListValue = this.metadataValue["secondsToMeasureNumberList"];

      fetch(this.urlValue)
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          return response.text();
        })
        .then((meiXML) => {
          let svg = document.toolkit.renderData(meiXML, {});
          if (!svg) {
            throw new Error('Rendered SVG is empty');
          }
          this.scoreTarget.innerHTML = svg;
        })
        .then(() => this.buildMeasureList(this))
        .then(() => {
          setTimeout(this.updateAndSetTimeout(this), this.delayInMillisecondsValue);
        })
        .catch((error) => {
          // Ignore fetch/render errors
        });
    } catch (error) {
      // Ignore toolkit creation errors
    }
  }

  scoreTargetConnected() {
    this.initializeVerovio();
  }

  buildMeasureList(controller) {
    let i = 1
    let lastMeasureId = null
    let measures = []

    while(true) {
      let elements = document.toolkit.getElementsAtTime(i)
      let currentMeasureId = elements.measure
      
      if (currentMeasureId === undefined) {
        break
      }

      if (currentMeasureId != lastMeasureId) {
        lastMeasureId = currentMeasureId
        measures.push([currentMeasureId, elements.page])
      }
      i += 500
    }

    controller.measureListValue = measures
  }

  getMeasure(recordingTime) {
    let biggerIndex = this.secondsToMeasureNumberListValue.findIndex((e) => e[0] > recordingTime)

    if (biggerIndex == -1) {
      return Math.max(...this.secondsToMeasureNumberListValue.map(e => e[1]))
    }

    if (biggerIndex == 0) {
      // We're before the beginning of the song (score-wise), therefore, no measure yet
      return undefined
    }

    let smallerIndex = biggerIndex - 1

    let nextMeasureNumber = this.secondsToMeasureNumberListValue[biggerIndex][1]
    let previousMeasureNumber = this.secondsToMeasureNumberListValue[smallerIndex][1]

    if (nextMeasureNumber - previousMeasureNumber <= 1 || nextMeasureNumber <= previousMeasureNumber) {
      // Either next measure is just one bigger or the same as the current, 
      // or we going to a repetition in the next measure: Either way, no interpolation needed!
      return previousMeasureNumber
    }

    let biggerTime = this.secondsToMeasureNumberListValue[biggerIndex][0]
    let smallerTime = this.secondsToMeasureNumberListValue[smallerIndex][0]

    let sectionTimeLength = biggerTime - smallerTime
    let sectionMeasuresLength = nextMeasureNumber - previousMeasureNumber
    let currentTimeInSection = recordingTime - smallerTime
    let currentMeasureInSection = parseInt((currentTimeInSection * sectionMeasuresLength) / sectionTimeLength)
    return previousMeasureNumber + currentMeasureInSection
  }

  hideMeasures() {
    let playingMeasures = this.scoreTarget.querySelectorAll(".playing");
    for (let playingMeasure of playingMeasures) playingMeasure.classList.remove("playing");
  }

  showMeasure(measure) {
    let measureListEntry = this.measureListValue[measure - 1]

    if (measureListEntry === undefined) {
      return
    }

    var playingMeasure = document.getElementById(measureListEntry[0])

    if (playingMeasure === null) {
      this.scoreTarget.innerHTML = document.toolkit.renderToSVG(measureListEntry[1]);
      playingMeasure = document.getElementById(measureListEntry[0])
    }

    if (playingMeasure === null) {
      return
    }

    playingMeasure.classList.add("playing")
  }

  updateAndSetTimeout(controller) {
    controller.update()
    setTimeout(() => controller.updateAndSetTimeout(controller), controller.delayInMillisecondsValue)
  }

  update(event) {
    // If called from an event (e.g., seeked event on audio tag), use and remember that audio element
    // Otherwise use the last remembered audio element or fall back to the first audio tag target
    if (event) {
      this.currentAudioElement = event.target;
    }
    
    const audioElement = this.currentAudioElement || this.audioTagTarget;
    
    if (!audioElement) {
      return;
    }
    
    this.hideMeasures()
    let measure = this.getMeasure(audioElement.currentTime)
    if (measure === undefined) {
      return
    }

    this.showMeasure(measure)
  }
}
