import { Controller } from "@hotwired/stimulus"

class Measure { // This represents a measure in the expanded score, meaning only number and repetition combined are unique
  constructor(number, expandedNumber, domId, repetition, startSeconds) {
    this.number = number
    this.expandedNumber = expandedNumber
    this.domId = domId
    this.repetition = repetition
    this.startSeconds = startSeconds
    this.endSeconds = undefined
  }

  isTimeInRange(seconds) {
    if (this.endSeconds === undefined) {
      return this.startSeconds <= seconds
    }
    return this.startSeconds <= seconds && seconds < this.endSeconds
  }

  setEndSeconds(seconds) {
    this.endSeconds = seconds
  }
}

class ScoreSection {
  constructor(fromMeasureNumber, toMeasureNumber, fromSecond, toSecond) {
    this.fromMeasureNumber = fromMeasureNumber
    this.toMeasureNumber = toMeasureNumber
    this.fromSecond = fromSecond
    this.toSecond = toSecond
  }

  calculateStartSeconds(measureNumber) {
    return this.fromSecond + ((measureNumber - this.fromMeasureNumber) * this.#getSecondsDuration()) / this.#getMeasureCount()
  }

  #getMeasureCount() {
    return this.toMeasureNumber - this.fromMeasureNumber
  }

  #getSecondsDuration() {
    return this.toSecond - this.fromSecond
  }
}

class ScoreMeasureList {
  constructor(expandedMeasures, domIdList) {
    this.expandedMeasures = expandedMeasures;
    this.domIdList = domIdList
  }

  static build(secondsToMeasureNumberList) {
    const domIdList = this.#buildDomIdList()    
    const scoreSectionsList = this.#buildScoreSectionList(secondsToMeasureNumberList)
    const expandedMeasures = this.#expandMeasures(scoreSectionsList, domIdList)
        
    return new ScoreMeasureList(expandedMeasures, domIdList)
  }

  static #expandMeasures(scoreSectionsList, domIdList) {
    let measures = []
    let expandedNumber = 0
    let lastMeasureNumber = -1

    let scoreMeasureCount = domIdList.length

    let repetitionCount = Array(scoreMeasureCount).fill(0)

    for (let scoreSection of scoreSectionsList) {
      for (let measureNumber = scoreSection.fromMeasureNumber; measureNumber <= scoreSection.toMeasureNumber && measureNumber <= scoreMeasureCount; measureNumber++) {
        if (measureNumber == lastMeasureNumber) {
          continue
        }

        const rCount = repetitionCount[measureNumber - 1] += 1
        expandedNumber += 1
        let startSeconds = scoreSection.calculateStartSeconds(measureNumber)

        if (measures.length > 0) {
          measures.slice(-1)[0].setEndSeconds(startSeconds)
        }

        let measure = new Measure(measureNumber, expandedNumber, domIdList[measureNumber - 1], rCount, startSeconds)
        measures.push(measure)
        lastMeasureNumber = measureNumber
      }
    }

    return measures
  }

  static #buildScoreSectionList(secondsToMeasureNumberList) {
    let list = []

    for (let i = 1; i < secondsToMeasureNumberList.length; i++) {
      const from = secondsToMeasureNumberList[i - 1]
      const to = secondsToMeasureNumberList[i]
      const fromMeasureNumber = from[1]
      const toMeasureNumber = to[1]

      if (toMeasureNumber > fromMeasureNumber) {
        const fromSecond = from[0]
        const toSecond = to[0]
        list.push(new ScoreSection(fromMeasureNumber, toMeasureNumber, fromSecond, toSecond))
      }
    }

    return list
  }

  static #buildDomIdList() {
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
        measures.push(currentMeasureId)
      }
      i += 100
    }

    return measures
  }

  getMeasureForTime(time) {
    for (let measure of this.expandedMeasures) {
      if (measure.isTimeInRange(time)) {
        return measure
      }
    }

    return undefined
  }

  getMeasureByDomId(domId) {
    for (let measure of this.expandedMeasures) {
      if (measure.domId === domId) {
        return measure
      }
    }

    return undefined
  }
}

export default class extends Controller {
  static targets = [ "trackswitchPlayer", "score" ]
  static values = {
    url: String,
    delayInMilliseconds: Number,
    metadata: Object,
    measureNumberToSecondsList: Array,
  }

  initializeVerovio() {
    this.currentMeasure = null;

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
        pageWidth: 100000,
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
        .then(() => { 
          this.scoreMeasureList = ScoreMeasureList.build(this.metadataValue["secondsToMeasureNumberList"]) 
        })
        .catch((error) => {
          console.log(error)
        });
    } catch (error) {
      console.log(error)
    }
  }

  scoreTargetConnected() {
    this.initializeVerovio();
  }

  hidePlayingMeasures() {
    let playingMeasures = this.scoreTarget.querySelectorAll(".playing");
    for (let playingMeasure of playingMeasures) playingMeasure.classList.remove("playing");
  }

  showPlayingMeasure(measure) {
    let playingMeasure = this.getDomMeasure(measure)
    playingMeasure.classList.add("playing")
  }

  getDomMeasure(measure) {
    return document.getElementById(measure.domId)
  }

  scrollToMeasure(measure) {
    const playingMeasure = this.getDomMeasure(measure)
    const container = this.scoreTarget

    const viewPortWidth = window.visualViewport.width
    const measureLeft = playingMeasure.getBoundingClientRect().left
    const measureWidth = playingMeasure.getBoundingClientRect().width
    const scrollToLeft = container.scrollLeft + measureLeft - viewPortWidth/2 + measureWidth/2
    
    container.scrollTo({
      left: scrollToLeft,
      scrollPosition: 'smooth'
    })
  }

  update(event) {    
    this.hidePlayingMeasures()

    const measure = this.scoreMeasureList.getMeasureForTime(event.detail.position)

    if (measure === undefined) {
      return
    }
    this.showPlayingMeasure(measure)

    if (this.currentMeasure != measure) {
      this.currentMeasure = measure
      this.scrollToMeasure(measure)
    }
  }

  click(event) {
    const x = event.clientX
    const y = event.clientY

    let clickedMeasureDomId = null
    for (const measureDomId of this.scoreMeasureList.domIdList) {
      const measureElement = document.getElementById(measureDomId)
      const rect = measureElement.getBoundingClientRect()
      if (rect.left <= x && x <= rect.right && rect.top <= y && y <= rect.bottom) {
        clickedMeasureDomId = measureDomId
        break
      }
    }

    if (clickedMeasureDomId) {      
      const measure = this.scoreMeasureList.getMeasureByDomId(clickedMeasureDomId)
      this.trackswitchPlayerTarget.controller.seekTo(measure.startSeconds)
    }
  }
}
