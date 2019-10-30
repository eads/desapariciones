import React from "react"
import throttle from "lodash/throttle"

/*
 * The state of the map can be defined by two properties:
 *
 * - The currently selected card; defines the state of the map style
 * - A Mapbox filter statement; defines the features/data used for visualizations
 *   and calculations
 *
 * Child components are in charge of knowing what to do with combination of 
 */
const defaultState = {
  card: "",
  filter: null,
  map: null,
  setCard: () => {},
  setFilter: () => {},
  setMap: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    card: "intro",
    filter: null,
    map: null,
  }

  render() {
    const { children } = this.props
    const { card, filter, map } = this.state

    return (
      <MapContext.Provider
        value={{
          card,
          filter,
          map,
          setCard: (card) => this.setState({card}),
          setFilter: (filter) => this.setState({filter}),
          setMap: (map) => this.setState({map}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
