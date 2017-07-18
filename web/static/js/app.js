
  /*
      VENDOR
  */

  require( "material-design-lite" );

  require( "phoenix_html" );

  /*
      APPLICATION
  */

  const { initializeMultiselects } = require( "./multiselect" );
  initializeMultiselects();

  const { initTerms } = require( "./term.js" );
  initTerms();

  const { initForm } = require( "./form.js" );
  initForm();

  const { initCalendar } = require( "./calendar.js" );
  initCalendar();
