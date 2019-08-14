import React from "react"
import MapContext from "../context/MapContext"
import ReactMapGL from "react-map-gl"
import { FaRegHandRock, FaRegHandPointer } from "react-icons/fa"
import "mapbox-gl/dist/mapbox-gl.css"


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
    mapSelectedLayer: "municipales-not-found-count",
  }

  onSourceData = (event) => {
    const { viewport } = this.props.mapState
    if (event.isSourceLoaded) {
      this.onViewportChange(viewport)
    }
  }

  // Capture estado from click event if one exists at the clicked coordinates
  onClick = (event) => {
    const { setSelectedEstado } = this.props.mapState
    const point = [event.center.x, event.center.y]
    const feature = this.mapRef.queryRenderedFeatures(point, { layers: ["estatales-interaction"] }).shift()
    if (feature) {
      setSelectedEstado(feature.properties.nom_ent)
    }
  }

  onViewportChange = (viewport) => {
    const { setViewport, setData, setStyle, selectedLayer } = this.props.mapState
    if (this.mapRef) {
      const map = this.mapRef.getMap()
      const data = map.queryRenderedFeatures({layers:[selectedLayer]})
      setViewport(viewport)
      setData(data)
      setStyle(map.getStyle())
    }
  }

  switchLayer = (layer) => {
    if (this.mapRef) {

      const map = this.mapRef.getMap()

      LAYERS.forEach((datalayer) => {
        map.setPaintProperty(datalayer, "fill-opacity", 0)
      })

      if (layer === "municipales-not-found-count") {
        map.setPaintProperty("municipales-not-found-count", "fill-opacity", 1)
      }
      if (layer === "municipales-status-ratio") {
        map.setPaintProperty("municipales-not-found-count", "fill-opacity", 1)
      }
      if (layer === "municipales-gender-diff") {
        map.setPaintProperty("municipales-gender-diff", "fill-opacity", 1)
      }
    }
  }

  switchEstado = (estado) => {
    if (this.mapRef) {
      const map = this.mapRef.getMap()
      if (estado) {
        map.setPaintProperty("estatales-interaction", "fill-opacity", ["match", ["get", "nom_ent"], estado, 0, 0.85])
      } else {
        map.setPaintProperty("estatales-interaction", "fill-opacity", 0)
      }
    }
  }

  componentDidMount() {
    const map = this.mapRef.getMap()

    // Process data when it loads/changes
    map.on("sourcedata", this.onSourceData)

    // @TODO zoom to container
  }

  render() {
    const { mapState } = this.props

    this.switchLayer(mapState.selectedLayer)
    this.switchEstado(mapState.selectedEstado)

    return (<>
      <div className="map">
        <ReactMapGL
          {...mapState.viewport}
          onViewportChange={this.onViewportChange}
          ref={map => this.mapRef = map}
          mapboxApiAccessToken={MAPBOX_TOKEN}
          minZoom={2}
          maxZoom={13}
          onClick={this.onClick}
          mapStyle="mapbox://styles/davideads/cjyc2n4b21q5g1cml2t5x8kcx?fresh=true"
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
