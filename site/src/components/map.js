import React from "react"
import ReactMapGL from "react-map-gl"
import "mapbox-gl/dist/mapbox-gl.css"

const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"


class Map extends React.Component {

  state = {
    viewport: {
      width: '100%',
      height: '100%',
      longitude: -102.9,
      latitude: 23.42,
      zoom: 3.1,
    }
  }

  render() {
    return (
      <ReactMapGL
        {...this.state.viewport}
        onViewportChange={(viewport) => this.setState({viewport})}
        mapboxApiAccessToken={MAPBOX_TOKEN}
        mapStyle="mapbox://styles/davideads/cjxhxnw2a3vz81cr178aj3syc"
      />
    )
  }
}

export default Map
