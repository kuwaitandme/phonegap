window.app = {
  /**
   * This function sets up the different variables
   */
  setup: function() {
    /* Initialize the header. */
    this.header = new this.views.components.header({ el: "header" });

    /* Setup the messages component */
    this.messages = new this.views.components.messages({ el: "#messages" });

    /* Get and initialize the main view */
    var view = $("body").attr('id');
    var CurrentView = this.views.pages[view];
    if(CurrentView) this.mainbody = new CurrentView({ el: "main" });
  },


  /**
   * This function starts up the app.
   */
  start: function() {
    /* Start attaching the module components here, so that other components
     * can refer to these modules by doing a 'app.modulename', since 'app'
     * is a global variable */
    this.config = require("./config");
    this.helpers = require("./helpers");
    this.libs = require("./libs");
    this.models = require("./models");
    this.views = require("./views");

    require("./globals");

    this.setup();
  }
};

/* Kick start the App. Start back-tracing the app's execution over here, if you
 * are trying to understand my code.
 */
// document.addEventListener("deviceready", function() {
  app.start()
// }, false);