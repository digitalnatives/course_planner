
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
