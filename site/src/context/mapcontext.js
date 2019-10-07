import React from "react"
import throttle from "lodash/throttle"
import mapStyle from "../map-styles/style.json"

const defaultState = {
  selectedCard: {},
  selectedEstado: null,
  data: {},
  viewport: {},
  style: {},
  setStyle: () => {},
  setData: () => {},
  setViewport: () => {},
  setSelectedCard: () => {},
  setSelectedEstado: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    style: mapStyle,
    data: {},
    selectedCard: {id: "intro", layer: "municipales-not-found-count-init"}, // Ugly way of setting default
    selectedEstado: null,
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.0,
      latitude: 22.5,
      zoom: 3.05,
      pitch: 0,
    },
  }

  constructor(props) {
    super(props)
    this.setStateThrottled = throttle(this.setState, 300)
  }

  render() {
    const { children } = this.props
    const { data, viewport, style, selectedCard, selectedEstado } = this.state

    return (
      <MapContext.Provider
        value={{
          selectedCard,
          data,
          viewport,
          style,
          selectedEstado,
          setViewport: (viewport) => this.setState({viewport}),
          setData: (data) => this.setStateThrottled({data}),
          setSelectedCard: (selectedCard) => this.setStateThrottled({selectedCard}),
          setStyle: (style) => this.setStateThrottled({style}),
          setSelectedEstado: (selectedEstado) => this.setState({selectedEstado}),
        }}
      >
        {children}
      </MapContext.Provider>
    )
  }
}

export default MapContext

export { MapProvider }
