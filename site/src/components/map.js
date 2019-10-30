import React from "react"
import MapContext from "../context/MapContext"
import ReactMapGL from "react-map-gl"
import { FaRegHandRock, FaRegHandPointer } from "react-icons/fa"
import "mapbox-gl/dist/mapbox-gl.css"

import mapStyle from "../map-styles/style.json"


const MAPBOX_TOKEN = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"

const LAYERS = [
  "municipales-not-found-count",
  "municipales-gender-diff",
  "municipales-status-ratio"
]
//const HANDLERS = [
  //"scrollZoom",
  //"boxZoom",
  //"dragRotate",
  //"dragPan",
  //"keyboard",
  //"doubleClickZoom",
  //"touchZoomRotate",
//]

class BaseMap extends React.Component {

  state = {
    viewport: {
      width: "100%",
      height: "100%",
      longitude: -102.0,
      latitude: 22.5,
      zoom: 3.05,
      pitch: 0,
    },
    config: {
      doubleClickZoom: false,
    }
  }

  componentDidMount() {
    const map = this.mapRef.getMap()
    this.props.mapState.setMap(map)
  }

  onViewportChange = (viewport) => {
    if (this.mapRef) {
      this.setState({viewport})
    }
  }

  _setFeatureState = () => {
    const { map } = this.props.mapState
    if (map) {
      console.log('set feature state')

      map.setFeatureState({
        source: 'composite',
      }, {
        active: true
      });


    }    
  }

  render() {
    const { viewport, config } = this.state

    this._setFeatureState()

    return (<>
      <div className="map">
        <ReactMapGL
          {...viewport}
          {...config}
          onViewportChange={this.onViewportChange}
          ref={map => this.mapRef = map}
          mapboxApiAccessToken={MAPBOX_TOKEN}
          minZoom={2}
          maxZoom={13}
          mapStyle={mapStyle}
        >
        </ReactMapGL>
      </div>
    </>)
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
