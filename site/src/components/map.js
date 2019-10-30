import MapGL from "react-map-gl-alt"
import React from "react"
import { FaRegHandRock, FaRegHandPointer } from "react-icons/fa"

import "mapbox-gl/dist/mapbox-gl.css"

const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"


export const Map = () => (
  <MapGL
    mapboxApiAccessToken={MAPBOX_TOKEN}
    mapStyle="mapbox://styles/mapbox/streets-v9"
  />
)

export default Map
