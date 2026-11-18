import { Controller } from "@hotwired/stimulus"
import Papa from 'papaparse'

// Verovio WASM toolkit, loaded on demand when a score is rendered.
const loadVerovio = async () => {
  const [{ VerovioToolkit }, { default: createVerovioModule }] = await Promise.all([
    import('verovio/esm'),
    import('verovio/wasm'),
  ])
  return { VerovioToolkit, module: await createVerovioModule() }
}

// The trackswitch lib does not register its custom element on import.
const loadTrackswitch = () => {
  if (customElements.get('trackswitch-player')) return Promise.resolve()
  return import('trackswitch').then(m => m.defineTrackswitchDefaultElement())
}

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

  static build(measureMarkers) {
    const domIdList = this.#buildDomIdList()    
    const scoreSectionsList = this.#buildScoreSectionList(measureMarkers)    
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

  static #buildScoreSectionList(measureMarkers) {
    let list = []

    for (let i = 1; i < measureMarkers.length; i++) {
      const from = measureMarkers[i - 1]
      const to = measureMarkers[i]
      const fromMeasureNumber = from.measure
      const toMeasureNumber = to.measure

      if (toMeasureNumber > fromMeasureNumber) {
        const fromSecond = from.time
        const toSecond = to.time
        list.push(new ScoreSection(fromMeasureNumber, toMeasureNumber, fromSecond, toSecond))
      }
    }

    return list
  }

  static #buildDomIdList() {
    let measures = []
    
    for (let measure of document.querySelectorAll('.measure')) {
      measures.push(measure.id)
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
    measureMarkers: String,
    measureNumberToSecondsList: Array,
  }

  async initializeVerovio() {
    this.currentMeasure = null;

    // Check if WebAssembly is supported
    if (typeof WebAssembly === 'undefined') {
      return;
    }

    // If the toolkit already exists, we're already initialized
    if (document.toolkit) {
      this.setupToolkit(document.toolkit);
      return;
    }

    try {
      const { VerovioToolkit, module } = await loadVerovio();
      this.setupToolkit(new VerovioToolkit(module));
    } catch (error) {
      console.log(error);
    }
  }

  setupToolkit(toolkit) {
    this.toolkit = toolkit
    document.toolkit = this.toolkit

    if (this.urlValue == "") {
      return
    }

    try {
      this.toolkit.setOptions({
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
          let svg = this.toolkit.renderData(meiXML, {});
          if (!svg) {
            throw new Error('Rendered SVG is empty');
          }
          this.scoreTarget.innerHTML = svg;
        })
        .then(() => { 
          const result = Papa.parse(this.measureMarkersValue, {header: true, dynamicTyping: true})
          this.scoreMeasureList = ScoreMeasureList.build(result.data)
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

  trackswitchPlayerTargetConnected() {
    this.trackswitchPlayerTarget.addEventListener('trackswitch-error', e => {
      console.error('TrackSwitch error:', e.detail);
    });
    loadTrackswitch()
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
    if (this.urlValue == "") {
      return
    }

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
      this.trackswitchPlayerTarget.controller?.seekTo(measure.startSeconds)
    }
  }
}
