import React from "react"
//import throttle from "lodash/throttle"

/*
 * The state of the map is defined by the currently selected card and a filter.
 *
 * - The currently selected card
 * - A Mapbox filter statement; defines the features/data used for visualizations
 *   and calculations
 *
 */
const defaultState = {
  card: "",
  mapboxFilter: null,
  setCard: () => {},
  setMapboxFilter: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    card: "intro",
    mapboxFilter: null,
  }

  render() {
    const { children } = this.props
    const { card, mapboxFilter } = this.state

    return (
      <MapContext.Provider
        value={{
          card,
          mapboxFilter,
          setCard: (card) => this.setState({card}),
          setMapboxFilter: (mapboxFilter) => this.setState({mapboxFilter}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
