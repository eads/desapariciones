import React from "react"
import MapContext from "../context/MapContext"
import ReactMapGL from "react-map-gl"
import "mapbox-gl/dist/mapbox-gl.css"

const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"

class BaseMap extends React.Component {

  onSourceData = (event) => {
    const { viewport } = this.props.mapState
    if (event.isSourceLoaded) {
      this.onViewportChange(viewport)
    }
  }

  onViewportChange = (viewport) => {
    const { setViewport, setData } = this.props.mapState
    if (this.mapRef) {
      const map = this.mapRef.getMap()
      const data = map.queryRenderedFeatures({layers:["municipales-summary"]})
      setViewport(viewport)
      setData(data)
    }
  }

  componentDidMount() {
    //const map = this.mapRef.getMap()
    //map.on("sourcedata", this.onSourceData)
    // @TODO zoom to container
  }

  render() {
    const { mapState } = this.props
    return (
      <ReactMapGL
        {...mapState.viewport}
        onViewportChange={this.onViewportChange}
        ref={map => this.mapRef = map}
        mapboxApiAccessToken={MAPBOX_TOKEN}
        mapStyle="mapbox://styles/davideads/cjy0ro2wa05tm1cqnk6lwhq6l"
      />
    )
  }
}

class Map extends React.Component {
  render() {
    return (
      <MapContext.Consumer>
        {mapState => (
          <BaseMap mapState={mapState} />
        )}
      </MapContext.Consumer>
    )
  }
}

export default Map
