
  const days = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ];

  function isoDate ( date ) {
    return date.toISOString( ).slice( 0, 10 );
  }

  function getMonday ( currentDate ) {
    const now = currentDate ? new Date( currentDate ) : new Date();
    const day = now.getDay( );
    const diff = now.getDate( ) - day + ( day == 0 ? -6 : 1 );

    const monday = new Date( now.setDate( diff ) );
    return isoDate( monday );
  }

  function toHours ( timeString ) {
    return timeString.split( /[:.]/ ).map(
      ( value, index ) => value * Math.pow( 60, -index )
    ).reduce(
      ( a, b ) => a + b
    );
  }

  function renderName ( user ) {
    return [
      user.name,
      user.family_name,
      user.nick_name && `(${user.nick_name})`
    ].filter(
      ( item ) => !!item
    ).join( " " );
  }

  function renderDay ( date ) {
    return days[ date.getDay() ] || "";
  }

  function renderHour ( hour ) {
    return `0${hour}:00`.slice( -5 );
  }

  function renderCalendar ( startDate, classes, calendar ) {
    const monday = new Date( startDate );

    let days = new Array( 7 ).fill( monday ).map(
      ( monday, index ) => {
        const day = new Date( monday );
        day.setDate( day.getDate() + index );
        return day;
      }
    ).map(
      ( date ) => {
        let stack = classes.filter(
          // filter the classes so they will contain the classes of the current day
          ( cl ) => cl.date === isoDate( date )
        ).sort().map(
          // add number hours, and index for them
          ( cl, index ) =>
            Object.assign( {}, cl, {
              a: toHours( cl.starting_at ),
              b: toHours( cl.finishes_at ),
              index
            })
        ).map(
          // add edges to classes that contains the overlapping classes (bot not the actual class)
          ( cl1, _, classes ) => Object.assign( {}, cl1, {
            edges:
              classes.filter(
                ( cl2 ) =>
                  cl1 !== cl2 && (
                    ( cl1.a <  cl2.a && cl2.a <  cl1.b ) ||
                    ( cl1.a <  cl2.b && cl2.b <  cl1.b ) ||
                    ( cl2.a <  cl1.a && cl1.a <  cl2.b ) ||
                    ( cl2.a <  cl1.b && cl1.b <  cl2.b ) ||
                    ( cl1.a == cl2.a )                   ||
                    ( cl1.b == cl2.b )
                  )
              ).map(
                ( cl ) => cl.index
              )
          })
        )

        /*
            calculate connected components of the graph
        */

        let classesWithComponents = [];

        let componentCounter = 0;

        while ( stack.length ) {
          // pop the top of the stack
          let [ cl ] = stack.slice( -1 );

          // separate the rest into connected & not connected arrays
          let { connected, notConnected } = stack.slice( 0, -1 ).reduce(
            ( acc, item ) => ({
              connected:
                item.edges.includes( cl.index ) ? acc.connected.concat( [ item ] ) : acc.connected,
              notConnected:
                item.edges.includes( cl.index ) ? acc.notConnected : acc.notConnected.concat( [ item ] )
            }), { connected: [], notConnected: [] }
          )

          // set component if it does not present
          if ( !( "component" in cl ) ) {
            cl = Object.assign( {}, cl, { component: componentCounter++ } );
          }

          // set the component of the connected vertexes to the same
          connected = connected.map(
            ( connectedCl ) => Object.assign( {}, connectedCl, { component: cl.component } )
          );

          // we move the connected vertexes to the top of the stack
          stack = notConnected.concat( connected );

          // add the current to the output array
          classesWithComponents = classesWithComponents.concat( [ cl ] );
        }

        /*
            color components of the graph
        */

        let everyColoredClasses = classesWithComponents.reduce(
          // separate them by component
          ( components, cl ) =>
            Object.assign(
              [],
              components,
              { [cl.component]: (components[ cl.component ] || []).concat( [ cl ] ) }
            )
          , []
        ).map(
          // color the components
          ( classes, _ ) => {
            let maxColor = 0;

            stack = classes.slice().sort(
              ( cl1, cl2 ) => cl1.edges.length > cl2.edges.length
            );

            let coloredClasses = [];

            while ( stack.length ) {
              let [ cl ] = stack.slice( -1 );
              stack = stack.slice( 0, -1 );

              const connectedColors = coloredClasses.filter(
                ( connectedCl ) => connectedCl.edges.includes( cl.index )
              ).map(
                ( connectedCl ) => connectedCl.color
              );

              let color = 0;

              while ( connectedColors.includes( color ) ) {
                color++;
              }

              cl = Object.assign( {}, cl, { color } );

              coloredClasses = coloredClasses.concat( [ cl ] );

              maxColor = Math.max( maxColor, color );
            }

            coloredClasses = coloredClasses.map(
              ( cl ) => Object.assign( {}, cl, { maxColor } )
            );

            return coloredClasses;
          }
        ).reduce(
          // merge the components into one array
          ( acc, component ) => acc.concat( component ), []
        )

        // console.log(s);

        return { classes: everyColoredClasses, date };
      }
    ).map(
      // calculate dimensions from the hours and colors
      ( day ) => Object.assign( {}, day, {
        classes:
          day.classes.map(
            ( cl ) => {
              const top = ( cl.a - 8 ) * 50;
              const height = ( cl.b - 8 ) * 50 - top;
              const left = cl.color / (cl.maxColor+1) * 100;
              const width = 100 / (cl.maxColor+1);

              return Object.assign( {}, cl, { top, height, left, width } );
            }
          )
      })
    ).map(
      ( day ) => `
        <div class="calendar__day">
          <div class="calendar__day-header">
            ${ renderDay( day.date ) }, ${ isoDate( day.date ) }
          </div>
          <div class="calendar__classes">
            ${
              new Array( 13 ).fill( 1 ).map(
                ( time ) => `
                  <div
                    class="
                      calendar__classes-hour
                      ${ [0,6].includes( day.date.getDay() ) ? "calendar__classes-hour--weekend" : "" }
                    "
                  ></div>
                `
              ).join( "" )
            }
            ${
              day.classes.map(
                ( cl, i ) => `
                  <div
                    class="calendar__class"
                    style="
                      top: ${ cl.top }px;
                      height: ${ cl.height }px;
                      left: ${ cl.left }%;
                      width: ${ cl.width }%;
                    "
                    id="${ isoDate( day.date ) }__${ cl.index }"
                  >
                    <div class="calendar__class-course">
                      ${ cl.course_name }
                    </div>
                    <div class="calendar__class-teachers">
                      ${ cl.teachers.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }
                    </div>
                    <div class="calendar__class-time">
                      ${ cl.classroom ? cl.classroom + "," : "" }
                      ${ renderHour( cl.starting_at.slice(0,2) ) }-${ renderHour( cl.finishes_at.slice(0,2) ) }
                    </div>
                  </div>
                  <div
                    class="
                      mdl-tooltip
                      ${ cl.color < cl.maxColor / 2 ? "mdl-tooltip--left" : "mdl-tooltip--right" }
                    "
                    for="${ isoDate( day.date ) }__${ cl.index }"
                  >
                    ${ cl.course_name }<br />
                    ${ cl.teachers.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }<br />
                    ${ cl.classroom ? cl.classroom + "," : "" }
                    ${ renderHour( cl.starting_at.slice(0,2) ) }-${ renderHour( cl.finishes_at.slice(0,2) ) }
                  </div>
                `
              ).join( "" )
            }
          </div>
        </div>
      `
    ).join( "" );

    let previousMonday = new Date( monday );
    previousMonday.setDate( monday.getDate() - 7 );

    let nextMonday = new Date( monday );
    nextMonday.setDate( monday.getDate() + 7 );

    calendar.innerHTML = `
      <div class="row">
        <div class="col-xs-4 col-md-3 col-lg-2">
          <a
            class="mdl-button mdl-js-button"
            href="/schedule?date=${ isoDate(previousMonday) }"
          >
            previous week
          </a>
        </div>
        <div class="col-xs-4 col-xs-offset-4 col-md-3 col-md-offset-6 col-lg-2 col-lg-offset-8">
          <a
            class="mdl-button mdl-js-button"
            href="/schedule?date=${ isoDate(nextMonday) }"
          >
            next week
          </a>
        </div>
      </div>
      <div class="calendar">
        <div class="calendar__time">
          <div class="calendar__time-header"></div>
          ${
            new Array(13).fill(8).map(
              ( startTime, index ) => startTime + index
            ).map(
              ( time ) => `<div class="calendar__time-hour">${ renderHour( time ) }</div>`
            ).join( "" )
          }
        </div>
        <div class="calendar__days">
          ${ days }
        </div>
      </div>
    `;

    componentHandler.upgradeDom();
  }

  function initCalendar ( ) {
    const calendar = document.querySelector( ".calendar__wrapper" );

    if ( calendar ) {
      const startDateParameter = window.location.search.slice( 1 ).split( "&" ).map(
        ( pairString ) => pairString.split( "=" ).map( decodeURIComponent )
      ).filter(
        ( pair ) => pair[0] === "date"
      );

      let startDate = startDateParameter.length && startDateParameter[0][1];
      startDate = getMonday( startDate );

      const req = new XMLHttpRequest( );

      req.addEventListener( "load",
        function ( ) {
          renderCalendar( startDate, JSON.parse( this.responseText ).classes, calendar );
        }
      );

      req.open( "GET", `/calendar?date=${ startDate }` );
      req.send( );
    }
  }

  module.exports.initCalendar = initCalendar;
