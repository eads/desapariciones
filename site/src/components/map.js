import MapGL, { MapEvents } from "react-map-gl-alt"
import React from "react"
import { FaRegHandRock, FaRegHandPointer } from "react-icons/fa"

import mapStyle from "../map-styles/style.json"
import "mapbox-gl/dist/mapbox-gl.css"

const mapboxApiAccessToken = "pk.eyJ1IjoiZGF2aWRlYWRzIiwiYSI6ImNpZ3d0azN2YzBzY213N201eTZ3b2E0cDgifQ.ZCHD8ZAk32iAp9Ue3tPVVg"

const flyTo = (target) => ({
  command: 'flyTo',
  args: [{
    ...target,
    // Use animation options, duration etc.
    duration: 1000,
    curve: 1.8,
  }],
})

const fitBounds = (target) => ({
  command: 'fitBounds',
  args: [target.bounds, { duration: 0 }]
})


class Map extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.state = {
      loaded: false,
      target: {
        center: [
          -102.0,
          22.5,
        ],
        zoom: 3.0,
      },
      motion: flyTo,
      flex: 1,
      featureStates: [],
    }

    this._onClick = this._onClick.bind(this)
    this._onChangeViewport = this._onChangeViewport.bind(this)
  }

  _onChangeViewport(viewport) {
    this.setState({ viewport })
  }

  _onClick(e) {
    // Access features under cursor through safe non-mutable map facade
    const features = e.target.queryRenderedFeatures(e.point)
    console.log(e, features)
  }

  render() {
    // Can update center/zoom etc to move
    return (
      <>

      <button onClick={() => this.setState({ featureStates:
        [{ feature: { source: 'composite', sourceLayer: 'water', id: 0 }, state: { active: true } }]
      })}>
          Display layer
        </button>
        <button onClick={() => this.setState({ featureStates: [] })}>
          Feature State Removed
        </button>

        <MapGL
          mapboxApiAccessToken={mapboxApiAccessToken}
          mapStyle={mapStyle}
          {...this.state.target}
          failIfMajorPerformanceCaveatDisabled
          onChangeViewport={this._onChangeViewport}
          move={this.state.motion}
          worldCopyJumpDisabled={false}
          trackResizeContainerDisabled={false}
          featureStates={this.state.featureStates}
          logoPosition="bottom-right"
        >
          <MapEvents
            onLoad={() => { this.setState({ loaded: true }) }}
            onError={console.error}
            onClick={this._onClick}
          />
        </MapGL>
      </>
    )
  }
}

export default Map

/*
 *
 *         <div>
          <button onClick={() => this.setState({ target: { ...this.state.viewport, bearing: 0, pitch: 0 }, motion: resetNorth })}>
            Reset North
          </button>
          <button onClick={() => this.setState({ target: { bounds: [10, 10, 20, 20] }, motion: fitBounds })}>
            Bounds
          </button>
          <button onClick={() => this.setState({ flex: this.state.flex === 1 ? 0.5 : 1 })}>
            Flex
          </button>
          <button onClick={() => this.setState({ featureStates: [{ feature: { source: 'composite', sourceLayer: 'water', id: 0 }, state: { example: 'updated' } }] })}>
            Feature State #2
          </button>
        </div>*/
