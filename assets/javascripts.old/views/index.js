module.exports = {
  components:    require("./components"),
  pages:         require("./pages"),

  /**
   * Setup the different views. ie. Initialize the different controllers for
   * the header, mainview and other components.
   */
  initialize: function() {
    console.group("initialize views");

    self = this;

    /* Index all the views first */
    self.indexViews();

    /* Render the header second */
    self.header = new components.header({ el: "header" });

    /* Set the main view based on the page variable, if any */
    self.setView('landing', {url: document.URL});
    // self.mainview = new pages.landing({ el: "#main-content" });

    console.groupEnd();
  },


  /**
   * Finds the view with the given name and returns it's object.
   *
   * @param  String          name  The name of the view to be found.
   * @return Backbone.View         The Backbone.View object of the view found.
   */
  getView: function(name) {
    return self.index[name];
  },


  /**
   * Set's the mainview with all the proper animations and DOM manipulations.
   */
  setView: function(page, arguments) {
    /* Get the view first */
    self.currentPage = page;
    var CurrentView = self.getView(page);

    if(self.mainview) {
      /* If there was a view before, clean it up */
      self.mainview.undelegateEvents();
      // self.mainview.onLeave();

      self.mainview = new CurrentView({
        arguments: arguments,
        el: "#next-page"
      });

      // self.animateNextPage();
    } else {
      /* Else load set the mainview directly without any transition
       * animations */
      self.mainview = new CurrentView({
        arguments: arguments,
        el: "#main-content"
      });
    }

    // self.mainview.onEnter();

    /* Give the body the right id, so that we can apply the right CSS
     * styles */
    // self.$body.attr("id", self.mainview.bodyid);

    /* Reattach the event handlers for the router */
    app.reattachRouter();
  },


  /**
   * Creates an index for all the views to referred by a single string. This
   * way we can have a nice way to navigate across views by using these simple
   * strings to represent them.
   */
  indexViews: function() {
    self.index = {
      'landing' : pages.landing
    }
  }
}