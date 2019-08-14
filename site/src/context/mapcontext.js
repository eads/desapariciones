import React from "react"

const defaultState = {
  selectedLayer: "",
  selectedEstado: null,
  data: {},
  viewport: {},
  style: {},
  setStyle: () => {},
  setData: () => {},
  setViewport: () => {},
  setSelectedLayer: () => {},
  setSelectedEstado: () => {},
}

const MapContext = React.createContext(defaultState)

class MapProvider extends React.Component {
  state = {
    style: {},
    data: {},
    selectedLayer: "municipales-not-found-count",
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

  render() {
    const { children } = this.props
    const { data, viewport, style, selectedLayer, selectedEstado } = this.state

    //console.log(this.state)

    return (
      <MapContext.Provider
        value={{
          selectedLayer,
          data,
          viewport,
          style,
          selectedEstado,
          setViewport: (viewport) => this.setState({viewport}),
          setData: (data) => this.setState({data}),
          setSelectedLayer: (selectedLayer) => this.setState({selectedLayer}),
          setStyle: (style) => this.setState({style}),
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
