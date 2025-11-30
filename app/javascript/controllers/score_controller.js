import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }
  
  connect() {
    var osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay(this.target, {
      autoResize: true, // just an example for an option, no option is necessary.
      backend: "svg",
      drawTitle: true,
      // put further options here
    });

    var loadPromise = osmd.load("http://www.example.org/my-score.xml");

    loadPromise.then(function(){
      osmd.render();
    });

    console.log("hello")
  }
}
