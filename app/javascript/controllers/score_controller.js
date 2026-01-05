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

  connect() {
    verovio.module.onRuntimeInitialized = () => {
      document.toolkit = new verovio.toolkit()
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
      })

      this.secondsToMeasureNumberListValue = this.metadataValue["secondsToMeasureNumberList"]

      fetch(this.urlValue)
      .then( (response) => response.text())
      .then( (meiXML) => {
        let svg = document.toolkit.renderData(meiXML, {});
        this.scoreTarget.innerHTML = svg;
      })
      .then(() => this.buildMeasureList(this))
      .then(() => {
        setTimeout(this.updateAndSetTimeout(this), this.delayInMillisecondsValue)
      })
    }
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

    playingMeasure.classList.add("playing")
  }

  updateAndSetTimeout(controller) {
    controller.update()
    setTimeout(() => controller.updateAndSetTimeout(controller), controller.delayInMillisecondsValue)
  }

  update() {
    this.hideMeasures()
    let measure = this.getMeasure(this.audioTagTarget.currentTime)
    if (measure === undefined) {
      return
    }

    this.showMeasure(measure)
  }
}
