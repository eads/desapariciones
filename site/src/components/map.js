import MapGL, { MapEvents } from "react-map-gl-alt"
import React from "react"
import MapContext from "../context/MapContext"

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


class BaseMap extends React.Component {
  constructor(props, context) {
    super(props, context)
    this.mapRef = React.createRef();
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
  }

  _onChangeViewport = (viewport) => {
    this.setState({ viewport })
  }

  _onClick = (e) => {
    // Access features under cursor through safe non-mutable map facade
    const features = e.target.queryRenderedFeatures(e.point)
    console.log(e.target)
    console.log(e, features)
  }

  getFeatureStates = () => { 
    const { card } = this.props.mapState

    if (!this.state.loaded) {
      return []
    }    


    switch(card) {
      case 2:
        return [{ 
          feature: { source: 'composite', sourceLayer: 'water', id: 0 },
          state: { active: true }
        }]
       case 1:
        const start = performance.now()
        const features = this.mapRef.current._map.queryRenderedFeatures({layers: ['municipales-not-found-count']})
        const end = performance.now()
        console.log(end - start)
        return features.map( (f) => ({
          feature: { source: 'composite', sourceLayer: 'municipales_summary', id: f.id },
          state: { active: true }
        }))
      default:
        return []  
    }  
  }

  render() {
    const featureStates = this.getFeatureStates()
    // console.log(featureStates)

    return (<>
      <MapGL
        ref={this.mapRef}
        mapboxApiAccessToken={mapboxApiAccessToken}
        mapStyle={mapStyle}
        {...this.state.target}
        failIfMajorPerformanceCaveatDisabled
        onChangeViewport={this._onChangeViewport}
        move={this.state.motion}
        worldCopyJumpDisabled={false}
        trackResizeContainerDisabled={false}
        featureStates={featureStates}
        logoPosition="bottom-right"
      >
        <MapEvents
          onLoad={() => { this.setState({ loaded: true }) }}
          onError={console.error}
          onClick={this._onClick}
        />
      </MapGL>
    </>)
  }
}

class Map extends React.Component {
  render() {
    return (
      <MapContext.Consumer>
        {mapState => (
          <BaseMap mapState={mapState} {...this.props} />
        )}
      </MapContext.Consumer>
    )
  }
}

export default Map

/*

      <button onClick={() => this.setState({ featureStates:
        [{ feature: { source: 'composite', sourceLayer: 'water', id: 0 }, state: { active: true } }]
      })}>
        Display layer
      </button>
      <button onClick={() => this.setState({ featureStates: [] })}>
        Feature State Removed
      </button>
*/