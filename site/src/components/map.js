import React from "react"
import ReactMapGL from "react-map-gl"
import DeckGL from "@deck.gl/react"
import {LineLayer} from "@deck.gl/layers"

import "mapbox-gl/dist/mapbox-gl.css"

const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"

// Initial viewport settings
const initialViewState = {
  longitude: -102.9,
  latitude: 23.42,
  zoom: 3.1,
  pitch: 0,
  bearing: 0
};

// Data to be used by the LineLayer
const data = [{sourcePosition: [-122.41669, 37.7853], targetPosition: [-122.41669, 37.781]}];


class Map extends React.Component {

  state = {
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.9,
      latitude: 23.42,
      zoom: 3.1,
    }
  }

  render() {
    const layers = [
      new LineLayer({id: "line-layer", data})
    ]

    return (
      <DeckGL
        initialViewState={initialViewState}
        controller={true}
        layers={layers}
      >

      <ReactMapGL
        mapboxApiAccessToken={MAPBOX_TOKEN}
        mapStyle="mapbox://styles/davideads/cjxtvq19a8ppw1cs5r13kmrss"
      />

      </DeckGL>
    )
  }
}

export default Map
