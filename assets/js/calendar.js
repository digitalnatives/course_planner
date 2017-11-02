
  const days = [ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" ];

  function isoDate ( date ) {
    return date.toISOString( ).slice( 0, 10 );
  }

  function getToday ( ) {
    return isoDate( new Date( ) );
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
    return `${hour}`.slice(0, 5);
  }

  function updatePointer ( ) {
    const now = new Date();
    const hours = now.getHours() + now.getMinutes() / 60;
    const top = ( hours - 8 ) * 50;

    const pointer = document.querySelector( ".calendar__classes-pointer" );

    if ( pointer ) {
      pointer.style.top = `${top}px`;
    }
  }

  function renderSlots(startDate, slots, calendar, displayEvery) {
    const monday = new Date( startDate );

    return new Array( 7 ).fill( monday ).map(
      ( monday, index ) => {
        const day = new Date( monday );
        day.setDate( day.getDate() + index );
        return day;
      }
    ).map(
      ( date ) => {
        let stack = slots.filter(
          // filter the slots so they will contain the slots of the current day
          ( cl ) => cl.date === isoDate( date )
        ).sort().map(
          // add number hours, and index for them
          ( cl, index ) =>
            Object.assign( {}, cl, {
              a: toHours( cl.start ),
              b: toHours( cl.finish ),
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
                      ${ cl.primary_name }
                    </div>
                    <div class="calendar__class-teachers">
                      ${ cl.primary_users.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }
                    </div>
                    <div class="calendar__class-time">
                      ${ cl.place ? cl.place + "," : "" }
                      ${ renderHour( cl.start ) }-${ renderHour( cl.finish ) }
                    </div>
                  </div>
                  <div
                    class="
                      mdl-tooltip
                      ${ cl.color < cl.maxColor / 2 ? "mdl-tooltip--left" : "mdl-tooltip--right" }
                    "
                    for="${ isoDate( day.date ) }__${ cl.index }"
                  >
                    ${ cl.primary_name }<br />
                    ${ cl.primary_users.map( ( teacher ) => renderName( teacher ) ).join( ", " ) }<br />
                    ${ cl.place ? cl.place + "," : "" }
                    ${ renderHour( cl.start ) }-${ renderHour( cl.finish ) }
                  </div>
                `
              ).join( "" )
            }
            ${ isoDate(day.date) === getToday() ? "<div class=\"calendar__classes-pointer\"></div>" : "" }
          </div>
        </div>
      `
    ).join( "" );
  }


  function createCalendarSlots(classes, events){
    var classSlots = classes.map(function(item) {
        var slot = new Object();
        slot.primary_name = item.course_name;
        slot.secondary_name = item.term_name;
        slot.description = "";
        slot.date = item.date;
        slot.start = item.starting_at;
        slot.finish = item.finishes_at;
        slot.place = item.classroom;
        slot.primary_users = item.teachers;
        slot.seconday_users = [];
        return slot;
      });

    var eventSlots = events.map(function(item) {
        var slot = new Object();
        slot.primary_name = item.name;
        slot.secondary_name = "";
        slot.description = item.description;
        slot.date = item.date;
        slot.start = item.starting_time;
        slot.finish = item.finishing_time;
        slot.place = item.location;
        slot.primary_users = [];
        slot.seconday_users = item.users;
        return slot;
      });

    return classSlots.concat(eventSlots);
  }

  function renderCalendar ( startDate, renderedSlots, calendar, displayEvery ) {
    const monday = new Date( startDate );

    let previousMonday = new Date( startDate );
    previousMonday.setDate( monday.getDate() - 7 );

    let nextMonday = new Date( startDate );
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
        <div class="col-xs-4 col-md-3 col-lg-2">
          <a
            class="mdl-button mdl-js-button"
            href="/schedule?date=${ getMonday( ) }"
          >
            current week
          </a>
        </div>
        <div class="col-xs-4 col-md-3 col-md-offset-3 col-lg-2 col-lg-offset-6">
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
          ${ renderedSlots }
        </div>
      </div>
      ${
        ( USER_ROLE === "Teacher" || USER_ROLE === "Student" ) ?
          `<div class="calendar__switch">
            <label class="mdl-switch mdl-js-switch mdl-js-ripple-effect" for="calendar-switch">
              <span class="mdl-switch__label calendar__switch-label">Display every class</span>
              <input
                type="checkbox"
                id="calendar-switch"
                class="mdl-switch__input"
                ${ displayEvery ? "checked" : "" }
              >
            </label>
          </div>`
        : ""
      }
    `;

    componentHandler.upgradeDom();

    updatePointer();
    setInterval( updatePointer, 10000 );
  }

  var calendarPointerInterval = null;

  function xhrGet ( path ) {
    return new Promise(
      function ( resolve, reject ) {
        const req = new XMLHttpRequest( );

        req.addEventListener( "load",
          function ( ) {
            var parsedData = JSON.parse( this.responseText );
            resolve(parsedData);
          }
        );

        req.addEventListener( "error", reject );

        req.open( "GET", path );
        req.setRequestHeader("authorization", `Bearer ${JWT}`)
        req.send( );
      }
    )
  }

  function loadCalendar ( displayEvery = false ) {
    const calendar = document.querySelector( ".calendar__wrapper" );

    const startDateParameter = window.location.search.slice( 1 ).split( "&" ).map(
      ( pairString ) => pairString.split( "=" ).map( decodeURIComponent )
    ).filter(
      ( pair ) => pair[0] === "date"
    );

    let startDate = startDateParameter.length && startDateParameter[0][1];
    startDate = getMonday( startDate );

    Promise.all([
      xhrGet(`/api/calendar?date=${ startDate }&my_classes=${ !displayEvery }`),
      xhrGet(`/api/events?date=${ startDate }&my_events=${ !displayEvery }`)
    ]).then(
      function ( responses ) {

        let slots = createCalendarSlots(responses[0].classes, responses[1].events)
        let renderedSlots = renderSlots(startDate, slots, calendar, displayEvery);
        renderCalendar( startDate, renderedSlots, calendar, displayEvery );

        clearInterval( calendarPointerInterval );
        updatePointer();
        calendarPointerInterval = setInterval( updatePointer, 10000 );
      }
    ).catch(
      function ( err ) {
        console.log(err);
      }
    )
  }

  function initCalendar ( ) {
    const calendar = document.querySelector( ".calendar__wrapper" );

    if ( calendar ) {
      loadCalendar();

      document.addEventListener( "change",
        function ( e ) {
          if ( e.target.id === "calendar-switch" ) {
            loadCalendar( e.target.checked )
          }
        }
      )
    }
  }

  module.exports.initCalendar = initCalendar;
